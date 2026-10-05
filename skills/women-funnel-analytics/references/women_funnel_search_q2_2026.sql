-- =============================================================================
-- ONE QUARTER smoke check — Q2 2026 (IST Apr 1 → Jul 1)
-- Women Funnel SEARCH · Women_SRP vs Female_SVOC · Android IND BUS
-- UTC: 2026-03-31 18:30 → 2026-06-30 18:30
-- =============================================================================

WITH params AS (
  SELECT
    TIMESTAMP '2026-03-31 18:30:00' AS t0,
    TIMESTAMP '2026-06-30 18:30:00' AS t1
),

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

women_srp AS (
  SELECT DISTINCT ux.mri_session_id
  FROM user_interaction.ui_ux_events ux
  CROSS JOIN params p
  WHERE ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND'
    AND ux.header_bu = 'BUS'
    AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value = 'Women'
),

any_srp AS (
  SELECT DISTINCT ux.mri_session_id
  FROM user_interaction.ui_ux_events ux
  CROSS JOIN params p
  WHERE ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND'
    AND ux.header_bu = 'BUS'
    AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
),

sess_user AS (
  SELECT s.mri_session_id, MAX(s.rb_user_id) AS rb_user_id
  FROM user_interaction.search_details s
  CROSS JOIN params p
  WHERE s.__time >= p.t0 AND s.__time < p.t1
    AND s.country = 'IND'
    AND s.os = 'Android'
  GROUP BY 1
),

female_svoc AS (
  SELECT DISTINCT a.mri_session_id
  FROM any_srp a
  INNER JOIN sess_user su ON a.mri_session_id = su.mri_session_id
  INNER JOIN svoc_female f ON su.rb_user_id = f.rb_user_id AND su.rb_user_id > 0
),

seg AS (
  SELECT mri_session_id, 'Women_SRP' AS segment FROM women_srp
  UNION ALL
  SELECT mri_session_id, 'Female_SVOC' AS segment FROM female_svoc
),

sl AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.seat_layout_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND country = 'IND' AND os = 'Android'
),
ci AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.cust_info_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND country = 'IND' AND os = 'Android'
),
tco AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.create_order_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND country = 'IND' AND os = 'Android'
),
pay AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.order_info_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND country = 'IND' AND os = 'Android'
),
conf AS (
  SELECT DISTINCT mri_session_id
  FROM transaction.bus_ticket_events
  CROSS JOIN params p
  WHERE time_of_event >= p.t0 AND time_of_event < p.t1
    AND country_code = 'IND'
    AND event_type = 101
    AND event_class = 2
)

SELECT
  'SEARCH' AS funnel_type,
  s.segment,
  '2026-Q2' AS quarter_label,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
  COUNT(DISTINCT ci.mri_session_id) AS ci_sessions,
  COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
  COUNT(DISTINCT pay.mri_session_id) AS payment_sessions,
  COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions,
  COUNT(DISTINCT sl.mri_session_id) * 100.0 / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS sl_pct,
  COUNT(DISTINCT ci.mri_session_id) * 100.0 / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS ci_pct,
  COUNT(DISTINCT tco.mri_session_id) * 100.0 / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS tco_pct,
  COUNT(DISTINCT pay.mri_session_id) * 100.0 / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS pay_pct,
  COUNT(DISTINCT conf.mri_session_id) * 100.0 / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS confirm_pct
FROM seg s
LEFT JOIN sl   ON s.mri_session_id = sl.mri_session_id
LEFT JOIN ci   ON s.mri_session_id = ci.mri_session_id
LEFT JOIN tco  ON s.mri_session_id = tco.mri_session_id
LEFT JOIN pay  ON s.mri_session_id = pay.mri_session_id
LEFT JOIN conf ON s.mri_session_id = conf.mri_session_id
GROUP BY 1, 2, 3
ORDER BY 2;
