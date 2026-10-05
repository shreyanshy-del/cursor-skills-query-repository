-- =============================================================================
-- UPSRTC (operator_id = 25946) | IND | Jun–Aug 2026 (IST)
-- UTC window: 2026-05-31 18:30:00 → 2026-08-31 18:30:00
--
-- High vs Low definition (CR bucket):
--   Eligible SDs: total_sessions >= 200
--   High = SD CR >= median CR across eligible SDs
--   Low  = SD CR <  median CR
--   CR   = distinct TIN (event_type=101) / distinct search sessions * 100
--
-- Guest = rb_user_id IS NULL
-- Heavy RBID = named rb_user_id with >= 15 distinct sessions on SAME day
--              + SAME SD (src,dest) + SAME operator (25946)
-- =============================================================================


-- =============================================================================
-- 1A) Guest session share — High vs Low (AGGREGATE)
-- =============================================================================
WITH searches_by_sd AS (
  SELECT
    src_id,
    dest_id,
    COUNT(DISTINCT mri_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN rb_user_id IS NULL THEN mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details
  WHERE
    country = 'IND'
    AND __time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND __time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    src_id,
    dest_id
), bookings_by_sd AS (
  SELECT
    source_location_id AS src_id,
    destination_location_id AS dest_id,
    COUNT(DISTINCT tin) AS transactions
  FROM transaction.bus_ticket_events
  WHERE
    country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    source_location_id,
    destination_location_id
), sd_metrics AS (
  SELECT
    s.src_id,
    s.dest_id,
    s.total_sessions,
    s.guest_sessions,
    COALESCE(b.transactions, 0) AS transactions,
    CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.total_sessions AS cr_pct
  FROM searches_by_sd AS s
  LEFT JOIN bookings_by_sd AS b
    ON s.src_id = b.src_id AND s.dest_id = b.dest_id
  WHERE
    s.total_sessions >= 200
), median_cr AS (
  SELECT APPROX_PERCENTILE(cr_pct, 0.5) AS median_cr_pct
  FROM sd_metrics
), bucketed AS (
  SELECT
    m.*,
    CASE WHEN m.cr_pct >= c.median_cr_pct THEN 'High' ELSE 'Low' END AS cr_bucket,
    c.median_cr_pct
  FROM sd_metrics AS m
  CROSS JOIN median_cr AS c
)
SELECT
  cr_bucket,
  COUNT(*) AS sd_count,
  MAX(median_cr_pct) AS median_cr_pct,
  SUM(total_sessions) AS total_sessions,
  SUM(guest_sessions) AS guest_sessions,
  CAST(SUM(guest_sessions) AS DOUBLE) * 100.0 / SUM(total_sessions) AS guest_session_share_pct,
  SUM(transactions) AS transactions,
  CAST(SUM(transactions) AS DOUBLE) * 100.0 / SUM(total_sessions) AS overall_cr_pct
FROM bucketed
GROUP BY
  cr_bucket
ORDER BY
  cr_bucket DESC;


-- =============================================================================
-- 1B) Guest session share — SD level (with High / Low flag)
-- =============================================================================
WITH searches_by_sd AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    src.location_name AS source_city,
    dst.location_name AS destination_city,
    COUNT(DISTINCT sd.mri_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  LEFT JOIN lis.config_locations AS src
    ON sd.src_id = src.id AND src.location_type = 'CITY' AND src.is_expired = 0
  LEFT JOIN lis.config_locations AS dst
    ON sd.dest_id = dst.id AND dst.location_type = 'CITY' AND dst.is_expired = 0
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY
    sd.src_id,
    sd.dest_id,
    src.location_name,
    dst.location_name
), bookings_by_sd AS (
  SELECT
    source_location_id AS src_id,
    destination_location_id AS dest_id,
    COUNT(DISTINCT tin) AS transactions
  FROM transaction.bus_ticket_events
  WHERE
    country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    source_location_id,
    destination_location_id
), sd_metrics AS (
  SELECT
    s.src_id,
    s.dest_id,
    s.source_city,
    s.destination_city,
    s.total_sessions,
    s.guest_sessions,
    CAST(s.guest_sessions AS DOUBLE) * 100.0 / s.total_sessions AS guest_session_share_pct,
    COALESCE(b.transactions, 0) AS transactions,
    CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.total_sessions AS cr_pct
  FROM searches_by_sd AS s
  LEFT JOIN bookings_by_sd AS b
    ON s.src_id = b.src_id AND s.dest_id = b.dest_id
  WHERE
    s.total_sessions >= 200
), median_cr AS (
  SELECT APPROX_PERCENTILE(cr_pct, 0.5) AS median_cr_pct
  FROM sd_metrics
)
SELECT
  m.src_id,
  m.dest_id,
  m.source_city,
  m.destination_city,
  m.total_sessions,
  m.guest_sessions,
  m.guest_session_share_pct,
  m.transactions,
  m.cr_pct,
  CASE WHEN m.cr_pct >= c.median_cr_pct THEN 'High' ELSE 'Low' END AS cr_bucket,
  c.median_cr_pct
FROM sd_metrics AS m
CROSS JOIN median_cr AS c
ORDER BY
  m.total_sessions DESC
LIMIT 1500;


-- =============================================================================
-- 2A) Heavy RBID (>=15 sessions / day / SD / operator) share — High vs Low AGG
-- =============================================================================
WITH daily_user_sd AS (
  SELECT
    rb_user_id,
    src_id,
    dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(__time, 'Asia/Kolkata')) AS day_ist
  FROM user_interaction.search_details
  WHERE
    country = 'IND'
    AND __time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND __time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
    AND rb_user_id IS NOT NULL
  GROUP BY
    rb_user_id,
    src_id,
    dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(__time, 'Asia/Kolkata'))
  HAVING
    COUNT(DISTINCT mri_session_id) >= 15
), heavy_sessions_by_sd AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS heavy_rbid_sessions,
    COUNT(DISTINCT sd.rb_user_id) AS heavy_rbids
  FROM user_interaction.search_details AS sd
  INNER JOIN daily_user_sd AS du
    ON sd.rb_user_id = du.rb_user_id
    AND sd.src_id = du.src_id
    AND sd.dest_id = du.dest_id
    AND DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) = du.day_ist
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY
    sd.src_id,
    sd.dest_id
), searches_by_sd AS (
  SELECT
    src_id,
    dest_id,
    COUNT(DISTINCT mri_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN rb_user_id IS NULL THEN mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details
  WHERE
    country = 'IND'
    AND __time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND __time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    src_id,
    dest_id
), bookings_by_sd AS (
  SELECT
    source_location_id AS src_id,
    destination_location_id AS dest_id,
    COUNT(DISTINCT tin) AS transactions
  FROM transaction.bus_ticket_events
  WHERE
    country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    source_location_id,
    destination_location_id
), sd_metrics AS (
  SELECT
    s.src_id,
    s.dest_id,
    s.total_sessions,
    s.guest_sessions,
    COALESCE(h.heavy_rbid_sessions, 0) AS heavy_rbid_sessions,
    COALESCE(h.heavy_rbids, 0) AS heavy_rbids,
    COALESCE(b.transactions, 0) AS transactions,
    CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.total_sessions AS cr_pct
  FROM searches_by_sd AS s
  LEFT JOIN bookings_by_sd AS b
    ON s.src_id = b.src_id AND s.dest_id = b.dest_id
  LEFT JOIN heavy_sessions_by_sd AS h
    ON s.src_id = h.src_id AND s.dest_id = h.dest_id
  WHERE
    s.total_sessions >= 200
), median_cr AS (
  SELECT APPROX_PERCENTILE(cr_pct, 0.5) AS median_cr_pct
  FROM sd_metrics
), bucketed AS (
  SELECT
    m.*,
    CASE WHEN m.cr_pct >= c.median_cr_pct THEN 'High' ELSE 'Low' END AS cr_bucket,
    c.median_cr_pct
  FROM sd_metrics AS m
  CROSS JOIN median_cr AS c
)
SELECT
  cr_bucket,
  COUNT(*) AS sd_count,
  MAX(median_cr_pct) AS median_cr_pct,
  SUM(total_sessions) AS total_sessions,
  SUM(guest_sessions) AS guest_sessions,
  CAST(SUM(guest_sessions) AS DOUBLE) * 100.0 / SUM(total_sessions) AS guest_session_share_pct,
  SUM(heavy_rbid_sessions) AS heavy_rbid_sessions,
  CAST(SUM(heavy_rbid_sessions) AS DOUBLE) * 100.0 / SUM(total_sessions) AS heavy_rbid_session_share_pct,
  SUM(heavy_rbids) AS heavy_rbids,
  SUM(transactions) AS transactions,
  CAST(SUM(transactions) AS DOUBLE) * 100.0 / SUM(total_sessions) AS overall_cr_pct
FROM bucketed
GROUP BY
  cr_bucket
ORDER BY
  cr_bucket DESC;


-- =============================================================================
-- 2B) Heavy RBID (>=15 sessions / day / SD / operator) — SD level
-- =============================================================================
WITH daily_user_sd AS (
  SELECT
    rb_user_id,
    src_id,
    dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(__time, 'Asia/Kolkata')) AS day_ist
  FROM user_interaction.search_details
  WHERE
    country = 'IND'
    AND __time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND __time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
    AND rb_user_id IS NOT NULL
  GROUP BY
    rb_user_id,
    src_id,
    dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(__time, 'Asia/Kolkata'))
  HAVING
    COUNT(DISTINCT mri_session_id) >= 15
), heavy_sessions_by_sd AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS heavy_rbid_sessions,
    COUNT(DISTINCT sd.rb_user_id) AS heavy_rbids
  FROM user_interaction.search_details AS sd
  INNER JOIN daily_user_sd AS du
    ON sd.rb_user_id = du.rb_user_id
    AND sd.src_id = du.src_id
    AND sd.dest_id = du.dest_id
    AND DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) = du.day_ist
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY
    sd.src_id,
    sd.dest_id
), searches_by_sd AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    src.location_name AS source_city,
    dst.location_name AS destination_city,
    COUNT(DISTINCT sd.mri_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  LEFT JOIN lis.config_locations AS src
    ON sd.src_id = src.id AND src.location_type = 'CITY' AND src.is_expired = 0
  LEFT JOIN lis.config_locations AS dst
    ON sd.dest_id = dst.id AND dst.location_type = 'CITY' AND dst.is_expired = 0
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY
    sd.src_id,
    sd.dest_id,
    src.location_name,
    dst.location_name
), bookings_by_sd AS (
  SELECT
    source_location_id AS src_id,
    destination_location_id AS dest_id,
    COUNT(DISTINCT tin) AS transactions
  FROM transaction.bus_ticket_events
  WHERE
    country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    source_location_id,
    destination_location_id
), sd_metrics AS (
  SELECT
    s.src_id,
    s.dest_id,
    s.source_city,
    s.destination_city,
    s.total_sessions,
    s.guest_sessions,
    CAST(s.guest_sessions AS DOUBLE) * 100.0 / s.total_sessions AS guest_session_share_pct,
    COALESCE(h.heavy_rbid_sessions, 0) AS heavy_rbid_sessions,
    CAST(COALESCE(h.heavy_rbid_sessions, 0) AS DOUBLE) * 100.0 / s.total_sessions AS heavy_rbid_session_share_pct,
    COALESCE(h.heavy_rbids, 0) AS heavy_rbids,
    COALESCE(b.transactions, 0) AS transactions,
    CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.total_sessions AS cr_pct
  FROM searches_by_sd AS s
  LEFT JOIN bookings_by_sd AS b
    ON s.src_id = b.src_id AND s.dest_id = b.dest_id
  LEFT JOIN heavy_sessions_by_sd AS h
    ON s.src_id = h.src_id AND s.dest_id = h.dest_id
  WHERE
    s.total_sessions >= 200
), median_cr AS (
  SELECT APPROX_PERCENTILE(cr_pct, 0.5) AS median_cr_pct
  FROM sd_metrics
)
SELECT
  m.src_id,
  m.dest_id,
  m.source_city,
  m.destination_city,
  m.total_sessions,
  m.guest_sessions,
  m.guest_session_share_pct,
  m.heavy_rbid_sessions,
  m.heavy_rbid_session_share_pct,
  m.heavy_rbids,
  m.transactions,
  m.cr_pct,
  CASE WHEN m.cr_pct >= c.median_cr_pct THEN 'High' ELSE 'Low' END AS cr_bucket,
  c.median_cr_pct
FROM sd_metrics AS m
CROSS JOIN median_cr AS c
ORDER BY
  m.heavy_rbid_session_share_pct DESC,
  m.total_sessions DESC
LIMIT 1500;


-- =============================================================================
-- OPTIONAL: list heavy RBIDs (named users with >=15 sessions/day on an SD)
-- Uncomment if you need user-level drilldown (do NOT export broadly)
-- =============================================================================
/*
WITH daily_user_sd AS (
  SELECT
    rb_user_id,
    src_id,
    dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(__time, 'Asia/Kolkata')) AS day_ist,
    COUNT(DISTINCT mri_session_id) AS sessions_on_day
  FROM user_interaction.search_details
  WHERE
    country = 'IND'
    AND __time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND __time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND operator_id = 25946
    AND rb_user_id IS NOT NULL
  GROUP BY
    rb_user_id,
    src_id,
    dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(__time, 'Asia/Kolkata'))
  HAVING
    COUNT(DISTINCT mri_session_id) >= 15
)
SELECT
  rb_user_id,
  src_id,
  dest_id,
  day_ist,
  sessions_on_day
FROM daily_user_sd
ORDER BY
  sessions_on_day DESC
LIMIT 500;
*/
