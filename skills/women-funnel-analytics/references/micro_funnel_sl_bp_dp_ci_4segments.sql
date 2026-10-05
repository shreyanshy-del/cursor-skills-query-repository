-- =============================================================================
-- Micro Funnel: SL → BP → DP → CI
-- Segments: Women_SRP | Regular_SRP | Female_SVOC | Male_SVOC
-- Cut: Overall + Usertype (GUEST / NEW / RETURNING from search_details)
-- Android · IND · BUS
-- Window (7d IST): 2026-09-07 → 2026-09-13
--   UTC: 2026-09-06 18:30 → 2026-09-13 18:30
--
-- Step definitions (session-level, distinct mri_session_id):
--   SL  = seat_layout_details (Android IND)
--   BP  = ui_ux screen_name = 'boarding point screen'
--         OR (event_group = 'bp_dp_screen_load' AND screen mentions board)
--   DP  = ui_ux screen_name = 'dropping point screen'
--         OR (event_group = 'bp_dp_screen_load' AND screen mentions drop)
--   CI  = cust_info_details (Android IND)
--
-- Denominator = SRP / segment sessions (not sequential forced path)
-- =============================================================================

WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1
),

svoc AS (
  SELECT
    TRY_CAST(rb_userid AS BIGINT) AS rb_user_id,
    CASE
      WHEN LOWER(gender) IN ('female', 'f') THEN 'Female'
      WHEN LOWER(gender) IN ('male', 'm') THEN 'Male'
      ELSE NULL
    END AS svoc_gender
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f', 'male', 'm')
),

-- SRP loaded sessions (Women + Regular)
srp AS (
  SELECT DISTINCT
    ux.mri_session_id,
    ux.event_value AS srp_cohort
  FROM user_interaction.ui_ux_events ux
  CROSS JOIN params p
  WHERE ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND'
    AND ux.header_bu = 'BUS'
    AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
),

-- Any SRP (for SVOC attach)
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

-- First search_details per session → usertype + rb_user_id
sd0 AS (
  SELECT *
  FROM (
    SELECT
      s.mri_session_id,
      s.rb_user_id,
      CASE
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('GUEST') THEN 'GUEST'
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('NEW') THEN 'NEW'
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('RETURNING', 'EXISTING', 'OLD') THEN 'RETURNING'
        ELSE 'OTHER'
      END AS user_type,
      ROW_NUMBER() OVER (PARTITION BY s.mri_session_id ORDER BY s.__time ASC) AS rn
    FROM user_interaction.search_details s
    CROSS JOIN params p
    WHERE s.__time >= p.t0 AND s.__time < p.t1
      AND s.country = 'IND'
      AND s.os = 'Android'
  ) x
  WHERE rn = 1
),

svoc_sess AS (
  SELECT DISTINCT
    a.mri_session_id,
    v.svoc_gender
  FROM any_srp a
  INNER JOIN sd0 ON a.mri_session_id = sd0.mri_session_id
  INNER JOIN svoc v ON sd0.rb_user_id = v.rb_user_id AND sd0.rb_user_id > 0
  WHERE v.svoc_gender IS NOT NULL
),

-- Four segment universes (overlapping OK — compare rates, don't add)
seg AS (
  SELECT mri_session_id, 'Women_SRP' AS segment
  FROM srp WHERE srp_cohort = 'Women'
  UNION ALL
  SELECT mri_session_id, 'Regular_SRP' AS segment
  FROM srp WHERE srp_cohort = 'Regular'
  UNION ALL
  SELECT mri_session_id, 'Female_SVOC' AS segment
  FROM svoc_sess WHERE svoc_gender = 'Female'
  UNION ALL
  SELECT mri_session_id, 'Male_SVOC' AS segment
  FROM svoc_sess WHERE svoc_gender = 'Male'
),

base AS (
  SELECT
    s.segment,
    s.mri_session_id,
    COALESCE(sd0.user_type, 'OTHER') AS user_type
  FROM seg s
  LEFT JOIN sd0 ON s.mri_session_id = sd0.mri_session_id
),

sl AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.seat_layout_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND country = 'IND'
    AND os = 'Android'
),

bp AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.ui_ux_events
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND event_src = 'Android'
    AND header_country = 'IND'
    AND header_bu = 'BUS'
    AND selected_country = 'India'
    AND (
      LOWER(COALESCE(screen_name, '')) = 'boarding point screen'
      OR event_group = 'bp_dp_screen_load'
         AND LOWER(COALESCE(screen_name, '')) LIKE '%board%'
    )
),

dp AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.ui_ux_events
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND event_src = 'Android'
    AND header_country = 'IND'
    AND header_bu = 'BUS'
    AND selected_country = 'India'
    AND (
      LOWER(COALESCE(screen_name, '')) = 'dropping point screen'
      OR event_group = 'bp_dp_screen_load'
         AND LOWER(COALESCE(screen_name, '')) LIKE '%drop%'
    )
),

ci AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.cust_info_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1
    AND country = 'IND'
    AND os = 'Android'
),

funnel AS (
  SELECT
    b.segment,
    b.user_type,
    b.mri_session_id,
    sl.mri_session_id AS sl_sid,
    bp.mri_session_id AS bp_sid,
    dp.mri_session_id AS dp_sid,
    ci.mri_session_id AS ci_sid
  FROM base b
  LEFT JOIN sl ON b.mri_session_id = sl.mri_session_id
  LEFT JOIN bp ON b.mri_session_id = bp.mri_session_id
  LEFT JOIN dp ON b.mri_session_id = dp.mri_session_id
  LEFT JOIN ci ON b.mri_session_id = ci.mri_session_id
)

-- Overall
SELECT
  'Overall' AS grain,
  segment,
  'ALL' AS user_type,
  COUNT(DISTINCT mri_session_id) AS srp_sessions,
  COUNT(DISTINCT sl_sid) AS sl_sessions,
  COUNT(DISTINCT bp_sid) AS bp_sessions,
  COUNT(DISTINCT dp_sid) AS dp_sessions,
  COUNT(DISTINCT ci_sid) AS ci_sessions,
  COUNT(DISTINCT sl_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS sl_pct,
  COUNT(DISTINCT bp_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS bp_pct,
  COUNT(DISTINCT dp_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS dp_pct,
  COUNT(DISTINCT ci_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS ci_pct,
  COUNT(DISTINCT bp_sid) * 100.0 / NULLIF(COUNT(DISTINCT sl_sid), 0) AS bp_of_sl_pct,
  COUNT(DISTINCT dp_sid) * 100.0 / NULLIF(COUNT(DISTINCT bp_sid), 0) AS dp_of_bp_pct,
  COUNT(DISTINCT ci_sid) * 100.0 / NULLIF(COUNT(DISTINCT dp_sid), 0) AS ci_of_dp_pct
FROM funnel
GROUP BY 1, 2, 3

UNION ALL

-- Usertype (GUEST / NEW / RETURNING)
SELECT
  'Usertype' AS grain,
  segment,
  user_type,
  COUNT(DISTINCT mri_session_id) AS srp_sessions,
  COUNT(DISTINCT sl_sid) AS sl_sessions,
  COUNT(DISTINCT bp_sid) AS bp_sessions,
  COUNT(DISTINCT dp_sid) AS dp_sessions,
  COUNT(DISTINCT ci_sid) AS ci_sessions,
  COUNT(DISTINCT sl_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS sl_pct,
  COUNT(DISTINCT bp_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS bp_pct,
  COUNT(DISTINCT dp_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS dp_pct,
  COUNT(DISTINCT ci_sid) * 100.0 / NULLIF(COUNT(DISTINCT mri_session_id), 0) AS ci_pct,
  COUNT(DISTINCT bp_sid) * 100.0 / NULLIF(COUNT(DISTINCT sl_sid), 0) AS bp_of_sl_pct,
  COUNT(DISTINCT dp_sid) * 100.0 / NULLIF(COUNT(DISTINCT bp_sid), 0) AS dp_of_bp_pct,
  COUNT(DISTINCT ci_sid) * 100.0 / NULLIF(COUNT(DISTINCT dp_sid), 0) AS ci_of_dp_pct
FROM funnel
WHERE user_type IN ('GUEST', 'NEW', 'RETURNING')
GROUP BY 1, 2, 3

ORDER BY 1, 2, 3;
