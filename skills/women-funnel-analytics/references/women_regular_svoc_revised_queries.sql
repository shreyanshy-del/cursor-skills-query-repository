-- =============================================================================
-- REVISED Women / Regular / SVOC Gender Analytics — Android · India BUS
-- Window (last 7 complete IST days): 2026-09-07 → 2026-09-13
--   UTC: 2026-09-06 18:30:00 → 2026-09-13 18:30:00
-- Return / cancel lookforward: +14d / +30d as noted per query
--
-- SEGMENT FAMILIES (use side-by-side; do not mix in one denominator):
--   A) SRP_WomenRegular  = ui_ux_events SRP loaded event_value IN ('Women','Regular')
--   B) SVOC_Gender       = svoc.svoc_booker.gender → Male / Female
--        join key: search_details.rb_user_id = TRY_CAST(svoc_booker.rb_userid AS BIGINT)
--
-- Usertype: normalized from search_details.user_type → GUEST / NEW / RETURNING
-- DBD: date_diff(day, search IST date, doj) → 0,1,2,3,4,5+
-- Confirm: transaction.bus_ticket_events event_type=101 AND event_class=2
-- =============================================================================


-- =============================================================================
-- Q1) FUNNEL THROUGHPUT — Overall / Usertype / DBD
--     Cuts: Women vs Regular  AND  Male vs Female (SVOC)
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
      WHEN LOWER(gender) IN ('male', 'm') THEN 'Male'
      WHEN LOWER(gender) IN ('female', 'f') THEN 'Female'
      ELSE NULL
    END AS svoc_gender
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('male', 'm', 'female', 'f')
),
srp AS (
  SELECT
    ux.mri_session_id,
    ux.event_value AS srp_cohort,          -- Women | Regular
    ux.usertype AS ux_usertype,
    ux.__time AS srp_ts
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
-- first search_details per session → DBD, usertype, rb_user_id, SD
sd0 AS (
  SELECT *
  FROM (
    SELECT
      s.mri_session_id,
      s.rb_user_id,
      s.src_id,
      s.dest_id,
      s.doj,
      s.__time AS sd_ts,
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
base AS (
  SELECT
    srp.mri_session_id,
    srp.srp_cohort,
    sd0.user_type,
    sd0.dbd_bucket,
    sd0.rb_user_id,
    sd0.src_id,
    sd0.dest_id,
    v.svoc_gender
  FROM srp
  INNER JOIN sd0 ON srp.mri_session_id = sd0.mri_session_id
  LEFT JOIN svoc v ON sd0.rb_user_id = v.rb_user_id AND sd0.rb_user_id > 0
),
-- explode to two segment families
seg AS (
  SELECT
    mri_session_id,
    'SRP_WomenRegular' AS segment_family,
    srp_cohort AS segment,
    user_type,
    dbd_bucket
  FROM base
  UNION ALL
  SELECT
    mri_session_id,
    'SVOC_Gender' AS segment_family,
    svoc_gender AS segment,
    user_type,
    dbd_bucket
  FROM base
  WHERE svoc_gender IS NOT NULL
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
    s.segment_family,
    s.segment,
    s.user_type,
    s.dbd_bucket,
    s.mri_session_id,
    CASE WHEN sl.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_sl,
    CASE WHEN ci.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_ci,
    CASE WHEN tco.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_tco,
    CASE WHEN pay.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_pay,
    CASE WHEN conf.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS has_conf
  FROM seg s
  LEFT JOIN sl   ON s.mri_session_id = sl.mri_session_id
  LEFT JOIN ci   ON s.mri_session_id = ci.mri_session_id
  LEFT JOIN tco  ON s.mri_session_id = tco.mri_session_id
  LEFT JOIN pay  ON s.mri_session_id = pay.mri_session_id
  LEFT JOIN conf ON s.mri_session_id = conf.mri_session_id
)
-- Overall
SELECT
  segment_family,
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
GROUP BY 1, 2

UNION ALL
-- Usertype
SELECT
  segment_family,
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
GROUP BY 1, 2, 4

UNION ALL
-- DBD
SELECT
  segment_family,
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
GROUP BY 1, 2, 5

ORDER BY 1, 2, 3, 4, 5;


-- =============================================================================
-- Q2) RETURN RATE within 14d of DOI
--     a) Search return (any search_details after DOI within 14d)
--     b) Transaction return (confirm BTE after DOI within 14d)
--     Cuts: Women/Regular  AND  Male/Female (SVOC)
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1,
    TIMESTAMP '2026-09-27 18:30:00' AS t_ret   -- +14d lookforward
),
svoc AS (
  SELECT
    TRY_CAST(rb_userid AS BIGINT) AS rb_user_id,
    CASE
      WHEN LOWER(gender) IN ('male', 'm') THEN 'Male'
      WHEN LOWER(gender) IN ('female', 'f') THEN 'Female'
      ELSE NULL
    END AS svoc_gender
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('male', 'm', 'female', 'f')
),
-- first confirmed booking in window, tagged by SRP Women/Regular on same session
bookings AS (
  SELECT
    bte.rb_user_id,
    bte.tin,
    bte.mri_session_id,
    bte.time_of_event AS doi_ts,
    CAST(AT_TIMEZONE(bte.time_of_event, 'Asia/Kolkata') AS DATE) AS doi_ist,
    ux.event_value AS srp_cohort,
    ROW_NUMBER() OVER (
      PARTITION BY bte.rb_user_id, ux.event_value
      ORDER BY bte.time_of_event
    ) AS rn_srp
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
    AND ux.event_value IN ('Women', 'Regular')
),
first_b AS (
  SELECT b.*, v.svoc_gender
  FROM bookings b
  LEFT JOIN svoc v ON b.rb_user_id = v.rb_user_id
  WHERE b.rn_srp = 1
),
seg AS (
  SELECT rb_user_id, tin, doi_ts, 'SRP_WomenRegular' AS segment_family, srp_cohort AS segment
  FROM first_b
  UNION ALL
  SELECT rb_user_id, tin, doi_ts, 'SVOC_Gender', svoc_gender
  FROM first_b
  WHERE svoc_gender IS NOT NULL
)
SELECT
  s.segment_family,
  s.segment,
  COUNT(DISTINCT s.rb_user_id) AS bookers,
  COUNT(DISTINCT CASE
    WHEN rs.rb_user_id IS NOT NULL THEN s.rb_user_id
  END) AS return_search_users_14d,
  COUNT(DISTINCT CASE
    WHEN rt.rb_user_id IS NOT NULL THEN s.rb_user_id
  END) AS return_txn_users_14d,
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
GROUP BY 1, 2
ORDER BY 1, 2;


-- =============================================================================
-- Q3) FILTER USAGE — Sort&Filter + Contextual
--     a) Coverage vs SRP
--     b) Type of filter used (filter_type / filter_applied / event_value)
--     Cuts: Women/Regular  AND  Male/Female (SVOC)
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
      WHEN LOWER(gender) IN ('male', 'm') THEN 'Male'
      WHEN LOWER(gender) IN ('female', 'f') THEN 'Female'
      ELSE NULL
    END AS svoc_gender
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('male', 'm', 'female', 'f')
),
srp AS (
  SELECT DISTINCT
    ux.mri_session_id,
    ux.event_value AS srp_cohort
  FROM user_interaction.ui_ux_events ux
  CROSS JOIN params p
  WHERE ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
),
sess_user AS (
  SELECT
    s.mri_session_id,
    MAX(s.rb_user_id) AS rb_user_id
  FROM user_interaction.search_details s
  INNER JOIN srp ON s.mri_session_id = srp.mri_session_id
  CROSS JOIN params p
  WHERE s.__time >= p.t0 AND s.__time < p.t1
    AND s.country = 'IND' AND s.os = 'Android'
  GROUP BY 1
),
base AS (
  SELECT
    srp.mri_session_id,
    srp.srp_cohort,
    v.svoc_gender
  FROM srp
  LEFT JOIN sess_user su ON srp.mri_session_id = su.mri_session_id
  LEFT JOIN svoc v ON su.rb_user_id = v.rb_user_id AND su.rb_user_id > 0
),
seg AS (
  SELECT mri_session_id, 'SRP_WomenRegular' AS segment_family, srp_cohort AS segment FROM base
  UNION ALL
  SELECT mri_session_id, 'SVOC_Gender', svoc_gender FROM base WHERE svoc_gender IS NOT NULL
),
filt AS (
  SELECT
    f.mri_session_id,
    f.event_name AS filter_surface,   -- sort_and_filter | contextual
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
-- Q3a coverage
SELECT
  'coverage' AS result_type,
  s.segment_family,
  s.segment,
  CAST(NULL AS VARCHAR) AS filter_surface,
  CAST(NULL AS VARCHAR) AS filter_detail,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT CASE WHEN f.filter_surface = 'sort_and_filter' THEN f.mri_session_id END) AS sort_filter_sessions,
  COUNT(DISTINCT CASE WHEN f.filter_surface = 'contextual' THEN f.mri_session_id END) AS contextual_sessions,
  COUNT(DISTINCT f.mri_session_id) AS any_sort_or_contextual_sessions
FROM seg s
LEFT JOIN filt f ON s.mri_session_id = f.mri_session_id
GROUP BY 1, 2, 3

UNION ALL
-- Q3b type of filter used (top detail per surface)
SELECT
  'filter_type' AS result_type,
  s.segment_family,
  s.segment,
  f.filter_surface,
  f.filter_detail,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions_in_segment,  -- not SRP denom; sessions with this filter
  COUNT(DISTINCT f.mri_session_id) AS filter_sessions,
  CAST(NULL AS BIGINT) AS contextual_sessions,
  CAST(NULL AS BIGINT) AS any_sort_or_contextual_sessions
FROM seg s
INNER JOIN filt f ON s.mri_session_id = f.mri_session_id
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, filter_sessions DESC NULLS LAST;


-- =============================================================================
-- Q4) NEW-TO-ROUTE FUNNEL
--     New-to-route = no prior confirm (BTE 101/2) on same src-dest for that user
--                   before this session's first search_details time
--     Funnels: Women vs Regular (SRP)  AND  SVOC Female vs Male
--     (also keeps Regular SRP as generic baseline)
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1,
    TIMESTAMP '2025-09-06 18:30:00' AS hist0   -- 1y lookback for prior bookings
),
svoc AS (
  SELECT
    TRY_CAST(rb_userid AS BIGINT) AS rb_user_id,
    CASE
      WHEN LOWER(gender) IN ('male', 'm') THEN 'Male'
      WHEN LOWER(gender) IN ('female', 'f') THEN 'Female'
      ELSE NULL
    END AS svoc_gender
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('male', 'm', 'female', 'f')
),
srp AS (
  SELECT DISTINCT
    ux.mri_session_id,
    ux.event_value AS srp_cohort
  FROM user_interaction.ui_ux_events ux
  CROSS JOIN params p
  WHERE ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
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
ntr AS (
  SELECT
    srp.mri_session_id,
    srp.srp_cohort,
    sd0.rb_user_id,
    sd0.src_id,
    sd0.dest_id,
    sd0.sd_ts,
    v.svoc_gender,
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
  FROM srp
  INNER JOIN sd0 ON srp.mri_session_id = sd0.mri_session_id
  LEFT JOIN svoc v ON sd0.rb_user_id = v.rb_user_id
),
base AS (
  SELECT * FROM ntr WHERE is_new_to_route = 1
),
seg AS (
  SELECT mri_session_id, 'SRP_WomenRegular' AS segment_family, srp_cohort AS segment FROM base
  UNION ALL
  SELECT mri_session_id, 'SVOC_Gender', svoc_gender FROM base WHERE svoc_gender IS NOT NULL
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
  s.segment_family,
  s.segment,
  COUNT(DISTINCT s.mri_session_id) AS ntr_srp_sessions,
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
GROUP BY 1, 2
ORDER BY 1, 2;


-- =============================================================================
-- Q5) CANCELLATION RATE + TIME BEFORE DEPARTURE
--     Base: confirmed Android tickets in window tagged Women/Regular (SRP session)
--           and SVOC Male/Female
--     Cancel: transaction.bus_cancellation_events (by tin), up to +30d
--     Hours before DOJ buckets
-- =============================================================================
WITH params AS (
  SELECT
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-13 18:30:00' AS t1,
    TIMESTAMP '2026-10-13 18:30:00' AS t_cancel   -- +30d cancel lookforward
),
svoc AS (
  SELECT
    TRY_CAST(rb_userid AS BIGINT) AS rb_user_id,
    CASE
      WHEN LOWER(gender) IN ('male', 'm') THEN 'Male'
      WHEN LOWER(gender) IN ('female', 'f') THEN 'Female'
      ELSE NULL
    END AS svoc_gender
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('male', 'm', 'female', 'f')
),
confirmed AS (
  SELECT
    bte.tin,
    bte.rb_user_id,
    bte.mri_session_id,
    bte.time_of_event AS doi_ts,
    bte.date_of_journey AS doj_ts,
    ux.event_value AS srp_cohort,
    v.svoc_gender
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  LEFT JOIN svoc v ON bte.rb_user_id = v.rb_user_id AND bte.rb_user_id > 0
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
    AND ux.event_value IN ('Women', 'Regular')
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
    c.tin,
    c.srp_cohort,
    c.svoc_gender,
    c.doj_ts,
    k.cancel_ts,
    CASE WHEN k.cancel_ts IS NOT NULL THEN 1 ELSE 0 END AS is_cancelled,
    CASE
      WHEN k.cancel_ts IS NULL THEN NULL
      ELSE date_diff('hour', k.cancel_ts, c.doj_ts)
    END AS hours_before_doj
  FROM confirmed c
  LEFT JOIN cancels k ON c.tin = k.tin AND k.rn = 1
),
seg AS (
  SELECT tin, is_cancelled, hours_before_doj, 'SRP_WomenRegular' AS segment_family, srp_cohort AS segment
  FROM tagged
  UNION ALL
  SELECT tin, is_cancelled, hours_before_doj, 'SVOC_Gender', svoc_gender
  FROM tagged
  WHERE svoc_gender IS NOT NULL
)
SELECT
  segment_family,
  segment,
  COUNT(DISTINCT tin) AS confirmed_txns,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 THEN tin END) AS cancelled_txns,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 THEN tin END) * 100.0
    / NULLIF(COUNT(DISTINCT tin), 0) AS cancel_rate_pct,
  -- time-before-departure mix among cancelled
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj < 6 THEN tin END) AS cancel_lt_6h,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 6 AND hours_before_doj < 24 THEN tin END) AS cancel_6_24h,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 24 AND hours_before_doj < 72 THEN tin END) AS cancel_1_3d,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 72 AND hours_before_doj < 168 THEN tin END) AS cancel_3_7d,
  COUNT(DISTINCT CASE WHEN is_cancelled = 1 AND hours_before_doj >= 168 THEN tin END) AS cancel_7d_plus,
  AVG(CASE WHEN is_cancelled = 1 THEN CAST(hours_before_doj AS DOUBLE) END) AS avg_hours_before_doj
FROM seg
GROUP BY 1, 2
ORDER BY 1, 2;
