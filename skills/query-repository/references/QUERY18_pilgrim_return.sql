WITH b AS (
  SELECT tin, rb_user_id, source_location_id, destination_location_id, date_of_journey, time_of_event
  FROM transaction.bus_ticket_events
  WHERE event_type = 101
    AND time_of_event >= TIMESTAMP '2026-05-26 00:00:00'
    AND time_of_event <  TIMESTAMP '2026-06-25 00:00:00'
    AND country_code = 'IND'
    AND rb_user_id IS NOT NULL
)
SELECT
  CASE WHEN t1.destination_location_id IN (134,71756,842,802,66007,70429,663,427,759,197504,1001,735,84832,489,501,293,231,76480,466,517,960,750,78796,74690,808,70628,1496,177,142,1136,669,403,217,68747,81826,496,94782,133,83409,747,305974,77093,76187,471,247,1343,68705,1141,93580,1148,75103,711,77705,520,65815,1528,275,636,987,879,189,1061,1007,80438,1128,70346,77167,1351,534,576,1219,68871,94509,975,65805,1242,69526,204358,94877,1459,196,74130,70030,196420,216354,84310,194482,77687,1157,298723,93189,70983,198750,84848,202212,196752,74708,215191,200347,77620,77530,300439)
       THEN 'Pilgrim' ELSE 'Non-Pilgrim' END AS destination_type,
  COUNT(DISTINCT t1.tin)        AS total_confirmed_bookings,
  COUNT(DISTINCT t1.rb_user_id) AS total_distinct_users,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id =  t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=24 THEN t2.tin END) AS return_bookings_24h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id =  t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=48 THEN t2.tin END) AS return_bookings_48h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id =  t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=72 THEN t2.tin END) AS return_bookings_72h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id =  t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=24 THEN t2.rb_user_id END) AS return_users_24h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id =  t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=48 THEN t2.rb_user_id END) AS return_users_48h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id =  t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=72 THEN t2.rb_user_id END) AS return_users_72h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id <> t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=24 THEN t2.tin END) AS source_to_other_bookings_24h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id <> t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=48 THEN t2.tin END) AS source_to_other_bookings_48h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id <> t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=72 THEN t2.tin END) AS source_to_other_bookings_72h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id <> t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=24 THEN t2.rb_user_id END) AS source_to_other_users_24h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id <> t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=48 THEN t2.rb_user_id END) AS source_to_other_users_48h,
  COUNT(DISTINCT CASE WHEN t2.destination_location_id <> t1.source_location_id AND ABS(DATE_DIFF('hour',t1.date_of_journey,t2.date_of_journey))<=72 THEN t2.rb_user_id END) AS source_to_other_users_72h
FROM b t1
LEFT JOIN b t2
  ON t2.rb_user_id = t1.rb_user_id
  AND t2.source_location_id = t1.destination_location_id
  AND t2.time_of_event > t1.time_of_event
  AND ABS(DATE_DIFF('hour', t1.date_of_journey, t2.date_of_journey)) <= 72
GROUP BY 1
LIMIT 1500;