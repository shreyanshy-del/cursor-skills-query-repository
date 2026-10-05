WITH metro_city_map AS (
  SELECT * FROM (
    VALUES
      ('MaharashtraMetroRailCoLtd', 'Pune'),
      ('Mumbai Metro One Pvt Ltd', 'Mumbai'),
      ('Bangalore Metro Rail Corporation Limited', 'Bangalore'),
      ('Mumbai Metro Rail Corporation Limited', 'Mumbai'),
      ('Kochi Metro Rail Limited', 'Ernakulam'),
      ('Maha Mumbai Metro Operation Corporation Limited', 'Mumbai'),
      ('Chennai Metro Rail Limited', 'Chennai'),
      ('Delhi Metro Rail Corporation', 'Delhi')
  ) AS t(service_provider_name, city)
),
metro_txns AS (
  SELECT DISTINCT a.rb_user_id, CAST(a.tin AS VARCHAR) AS tin, m.city
  FROM transaction.addon_item a
  INNER JOIN metro_city_map m ON a.service_provider_name = m.service_provider_name
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
    AND uue.event_name = 'BusMetro_MetroHomeLanded'
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
)
SELECT
  COUNT(DISTINCT t.tin) AS metro_tins,
  COUNT(DISTINCT t.rb_user_id) AS metro_users
FROM id_map m
INNER JOIN metro_txns t ON m.rb_user_id = t.rb_user_id
LIMIT 5
