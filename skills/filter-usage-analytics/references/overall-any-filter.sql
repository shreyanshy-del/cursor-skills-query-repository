-- Overall any-filter sessions by day × platform × usertype
-- Any = sort_and_filter OR contextual/LMB/inline Clicked (distinct mri_session_id)
-- Join to SRP load from sort-vs-srp.sql for coverage = any / srp
-- Swap date window and eligible versions as needed.

SELECT
  CAST(uue.__time AS DATE) AS event_date,
  uue.event_src,
  CASE
    WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'GUEST' THEN 'GUEST'
    WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'NEW' THEN 'NEW'
    WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'RETURNING' THEN 'RETURNING'
    ELSE 'OTHER'
  END AS usertype_norm,
  COUNT(DISTINCT uue.mri_session_id) AS any_filter_sessions
FROM user_interaction.ui_ux_events AS uue
WHERE
  uue.__time >= CAST('2026-08-04 00:00:00' AS TIMESTAMP)
  AND uue.__time < CAST('2026-08-11 00:00:00' AS TIMESTAMP)
  AND uue.header_country = 'IND'
  AND uue.event_src IN ('Android', 'iOS')
  AND uue.header_bu = 'BUS'
  AND uue.selected_country = 'India'
  AND uue.event_group = 'srp_filter_event'
  AND (
    uue.event_name = 'sort_and_filter'
    OR (uue.event_name = 'contextual' AND uue.event_value = 'Clicked')
    OR (uue.event_name = 'LMB' AND uue.event_value = 'Clicked')
    OR (LOWER(uue.event_name) = 'inline' AND uue.event_value = 'Clicked')
  )
  AND (
    (uue.event_src = 'Android' AND uue.app_version IN ('82.3.0', '82.3.1', '82.3.5', '82.3.6', '82.4.0-IB1'))
    OR (uue.event_src = 'iOS' AND uue.app_version IN ('8.6.7.10', '8.7.0.1', '8.6.9.2', '8.6.8.1'))
  )
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
LIMIT 200;
