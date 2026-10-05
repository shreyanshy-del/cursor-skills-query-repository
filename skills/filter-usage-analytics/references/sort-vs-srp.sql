-- Sort & Filter sessions vs SRP load by day × platform × usertype
-- Coverage = sort_sessions / srp_sessions (Σ of daily distinct for multi-day)

WITH sort_sessions AS (
  SELECT
    CAST(uue.__time AS DATE) AS event_date,
    uue.event_src,
    CASE
      WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'GUEST' THEN 'GUEST'
      WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'NEW' THEN 'NEW'
      WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'RETURNING' THEN 'RETURNING'
      ELSE 'OTHER'
    END AS usertype_norm,
    COUNT(DISTINCT uue.mri_session_id) AS sort_sessions
  FROM user_interaction.ui_ux_events AS uue
  WHERE
    uue.__time >= CAST('2026-08-04 00:00:00' AS TIMESTAMP)
    AND uue.__time < CAST('2026-08-11 00:00:00' AS TIMESTAMP)
    AND uue.header_country = 'IND'
    AND uue.event_src IN ('Android', 'iOS')
    AND uue.header_bu = 'BUS'
    AND uue.selected_country = 'India'
    AND uue.event_group = 'srp_filter_event'
    AND uue.event_name = 'sort_and_filter'
    AND (
      (uue.event_src = 'Android' AND uue.app_version IN ('82.3.0', '82.3.1', '82.3.5', '82.3.6', '82.4.0-IB1'))
      OR (uue.event_src = 'iOS' AND uue.app_version IN ('8.6.7.10', '8.7.0.1', '8.6.9.2', '8.6.8.1'))
    )
  GROUP BY 1, 2, 3
),
srp_sessions AS (
  SELECT
    CAST(uue.__time AS DATE) AS event_date,
    uue.event_src,
    CASE
      WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'GUEST' THEN 'GUEST'
      WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'NEW' THEN 'NEW'
      WHEN UPPER(TRIM(COALESCE(uue.usertype, ''))) = 'RETURNING' THEN 'RETURNING'
      ELSE 'OTHER'
    END AS usertype_norm,
    COUNT(DISTINCT uue.mri_session_id) AS srp_sessions
  FROM user_interaction.ui_ux_events AS uue
  WHERE
    uue.__time >= CAST('2026-08-04 00:00:00' AS TIMESTAMP)
    AND uue.__time < CAST('2026-08-11 00:00:00' AS TIMESTAMP)
    AND uue.header_country = 'IND'
    AND uue.event_src IN ('Android', 'iOS')
    AND uue.header_bu = 'BUS'
    AND uue.selected_country = 'India'
    AND uue.event_group = 'srpLoad'
    AND uue.event_name = 'SRP load'
    AND (
      (uue.event_src = 'Android' AND uue.app_version IN ('82.3.0', '82.3.1', '82.3.5', '82.3.6', '82.4.0-IB1'))
      OR (uue.event_src = 'iOS' AND uue.app_version IN ('8.6.7.10', '8.7.0.1', '8.6.9.2', '8.6.8.1'))
    )
  GROUP BY 1, 2, 3
)
SELECT
  COALESCE(s.event_date, r.event_date) AS event_date,
  COALESCE(s.event_src, r.event_src) AS event_src,
  COALESCE(s.usertype_norm, r.usertype_norm) AS usertype_norm,
  COALESCE(s.sort_sessions, 0) AS sort_sessions,
  COALESCE(r.srp_sessions, 0) AS srp_sessions
FROM sort_sessions s
FULL OUTER JOIN srp_sessions r
  ON s.event_date = r.event_date
 AND s.event_src = r.event_src
 AND s.usertype_norm = r.usertype_norm
ORDER BY 1, 2, 3
LIMIT 200;
