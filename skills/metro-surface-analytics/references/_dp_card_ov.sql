WITH metro_any AS (
  SELECT DISTINCT a.rb_user_id
  FROM transaction.addon_item a
  WHERE a.country_code = 'IND'
    AND a.item_type = 13
    AND a.s_c_t = 'Ticket'
    AND a.c_t = 'METRO_TICKETING'
    AND a.event_type = 101
    AND a.status = 'CONFIRMED'
    AND a.tin IS NOT NULL
    AND a.rb_user_id IS NOT NULL
    AND a.rb_user_id <> 0
    AND a.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND a.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
),
ev AS (
  SELECT DISTINCT uue.mri_client_id
  FROM user_interaction.ui_ux_events AS uue
  WHERE
    uue.__time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND uue.__time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
    AND uue.header_country = 'IND'
    AND uue.header_bu = 'BUS'
    AND uue.selected_country = 'India'
    AND uue.event_group = 'bus_buddy_click_event'
    AND uue.event_src = 'Android'
    AND uue.event_name = 'BusMetro_MetroCardLoaded'
    AND uue.mri_client_id IS NOT NULL
    AND uue.mri_client_id NOT IN ('', '0')
),
id_map AS (
  SELECT b.mri_client_id, MAX(b.rb_user_id) AS rb_user_id
  FROM transaction.bus_ticket_events AS b
  INNER JOIN ev i ON b.mri_client_id = i.mri_client_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.rb_user_id IS NOT NULL
    AND b.rb_user_id <> 0
    AND b.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND b.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  GROUP BY 1
),
u_event AS (
  SELECT DISTINCT e.mri_client_id, m.rb_user_id
  FROM ev e
  LEFT JOIN id_map m ON e.mri_client_id = m.mri_client_id
)
SELECT
  COUNT(*) AS users,
  SUM(CASE WHEN u.rb_user_id IS NOT NULL THEN 1 ELSE 0 END) AS mapped_users,
  SUM(CASE WHEN a.rb_user_id IS NOT NULL THEN 1 ELSE 0 END) AS metro_users
FROM u_event u
LEFT JOIN metro_any a ON u.rb_user_id = a.rb_user_id
LIMIT 5
