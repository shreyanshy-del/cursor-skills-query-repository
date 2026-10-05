WITH params AS (
  SELECT
    CAST('2026-08-10 18:30:00' AS TIMESTAMP) AS win_start,
    CAST('2026-08-17 18:30:00' AS TIMESTAMP) AS win_end
),
home AS (
  SELECT
    CAST(u.mri_client_id AS VARCHAR) AS mri_client_id,
    MIN(u.__time) AS home_time
  FROM user_interaction.ui_ux_events u
  CROSS JOIN params p
  WHERE u.__time >= p.win_start
    AND u.__time < p.win_end
    AND u.header_country = 'IND'
    AND u.header_bu = 'BUS'
    AND u.selected_country = 'India'
    AND u.event_group = 'bus_buddy_click_event'
    AND u.event_src = 'Android'
    AND u.event_name = 'BusMetro_MetroHomeLanded'
    AND u.mri_client_id IS NOT NULL
    AND CAST(u.mri_client_id AS VARCHAR) NOT IN ('', '0')
  GROUP BY 1
),
id_map AS (
  SELECT
    CAST(b.mri_client_id AS VARCHAR) AS mri_client_id,
    MAX(b.rb_user_id) AS rb_user_id
  FROM transaction.bus_ticket_events b
  INNER JOIN home h ON CAST(b.mri_client_id AS VARCHAR) = h.mri_client_id
  CROSS JOIN params p
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.rb_user_id IS NOT NULL
    AND b.rb_user_id <> 0
    AND b.time_of_event >= p.win_start
    AND b.time_of_event < p.win_end
  GROUP BY 1
),
mapped AS (
  SELECT m.rb_user_id, MIN(h.home_time) AS home_time
  FROM home h
  INNER JOIN id_map m ON h.mri_client_id = m.mri_client_id
  GROUP BY 1
),
metro AS (
  SELECT
    a.rb_user_id,
    a.time_of_event,
    CAST(a.tin AS VARCHAR) AS tin
  FROM transaction.addon_item a
  CROSS JOIN params p
  WHERE a.country_code = 'IND'
    AND a.item_type = 13
    AND a.s_c_t = 'Ticket'
    AND a.c_t = 'METRO_TICKETING'
    AND a.event_type = 101
    AND a.status = 'CONFIRMED'
    AND a.tin IS NOT NULL
    AND a.rb_user_id IS NOT NULL
    AND a.rb_user_id <> 0
    AND a.time_of_event >= p.win_start
    AND a.time_of_event < p.win_end
),
after_home AS (
  SELECT DISTINCT m.rb_user_id, m.home_time
  FROM mapped m
  INNER JOIN metro t
    ON m.rb_user_id = t.rb_user_id
   AND t.time_of_event > m.home_time
),
before_home AS (
  SELECT DISTINCT ah.rb_user_id
  FROM after_home ah
  INNER JOIN transaction.addon_item a
    ON ah.rb_user_id = a.rb_user_id
  WHERE a.country_code = 'IND'
    AND a.item_type = 13
    AND a.s_c_t = 'Ticket'
    AND a.c_t = 'METRO_TICKETING'
    AND a.event_type = 101
    AND a.status = 'CONFIRMED'
    AND a.tin IS NOT NULL
    AND a.time_of_event < ah.home_time
)
SELECT
  (SELECT COUNT(*) FROM home) AS home_users,
  (SELECT COUNT(*) FROM mapped) AS mapped_home_users,
  (SELECT COUNT(DISTINCT rb_user_id) FROM after_home) AS metro_after_home_users,
  (SELECT COUNT(DISTINCT ah.rb_user_id) FROM after_home ah WHERE ah.rb_user_id NOT IN (SELECT rb_user_id FROM before_home)) AS new_to_metro_after_home,
  (SELECT COUNT(DISTINCT rb_user_id) FROM before_home) AS repeat_metro_after_home
LIMIT 5
