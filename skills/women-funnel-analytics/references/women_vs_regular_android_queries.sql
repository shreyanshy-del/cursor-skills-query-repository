-- =============================================================================
-- Women vs Regular (SRP loaded) — Android · India BUS
-- Window (7d IST): 2026-08-30 → 2026-09-05  = UTC 2026-08-29 18:30 → 2026-09-05 18:30
-- Cohort: ui_ux_events
--   event_group = 'srp_click_event'
--   event_name  = 'SRP loaded'
--   event_value IN ('Women', 'Regular')
--   event_src   = 'Android'
-- City / SD / DOJ: user_interaction.search_details
--   src_id  = source city id
--   dest_id = destination city id
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q1) Funnel throughput × DBD (0,1,2,3,4,5+)
--     DBD + src/dest from search_details (not search_route_details)
-- -----------------------------------------------------------------------------
WITH cohort AS (
  SELECT DISTINCT
    ux.mri_session_id,
    ux.event_value AS cohort
  FROM user_interaction.ui_ux_events ux
  WHERE ux.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND ux.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND'
    AND ux.header_bu = 'BUS'
    AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
),
srp_dbd AS (
  SELECT
    c.mri_session_id,
    c.cohort,
    sd.src_id,
    sd.dest_id,
    CASE
      WHEN date_diff('day', CAST(AT_TIMEZONE(sd.__time, 'Asia/Kolkata') AS DATE), CAST(sd.doj AS DATE)) <= 0 THEN '0'
      WHEN date_diff('day', CAST(AT_TIMEZONE(sd.__time, 'Asia/Kolkata') AS DATE), CAST(sd.doj AS DATE)) = 1 THEN '1'
      WHEN date_diff('day', CAST(AT_TIMEZONE(sd.__time, 'Asia/Kolkata') AS DATE), CAST(sd.doj AS DATE)) = 2 THEN '2'
      WHEN date_diff('day', CAST(AT_TIMEZONE(sd.__time, 'Asia/Kolkata') AS DATE), CAST(sd.doj AS DATE)) = 3 THEN '3'
      WHEN date_diff('day', CAST(AT_TIMEZONE(sd.__time, 'Asia/Kolkata') AS DATE), CAST(sd.doj AS DATE)) = 4 THEN '4'
      ELSE '5+'
    END AS dbd_bucket,
    ROW_NUMBER() OVER (
      PARTITION BY c.mri_session_id
      ORDER BY sd.__time ASC
    ) AS rn
  FROM cohort c
  INNER JOIN user_interaction.search_details sd
    ON c.mri_session_id = sd.mri_session_id
  WHERE sd.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND sd.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND sd.country = 'IND'
    AND sd.os = 'Android'
    AND sd.src_id IS NOT NULL
    AND sd.dest_id IS NOT NULL
),
session_dbd AS (
  -- first search_details row per session
  SELECT mri_session_id, cohort, src_id, dest_id, dbd_bucket
  FROM srp_dbd
  WHERE rn = 1
)
SELECT
  d.cohort,
  d.dbd_bucket,
  COUNT(DISTINCT d.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
  COUNT(DISTINCT ci.mri_session_id) AS ci_sessions,
  COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
  COUNT(DISTINCT pay.mri_session_id) AS payment_sessions,
  COUNT(DISTINCT bte.mri_session_id) AS confirm_sessions
FROM session_dbd d
LEFT JOIN user_interaction.seat_layout_details sl
  ON d.mri_session_id = sl.mri_session_id
 AND sl.__time >= TIMESTAMP '2026-08-29 18:30:00'
 AND sl.__time <  TIMESTAMP '2026-09-05 18:30:00'
 AND sl.country = 'IND' AND sl.os = 'Android'
LEFT JOIN user_interaction.cust_info_details ci
  ON d.mri_session_id = ci.mri_session_id
 AND ci.__time >= TIMESTAMP '2026-08-29 18:30:00'
 AND ci.__time <  TIMESTAMP '2026-09-05 18:30:00'
 AND ci.country = 'IND' AND ci.os = 'Android'
LEFT JOIN user_interaction.create_order_details tco
  ON d.mri_session_id = tco.mri_session_id
 AND tco.__time >= TIMESTAMP '2026-08-29 18:30:00'
 AND tco.__time <  TIMESTAMP '2026-09-05 18:30:00'
 AND tco.country = 'IND' AND tco.os = 'Android'
LEFT JOIN user_interaction.order_info_details pay
  ON d.mri_session_id = pay.mri_session_id
 AND pay.__time >= TIMESTAMP '2026-08-29 18:30:00'
 AND pay.__time <  TIMESTAMP '2026-09-05 18:30:00'
 AND pay.country = 'IND' AND pay.os = 'Android'
LEFT JOIN transaction.bus_ticket_events bte
  ON d.mri_session_id = bte.mri_session_id
 AND bte.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
 AND bte.time_of_event <  TIMESTAMP '2026-09-05 18:30:00'
 AND bte.country_code = 'IND'
 AND bte.event_type = 101
 AND bte.event_class = 2
GROUP BY 1, 2
ORDER BY 1, 2;


-- -----------------------------------------------------------------------------
-- Q2a) Filter coverage — Contextual / Sort&Filter vs Women|Regular SRP
-- -----------------------------------------------------------------------------
WITH cohort AS (
  SELECT DISTINCT mri_session_id, event_value AS cohort
  FROM user_interaction.ui_ux_events
  WHERE __time >= TIMESTAMP '2026-08-29 18:30:00'
    AND __time <  TIMESTAMP '2026-09-05 18:30:00'
    AND event_src = 'Android'
    AND header_country = 'IND' AND header_bu = 'BUS' AND selected_country = 'India'
    AND event_group = 'srp_click_event' AND event_name = 'SRP loaded'
    AND event_value IN ('Women', 'Regular')
),
filt AS (
  SELECT
    c.cohort,
    f.mri_session_id,
    f.event_name,
    f.event_value,
    f.filter_applied
  FROM cohort c
  INNER JOIN user_interaction.ui_ux_events f
    ON c.mri_session_id = f.mri_session_id
  WHERE f.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND f.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND f.event_src = 'Android'
    AND f.header_country = 'IND' AND f.header_bu = 'BUS' AND f.selected_country = 'India'
    AND f.event_group = 'srp_filter_event'
    AND (
      f.event_name = 'sort_and_filter'
      OR (f.event_name = 'contextual' AND f.event_value = 'Clicked')
    )
)
SELECT
  c.cohort,
  COUNT(DISTINCT c.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT CASE WHEN f.event_name = 'sort_and_filter' THEN f.mri_session_id END) AS sort_filter_sessions,
  COUNT(DISTINCT CASE WHEN f.event_name = 'contextual' THEN f.mri_session_id END) AS contextual_clicked_sessions,
  COUNT(DISTINCT f.mri_session_id) AS any_sort_or_contextual_sessions
FROM cohort c
LEFT JOIN filt f ON c.mri_session_id = f.mri_session_id AND c.cohort = f.cohort
GROUP BY 1
ORDER BY 1;

-- Q2b) Top filter types / chips within each cohort
WITH cohort AS (
  SELECT DISTINCT mri_session_id, event_value AS cohort
  FROM user_interaction.ui_ux_events
  WHERE __time >= TIMESTAMP '2026-08-29 18:30:00'
    AND __time <  TIMESTAMP '2026-09-05 18:30:00'
    AND event_src = 'Android'
    AND header_country = 'IND' AND header_bu = 'BUS' AND selected_country = 'India'
    AND event_group = 'srp_click_event' AND event_name = 'SRP loaded'
    AND event_value IN ('Women', 'Regular')
)
SELECT
  c.cohort,
  f.event_name AS filter_surface,          -- sort_and_filter | contextual
  COALESCE(NULLIF(TRIM(f.filter_applied), ''), f.event_value) AS filter_detail,
  COUNT(DISTINCT f.mri_session_id) AS sessions
FROM cohort c
INNER JOIN user_interaction.ui_ux_events f
  ON c.mri_session_id = f.mri_session_id
WHERE f.__time >= TIMESTAMP '2026-08-29 18:30:00'
  AND f.__time <  TIMESTAMP '2026-09-05 18:30:00'
  AND f.event_src = 'Android'
  AND f.header_country = 'IND' AND f.header_bu = 'BUS' AND f.selected_country = 'India'
  AND f.event_group = 'srp_filter_event'
  AND (
    f.event_name = 'sort_and_filter'
    OR (f.event_name = 'contextual' AND f.event_value = 'Clicked')
  )
GROUP BY 1, 2, 3
ORDER BY 1, 2, sessions DESC
LIMIT 500;


-- -----------------------------------------------------------------------------
-- Q3) Return rate (14d) — next txn OR reverse-SD search
-- -----------------------------------------------------------------------------
WITH bookings AS (
  SELECT
    bte.rb_user_id,
    bte.mri_session_id,
    bte.time_of_event AS booking_time,
    bte.source_location_id,
    bte.destination_location_id,
    ux.event_value AS cohort,
    ROW_NUMBER() OVER (PARTITION BY bte.rb_user_id, ux.event_value ORDER BY bte.time_of_event) AS rn
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  WHERE bte.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
    AND bte.time_of_event <  TIMESTAMP '2026-09-05 18:30:00'
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND ux.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND ux.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
),
first_booking AS (
  SELECT * FROM bookings WHERE rn = 1 AND rb_user_id > 0
)
SELECT
  fb.cohort,
  COUNT(DISTINCT fb.rb_user_id) AS bookers,
  COUNT(DISTINCT CASE WHEN ret.rb_user_id IS NOT NULL THEN fb.rb_user_id END) AS return_txn_users_14d,
  COUNT(DISTINCT CASE WHEN rs.rb_user_id IS NOT NULL THEN fb.rb_user_id END) AS return_search_users_14d,
  COUNT(DISTINCT CASE
    WHEN ret.rb_user_id IS NOT NULL OR rs.rb_user_id IS NOT NULL THEN fb.rb_user_id
  END) AS either_return_users_14d
FROM first_booking fb
LEFT JOIN transaction.bus_ticket_events ret
  ON ret.rb_user_id = fb.rb_user_id
 AND ret.time_of_event > fb.booking_time
 AND ret.time_of_event <= fb.booking_time + INTERVAL '14' DAY
 AND ret.country_code = 'IND'
 AND ret.event_type = 101
 AND ret.event_class = 2
 AND ret.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
 AND ret.time_of_event <  TIMESTAMP '2026-09-19 18:30:00'
LEFT JOIN user_interaction.search_details rs
  ON rs.rb_user_id = fb.rb_user_id
 AND rs.__time > fb.booking_time
 AND rs.__time <= fb.booking_time + INTERVAL '14' DAY
 AND rs.src_id = fb.destination_location_id   -- reverse SD
 AND rs.dest_id = fb.source_location_id
 AND rs.country = 'IND'
 AND rs.os = 'Android'
 AND rs.__time >= TIMESTAMP '2026-08-29 18:30:00'
 AND rs.__time <  TIMESTAMP '2026-09-19 18:30:00'
GROUP BY 1
ORDER BY 1;


-- -----------------------------------------------------------------------------
-- Q4) ASP × DBD (0,1,2,3,4,5+) — Women vs Regular confirmed
-- -----------------------------------------------------------------------------
WITH tagged AS (
  SELECT
    bte.tin,
    bte.mri_session_id,
    ux.event_value AS cohort,
    date_diff(
      'day',
      CAST(AT_TIMEZONE(bte.date_of_issue, 'Asia/Kolkata') AS DATE),
      CAST(bte.date_of_journey AS DATE)
    ) AS dbd_raw,
    CARDINALITY(bte.seat_price) AS seats,
    REDUCE(bte.seat_price, CAST(0 AS DOUBLE), (s, x) -> s + CAST(x AS DOUBLE), s -> s) AS gmv
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  WHERE bte.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
    AND bte.time_of_event <  TIMESTAMP '2026-09-05 18:30:00'
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND bte.seat_price IS NOT NULL
    AND CARDINALITY(bte.seat_price) > 0
    AND ux.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND ux.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
)
SELECT
  cohort,
  CASE
    WHEN dbd_raw <= 0 THEN '0'
    WHEN dbd_raw = 1 THEN '1'
    WHEN dbd_raw = 2 THEN '2'
    WHEN dbd_raw = 3 THEN '3'
    WHEN dbd_raw = 4 THEN '4'
    ELSE '5+'
  END AS dbd_bucket,
  COUNT(DISTINCT tin) AS txns,
  SUM(seats) AS seats,
  SUM(gmv) AS gmv,
  SUM(gmv) * 1.0 / NULLIF(SUM(seats), 0) AS asp
FROM tagged
GROUP BY 1, 2
ORDER BY 1, 2;


-- -----------------------------------------------------------------------------
-- Q5) Micro funnel — SL → BP/DP → bus-details tray → BP/DP search
--     Optimized: filtered stage CTEs (not full ui_ux self-join)
-- -----------------------------------------------------------------------------
WITH cohort AS (
  SELECT DISTINCT mri_session_id, event_value AS cohort
  FROM user_interaction.ui_ux_events
  WHERE __time >= TIMESTAMP '2026-08-29 18:30:00'
    AND __time <  TIMESTAMP '2026-09-05 18:30:00'
    AND event_src = 'Android'
    AND header_country = 'IND' AND header_bu = 'BUS' AND selected_country = 'India'
    AND event_group = 'srp_click_event' AND event_name = 'SRP loaded'
    AND event_value IN ('Women', 'Regular')
),
sl AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.ui_ux_events
  WHERE __time >= TIMESTAMP '2026-08-29 18:30:00'
    AND __time <  TIMESTAMP '2026-09-05 18:30:00'
    AND event_src = 'Android'
    AND header_country = 'IND' AND header_bu = 'BUS' AND selected_country = 'India'
    AND (event_group = 'sl_screen_load' OR event_name IN ('SL loaded', 'sl loaded'))
),
bp AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.ui_ux_events
  WHERE __time >= TIMESTAMP '2026-08-29 18:30:00'
    AND __time <  TIMESTAMP '2026-09-05 18:30:00'
    AND event_src = 'Android'
    AND header_country = 'IND' AND header_bu = 'BUS' AND selected_country = 'India'
    AND (
      event_group = 'bp_dp_screen_load'
      OR event_name = 'BP DP screen loaded'
      OR LOWER(COALESCE(screen_name, '')) IN ('boarding point screen', 'dropping point screen')
    )
),
tray AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.ui_ux_events
  WHERE __time >= TIMESTAMP '2026-08-29 18:30:00'
    AND __time <  TIMESTAMP '2026-09-05 18:30:00'
    AND event_src = 'Android'
    AND header_country = 'IND' AND header_bu = 'BUS' AND selected_country = 'India'
    AND (
      REGEXP_LIKE(LOWER(COALESCE(event_name, '')), 'busdetails|bus.?details|tray')
      OR event_name IN ('NewImagesBusDetailsExpanded', 'BusDetailsExpanded')
    )
),
bpsearch AS (
  SELECT DISTINCT mri_session_id
  FROM user_interaction.ui_ux_events
  WHERE __time >= TIMESTAMP '2026-08-29 18:30:00'
    AND __time <  TIMESTAMP '2026-09-05 18:30:00'
    AND event_src = 'Android'
    AND header_country = 'IND' AND header_bu = 'BUS' AND selected_country = 'India'
    AND event_name IN ('search information', 'location widget', 'location widget tapped')
    AND LOWER(COALESCE(screen_name, '')) IN ('boarding point screen', 'dropping point screen')
)
SELECT
  c.cohort,
  COUNT(DISTINCT c.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
  COUNT(DISTINCT bp.mri_session_id) AS bp_dp_screen_sessions,
  COUNT(DISTINCT tray.mri_session_id) AS bus_details_tray_sessions,
  COUNT(DISTINCT bpsearch.mri_session_id) AS bp_dp_search_sessions
FROM cohort c
LEFT JOIN sl ON c.mri_session_id = sl.mri_session_id
LEFT JOIN bp ON c.mri_session_id = bp.mri_session_id
LEFT JOIN tray ON c.mri_session_id = tray.mri_session_id
LEFT JOIN bpsearch ON c.mri_session_id = bpsearch.mri_session_id
GROUP BY 1
ORDER BY 1;


-- -----------------------------------------------------------------------------
-- Q6) Omega proxy — women booking near other women (same row)
--     Top 100 SDs (from search_details src_id-dest_id) → top 10 route_ids
--     Proxy: seats where female gender shares same numeric row token
--     (e.g. L1/L2 → row 1). Needs Omega seat map for true adjacency —
--     this is a simplified seat-code heuristic on BTE.
-- -----------------------------------------------------------------------------
WITH confirmed AS (
  SELECT
    bte.tin,
    bte.route_id,
    sd.src_id,
    sd.dest_id,
    CONCAT(CAST(sd.src_id AS VARCHAR), '-', CAST(sd.dest_id AS VARCHAR)) AS sd,
    bte.seat_name,
    bte.travellers_gender,
    ux.event_value AS cohort
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  INNER JOIN user_interaction.search_details sd
    ON bte.mri_session_id = sd.mri_session_id
  WHERE bte.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
    AND bte.time_of_event <  TIMESTAMP '2026-09-05 18:30:00'
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND bte.seat_name IS NOT NULL
    AND bte.travellers_gender IS NOT NULL
    AND sd.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND sd.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND sd.country = 'IND'
    AND sd.os = 'Android'
    AND sd.src_id IS NOT NULL
    AND sd.dest_id IS NOT NULL
    AND ux.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND ux.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
),
top_sd AS (
  SELECT sd
  FROM confirmed
  GROUP BY 1
  ORDER BY COUNT(*) DESC
  LIMIT 100
),
top_routes AS (
  SELECT route_id
  FROM (
    SELECT
      c.route_id,
      ROW_NUMBER() OVER (PARTITION BY c.sd ORDER BY COUNT(*) DESC) AS rn
    FROM confirmed c
    INNER JOIN top_sd t ON c.sd = t.sd
    GROUP BY c.sd, c.route_id
  ) x
  WHERE rn <= 10
),
seat_exp AS (
  SELECT
    c.cohort,
    c.tin,
    c.route_id,
    c.sd,
    seat,
    gender,
    REGEXP_EXTRACT(seat, '([0-9]+)', 1) AS row_token
  FROM confirmed c
  INNER JOIN top_sd t ON c.sd = t.sd
  INNER JOIN top_routes r ON c.route_id = r.route_id
  CROSS JOIN UNNEST(c.seat_name, c.travellers_gender) AS u(seat, gender)
),
tin_flags AS (
  SELECT
    cohort,
    tin,
    route_id,
    sd,
    COUNT(*) AS pax,
    COUNT_IF(UPPER(gender) = 'FEMALE') AS female_pax,
    -- female seats sharing a row_token with ≥2 females on same TIN
    MAX(CASE WHEN UPPER(gender) = 'FEMALE' AND female_on_row >= 2 THEN 1 ELSE 0 END) AS has_female_same_row
  FROM (
    SELECT
      s.*,
      COUNT_IF(UPPER(gender) = 'FEMALE') OVER (PARTITION BY tin, row_token) AS female_on_row
    FROM seat_exp s
    WHERE row_token IS NOT NULL AND row_token <> ''
  ) z
  GROUP BY 1, 2, 3, 4
)
SELECT
  cohort,
  COUNT(DISTINCT tin) AS txns,
  COUNT(DISTINCT CASE WHEN female_pax >= 1 THEN tin END) AS txns_with_female,
  COUNT(DISTINCT CASE WHEN has_female_same_row = 1 THEN tin END) AS txns_female_same_row,
  COUNT(DISTINCT CASE WHEN has_female_same_row = 1 THEN tin END) * 1.0
    / NULLIF(COUNT(DISTINCT CASE WHEN female_pax >= 1 THEN tin END), 0) AS pct_female_same_row_among_female_txns
FROM tin_flags
GROUP BY 1
ORDER BY 1;


-- -----------------------------------------------------------------------------
-- Q7) Pax booked % split × ASP buckets — Women / Regular
-- -----------------------------------------------------------------------------
WITH base AS (
  SELECT
    ux.event_value AS cohort,
    bte.tin,
    CARDINALITY(bte.seat_price) AS seats,
    REDUCE(bte.seat_price, CAST(0 AS DOUBLE), (s, x) -> s + CAST(x AS DOUBLE), s -> s)
      / NULLIF(CARDINALITY(bte.seat_price), 0) AS tin_asp
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  WHERE bte.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
    AND bte.time_of_event <  TIMESTAMP '2026-09-05 18:30:00'
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND bte.seat_price IS NOT NULL
    AND CARDINALITY(bte.seat_price) > 0
    AND ux.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND ux.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
),
bucketed AS (
  SELECT
    cohort,
    seats,
    CASE
      WHEN tin_asp < 500 THEN 'a.<500'
      WHEN tin_asp < 800 THEN 'b.500-799'
      WHEN tin_asp < 1200 THEN 'c.800-1199'
      WHEN tin_asp < 1800 THEN 'd.1200-1799'
      ELSE 'e.1800+'
    END AS asp_bucket
  FROM base
)
SELECT
  cohort,
  asp_bucket,
  SUM(seats) AS seats,
  SUM(seats) * 100.0 / SUM(SUM(seats)) OVER (PARTITION BY cohort) AS seats_pct
FROM bucketed
GROUP BY 1, 2
ORDER BY 1, 2;


-- -----------------------------------------------------------------------------
-- BONUS) Same BP/DP preference on return to same route (hypothesis 6)
-- -----------------------------------------------------------------------------
WITH first_txn AS (
  SELECT
    bte.rb_user_id,
    bte.boarding_point_id,
    bte.dropping_point_id,
    bte.source_location_id,
    bte.destination_location_id,
    bte.time_of_event,
    ux.event_value AS cohort,
    ROW_NUMBER() OVER (PARTITION BY bte.rb_user_id ORDER BY bte.time_of_event) AS rn
  FROM transaction.bus_ticket_events bte
  INNER JOIN user_interaction.ui_ux_events ux
    ON bte.mri_session_id = ux.mri_session_id
  WHERE bte.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
    AND bte.time_of_event <  TIMESTAMP '2026-09-05 18:30:00'
    AND bte.country_code = 'IND'
    AND bte.event_type = 101 AND bte.event_class = 2
    AND bte.sales_channel LIKE '%droidapp%'
    AND ux.__time >= TIMESTAMP '2026-08-29 18:30:00'
    AND ux.__time <  TIMESTAMP '2026-09-05 18:30:00'
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND' AND ux.header_bu = 'BUS' AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event' AND ux.event_name = 'SRP loaded'
    AND ux.event_value IN ('Women', 'Regular')
),
f AS (SELECT * FROM first_txn WHERE rn = 1 AND rb_user_id > 0)
SELECT
  f.cohort,
  COUNT(DISTINCT f.rb_user_id) AS users_with_same_sd_return_txn,
  COUNT(DISTINCT CASE
    WHEN r.boarding_point_id = f.boarding_point_id
     AND r.dropping_point_id = f.dropping_point_id
    THEN f.rb_user_id END) AS same_bp_and_dp,
  COUNT(DISTINCT CASE WHEN r.boarding_point_id = f.boarding_point_id THEN f.rb_user_id END) AS same_bp,
  COUNT(DISTINCT CASE WHEN r.dropping_point_id = f.dropping_point_id THEN f.rb_user_id END) AS same_dp
FROM f
INNER JOIN transaction.bus_ticket_events r
  ON r.rb_user_id = f.rb_user_id
 AND r.time_of_event > f.time_of_event
 AND r.time_of_event <= f.time_of_event + INTERVAL '14' DAY
 AND r.source_location_id = f.source_location_id
 AND r.destination_location_id = f.destination_location_id
 AND r.country_code = 'IND'
 AND r.event_type = 101 AND r.event_class = 2
 AND r.time_of_event >= TIMESTAMP '2026-08-29 18:30:00'
 AND r.time_of_event <  TIMESTAMP '2026-09-19 18:30:00'
GROUP BY 1
ORDER BY 1;
