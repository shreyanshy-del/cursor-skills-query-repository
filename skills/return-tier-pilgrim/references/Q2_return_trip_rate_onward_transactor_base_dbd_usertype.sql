-- =============================================================================
-- Q2: Return Trip Rate + Return Trip Sessions
-- BASE = onward TRANSACTORS (booked A→B), NOT onward searchers
-- Cuts: DBD (of onward booking) × user_type
-- Android IND | Mehar dest_ids | 14-day onward cohort
--
-- Definitions
--   Onward txn         : event_type=101, dest in tier, Android app channels
--   Return search      : same user searches B→A after onward booking time
--   Return booking     : same user books B→A (event_type=101) after onward booking
--   Return lookforward : within 14 days after onward DOI (IST)
--
-- Metrics
--   onward_txns                 = DISTINCT tin (base volume)
--   onward_bookers              = DISTINCT rb_user_id (base users)
--   return_trip_sessions        = DISTINCT return mri_session_id from onward bookers
--   return_search_bookers       = DISTINCT onward bookers who searched return
--   return_bookers              = DISTINCT onward bookers who booked return
--   return_txns                 = DISTINCT return tin
--   return_trip_session_rate %  = return_search_bookers / onward_bookers
--   return_trip_booking_rate %  = return_bookers / onward_bookers
-- =============================================================================

WITH dest_ids AS (
  SELECT dest_id FROM (VALUES
    (122),(123),(124),(126),(130),(141),(313),(462),(551),(733),(807),(933),
    (1073),(1304),(1429),(70015),(70633),(71145),(74820),(76397),(82100),
    (94113),(95174),(201126),(201665),(215450)
  ) AS t(dest_id)  -- <-- Tier 1 example; replace for other tiers / OVERALL
),
onward_txn AS (
  SELECT
    b.rb_user_id,
    b.tin AS onward_tin,
    b.source_location_id AS src_id,
    b.destination_location_id AS dest_id,
    b.time_of_event AS onward_txn_time,
    CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_issue, 'Asia/Kolkata')) AS DATE) AS onward_doi,
    CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata')) AS DATE) AS onward_doj,
    UPPER(TRIM(COALESCE(b.user_type, ''))) AS user_type,
    CASE
      WHEN DATE_DIFF(
             'day',
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_issue, 'Asia/Kolkata')) AS DATE),
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata')) AS DATE)
           ) <= 0 THEN '0. Same Day'
      WHEN DATE_DIFF(
             'day',
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_issue, 'Asia/Kolkata')) AS DATE),
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata')) AS DATE)
           ) = 1 THEN '1. DBD 1'
      WHEN DATE_DIFF(
             'day',
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_issue, 'Asia/Kolkata')) AS DATE),
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata')) AS DATE)
           ) = 2 THEN '2. DBD 2'
      WHEN DATE_DIFF(
             'day',
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_issue, 'Asia/Kolkata')) AS DATE),
             CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata')) AS DATE)
           ) BETWEEN 3 AND 7 THEN '3. DBD 3-7'
      ELSE '4. DBD 8+'
    END AS dbd
  FROM transaction.bus_ticket_events b
  INNER JOIN dest_ids d ON b.destination_location_id = d.dest_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.tin IS NOT NULL
    AND b.rb_user_id > 0
    AND b.sales_channel IN ('RB:MOBILEWEB#droidapp', 'DROIDAPP')
    AND b.date_of_issue >= TIMESTAMP '2026-08-23 18:30:00'
    AND b.date_of_issue <  TIMESTAMP '2026-09-06 18:30:00'
),
onward_bookers AS (
  SELECT DISTINCT rb_user_id, user_type, dbd, onward_doi
  FROM onward_txn
),
-- Return searches by onward bookers (reverse route after onward txn)
return_search AS (
  SELECT
    o.rb_user_id,
    o.user_type,
    o.dbd,
    o.onward_doi,
    o.onward_tin,
    s.mri_session_id AS return_session_id,
    s.__time AS return_search_time
  FROM onward_txn o
  INNER JOIN user_interaction.search_details s
    ON s.rb_user_id = o.rb_user_id
   AND s.src_id = o.dest_id
   AND s.dest_id = o.src_id
   AND s.country = 'IND'
   AND s.os = 'Android'
   AND s.mri_session_id IS NOT NULL
   AND s.__time > o.onward_txn_time
   AND s.__time < o.onward_txn_time + INTERVAL '14' DAY
),
-- Return bookings by onward bookers
return_txn AS (
  SELECT
    o.rb_user_id,
    o.user_type,
    o.dbd,
    o.onward_doi,
    o.onward_tin,
    rt.tin AS return_tin,
    rt.time_of_event AS return_txn_time
  FROM onward_txn o
  INNER JOIN transaction.bus_ticket_events rt
    ON rt.rb_user_id = o.rb_user_id
   AND rt.source_location_id = o.dest_id
   AND rt.destination_location_id = o.src_id
   AND rt.country_code = 'IND'
   AND rt.event_type = 101
   AND rt.tin IS NOT NULL
   AND rt.sales_channel IN ('RB:MOBILEWEB#droidapp', 'DROIDAPP')
   AND rt.time_of_event > o.onward_txn_time
   AND rt.time_of_event < o.onward_txn_time + INTERVAL '14' DAY
),
base_agg AS (
  SELECT
    dbd,
    user_type,
    COUNT(DISTINCT onward_tin) AS onward_txns,
    COUNT(DISTINCT rb_user_id) AS onward_bookers
  FROM onward_txn
  GROUP BY 1, 2
),
ret_search_agg AS (
  SELECT
    dbd,
    user_type,
    COUNT(DISTINCT return_session_id) AS return_trip_sessions,
    COUNT(DISTINCT rb_user_id) AS return_search_bookers
  FROM return_search
  GROUP BY 1, 2
),
ret_txn_agg AS (
  SELECT
    dbd,
    user_type,
    COUNT(DISTINCT return_tin) AS return_txns,
    COUNT(DISTINCT rb_user_id) AS return_bookers
  FROM return_txn
  GROUP BY 1, 2
)
SELECT
  b.dbd,
  b.user_type,
  b.onward_txns,
  b.onward_bookers,
  COALESCE(rs.return_trip_sessions, 0) AS return_trip_sessions,
  COALESCE(rs.return_search_bookers, 0) AS return_search_bookers,
  COALESCE(rt.return_txns, 0) AS return_txns,
  COALESCE(rt.return_bookers, 0) AS return_bookers,
  ROUND(100.0 * COALESCE(rs.return_search_bookers, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS return_trip_session_rate_pct,   -- share of onward bookers who SEARCH return
  ROUND(100.0 * COALESCE(rt.return_bookers, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS return_trip_booking_rate_pct    -- share of onward bookers who BOOK return
FROM base_agg b
LEFT JOIN ret_search_agg rs
  ON b.dbd = rs.dbd AND b.user_type = rs.user_type
LEFT JOIN ret_txn_agg rt
  ON b.dbd = rt.dbd AND b.user_type = rt.user_type
ORDER BY 1, 2;
