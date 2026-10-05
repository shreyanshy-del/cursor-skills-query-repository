-- UPSRTC (operator_id = 25946) | IND | Window: 2026-08-26 → 2026-09-09 (end exclusive)
-- ============================================================
-- 1) SD-level SRP searches, transactions, CR
-- ============================================================
WITH searches_cte AS (
  SELECT
    src_id,
    dest_id,
    COUNT(DISTINCT mri_session_id) AS searches
  FROM user_interaction.search_details
  WHERE
    country = 'IND'
    AND __time >= CAST('2026-08-26 00:00:00' AS TIMESTAMP)
    AND __time < CAST('2026-09-09 00:00:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    src_id,
    dest_id
), bookings_cte AS (
  SELECT
    source_location_id AS src_id,
    destination_location_id AS dest_id,
    COUNT(DISTINCT tin) AS transactions
  FROM transaction.bus_ticket_events
  WHERE
    country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2026-08-26 00:00:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-09-09 00:00:00' AS TIMESTAMP)
    AND operator_id = 25946
  GROUP BY
    source_location_id,
    destination_location_id
)
SELECT
  COALESCE(s.src_id, b.src_id) AS src_id,
  COALESCE(s.dest_id, b.dest_id) AS dest_id,
  src_loc.location_name AS source_location_name,
  dest_loc.location_name AS destination_location_name,
  SUM(COALESCE(s.searches, 0)) AS total_searches,
  SUM(COALESCE(b.transactions, 0)) AS total_transactions,
  100.0 * SUM(COALESCE(b.transactions, 0)) / NULLIF(SUM(COALESCE(s.searches, 0)), 0) AS conversion_rate_pct
FROM searches_cte AS s
FULL OUTER JOIN bookings_cte AS b
  ON s.src_id = b.src_id AND s.dest_id = b.dest_id
LEFT JOIN lis.config_locations AS src_loc
  ON COALESCE(s.src_id, b.src_id) = src_loc.id
  AND src_loc.location_type = 'CITY'
  AND src_loc.is_expired = 0
LEFT JOIN lis.config_locations AS dest_loc
  ON COALESCE(s.dest_id, b.dest_id) = dest_loc.id
  AND dest_loc.location_type = 'CITY'
  AND dest_loc.is_expired = 0
GROUP BY
  COALESCE(s.src_id, b.src_id),
  COALESCE(s.dest_id, b.dest_id),
  src_loc.location_name,
  dest_loc.location_name
ORDER BY total_searches DESC
LIMIT 1500;


-- ============================================================
-- 2) SD-level NULL rb_user_id searches
-- ============================================================
SELECT
  sd.src_id,
  src.location_name AS src_location_name,
  sd.dest_id,
  dst.location_name AS dst_location_name,
  COUNT(DISTINCT sd.mri_session_id) AS total_searches,
  COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS null_rbid_searches,
  COUNT(DISTINCT CASE WHEN NOT sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS named_rbid_searches,
  100.0 * COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END)
    / NULLIF(COUNT(DISTINCT sd.mri_session_id), 0) AS null_rbid_share_pct,
  COUNT(DISTINCT sd.rb_user_id) AS unique_named_rbids
FROM user_interaction.search_details AS sd
LEFT JOIN lis.config_locations AS src
  ON sd.src_id = src.id AND src.location_type = 'CITY' AND src.is_expired = 0
LEFT JOIN lis.config_locations AS dst
  ON sd.dest_id = dst.id AND dst.location_type = 'CITY' AND dst.is_expired = 0
WHERE
  sd.__time >= CAST('2026-08-26 00:00:00' AS TIMESTAMP)
  AND sd.__time < CAST('2026-09-09 00:00:00' AS TIMESTAMP)
  AND sd.country = 'IND'
  AND sd.operator_id = 25946
GROUP BY
  sd.src_id,
  sd.dest_id,
  src.location_name,
  dst.location_name
ORDER BY
  total_searches DESC
LIMIT 1500;


-- ============================================================
-- 3) SD-level fraud check (adapted from your burst template)
--    Grain: mobile × SD (closest to your query, with SD columns)
--    WARNING: returns mobile (PII) — handle securely
--    Burst day = daily DISTINCT TIN > 3 on that SD
--    Flag if burst_day_frequency >= 3
--    Exclude: prior-year bookers OR any other-operator bookers in lookback
-- ============================================================
WITH excluded_mobiles AS (
  SELECT DISTINCT
    mobile
  FROM transaction.bus_ticket_events
  WHERE
    country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2025-08-26 00:00:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-09-09 00:00:00' AS TIMESTAMP)
    AND (
      time_of_event < CAST('2026-08-26 00:00:00' AS TIMESTAMP) OR operator_id <> 25946
    )
    AND NOT mobile IS NULL
    AND mobile <> ''
), daily_agg AS (
  SELECT
    mobile,
    source_location_id,
    destination_location_id,
    CAST(time_of_event AS DATE) AS event_date,
    COUNT(DISTINCT tin) AS daily_txn,
    SUM(seat_count) AS daily_seats
  FROM transaction.bus_ticket_events
  WHERE
    country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2026-08-26 00:00:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-09-09 00:00:00' AS TIMESTAMP)
    AND operator_id = 25946
    AND NOT mobile IN (
      SELECT mobile FROM excluded_mobiles
    )
  GROUP BY
    mobile,
    source_location_id,
    destination_location_id,
    CAST(time_of_event AS DATE)
), mobile_sd_agg AS (
  SELECT
    mobile,
    source_location_id,
    destination_location_id,
    SUM(daily_txn) AS total_txn,
    SUM(daily_seats) AS total_seats,
    MAX(daily_txn) AS max_daily_txn,
    MAX_BY(daily_seats, daily_txn) AS seats_on_peak_day,
    COUNT(CASE WHEN daily_txn > 3 THEN 1 END) AS burst_day_frequency
  FROM daily_agg
  GROUP BY
    mobile,
    source_location_id,
    destination_location_id
)
SELECT
  m.mobile,
  m.source_location_id,
  src.location_name AS source_location_name,
  m.destination_location_id,
  dst.location_name AS destination_location_name,
  m.total_txn,
  m.total_seats,
  m.max_daily_txn,
  m.seats_on_peak_day,
  m.burst_day_frequency
FROM mobile_sd_agg AS m
LEFT JOIN lis.config_locations AS src
  ON m.source_location_id = src.id
  AND src.location_type = 'CITY'
  AND src.is_expired = 0
LEFT JOIN lis.config_locations AS dst
  ON m.destination_location_id = dst.id
  AND dst.location_type = 'CITY'
  AND dst.is_expired = 0
WHERE
  m.burst_day_frequency >= 3
ORDER BY
  m.burst_day_frequency DESC,
  m.total_txn DESC
LIMIT 1500;


-- ============================================================
-- 3b) OPTIONAL — SD rollup of flagged mobiles (no mobile in output)
-- ============================================================
/*
WITH excluded_mobiles AS (
  SELECT DISTINCT mobile
  FROM transaction.bus_ticket_events
  WHERE country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2025-08-26 00:00:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-09-09 00:00:00' AS TIMESTAMP)
    AND (time_of_event < CAST('2026-08-26 00:00:00' AS TIMESTAMP) OR operator_id <> 25946)
    AND mobile IS NOT NULL AND mobile <> ''
), daily_agg AS (
  SELECT
    mobile, source_location_id, destination_location_id,
    CAST(time_of_event AS DATE) AS event_date,
    COUNT(DISTINCT tin) AS daily_txn,
    SUM(seat_count) AS daily_seats
  FROM transaction.bus_ticket_events
  WHERE country_code = 'IND'
    AND event_type = 101
    AND time_of_event >= CAST('2026-08-26 00:00:00' AS TIMESTAMP)
    AND time_of_event < CAST('2026-09-09 00:00:00' AS TIMESTAMP)
    AND operator_id = 25946
    AND mobile NOT IN (SELECT mobile FROM excluded_mobiles)
  GROUP BY 1,2,3,4
), mobile_sd_agg AS (
  SELECT
    mobile, source_location_id, destination_location_id,
    SUM(daily_txn) AS total_txn,
    SUM(daily_seats) AS total_seats,
    MAX(daily_txn) AS max_daily_txn,
    COUNT(CASE WHEN daily_txn > 3 THEN 1 END) AS burst_day_frequency
  FROM daily_agg
  GROUP BY 1,2,3
  HAVING COUNT(CASE WHEN daily_txn > 3 THEN 1 END) >= 3
)
SELECT
  source_location_id,
  destination_location_id,
  COUNT(DISTINCT mobile) AS flagged_mobile_count,
  SUM(total_txn) AS total_txn_of_flagged,
  SUM(total_seats) AS total_seats_of_flagged,
  AVG(CAST(max_daily_txn AS DOUBLE)) AS avg_max_daily_txn,
  AVG(CAST(burst_day_frequency AS DOUBLE)) AS avg_burst_day_frequency,
  MAX(burst_day_frequency) AS max_burst_day_frequency
FROM mobile_sd_agg
GROUP BY 1,2
ORDER BY flagged_mobile_count DESC;
*/
