-- =============================================================================
-- Single Women Pax vs All Single Pax
-- Share of transactions with Start of Journey in 7 PM – 12 AM IST (hours 19–23)
-- Android · IND · BUS · confirm event_type=101 event_class=2
--
-- CHANGE ONLY params t0 / t1 (UTC).
--
-- Definitions:
--   Single pax        = seat_count = 1
--   Single women pax  = seat_count = 1
--                       AND travellers_gender[1] = FEMALE
--                       AND CARDINALITY(travellers_gender) = 1
--   Start of journey  = date_of_journey (UTC → IST)  [NOT boarding_time]
--   Post 7 PM window  = HOUR(date_of_journey IST) BETWEEN 19 AND 23  (7pm–11:59pm)
-- =============================================================================

WITH params AS (
  SELECT
    -- >>> CHANGE ANALYSIS DATE RANGE ONLY <<<
    TIMESTAMP '2026-03-31 18:30:00' AS t0,
    TIMESTAMP '2026-06-30 18:30:00' AS t1
),

base AS (
  SELECT
    b.tin,
    b.rb_user_id,
    b.seat_count,
    b.date_of_journey,
    b.travellers_gender,
    HOUR(CAST(AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata') AS TIMESTAMP)) AS journey_start_hour_ist,
    CASE
      WHEN b.seat_count = 1
       AND b.travellers_gender IS NOT NULL
       AND CARDINALITY(b.travellers_gender) = 1
       AND UPPER(TRIM(CAST(element_at(b.travellers_gender, 1) AS VARCHAR))) = 'FEMALE'
      THEN 'Single_Women_Pax'
      WHEN b.seat_count = 1
       AND b.travellers_gender IS NOT NULL
       AND CARDINALITY(b.travellers_gender) = 1
       AND UPPER(TRIM(CAST(element_at(b.travellers_gender, 1) AS VARCHAR))) = 'MALE'
      THEN 'Single_Male_Pax'
      WHEN b.seat_count = 1
      THEN 'Single_Pax_OtherGender'
      ELSE NULL
    END AS pax_segment,
    CASE
      WHEN b.date_of_journey IS NOT NULL
       AND HOUR(CAST(AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata') AS TIMESTAMP)) BETWEEN 19 AND 23
      THEN 1 ELSE 0
    END AS is_start_7pm_to_12am
  FROM transaction.bus_ticket_events b
  CROSS JOIN params p
  WHERE b.time_of_event >= p.t0 AND b.time_of_event < p.t1
    AND b.country_code = 'IND'
    AND b.event_type = 101
    AND b.event_class = 2
    AND b.sales_channel LIKE '%droidapp%'
    AND b.seat_count = 1
    AND b.date_of_journey IS NOT NULL
),

flagged AS (
  SELECT *
  FROM base
  WHERE pax_segment IS NOT NULL
),

seg AS (
  SELECT
    'All_Single_Pax' AS segment,
    tin,
    rb_user_id,
    is_start_7pm_to_12am,
    journey_start_hour_ist
  FROM flagged

  UNION ALL

  SELECT
    'Single_Women_Pax' AS segment,
    tin,
    rb_user_id,
    is_start_7pm_to_12am,
    journey_start_hour_ist
  FROM flagged
  WHERE pax_segment = 'Single_Women_Pax'

  UNION ALL

  SELECT
    'Single_Male_Pax' AS segment,
    tin,
    rb_user_id,
    is_start_7pm_to_12am,
    journey_start_hour_ist
  FROM flagged
  WHERE pax_segment = 'Single_Male_Pax'
)

SELECT
  segment,
  COUNT(DISTINCT tin) AS single_pax_txns,
  COUNT(DISTINCT CASE WHEN is_start_7pm_to_12am = 1 THEN tin END) AS txns_start_7pm_to_12am,
  COUNT(DISTINCT CASE WHEN is_start_7pm_to_12am = 1 THEN tin END) * 100.0
    / NULLIF(COUNT(DISTINCT tin), 0) AS txn_share_pct_start_7pm_to_12am,
  COUNT(DISTINCT rb_user_id) AS single_pax_users,
  COUNT(DISTINCT CASE WHEN is_start_7pm_to_12am = 1 THEN rb_user_id END) AS users_start_7pm_to_12am,
  COUNT(DISTINCT CASE WHEN is_start_7pm_to_12am = 1 THEN rb_user_id END) * 100.0
    / NULLIF(COUNT(DISTINCT rb_user_id), 0) AS user_share_pct_start_7pm_to_12am
FROM seg
GROUP BY 1
ORDER BY
  CASE segment
    WHEN 'All_Single_Pax' THEN 1
    WHEN 'Single_Women_Pax' THEN 2
    WHEN 'Single_Male_Pax' THEN 3
    ELSE 4
  END;
