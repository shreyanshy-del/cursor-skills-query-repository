WITH ev AS (
  SELECT
    CAST(u.mri_session_id AS VARCHAR) AS mri_session_id,
    CAST(u.mri_client_id AS VARCHAR) AS mri_client_id,
    MIN(u.__time) AS home_time,
    MIN_BY(
      CASE
        WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'bengaluru|bangalore|ಬೆಂಗಳೂರು|பெங்களூரு') THEN 'Bangalore'
        WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'chennai|சென்னை') THEN 'Chennai'
        WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'delhi|दिल्ली') THEN 'Delhi'
        WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'ernakulam|kochi') THEN 'Ernakulam'
        WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'mumbai|मुंबई') THEN 'Mumbai'
        WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'pune|पुणे') THEN 'Pune'
      END,
      u.__time
    ) AS city
  FROM user_interaction.ui_ux_events u
  WHERE u.__time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND u.__time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
    AND u.header_country = 'IND'
    AND u.header_bu = 'BUS'
    AND u.selected_country = 'India'
    AND u.event_group = 'bus_buddy_click_event'
    AND u.event_src = 'Android'
    AND u.event_name = 'BusMetro_MetroHomeLanded'
    AND u.mri_session_id IS NOT NULL
    AND CAST(u.mri_session_id AS VARCHAR) NOT IN ('', '0')
    AND u.mri_client_id IS NOT NULL
    AND CAST(u.mri_client_id AS VARCHAR) NOT IN ('', '0')
  GROUP BY 1, 2
),
ev_ids AS (
  SELECT DISTINCT mri_client_id FROM ev WHERE city IS NOT NULL
),
id_map AS (
  SELECT CAST(b.mri_client_id AS VARCHAR) AS mri_client_id, MAX(b.rb_user_id) AS rb_user_id
  FROM transaction.bus_ticket_events b
  INNER JOIN ev_ids i ON CAST(b.mri_client_id AS VARCHAR) = i.mri_client_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.rb_user_id IS NOT NULL
    AND b.rb_user_id <> 0
    AND b.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND b.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  GROUP BY 1
),
sess AS (
  SELECT e.city, e.mri_session_id, e.home_time, m.rb_user_id
  FROM ev e
  INNER JOIN id_map m ON e.mri_client_id = m.mri_client_id
  WHERE e.city IS NOT NULL
)
SELECT
  city,
  COUNT(DISTINCT mri_session_id) AS mapped_home_sessions,
  COUNT(DISTINCT CASE WHEN EXISTS (
    SELECT 1 FROM transaction.addon_item a
    WHERE a.rb_user_id = sess.rb_user_id
      AND a.country_code = 'IND'
      AND a.item_type = 13
      AND a.s_c_t = 'Ticket'
      AND a.c_t = 'METRO_TICKETING'
      AND a.event_type = 101
      AND a.status = 'CONFIRMED'
      AND a.tin IS NOT NULL
      AND a.time_of_event > sess.home_time
      AND a.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  ) THEN mri_session_id END) AS metro_after_home_sessions,
  COUNT(DISTINCT CASE WHEN EXISTS (
    SELECT 1 FROM transaction.addon_item a
    WHERE a.rb_user_id = sess.rb_user_id
      AND a.country_code = 'IND'
      AND a.item_type = 13
      AND a.s_c_t = 'Ticket'
      AND a.c_t = 'METRO_TICKETING'
      AND a.event_type = 101
      AND a.status = 'CONFIRMED'
      AND a.tin IS NOT NULL
      AND a.time_of_event > sess.home_time
      AND a.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  ) AND NOT EXISTS (
    SELECT 1 FROM transaction.addon_item p
    WHERE p.rb_user_id = sess.rb_user_id
      AND p.country_code = 'IND'
      AND p.item_type = 13
      AND p.s_c_t = 'Ticket'
      AND p.c_t = 'METRO_TICKETING'
      AND p.event_type = 101
      AND p.status = 'CONFIRMED'
      AND p.tin IS NOT NULL
      AND p.time_of_event < sess.home_time
  ) THEN mri_session_id END) AS new_to_metro_sessions
FROM sess
GROUP BY 1
ORDER BY 1
LIMIT 20
