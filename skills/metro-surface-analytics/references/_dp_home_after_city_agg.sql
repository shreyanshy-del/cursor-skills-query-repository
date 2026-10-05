WITH ev AS (
  SELECT
    uue.mri_client_id,
    MIN(uue.__time) AS home_time,
    MIN_BY(
      CASE
        WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'bengaluru|bangalore|ಬೆಂಗಳೂರು|பெங்களூரு') THEN 'Bangalore'
        WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'chennai|சென்னை') THEN 'Chennai'
        WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'delhi|दिल्ली') THEN 'Delhi'
        WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'ernakulam|kochi') THEN 'Ernakulam'
        WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'mumbai|मुंबई') THEN 'Mumbai'
        WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'pune|पुणे') THEN 'Pune'
      END,
      uue.__time
    ) AS city
  FROM user_interaction.ui_ux_events AS uue
  WHERE
    uue.__time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND uue.__time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
    AND uue.header_country = 'IND'
    AND uue.header_bu = 'BUS'
    AND uue.selected_country = 'India'
    AND uue.event_group = 'bus_buddy_click_event'
    AND uue.event_src = 'Android'
    AND uue.event_name = 'BusMetro_MetroHomeLanded'
    AND uue.mri_client_id IS NOT NULL
    AND uue.mri_client_id NOT IN ('', '0')
  GROUP BY 1
),
ev_ids AS (
  SELECT DISTINCT mri_client_id FROM ev WHERE city IS NOT NULL
),
id_map AS (
  SELECT b.mri_client_id, MAX(b.rb_user_id) AS rb_user_id
  FROM transaction.bus_ticket_events AS b
  INNER JOIN ev_ids i ON b.mri_client_id = i.mri_client_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.rb_user_id IS NOT NULL
    AND b.rb_user_id <> 0
    AND b.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND b.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  GROUP BY 1
),
u AS (
  SELECT e.city, e.mri_client_id, e.home_time, m.rb_user_id
  FROM ev e
  INNER JOIN id_map m ON e.mri_client_id = m.mri_client_id
  WHERE e.city IS NOT NULL
)
SELECT
  city,
  COUNT(*) AS mapped_home_users,
  SUM(CASE WHEN EXISTS (
    SELECT 1 FROM transaction.addon_item a
    WHERE a.rb_user_id = u.rb_user_id
      AND a.country_code = 'IND'
      AND a.item_type = 13
      AND a.s_c_t = 'Ticket'
      AND a.c_t = 'METRO_TICKETING'
      AND a.event_type = 101
      AND a.status = 'CONFIRMED'
      AND a.tin IS NOT NULL
      AND a.time_of_event > u.home_time
      AND a.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  ) THEN 1 ELSE 0 END) AS metro_after_home_users,
  SUM(CASE WHEN EXISTS (
    SELECT 1 FROM transaction.addon_item a
    WHERE a.rb_user_id = u.rb_user_id
      AND a.country_code = 'IND'
      AND a.item_type = 13
      AND a.s_c_t = 'Ticket'
      AND a.c_t = 'METRO_TICKETING'
      AND a.event_type = 101
      AND a.status = 'CONFIRMED'
      AND a.tin IS NOT NULL
      AND a.time_of_event > u.home_time
      AND a.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  ) AND NOT EXISTS (
    SELECT 1 FROM transaction.addon_item p
    WHERE p.rb_user_id = u.rb_user_id
      AND p.country_code = 'IND'
      AND p.item_type = 13
      AND p.s_c_t = 'Ticket'
      AND p.c_t = 'METRO_TICKETING'
      AND p.event_type = 101
      AND p.status = 'CONFIRMED'
      AND p.tin IS NOT NULL
      AND p.time_of_event < u.home_time
  ) THEN 1 ELSE 0 END) AS new_to_metro_after_home
FROM u
GROUP BY 1
ORDER BY 1
LIMIT 20
