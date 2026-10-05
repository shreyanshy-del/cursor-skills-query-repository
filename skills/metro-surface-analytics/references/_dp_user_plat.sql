WITH ev AS (
  SELECT DISTINCT
    u.event_name,
    CASE
      WHEN u.event_src LIKE '%iOS%' THEN 'iOS'
      WHEN u.event_src LIKE '%Android%' THEN 'Android'
      ELSE 'Other'
    END AS platform,
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
metro_users AS (
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
u AS (
  SELECT DISTINCT
    e.event_name,
    e.platform,
    e.mri_client_id,
    m.rb_user_id
  FROM ev e
  LEFT JOIN id_map m ON e.mri_client_id = m.mri_client_id
)
SELECT
  u.event_name,
  u.platform,
  COUNT(DISTINCT u.mri_client_id) AS users,
  COUNT(DISTINCT CASE WHEN u.rb_user_id IS NOT NULL THEN u.mri_client_id END) AS mapped_users,
  COUNT(DISTINCT CASE WHEN mu.rb_user_id IS NOT NULL THEN u.mri_client_id END) AS metro_users
FROM u
LEFT JOIN metro_users mu ON u.rb_user_id = mu.rb_user_id
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 20
