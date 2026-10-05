-- Guest / Fraud (multi-op same DOJ same rb_user_id) / Android / Overall sessions
-- Scopes: INDIA | UP (dest state) | UP_Pilgrim (dest_id list)
-- Window: 2026-08-27 → 2026-09-10

WITH base_searches AS (
  SELECT
    sd.mri_session_id,
    sd.doj,
    sd.operator_id,
    sd.os,
    sd.dest_id,
    sd.rb_user_id,
    state.location_name AS state_name
  FROM user_interaction.search_details AS sd
  LEFT JOIN lis.config_locations AS city
    ON sd.dest_id = city.id AND city.location_type = 'CITY' AND city.is_expired = 0
  LEFT JOIN lis.config_locations AS state
    ON city.parent_location = state.id
    AND state.location_type = 'STATE'
    AND state.is_expired = 0
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-08-27 00:00:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-09-10 00:00:00' AS TIMESTAMP)
), scoped_searches AS (
  SELECT 'INDIA' AS scope, mri_session_id, doj, operator_id, os, rb_user_id FROM base_searches
  UNION ALL
  SELECT 'UP', mri_session_id, doj, operator_id, os, rb_user_id FROM base_searches
  WHERE LOWER(state_name) LIKE '%uttar%' AND LOWER(state_name) LIKE '%pradesh%'
  UNION ALL
  SELECT 'UP_Pilgrim', mri_session_id, doj, operator_id, os, rb_user_id FROM base_searches
  WHERE dest_id IN (76480, 70429, 84832, 747, 94782)
), fraudulent_pairs AS (
  SELECT scope, rb_user_id, doj
  FROM scoped_searches
  WHERE NOT rb_user_id IS NULL AND NOT doj IS NULL
  GROUP BY scope, rb_user_id, doj
  HAVING COUNT(DISTINCT operator_id) > 1
), metrics AS (
  SELECT
    s.scope,
    COUNT(DISTINCT s.mri_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN s.rb_user_id IS NULL THEN s.mri_session_id END) AS guest_sessions,
    COUNT(DISTINCT CASE WHEN LOWER(s.os) = 'android' THEN s.mri_session_id END) AS android_sessions,
    COUNT(DISTINCT CASE WHEN NOT f.rb_user_id IS NULL THEN s.mri_session_id END) AS fraud_sessions
  FROM scoped_searches AS s
  LEFT JOIN fraudulent_pairs AS f
    ON s.scope = f.scope AND s.rb_user_id = f.rb_user_id AND s.doj = f.doj
  GROUP BY s.scope
)
SELECT
  scope,
  total_sessions AS overall_sessions,
  android_sessions,
  guest_sessions,
  CAST(guest_sessions AS DOUBLE) / NULLIF(total_sessions, 0) * 100 AS guest_share_pct,
  fraud_sessions,
  CAST(fraud_sessions AS DOUBLE) / NULLIF(total_sessions, 0) * 100 AS fraud_share_pct
FROM metrics
ORDER BY scope;
