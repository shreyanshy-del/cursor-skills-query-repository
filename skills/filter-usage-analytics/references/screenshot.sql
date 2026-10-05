-- Screenshot taken — volume by day × platform (eligible versions)
-- event_value / filter_applied (page name) and usertype are typically NULL

SELECT
  CAST(uue.__time AS DATE) AS event_date,
  uue.event_src,
  COUNT(DISTINCT uue.mri_session_id) AS sessions
FROM user_interaction.ui_ux_events AS uue
WHERE
  uue.__time >= CAST('2026-08-04 00:00:00' AS TIMESTAMP)
  AND uue.__time < CAST('2026-08-11 00:00:00' AS TIMESTAMP)
  AND uue.header_country = 'IND'
  AND uue.event_src IN ('Android', 'iOS')
  AND uue.header_bu = 'BUS'
  AND uue.selected_country = 'India'
  AND uue.event_group = 'screenshot_taken'
  AND (
    (uue.event_src = 'Android' AND uue.app_version IN ('82.3.0', '82.3.1', '82.3.5', '82.3.6', '82.4.0-IB1'))
    OR (uue.event_src = 'iOS' AND uue.app_version IN ('8.6.7.10', '8.7.0.1', '8.6.9.2', '8.6.8.1'))
  )
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 50;
