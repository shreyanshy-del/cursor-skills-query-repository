-- SAMPLE: raw confirmed India tickets — smallest window (1 hour)
SELECT tin, rb_user_id, source_location_id, destination_location_id,
       source_location, destination_location, operator_id,
       CAST(date_of_issue AS VARCHAR) AS date_of_issue,
       CAST(date_of_journey AS VARCHAR) AS date_of_journey,
       country_code, event_type, event_class
FROM transaction.bus_ticket_events
WHERE country_code = 'IND' AND event_type = 101 AND event_class = 2
  AND date_of_issue >= TIMESTAMP '2026-06-10 00:00:00'
  AND date_of_issue < TIMESTAMP '2026-06-10 01:00:00'
LIMIT 50;
