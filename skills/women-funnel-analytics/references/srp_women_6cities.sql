-- MCP dataplatformCreateQuery (session 93d328c0-89dc-4036-a1fe-027c59b004e7)
-- SRP loaded Women vs Overall by source city · Android/iOS · IND BUS
-- Window: 2026-02-24 to 2026-08-24 IST
-- Note: ui_ux_events.src_id is STRING → TRY_CAST to BIGINT

SELECT
  DATE_TRUNC('MONTH', AT_TIMEZONE(ui.__time, 'Asia/Kolkata')) AS month_ist,
  CASE TRY_CAST(ui.src_id AS BIGINT)
    WHEN 124 THEN 'Hyderabad'
    WHEN 122 THEN 'Bangalore'
    WHEN 123 THEN 'Chennai'
    WHEN 462 THEN 'Mumbai'
    WHEN 733 THEN 'Delhi'
    WHEN 807 THEN 'Jaipur'
  END AS source_city,
  ui.event_src,
  COUNT(DISTINCT ui.mri_session_id) AS overall_sessions,
  COUNT(DISTINCT CASE WHEN ui.event_value = 'Women' THEN ui.mri_session_id END) AS women_sessions,
  COUNT(DISTINCT CASE WHEN ui.event_value = 'Regular' THEN ui.mri_session_id END) AS regular_sessions
FROM user_interaction.ui_ux_events AS ui
WHERE
  ui.__time >= CAST('2026-02-23 18:30:00' AS TIMESTAMP)
  AND ui.__time < CAST('2026-08-24 18:30:00' AS TIMESTAMP)
  AND ui.event_src IN ('Android', 'iOS')
  AND ui.header_country = 'IND'
  AND ui.header_bu = 'BUS'
  AND ui.selected_country = 'India'
  AND ui.event_group = 'srp_click_event'
  AND ui.event_name = 'SRP loaded'
  AND TRY_CAST(ui.src_id AS BIGINT) IN (124, 122, 123, 462, 733, 807)
GROUP BY
  DATE_TRUNC('MONTH', AT_TIMEZONE(ui.__time, 'Asia/Kolkata')),
  CASE TRY_CAST(ui.src_id AS BIGINT)
    WHEN 124 THEN 'Hyderabad'
    WHEN 122 THEN 'Bangalore'
    WHEN 123 THEN 'Chennai'
    WHEN 462 THEN 'Mumbai'
    WHEN 733 THEN 'Delhi'
    WHEN 807 THEN 'Jaipur'
  END,
  ui.event_src
LIMIT 1500
;