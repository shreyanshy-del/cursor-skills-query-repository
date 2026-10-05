-- =============================================================================
-- Return Trip — Women_SRP vs Female_SVOC
-- Android · IND · BUS · confirm event_type=101 event_class=2
--
-- Return check = 14 DAYS OF DOI (per booker), NOT a 14-day cohort window.
--   After first confirm (doi_ts):
--     (A) Return SEARCH session  → search_details, same rb_user_id, OR
--     (B) Return TRANSACTION     → BTE confirm, same rb_user_id
--   within (doi_ts, doi_ts + 14 days]
--
-- Cohort (booker window) — change t0 / t1 as needed.
--   t_ret must be ≥ t1 + 14d so late-cohort bookers still get full lookforward.
-- Default: Q2 2026 bookers → lookforward through 2026-07-14 18:30 UTC
-- =============================================================================

WITH params AS (
  SELECT
    -- >>> BOOKER COHORT WINDOW (UTC) <<<
    TIMESTAMP '2026-03-31 18:30:00' AS t0,   -- Q2 start IST
    TIMESTAMP '2026-06-30 18:30:00' AS t1,   -- Q2 end IST
    -- must cover DOI + 14d for every booker in [t0, t1)
    TIMESTAMP '2026-07-14 18:30:00' AS t_ret
),

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

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
    AND ux.header_country = 'IND'
    AND ux.header_bu = 'BUS'
    AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value = 'Women'
),

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
),

-- Return SEARCH within 14 days of DOI
return_search AS (
  SELECT DISTINCT s.rb_user_id, s.segment
  FROM seg s
  CROSS JOIN params p
  INNER JOIN user_interaction.search_details rs
    ON rs.rb_user_id = s.rb_user_id
   AND rs.__time > s.doi_ts
   AND rs.__time <= s.doi_ts + INTERVAL '14' DAY
   AND rs.__time < p.t_ret
   AND rs.country = 'IND'
   AND rs.os = 'Android'
),

-- Return TXN within 14 days of DOI
return_txn AS (
  SELECT DISTINCT s.rb_user_id, s.segment
  FROM seg s
  CROSS JOIN params p
  INNER JOIN transaction.bus_ticket_events rt
    ON rt.rb_user_id = s.rb_user_id
   AND rt.time_of_event > s.doi_ts
   AND rt.time_of_event <= s.doi_ts + INTERVAL '14' DAY
   AND rt.time_of_event < p.t_ret
   AND rt.country_code = 'IND'
   AND rt.event_type = 101
   AND rt.event_class = 2
)

SELECT
  s.segment,
  COUNT(DISTINCT s.rb_user_id) AS bookers,
  COUNT(DISTINCT rs.rb_user_id) AS return_search_users_14d,
  COUNT(DISTINCT rt.rb_user_id) AS return_txn_users_14d,
  COUNT(DISTINCT CASE
    WHEN rs.rb_user_id IS NOT NULL OR rt.rb_user_id IS NOT NULL THEN s.rb_user_id
  END) AS either_return_users_14d,
  COUNT(DISTINCT rs.rb_user_id) * 100.0
    / NULLIF(COUNT(DISTINCT s.rb_user_id), 0) AS return_search_rate_pct,
  COUNT(DISTINCT rt.rb_user_id) * 100.0
    / NULLIF(COUNT(DISTINCT s.rb_user_id), 0) AS return_txn_rate_pct,
  COUNT(DISTINCT CASE
    WHEN rs.rb_user_id IS NOT NULL OR rt.rb_user_id IS NOT NULL THEN s.rb_user_id
  END) * 100.0
    / NULLIF(COUNT(DISTINCT s.rb_user_id), 0) AS return_trip_rate_pct
FROM seg s
LEFT JOIN return_search rs
  ON s.rb_user_id = rs.rb_user_id AND s.segment = rs.segment
LEFT JOIN return_txn rt
  ON s.rb_user_id = rt.rb_user_id AND s.segment = rt.segment
GROUP BY 1
ORDER BY 1;
