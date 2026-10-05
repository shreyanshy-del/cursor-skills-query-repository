-- =============================================================================
-- Women_SRP + Female_SVOC Funnel Throughput — Overall Level
-- Q2 2026 (IST Apr 1 → Jul 1) · Android · IND · BUS
-- UTC: 2026-03-31 18:30 → 2026-06-30 18:30
--
-- Funnel: SRP → SL → CI → TCO → Payment → Confirm
-- CR / confirm_pct = confirm_sessions / srp_sessions × 100
-- Step % = step_sessions / srp_sessions × 100 (denominator = SRP)
--
-- Segments:
--   Platform     = any SRP loaded (Android IND BUS)
--   Women_SRP    = SRP loaded event_value = 'Women'
--   Female_SVOC  = any SRP loaded + SVOC female (search_details.rb_user_id)
-- Confirm = bus_ticket_events event_type=101 AND event_class=2
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

-- One SRP scan: all sessions + Women flag
srp_base AS (
  SELECT
    ux.mri_session_id,
    MAX(CASE WHEN ux.event_value = 'Women' THEN 1 ELSE 0 END) AS is_women_srp
  FROM user_interaction.ui_ux_events ux
  CROSS JOIN params p
  WHERE ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND'
    AND ux.header_bu = 'BUS'
    AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
  GROUP BY 1
),

-- User attach only for SRP sessions (Female_SVOC)
sess_user AS (
  SELECT
    s.mri_session_id,
    MAX(s.rb_user_id) AS rb_user_id
  FROM user_interaction.search_details s
  INNER JOIN srp_base b ON s.mri_session_id = b.mri_session_id
  CROSS JOIN params p
  WHERE s.__time >= p.t0 AND s.__time < p.t1
    AND s.country = 'IND'
    AND s.os = 'Android'
  GROUP BY 1
),

seg AS (
  SELECT mri_session_id, 'Platform' AS segment
  FROM srp_base

  UNION ALL

  SELECT mri_session_id, 'Women_SRP' AS segment
  FROM srp_base
  WHERE is_women_srp = 1

  UNION ALL

  SELECT b.mri_session_id, 'Female_SVOC' AS segment
  FROM srp_base b
  INNER JOIN sess_user su ON b.mri_session_id = su.mri_session_id
  INNER JOIN svoc_female f ON su.rb_user_id = f.rb_user_id AND su.rb_user_id > 0
),

-- Funnel steps restricted to SRP sessions
sl AS (
  SELECT DISTINCT sl.mri_session_id
  FROM user_interaction.seat_layout_details sl
  INNER JOIN srp_base b ON sl.mri_session_id = b.mri_session_id
  CROSS JOIN params p
  WHERE sl.__time >= p.t0 AND sl.__time < p.t1
    AND sl.country = 'IND' AND sl.os = 'Android'
),
ci AS (
  SELECT DISTINCT ci.mri_session_id
  FROM user_interaction.cust_info_details ci
  INNER JOIN srp_base b ON ci.mri_session_id = b.mri_session_id
  CROSS JOIN params p
  WHERE ci.__time >= p.t0 AND ci.__time < p.t1
    AND ci.country = 'IND' AND ci.os = 'Android'
),
tco AS (
  SELECT DISTINCT t.mri_session_id
  FROM user_interaction.create_order_details t
  INNER JOIN srp_base b ON t.mri_session_id = b.mri_session_id
  CROSS JOIN params p
  WHERE t.__time >= p.t0 AND t.__time < p.t1
    AND t.country = 'IND' AND t.os = 'Android'
),
pay AS (
  SELECT DISTINCT o.mri_session_id
  FROM user_interaction.order_info_details o
  INNER JOIN srp_base b ON o.mri_session_id = b.mri_session_id
  CROSS JOIN params p
  WHERE o.__time >= p.t0 AND o.__time < p.t1
    AND o.country = 'IND' AND o.os = 'Android'
),
conf AS (
  SELECT DISTINCT bte.mri_session_id
  FROM transaction.bus_ticket_events bte
  INNER JOIN srp_base b ON bte.mri_session_id = b.mri_session_id
  CROSS JOIN params p
  WHERE bte.time_of_event >= p.t0 AND bte.time_of_event < p.t1
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
)

SELECT
  'SEARCH' AS funnel_type,
  s.segment,
  'ALL' AS user_type,
  '2026-Q2' AS quarter_label,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
  COUNT(DISTINCT ci.mri_session_id) AS ci_sessions,
  COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
  COUNT(DISTINCT pay.mri_session_id) AS payment_sessions,
  COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions,
  COUNT(DISTINCT sl.mri_session_id) * 100.0
    / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS sl_pct,
  COUNT(DISTINCT ci.mri_session_id) * 100.0
    / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS ci_pct,
  COUNT(DISTINCT tco.mri_session_id) * 100.0
    / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS tco_pct,
  COUNT(DISTINCT pay.mri_session_id) * 100.0
    / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS pay_pct,
  COUNT(DISTINCT conf.mri_session_id) * 100.0
    / NULLIF(COUNT(DISTINCT s.mri_session_id), 0) AS cr_pct
FROM seg s
LEFT JOIN sl   ON s.mri_session_id = sl.mri_session_id
LEFT JOIN ci   ON s.mri_session_id = ci.mri_session_id
LEFT JOIN tco  ON s.mri_session_id = tco.mri_session_id
LEFT JOIN pay  ON s.mri_session_id = pay.mri_session_id
LEFT JOIN conf ON s.mri_session_id = conf.mri_session_id
GROUP BY 1, 2, 3, 4
ORDER BY
  CASE s.segment
    WHEN 'Platform' THEN 1
    WHEN 'Female_SVOC' THEN 2
    WHEN 'Women_SRP' THEN 3
    ELSE 4
  END;
