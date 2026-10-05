WITH ev AS (
  SELECT DISTINCT
    u.event_name,
    CAST(u.mri_client_id AS VARCHAR) AS mri_client_id
  FROM user_interaction.ui_ux_events u
  WHERE u.__time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND u.__time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
    AND u.header_country = 'IND'
    AND u.header_bu = 'BUS'
    AND u.selected_country = 'India'
    AND u.event_group = 'bus_buddy_click_event'
    AND u.event_name IN (
      'BusMetro_MetroCardLoaded',
      'BusMetro_MetroStickyLoaded',
      'BusMetro_MetroHomeLanded'
    )
    AND u.mri_client_id IS NOT NULL
    AND CAST(u.mri_client_id AS VARCHAR) NOT IN ('', '0')
),
id_map AS (
  SELECT
    CAST(b.mri_client_id AS VARCHAR) AS mri_client_id,
    MAX(b.rb_user_id) AS rb_user_id
  FROM transaction.bus_ticket_events b
  INNER JOIN (SELECT DISTINCT mri_client_id FROM ev) i
    ON CAST(b.mri_client_id AS VARCHAR) = i.mri_client_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.rb_user_id IS NOT NULL
    AND b.rb_user_id <> 0
    AND b.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND b.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  GROUP BY 1
),
metro_txns AS (
  SELECT DISTINCT
    a.rb_user_id,
    CAST(a.tin AS VARCHAR) AS tin,
    CASE a.service_provider_name
      WHEN 'MaharashtraMetroRailCoLtd' THEN 'Pune'
      WHEN 'Mumbai Metro One Pvt Ltd' THEN 'Mumbai'
      WHEN 'Bangalore Metro Rail Corporation Limited' THEN 'Bangalore'
      WHEN 'Mumbai Metro Rail Corporation Limited' THEN 'Mumbai'
      WHEN 'Kochi Metro Rail Limited' THEN 'Ernakulam'
      WHEN 'Maha Mumbai Metro Operation Corporation Limited' THEN 'Mumbai'
      WHEN 'Chennai Metro Rail Limited' THEN 'Chennai'
      WHEN 'Delhi Metro Rail Corporation' THEN 'Delhi'
    END AS metro_city
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
    AND a.service_provider_name IN (
      'MaharashtraMetroRailCoLtd',
      'Mumbai Metro One Pvt Ltd',
      'Bangalore Metro Rail Corporation Limited',
      'Mumbai Metro Rail Corporation Limited',
      'Kochi Metro Rail Limited',
      'Maha Mumbai Metro Operation Corporation Limited',
      'Chennai Metro Rail Limited',
      'Delhi Metro Rail Corporation'
    )
),
u AS (
  SELECT DISTINCT
    e.event_name,
    e.mri_client_id,
    m.rb_user_id
  FROM ev e
  LEFT JOIN id_map m ON e.mri_client_id = m.mri_client_id
)
SELECT
  u.event_name,
  COUNT(DISTINCT u.mri_client_id) AS users,
  COUNT(DISTINCT CASE WHEN u.rb_user_id IS NOT NULL THEN u.mri_client_id END) AS mapped_users,
  COUNT(DISTINCT CASE WHEN t.rb_user_id IS NOT NULL THEN u.mri_client_id END) AS metro_users,
  COUNT(DISTINCT t.tin) AS metro_tins
FROM u
LEFT JOIN metro_txns t ON u.rb_user_id = t.rb_user_id
GROUP BY 1
ORDER BY 1
LIMIT 20
