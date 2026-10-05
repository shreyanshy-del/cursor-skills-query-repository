-- =============================================================================
-- Q3: Days after onward booking (Day 0 = onward DOI)
-- Among onward TRANSACTORS, how many session / transact a return trip on D+N
--
-- Day 0 = date of issue (DOI, IST) of forward booking
-- Day N = date_diff(return_event_date_IST, onward_doi)
--
-- Outputs (per days_since_doi, optional user_type / dbd):
--   onward_bookers_base
--   return_search_bookers_on_day   (users with ≥1 reverse search on that day)
--   return_trip_sessions_on_day
--   return_bookers_on_day
--   return_txns_on_day
--   pct of onward bookers sessioning return on that day
--   pct of onward bookers transacting return on that day
--
-- Lookahead: D+0 … D+13 (14 days post onward DOI)
-- Cohort: onward bookings 24 Aug – 6 Sep 2026
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
-- Expand return SEARCH events tagged with days since onward DOI
return_search_days AS (
  SELECT
    o.rb_user_id,
    o.user_type,
    o.dbd,
    o.onward_doi,
    s.mri_session_id AS return_session_id,
    DATE_DIFF(
      'day',
      o.onward_doi,
      CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE)
    ) AS days_since_doi
  FROM onward_txn o
  INNER JOIN user_interaction.search_details s
    ON s.rb_user_id = o.rb_user_id
   AND s.src_id = o.dest_id
   AND s.dest_id = o.src_id
   AND s.country = 'IND'
   AND s.os = 'Android'
   AND s.mri_session_id IS NOT NULL
   AND s.__time > o.onward_txn_time
   AND CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE)
       <= o.onward_doi + INTERVAL '13' DAY   -- D+0 .. D+13
),
-- Expand return BOOKING events
return_txn_days AS (
  SELECT
    o.rb_user_id,
    o.user_type,
    o.dbd,
    o.onward_doi,
    rt.tin AS return_tin,
    DATE_DIFF(
      'day',
      o.onward_doi,
      CAST(DATE_TRUNC('day', AT_TIMEZONE(rt.time_of_event, 'Asia/Kolkata')) AS DATE)
    ) AS days_since_doi
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
   AND CAST(DATE_TRUNC('day', AT_TIMEZONE(rt.time_of_event, 'Asia/Kolkata')) AS DATE)
       <= o.onward_doi + INTERVAL '13' DAY
),
day_spine AS (
  SELECT day_n FROM UNNEST(SEQUENCE(0, 13)) AS t(day_n)
),
base_users AS (
  SELECT
    user_type,
    dbd,
    COUNT(DISTINCT rb_user_id) AS onward_bookers
  FROM onward_txn
  GROUP BY 1, 2
),
search_by_day AS (
  SELECT
    user_type,
    dbd,
    days_since_doi,
    COUNT(DISTINCT rb_user_id) AS return_search_bookers_on_day,
    COUNT(DISTINCT return_session_id) AS return_trip_sessions_on_day
  FROM return_search_days
  WHERE days_since_doi BETWEEN 0 AND 13
  GROUP BY 1, 2, 3
),
txn_by_day AS (
  SELECT
    user_type,
    dbd,
    days_since_doi,
    COUNT(DISTINCT rb_user_id) AS return_bookers_on_day,
    COUNT(DISTINCT return_tin) AS return_txns_on_day
  FROM return_txn_days
  WHERE days_since_doi BETWEEN 0 AND 13
  GROUP BY 1, 2, 3
)
SELECT
  b.user_type,
  b.dbd,
  d.day_n AS days_since_doi,          -- 0 = onward DOI day
  b.onward_bookers AS onward_bookers_base,
  COALESCE(s.return_search_bookers_on_day, 0) AS return_search_bookers_on_day,
  COALESCE(s.return_trip_sessions_on_day, 0) AS return_trip_sessions_on_day,
  COALESCE(t.return_bookers_on_day, 0) AS return_bookers_on_day,
  COALESCE(t.return_txns_on_day, 0) AS return_txns_on_day,
  ROUND(100.0 * COALESCE(s.return_search_bookers_on_day, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS pct_onward_bookers_sessioning_return,
  ROUND(100.0 * COALESCE(t.return_bookers_on_day, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS pct_onward_bookers_transacting_return
FROM base_users b
CROSS JOIN day_spine d
LEFT JOIN search_by_day s
  ON b.user_type = s.user_type
 AND b.dbd = s.dbd
 AND d.day_n = s.days_since_doi
LEFT JOIN txn_by_day t
  ON b.user_type = t.user_type
 AND b.dbd = t.dbd
 AND d.day_n = t.days_since_doi
ORDER BY b.user_type, b.dbd, d.day_n;


-- -----------------------------------------------------------------------------
-- Q3b (optional): Overall curve — collapse user_type / DBD
-- Same base logic, single D+0..D+13 curve for the destination set
-- -----------------------------------------------------------------------------
/*
WITH dest_ids AS ( ... same ... ),
onward_txn AS ( ... same ... ),
return_search_days AS ( ... same without needing user_type/dbd in SELECT if collapsed ... ),
...
SELECT
  days_since_doi,
  (SELECT COUNT(DISTINCT rb_user_id) FROM onward_txn) AS onward_bookers_base,
  COUNT(DISTINCT rb_user_id) FILTER ... 
*/
