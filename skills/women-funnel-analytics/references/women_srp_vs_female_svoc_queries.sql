-- =============================================================================
-- Women (SRP) vs Female (SVOC) — Android · India BUS
-- Window (7d IST): 2026-09-07 → 2026-09-13
--   UTC: 2026-09-06 18:30:00 → 2026-09-13 18:30:00
--
-- SEGMENTS (side-by-side; overlapping users possible — do not mix denominators):
--   'Women_SRP'     = SRP loaded event_value = 'Women'
--   'Female_SVOC'   = svoc.svoc_booker.gender ∈ (female/f), joined via rb_user_id
--
-- Confirm: transaction.bus_ticket_events event_type=101 AND event_class=2
-- =============================================================================


-- =============================================================================
-- Q1) FUNNEL THROUGHPUT — Overall / Usertype / DBD
--     Women (SRP) vs Female (SVOC)
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1
),
svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),
-- Women SRP sessions
women_srp AS (
  SELECT DISTINCT
    ux.mri_session_id
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
-- Any Android IND BUS SRP loaded session in window (base for SVOC Female attach)
any_srp AS (
  SELECT DISTINCT
    ux.mri_session_id
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
sd0 AS (
  SELECT *
  FROM (
    SELECT
      s.mri_session_id,
      s.rb_user_id,
      s.src_id,
      s.dest_id,
      s.doj,
      CASE
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('GUEST') THEN 'GUEST'
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('NEW') THEN 'NEW'
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('RETURNING', 'EXISTING', 'OLD') THEN 'RETURNING'
        ELSE 'OTHER'
      END AS user_type,
      CASE
        WHEN date_diff('day', CAST(AT_TIMEZONE(s.__time, 'Asia/Kolkata') AS DATE), CAST(s.doj AS DATE)) <= 0 THEN '0'
        WHEN date_diff('day', CAST(AT_TIMEZONE(s.__time, 'Asia/Kolkata') AS DATE), CAST(s.doj AS DATE)) = 1 THEN '1'
        WHEN date_diff('day', CAST(AT_TIMEZONE(s.__time, 'Asia/Kolkata') AS DATE), CAST(s.doj AS DATE)) = 2 THEN '2'
        WHEN date_diff('day', CAST(AT_TIMEZONE(s.__time, 'Asia/Kolkata') AS DATE), CAST(s.doj AS DATE)) = 3 THEN '3'
        WHEN date_diff('day', CAST(AT_TIMEZONE(s.__time, 'Asia/Kolkata') AS DATE), CAST(s.doj AS DATE)) = 4 THEN '4'
        ELSE '5+'
      END AS dbd_bucket,
      ROW_NUMBER() OVER (PARTITION BY s.mri_session_id ORDER BY s.__time ASC) AS rn
    FROM user_interaction.search_details s
    CROSS JOIN params p
    WHERE s.__time >= p.t0 AND s.__time < p.t1
      AND s.country = 'IND'
      AND s.os = 'Android'
      AND s.src_id IS NOT NULL
      AND s.dest_id IS NOT NULL
  ) x
  WHERE rn = 1
),
-- Female SVOC sessions = any SRP session whose user is SVOC female
female_svoc AS (
  SELECT DISTINCT a.mri_session_id
  FROM any_srp a
  INNER JOIN sd0 ON a.mri_session_id = sd0.mri_session_id
  INNER JOIN svoc_female f ON sd0.rb_user_id = f.rb_user_id AND sd0.rb_user_id > 0
),
seg AS (
  SELECT mri_session_id, 'Women_SRP' AS segment FROM women_srp
  UNION ALL
  SELECT mri_session_id, 'Female_SVOC' AS segment FROM female_svoc
),
base AS (
  SELECT
    s.segment,
    s.mri_session_id,
    sd0.user_type,
    sd0.dbd_bucket
  FROM seg s
  INNER JOIN sd0 ON s.mri_session_id = sd0.mri_session_id
),
sl AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.seat_layout_details sl
  CROSS JOIN params p
  WHERE sl.__time >= p.t0 AND sl.__time < p.t1
    AND sl.country = 'IND' AND sl.os = 'Android'
),
ci AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.cust_info_details ci
  CROSS JOIN params p
  WHERE ci.__time >= p.t0 AND ci.__time < p.t1
    AND ci.country = 'IND' AND ci.os = 'Android'
),
tco AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.create_order_details t
  CROSS JOIN params p
  WHERE t.__time >= p.t0 AND t.__time < p.t1
    AND t.country = 'IND' AND t.os = 'Android'
),
pay AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.order_info_details o
  CROSS JOIN params p
  WHERE o.__time >= p.t0 AND o.__time < p.t1
    AND o.country = 'IND' AND o.os = 'Android'
),
conf AS (
  SELECT DISTINCT mri_session_id
  FROM transaction.bus_ticket_events b
  CROSS JOIN params p
  WHERE b.time_of_event >= p.t0 AND b.time_of_event < p.t1
    AND b.country_code = 'IND'
    AND b.event_type = 101
    AND b.event_class = 2
),
funnel_raw AS (
  SELECT
    b.segment,
    b.user_type,
    b.dbd_bucket,
    b.mri_session_id,
    CASE WHEN sl.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_sl,
    CASE WHEN ci.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_ci,
    CASE WHEN tco.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_tco,
    CASE WHEN pay.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_pay,
    CASE WHEN conf.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_conf
  FROM base b
  LEFT JOIN sl   ON b.mri_session_id = sl.mri_session_id
  LEFT JOIN ci   ON b.mri_session_id = ci.mri_session_id
  LEFT JOIN tco  ON b.mri_session_id = tco.mri_session_id
  LEFT JOIN pay  ON b.mri_session_id = pay.mri_session_id
  LEFT JOIN conf ON b.mri_session_id = conf.mri_session_id
)
SELECT
  segment,
  'Overall' AS grain,
  'ALL' AS user_type,
  'ALL' AS dbd_bucket,
  COUNT(DISTINCT mri_session_id) AS srp_sessions,
  COUNT(DISTINCT CASE WHEN has_sl = 1 THEN mri_session_id END) AS sl_sessions,
  COUNT(DISTINCT CASE WHEN has_ci = 1 THEN mri_session_id END) AS ci_sessions,
  COUNT(DISTINCT CASE WHEN has_tco = 1 THEN mri_session_id END) AS tco_sessions,
  COUNT(DISTINCT CASE WHEN has_pay = 1 THEN mri_session_id END) AS payment_sessions,
  COUNT(DISTINCT CASE WHEN has_conf = 1 THEN mri_session_id END) AS confirm_sessions
FROM funnel_raw
GROUP BY 1

UNION ALL
SELECT
  segment,
  'Usertype' AS grain,
  user_type,
  'ALL' AS dbd_bucket,
  COUNT(DISTINCT mri_session_id),
  COUNT(DISTINCT CASE WHEN has_sl = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_ci = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_tco = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_pay = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_conf = 1 THEN mri_session_id END)
FROM funnel_raw
WHERE user_type <> 'OTHER'
GROUP BY 1, 3

UNION ALL
SELECT
  segment,
  'DBD' AS grain,
  'ALL' AS user_type,
  dbd_bucket,
  COUNT(DISTINCT mri_session_id),
  COUNT(DISTINCT CASE WHEN has_sl = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_ci = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_tco = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_pay = 1 THEN mri_session_id END),
  COUNT(DISTINCT CASE WHEN has_conf = 1 THEN mri_session_id END)
FROM funnel_raw
GROUP BY 1, 4

ORDER BY 1, 2, 3, 4;


-- =============================================================================
-- Q2) RETURN RATE (14d of DOI) — Women (SRP) vs Female (SVOC)
--     Search return + Transaction return
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1,
    TIMESTAMP '2026-09-27 18:30:00' AS t_ret
),
svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),
-- Women_SRP bookers: first confirm in window on a Women SRP session
women_bookings AS (
  SELECT
    bte.rb_user_id,
    bte.time_of_event AS doi_ts,
    ROW_NUMBER() OVER (PARTITION BY bte.rb_user_id ORDER BY bte.time_of_event) AS rn
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  CROSS JOIN params p
  WHERE bte.time_of_event >= p.t0 AND bte.time_of_event < p.t1
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND bte.rb_user_id > 0
    AND ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value = 'Women'
),
-- Female_SVOC bookers: first confirm in window for SVOC female users (Android)
female_bookings AS (
  SELECT
    bte.rb_user_id,
    bte.time_of_event AS doi_ts,
    ROW_NUMBER() OVER (PARTITION BY bte.rb_user_id ORDER BY bte.time_of_event) AS rn
  FROM transaction.bus_ticket_events bte
  INNER JOIN svoc_female f ON bte.rb_user_id = f.rb_user_id
  CROSS JOIN params p
  WHERE bte.time_of_event >= p.t0 AND bte.time_of_event < p.t1
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND bte.rb_user_id > 0
),
seg AS (
  SELECT rb_user_id, doi_ts, 'Women_SRP' AS segment
  FROM women_bookings WHERE rn = 1
  UNION ALL
  SELECT rb_user_id, doi_ts, 'Female_SVOC' AS segment
  FROM female_bookings WHERE rn = 1
)
SELECT
  s.segment,
  COUNT(DISTINCT s.rb_user_id) AS bookers,
  COUNT(DISTINCT CASE WHEN rs.rb_user_id IS NOT NULL THEN s.rb_user_id END) AS return_search_users_14d,
  COUNT(DISTINCT CASE WHEN rt.rb_user_id IS NOT NULL THEN s.rb_user_id END) AS return_txn_users_14d,
  COUNT(DISTINCT CASE
    WHEN rs.rb_user_id IS NOT NULL OR rt.rb_user_id IS NOT NULL THEN s.rb_user_id
  END) AS either_return_users_14d,
  COUNT(DISTINCT CASE WHEN rs.rb_user_id IS NOT NULL THEN s.rb_user_id END) * 100.0
    / NULLIF(COUNT(DISTINCT s.rb_user_id), 0) AS search_return_rate_pct,
  COUNT(DISTINCT CASE WHEN rt.rb_user_id IS NOT NULL THEN s.rb_user_id END) * 100.0
    / NULLIF(COUNT(DISTINCT s.rb_user_id), 0) AS txn_return_rate_pct
FROM seg s
CROSS JOIN params p
LEFT JOIN user_interaction.search_details rs
  ON rs.rb_user_id = s.rb_user_id
 AND rs.__time > s.doi_ts
 AND rs.__time <= s.doi_ts + INTERVAL '14' DAY
 AND rs.__time >= p.t0 AND rs.__time < p.t_ret
 AND rs.country = 'IND'
 AND rs.os = 'Android'
LEFT JOIN transaction.bus_ticket_events rt
  ON rt.rb_user_id = s.rb_user_id
 AND rt.time_of_event > s.doi_ts
 AND rt.time_of_event <= s.doi_ts + INTERVAL '14' DAY
 AND rt.time_of_event >= p.t0 AND rt.time_of_event < p.t_ret
 AND rt.country_code = 'IND'
 AND rt.event_type = 101
 AND rt.event_class = 2
GROUP BY 1
ORDER BY 1;


-- =============================================================================
-- Q3a) FILTER COVERAGE — Sort&Filter + Contextual
--     Women (SRP) vs Female (SVOC)
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
),
sess_user AS (
  SELECT s.mri_session_id, MAX(s.rb_user_id) AS rb_user_id
  FROM user_interaction.search_details s
  CROSS JOIN params p
  WHERE s.__time >= p.t0 AND s.__time < p.t1
    AND s.country = 'IND' AND s.os = 'Android'
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
filt AS (
  SELECT
    f.mri_session_id,
    f.event_name AS filter_surface
  FROM user_interaction.ui_ux_events f
  CROSS JOIN params p
  WHERE f.__time >= p.t0 AND f.__time < p.t1
    AND f.event_src = 'Android'
    AND f.header_country = 'IND' AND f.header_bu = 'BUS' AND f.selected_country = 'India'
    AND f.event_group = 'srp_filter_event'
    AND (
      f.event_name = 'sort_and_filter'
      OR (f.event_name = 'contextual' AND f.event_value = 'Clicked')
    )
)
SELECT
  s.segment,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT CASE WHEN f.filter_surface = 'sort_and_filter' THEN f.mri_session_id END) AS sort_filter_sessions,
  COUNT(DISTINCT CASE WHEN f.filter_surface = 'contextual' THEN f.mri_session_id END) AS contextual_sessions,
  COUNT(DISTINCT f.mri_session_id) AS any_sort_or_contextual_sessions
FROM seg s
LEFT JOIN filt f ON s.mri_session_id = f.mri_session_id
GROUP BY 1
ORDER BY 1;


-- =============================================================================
-- Q3b) FILTER TYPES USED — Sort&Filter + Contextual detail
--     Women (SRP) vs Female (SVOC)
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
),
sess_user AS (
  SELECT s.mri_session_id, MAX(s.rb_user_id) AS rb_user_id
  FROM user_interaction.search_details s
  CROSS JOIN params p
  WHERE s.__time >= p.t0 AND s.__time < p.t1
    AND s.country = 'IND' AND s.os = 'Android'
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
filt AS (
  SELECT
    f.mri_session_id,
    f.event_name AS filter_surface,
    COALESCE(
      NULLIF(TRIM(f.filter_type), ''),
      NULLIF(TRIM(f.filter_applied), ''),
      NULLIF(TRIM(f.event_value), ''),
      'UNKNOWN'
    ) AS filter_detail
  FROM user_interaction.ui_ux_events f
  CROSS JOIN params p
  WHERE f.__time >= p.t0 AND f.__time < p.t1
    AND f.event_src = 'Android'
    AND f.header_country = 'IND' AND f.header_bu = 'BUS' AND f.selected_country = 'India'
    AND f.event_group = 'srp_filter_event'
    AND (
      f.event_name = 'sort_and_filter'
      OR (f.event_name = 'contextual' AND f.event_value = 'Clicked')
    )
)
SELECT
  s.segment,
  f.filter_surface,
  f.filter_detail,
  COUNT(DISTINCT f.mri_session_id) AS filter_sessions
FROM seg s
INNER JOIN filt f ON s.mri_session_id = f.mri_session_id
GROUP BY 1, 2, 3
ORDER BY 1, 2, 4 DESC;


-- =============================================================================
-- Q4) NEW-TO-ROUTE FUNNEL — Women (SRP) vs Female (SVOC)
--     New-to-route = no prior confirm on same src-dest before this search
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1,
    TIMESTAMP '2025-09-06 18:30:00' AS hist0
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
),
sd0 AS (
  SELECT *
  FROM (
    SELECT
      s.mri_session_id,
      s.rb_user_id,
      s.src_id,
      s.dest_id,
      s.__time AS sd_ts,
      ROW_NUMBER() OVER (PARTITION BY s.mri_session_id ORDER BY s.__time ASC) AS rn
    FROM user_interaction.search_details s
    CROSS JOIN params p
    WHERE s.__time >= p.t0 AND s.__time < p.t1
      AND s.country = 'IND' AND s.os = 'Android'
      AND s.src_id IS NOT NULL AND s.dest_id IS NOT NULL
      AND s.rb_user_id > 0
  ) x
  WHERE rn = 1
),
female_svoc AS (
  SELECT DISTINCT a.mri_session_id
  FROM any_srp a
  INNER JOIN sd0 ON a.mri_session_id = sd0.mri_session_id
  INNER JOIN svoc_female f ON sd0.rb_user_id = f.rb_user_id
),
cand AS (
  SELECT mri_session_id, 'Women_SRP' AS segment FROM women_srp
  UNION ALL
  SELECT mri_session_id, 'Female_SVOC' AS segment FROM female_svoc
),
ntr AS (
  SELECT
    c.segment,
    c.mri_session_id,
    sd0.rb_user_id,
    sd0.src_id,
    sd0.dest_id,
    sd0.sd_ts,
    CASE
      WHEN EXISTS (
        SELECT 1
        FROM transaction.bus_ticket_events b
        CROSS JOIN params p
        WHERE b.rb_user_id = sd0.rb_user_id
          AND b.source_location_id = sd0.src_id
          AND b.destination_location_id = sd0.dest_id
          AND b.time_of_event >= p.hist0
          AND b.time_of_event < sd0.sd_ts
          AND b.country_code = 'IND'
          AND b.event_type = 101
          AND b.event_class = 2
      ) THEN 0 ELSE 1
    END AS is_new_to_route
  FROM cand c
  INNER JOIN sd0 ON c.mri_session_id = sd0.mri_session_id
),
base AS (
  SELECT segment, mri_session_id
  FROM ntr
  WHERE is_new_to_route = 1
),
sl AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.seat_layout_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
ci AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.cust_info_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
tco AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.create_order_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
pay AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.order_info_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
conf AS (
  SELECT DISTINCT mri_session_id FROM transaction.bus_ticket_events
  CROSS JOIN params p
  WHERE time_of_event >= p.t0 AND time_of_event < p.t1
    AND country_code = 'IND' AND event_type = 101 AND event_class = 2
)
SELECT
  b.segment,
  COUNT(DISTINCT b.mri_session_id) AS ntr_srp_sessions,
  COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
  COUNT(DISTINCT ci.mri_session_id) AS ci_sessions,
  COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
  COUNT(DISTINCT pay.mri_session_id) AS payment_sessions,
  COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions
FROM base b
LEFT JOIN sl   ON b.mri_session_id = sl.mri_session_id
LEFT JOIN ci   ON b.mri_session_id = ci.mri_session_id
LEFT JOIN tco  ON b.mri_session_id = tco.mri_session_id
LEFT JOIN pay  ON b.mri_session_id = pay.mri_session_id
LEFT JOIN conf ON b.mri_session_id = conf.mri_session_id
GROUP BY 1
ORDER BY 1;


-- =============================================================================
-- Q4b) SAME-ROUTE FUNNEL — Women (SRP) vs Female (SVOC)
--     Same-route = HAS prior confirm (BTE 101/2) on same src-dest before this search
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1,
    TIMESTAMP '2025-09-06 18:30:00' AS hist0
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
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
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
),
sd0 AS (
  SELECT *
  FROM (
    SELECT
      s.mri_session_id,
      s.rb_user_id,
      s.src_id,
      s.dest_id,
      s.__time AS sd_ts,
      ROW_NUMBER() OVER (PARTITION BY s.mri_session_id ORDER BY s.__time ASC) AS rn
    FROM user_interaction.search_details s
    CROSS JOIN params p
    WHERE s.__time >= p.t0 AND s.__time < p.t1
      AND s.country = 'IND' AND s.os = 'Android'
      AND s.src_id IS NOT NULL AND s.dest_id IS NOT NULL
      AND s.rb_user_id > 0
  ) x
  WHERE rn = 1
),
female_svoc AS (
  SELECT DISTINCT a.mri_session_id
  FROM any_srp a
  INNER JOIN sd0 ON a.mri_session_id = sd0.mri_session_id
  INNER JOIN svoc_female f ON sd0.rb_user_id = f.rb_user_id
),
cand AS (
  SELECT mri_session_id, 'Women_SRP' AS segment FROM women_srp
  UNION ALL
  SELECT mri_session_id, 'Female_SVOC' AS segment FROM female_svoc
),
route_flag AS (
  SELECT
    c.segment,
    c.mri_session_id,
    CASE
      WHEN EXISTS (
        SELECT 1
        FROM transaction.bus_ticket_events b
        CROSS JOIN params p
        WHERE b.rb_user_id = sd0.rb_user_id
          AND b.source_location_id = sd0.src_id
          AND b.destination_location_id = sd0.dest_id
          AND b.time_of_event >= p.hist0
          AND b.time_of_event < sd0.sd_ts
          AND b.country_code = 'IND'
          AND b.event_type = 101
          AND b.event_class = 2
      ) THEN 1 ELSE 0
    END AS is_same_route
  FROM cand c
  INNER JOIN sd0 ON c.mri_session_id = sd0.mri_session_id
),
base AS (
  SELECT segment, mri_session_id
  FROM route_flag
  WHERE is_same_route = 1
),
sl AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.seat_layout_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
ci AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.cust_info_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
tco AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.create_order_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
pay AS (
  SELECT DISTINCT mri_session_id FROM user_interaction.order_info_details
  CROSS JOIN params p
  WHERE __time >= p.t0 AND __time < p.t1 AND country = 'IND' AND os = 'Android'
),
conf AS (
  SELECT DISTINCT mri_session_id FROM transaction.bus_ticket_events
  CROSS JOIN params p
  WHERE time_of_event >= p.t0 AND time_of_event < p.t1
    AND country_code = 'IND' AND event_type = 101 AND event_class = 2
)
SELECT
  b.segment,
  COUNT(DISTINCT b.mri_session_id) AS same_route_srp_sessions,
  COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
  COUNT(DISTINCT ci.mri_session_id) AS ci_sessions,
  COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
  COUNT(DISTINCT pay.mri_session_id) AS payment_sessions,
  COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions
FROM base b
LEFT JOIN sl   ON b.mri_session_id = sl.mri_session_id
LEFT JOIN ci   ON b.mri_session_id = ci.mri_session_id
LEFT JOIN tco  ON b.mri_session_id = tco.mri_session_id
LEFT JOIN pay  ON b.mri_session_id = pay.mri_session_id
LEFT JOIN conf ON b.mri_session_id = conf.mri_session_id
GROUP BY 1
ORDER BY 1;


-- =============================================================================
-- Q5) CANCELLATION RATE + TIME BEFORE DEPARTURE
--     Women (SRP) vs Female (SVOC)
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1,
    TIMESTAMP '2026-10-13 18:30:00' AS t_cancel
),
svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),
women_txns AS (
  SELECT DISTINCT
    bte.tin,
    bte.date_of_journey AS doj_ts
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  CROSS JOIN params p
  WHERE bte.time_of_event >= p.t0 AND bte.time_of_event < p.t1
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND bte.tin IS NOT NULL
    AND ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value = 'Women'
),
female_txns AS (
  SELECT DISTINCT
    bte.tin,
    bte.date_of_journey AS doj_ts
  FROM transaction.bus_ticket_events bte
  INNER JOIN svoc_female f ON bte.rb_user_id = f.rb_user_id
  CROSS JOIN params p
  WHERE bte.time_of_event >= p.t0 AND bte.time_of_event < p.t1
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND bte.tin IS NOT NULL
    AND bte.rb_user_id > 0
),
confirmed AS (
  SELECT tin, doj_ts, 'Women_SRP' AS segment FROM women_txns
  UNION ALL
  SELECT tin, doj_ts, 'Female_SVOC' AS segment FROM female_txns
),
cancels AS (
  SELECT
    bc.tin,
    COALESCE(bc.cancellation_date_time, bc.time_of_event) AS cancel_ts,
    ROW_NUMBER() OVER (
      PARTITION BY bc.tin
      ORDER BY COALESCE(bc.cancellation_date_time, bc.time_of_event) DESC
    ) AS rn
  FROM transaction.bus_cancellation_events bc
  CROSS JOIN params p
  WHERE COALESCE(bc.cancellation_date_time, bc.time_of_event) >= p.t0
    AND COALESCE(bc.cancellation_date_time, bc.time_of_event) < p.t_cancel
    AND bc.country_code = 'IND'
),
tagged AS (
  SELECT
    c.segment,
    c.tin,
    c.doj_ts,
    k.cancel_ts,
    CASE WHEN k.cancel_ts IS NOT NULL THEN 1 ELSE 0 END AS is_cancelled,
    CASE
      WHEN k.cancel_ts IS NULL THEN NULL
      ELSE date_diff('hour', k.cancel_ts, c.doj_ts)
    END AS hours_before_doj
  FROM confirmed c
  LEFT JOIN cancels k ON c.tin = k.tin AND k.rn = 1
)
SELECT
  segment,
  COUNT(DISTINCT tin) AS confirmed_txns,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 THEN tin END) AS cancelled_txns,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 THEN tin END) * 100.0
    / NULLIF(COUNT(DISTINCT tin), 0) AS cancel_rate_pct,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj < 6 THEN tin END) AS cancel_lt_6h,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 6 AND hours_before_doj < 24 THEN tin END) AS cancel_6_24h,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 24 AND hours_before_doj < 72 THEN tin END) AS cancel_1_3d,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 72 AND hours_before_doj < 168 THEN tin END) AS cancel_3_7d,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 168 THEN tin END) AS cancel_7d_plus,
  AVG(CASE WHEN is_cancelled = 1 THEN CAST(hours_before_doj AS DOUBLE) END) AS avg_hours_before_doj
FROM tagged
GROUP BY 1
ORDER BY 1;
