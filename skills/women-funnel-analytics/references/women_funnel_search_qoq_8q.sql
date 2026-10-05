-- =============================================================================
-- QoQ — Last 8 Quarters · Women_SRP vs Female_SVOC · Android IND BUS
-- Quarters: current IST quarter + prior 7 (Q4'24…Q3'26 as of 2026-09-15)
-- Women_SRP = SRP loaded event_value='Women'
-- Female_SVOC = any SRP loaded + SVOC female via search_details.rb_user_id
-- Confirm = bus_ticket_events event_type=101 AND event_class=2
-- NOTE: Women SRP may be zero in early quarters (instrumentation launch).
-- =============================================================================

-- =============================================================================
-- A) WOMEN FUNNEL SEARCH — session funnel by quarter × segment
--    SRP → SL → CI → TCO → Payment → Confirm
-- =============================================================================
WITH params AS (
  SELECT
    -- start of (current IST quarter − 7 quarters) as UTC
    CAST(
      AT_TIMEZONE(
        CAST(
          date_add(
            'quarter', -7,
            date_trunc('quarter', CAST(AT_TIMEZONE(CURRENT_TIMESTAMP, 'Asia/Kolkata') AS TIMESTAMP))
          ) AS TIMESTAMP
        ),
        'UTC'
      ) AS TIMESTAMP
    ) AS t0,
    CURRENT_TIMESTAMP AS t1
),

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

-- Women SRP sessions + IST quarter
women_srp AS (
  SELECT DISTINCT
    ux.mri_session_id,
    CAST(date_trunc('quarter', CAST(AT_TIMEZONE(ux.__time, 'Asia/Kolkata') AS TIMESTAMP)) AS DATE) AS qtr_start
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

-- Any SRP loaded (base for Female SVOC attach)
any_srp AS (
  SELECT DISTINCT
    ux.mri_session_id,
    CAST(date_trunc('quarter', CAST(AT_TIMEZONE(ux.__time, 'Asia/Kolkata') AS TIMESTAMP)) AS DATE) AS qtr_start
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
  SELECT
    s.mri_session_id,
    MAX(s.rb_user_id) AS rb_user_id
  FROM user_interaction.search_details s
  CROSS JOIN params p
  WHERE s.__time >= p.t0 AND s.__time < p.t1
    AND s.country = 'IND'
    AND s.os = 'Android'
  GROUP BY 1
),

female_svoc AS (
  SELECT DISTINCT
    a.mri_session_id,
    a.qtr_start
  FROM any_srp a
  INNER JOIN sess_user su ON a.mri_session_id = su.mri_session_id
  INNER JOIN svoc_female f ON su.rb_user_id = f.rb_user_id AND su.rb_user_id > 0
),

seg AS (
  SELECT mri_session_id, qtr_start, 'Women_SRP' AS segment FROM women_srp
  UNION ALL
  SELECT mri_session_id, qtr_start, 'Female_SVOC' AS segment FROM female_svoc
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
),

qtr_agg AS (
  SELECT
    s.segment,
    s.qtr_start,
    CONCAT(
      CAST(year(s.qtr_start) AS VARCHAR),
      '-Q',
      CAST(quarter(s.qtr_start) AS VARCHAR)
    ) AS quarter_label,
    COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
    COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
    COUNT(DISTINCT ci.mri_session_id) AS ci_sessions,
    COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
    COUNT(DISTINCT pay.mri_session_id) AS payment_sessions,
    COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions
  FROM seg s
  LEFT JOIN sl   ON s.mri_session_id = sl.mri_session_id
  LEFT JOIN ci   ON s.mri_session_id = ci.mri_session_id
  LEFT JOIN tco  ON s.mri_session_id = tco.mri_session_id
  LEFT JOIN pay  ON s.mri_session_id = pay.mri_session_id
  LEFT JOIN conf ON s.mri_session_id = conf.mri_session_id
  GROUP BY 1, 2, 3
)

SELECT
  'SEARCH' AS funnel_type,
  segment,
  quarter_label,
  qtr_start,
  srp_sessions,
  sl_sessions,
  ci_sessions,
  tco_sessions,
  payment_sessions,
  confirm_sessions,
  sl_sessions * 100.0 / NULLIF(srp_sessions, 0) AS sl_pct,
  ci_sessions * 100.0 / NULLIF(srp_sessions, 0) AS ci_pct,
  tco_sessions * 100.0 / NULLIF(srp_sessions, 0) AS tco_pct,
  payment_sessions * 100.0 / NULLIF(srp_sessions, 0) AS pay_pct,
  confirm_sessions * 100.0 / NULLIF(srp_sessions, 0) AS confirm_pct,
  -- QoQ on SRP volume + confirm CR
  LAG(srp_sessions) OVER (PARTITION BY segment ORDER BY qtr_start) AS prev_srp_sessions,
  (srp_sessions - LAG(srp_sessions) OVER (PARTITION BY segment ORDER BY qtr_start)) * 100.0
    / NULLIF(LAG(srp_sessions) OVER (PARTITION BY segment ORDER BY qtr_start), 0) AS srp_qoq_pct,
  LAG(confirm_sessions * 100.0 / NULLIF(srp_sessions, 0))
    OVER (PARTITION BY segment ORDER BY qtr_start) AS prev_confirm_pct,
  (confirm_sessions * 100.0 / NULLIF(srp_sessions, 0)
    - LAG(confirm_sessions * 100.0 / NULLIF(srp_sessions, 0))
        OVER (PARTITION BY segment ORDER BY qtr_start)
  ) AS confirm_cr_pp_qoq
FROM qtr_agg
ORDER BY segment, qtr_start;
