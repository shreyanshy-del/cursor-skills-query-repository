-- =============================================================================
-- ONE QUARTER — Q2 2026 (IST Apr 1 → Jul 1) · OPTIMISED
-- Women Funnel TRANSACTION
--   Platform | Overall_Women | Female_SVOC | Women_SRP
-- Cuts: Platform = ALL only
--       Overall_Women / Women_SRP / Female_SVOC = ALL + NEW + RETURNING
-- Overall_Women = Women_SRP ∪ Female_SVOC (distinct tin; overlap not double-counted)
-- Android · IND · BUS · confirm event_type=101 event_class=2
-- UTC: 2026-03-31 18:30 → 2026-06-30 18:30
-- Share % = always vs Platform Overall (ALL)
-- =============================================================================

WITH params AS (
  SELECT
    TIMESTAMP '2026-03-31 18:30:00' AS t0,
    TIMESTAMP '2026-06-30 18:30:00' AS t1
),

-- (1) Confirmed Android IND txns — scanned once
platform_txns AS (
  SELECT
    b.tin,
    b.rb_user_id,
    b.seat_count,
    b.ticket_fare,
    b.mri_session_id
  FROM transaction.bus_ticket_events b
  CROSS JOIN params p
  WHERE b.time_of_event >= p.t0 AND b.time_of_event < p.t1
    AND b.country_code = 'IND'
    AND b.event_type = 101
    AND b.event_class = 2
    AND b.sales_channel LIKE '%droidapp%'
),

confirm_sess AS (
  SELECT DISTINCT mri_session_id
  FROM platform_txns
  WHERE mri_session_id IS NOT NULL
),

-- (2) Usertype only for confirm sessions
sd0 AS (
  SELECT
    mri_session_id,
    user_type
  FROM (
    SELECT
      s.mri_session_id,
      CASE
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('GUEST') THEN 'GUEST'
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('NEW') THEN 'NEW'
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('RETURNING', 'EXISTING', 'OLD') THEN 'RETURNING'
        ELSE 'OTHER'
      END AS user_type,
      ROW_NUMBER() OVER (PARTITION BY s.mri_session_id ORDER BY s.__time ASC) AS rn
    FROM user_interaction.search_details s
    INNER JOIN confirm_sess c ON s.mri_session_id = c.mri_session_id
    CROSS JOIN params p
    WHERE s.__time >= p.t0 AND s.__time < p.t1
      AND s.country = 'IND'
      AND s.os = 'Android'
  ) x
  WHERE rn = 1
),

-- (3) Women SRP flag only for confirm sessions
women_srp_sess AS (
  SELECT DISTINCT ux.mri_session_id
  FROM user_interaction.ui_ux_events ux
  INNER JOIN confirm_sess c ON ux.mri_session_id = c.mri_session_id
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

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

-- (4) Enrich once with flags
enriched AS (
  SELECT
    t.tin,
    t.rb_user_id,
    t.seat_count,
    t.ticket_fare,
    COALESCE(sd.user_type, 'OTHER') AS user_type,
    CASE WHEN w.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS is_women_srp,
    CASE WHEN f.rb_user_id IS NOT NULL AND t.rb_user_id > 0 THEN 1 ELSE 0 END AS is_female_svoc
  FROM platform_txns t
  LEFT JOIN sd0 sd ON t.mri_session_id = sd.mri_session_id
  LEFT JOIN women_srp_sess w ON t.mri_session_id = w.mri_session_id
  LEFT JOIN svoc_female f ON t.rb_user_id = f.rb_user_id
),

-- (5) Light segment explode on already-small confirm set
seg_txns AS (
  SELECT tin, rb_user_id, seat_count, ticket_fare, user_type, 'Platform' AS segment
  FROM enriched

  UNION ALL

  -- Overall Women = Women SRP OR Female SVOC (union)
  SELECT tin, rb_user_id, seat_count, ticket_fare, user_type, 'Overall_Women' AS segment
  FROM enriched
  WHERE is_women_srp = 1 OR is_female_svoc = 1

  UNION ALL

  SELECT tin, rb_user_id, seat_count, ticket_fare, user_type, 'Women_SRP' AS segment
  FROM enriched
  WHERE is_women_srp = 1

  UNION ALL

  SELECT tin, rb_user_id, seat_count, ticket_fare, user_type, 'Female_SVOC' AS segment
  FROM enriched
  WHERE is_female_svoc = 1
),

-- (6) Platform: ALL only | Overall_Women / Women_SRP / Female_SVOC: ALL + NEW + RETURNING
cuts AS (
  SELECT * FROM (VALUES ('ALL'), ('NEW'), ('RETURNING')) AS t(user_type)
),

seg_agg AS (
  SELECT
    s.segment,
    c.user_type,
    COUNT(DISTINCT s.tin) AS txns,
    SUM(COALESCE(s.seat_count, 0)) AS seats,
    SUM(COALESCE(s.ticket_fare, 0)) AS gmv,
    COUNT(DISTINCT s.rb_user_id) AS unique_users,
    SUM(COALESCE(s.ticket_fare, 0)) * 1.0
      / NULLIF(SUM(COALESCE(s.seat_count, 0)), 0) AS asp
  FROM seg_txns s
  CROSS JOIN cuts c
  WHERE
    (s.segment = 'Platform' AND c.user_type = 'ALL')
    OR (
      s.segment IN ('Overall_Women', 'Women_SRP', 'Female_SVOC')
      AND (c.user_type = 'ALL' OR s.user_type = c.user_type)
    )
  GROUP BY 1, 2
)

SELECT
  'TRANSACTION' AS funnel_type,
  s.segment,
  s.user_type,
  '2026-Q2' AS quarter_label,
  s.txns,
  s.seats,
  s.gmv,
  s.unique_users,
  s.asp,
  s.txns * 100.0 / NULLIF(p.txns, 0) AS txn_share_of_platform_pct,
  s.seats * 100.0 / NULLIF(p.seats, 0) AS seat_share_of_platform_pct,
  s.gmv * 100.0 / NULLIF(p.gmv, 0) AS gmv_share_of_platform_pct
FROM seg_agg s
CROSS JOIN (SELECT * FROM seg_agg WHERE segment = 'Platform' AND user_type = 'ALL') p
ORDER BY
  CASE s.segment
    WHEN 'Platform' THEN 1
    WHEN 'Overall_Women' THEN 2
    WHEN 'Female_SVOC' THEN 3
    WHEN 'Women_SRP' THEN 4
    ELSE 5
  END,
  CASE s.user_type
    WHEN 'ALL' THEN 1
    WHEN 'NEW' THEN 2
    WHEN 'RETURNING' THEN 3
    ELSE 4
  END;
