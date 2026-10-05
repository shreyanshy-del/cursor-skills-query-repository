SELECT
  CAST(u.mri_client_id AS VARCHAR) AS mri_client_id,
  MIN(u.__time) AS home_time
FROM user_interaction.ui_ux_events u
WHERE u.__time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
  AND u.__time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  AND u.header_country = 'IND'
  AND u.header_bu = 'BUS'
  AND u.selected_country = 'India'
  AND u.event_group = 'bus_buddy_click_event'
  AND u.event_src = 'Android'
  AND u.event_name = 'BusMetro_MetroHomeLanded'
  AND u.mri_client_id IS NOT NULL
  AND CAST(u.mri_client_id AS VARCHAR) NOT IN ('', '0')
GROUP BY 1
LIMIT 20000
