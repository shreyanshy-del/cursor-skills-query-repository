-- =============================================================================
-- Q1: Funnel Throughputs (14 days) — DBD × user_type
-- Android IND | Mehar destination mapping via dest_ids
-- Window: 24 Aug 2026 – 6 Sep 2026 (IST calendar days)
--
-- Funnel: SRP → SL → CustInfo → TCO → PaymentLand → Confirm
-- Forward CR (sessions) ≈ confirmsession / srpload  (or tin / srpload)
-- DBD = Days Before Departure = DOJ − DOI (search day IST)
-- =============================================================================
-- Swap dest_ids: paste from _tier_analysis_{tier}_executed.sql city_tier_dest_ids
--   Tier1 / Tier2 / Pilgrim / Leisure / Tier3 / OVERALL (union of mapped ids)
-- =============================================================================

WITH dest_ids AS (
  SELECT dest_id FROM (VALUES
    (122),(123),(124),(126),(130),(141),(313),(462),(551),(733),(807),(933),
    (1073),(1304),(1429),(70015),(70633),(71145),(74820),(76397),(82100),
    (94113),(95174),(201126),(201665),(215450)
  ) AS t(dest_id)  -- <-- Tier 1 example; replace for other tiers / OVERALL
),
srp_deduped AS (
  SELECT DISTINCT
    s.mri_session_id,
    s.route_id,
    s.rb_user_id,
    UPPER(TRIM(COALESCE(s.user_type, ''))) AS user_type,
    s.os,
    s.channel,
    s.src_id,
    s.dest_id,
    s.doj,
    CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE) AS doi,
    CASE
      WHEN DATE_DIFF('day', CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE), CAST(s.doj AS DATE)) <= 0
        THEN '0. Same Day'
      WHEN DATE_DIFF('day', CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE), CAST(s.doj AS DATE)) = 1
        THEN '1. DBD 1'
      WHEN DATE_DIFF('day', CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE), CAST(s.doj AS DATE)) = 2
        THEN '2. DBD 2'
      WHEN DATE_DIFF('day', CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE), CAST(s.doj AS DATE)) BETWEEN 3 AND 7
        THEN '3. DBD 3-7'
      ELSE '4. DBD 8+'
    END AS dbd
  FROM user_interaction.search_route_details s
  INNER JOIN dest_ids d ON s.dest_id = d.dest_id
  WHERE s.__time >= TIMESTAMP '2026-08-23 18:30:00'   -- IST 24 Aug 00:00
    AND s.__time <  TIMESTAMP '2026-09-06 18:30:00'   -- IST 7 Sep 00:00
    AND s.country = 'IND'
    AND s.os = 'Android'
    AND s.channel = 'MOBILE_APP'
    AND s.status = 200
    AND s.mri_session_id IS NOT NULL
),
sl_deduped AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.seat_layout_details
  WHERE __time >= TIMESTAMP '2026-08-23 18:30:00'
    AND __time <  TIMESTAMP '2026-09-06 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
mpax_deduped AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.cust_info_details
  WHERE __time >= TIMESTAMP '2026-08-23 18:30:00'
    AND __time <  TIMESTAMP '2026-09-06 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
tco_deduped AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.create_order_details
  WHERE __time >= TIMESTAMP '2026-08-23 18:30:00'
    AND __time <  TIMESTAMP '2026-09-06 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
orderinfo_deduped AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.order_info_details
  WHERE __time >= TIMESTAMP '2026-08-23 18:30:00'
    AND __time <  TIMESTAMP '2026-09-06 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
confirm_deduped AS (
  SELECT
    mri_session_id,
    route_id,
    COUNT(DISTINCT tin) AS tin_count
  FROM user_interaction.confirm_order_details
  WHERE __time >= TIMESTAMP '2026-08-23 18:30:00'
    AND __time <  TIMESTAMP '2026-09-06 18:30:00'
    AND country = 'IND'
    AND status = 200
    AND tin IS NOT NULL
    AND tin NOT IN ('', 'null')
  GROUP BY 1, 2
)
SELECT
  srp.doi,
  srp.dbd,
  srp.user_type,
  COUNT(DISTINCT srp.mri_session_id) AS srpload,
  COUNT(DISTINCT sl.mri_session_id) AS slload,
  COUNT(DISTINCT pax.mri_session_id) AS custinfo_sessions,
  COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
  COUNT(DISTINCT oi.mri_session_id) AS payment_land_sessions,
  COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions,
  COALESCE(SUM(conf.tin_count), 0) AS tin,
  ROUND(100.0 * COUNT(DISTINCT conf.mri_session_id)
        / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS forward_cr_session_pct,
  ROUND(100.0 * COALESCE(SUM(conf.tin_count), 0)
        / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS forward_cr_tin_per_srp_pct
FROM srp_deduped srp
LEFT JOIN sl_deduped sl
  ON srp.mri_session_id = sl.mri_session_id AND srp.route_id = sl.route_id
LEFT JOIN mpax_deduped pax
  ON srp.mri_session_id = pax.mri_session_id AND srp.route_id = pax.route_id
LEFT JOIN tco_deduped tco
  ON srp.mri_session_id = tco.mri_session_id AND srp.route_id = tco.route_id
LEFT JOIN orderinfo_deduped oi
  ON srp.mri_session_id = oi.mri_session_id AND srp.route_id = oi.route_id
LEFT JOIN confirm_deduped conf
  ON srp.mri_session_id = conf.mri_session_id AND srp.route_id = conf.route_id
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;
