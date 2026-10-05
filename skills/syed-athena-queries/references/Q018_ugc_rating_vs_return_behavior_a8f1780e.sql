-- Athena saved query (Product_B2C_Intl)
-- ID: a8f1780e-6519-4fb4-bce7-c37a0276fb91
-- Name: UGC Rating vs Return Behavior - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH universe AS ( SELECT DISTINCT rb_user_id FROM transaction.bus_ticket_events WHERE date_of_issue >= TIMESTAMP '2026-05-01 00:00:00' AND date_of_issue < TIMESTAMP '2026-05-08 00:00:00' AND event_type = 101 AND country_code = 'IND' AND rb_user_id > 0 ) SELECT ROUND(AVG(CASE WHEN bte.time_of_event >= TIMESTAMP '2026-05-01 00:00:00' AND bte.time_of_event < TIMESTAMP '2026-05-08 00:00:00' THEN bte.ticket_fare END), 2) AS avg_ticket_fare_pre, ROUND(AVG(CASE WHEN bte.time_of_event >= TIMESTAMP '2026-05-08 00:00:00' AND bte.time_of_event < TIMESTAMP '2026-06-18 00:00:00' THEN bte.ticket_fare END), 2) AS avg_ticket_fare_post, ROUND( AVG(CASE WHEN bte.time_of_event >= TIMESTAMP '2026-05-08 00:00:00' AND bte.time_of_event < TIMESTAMP '2026-06-18 00:00:00' THEN bte.ticket_fare END) - AVG(CASE WHEN bte.time_of_event >= TIMESTAMP '2026-05-01 00:00:00' AND bte.time_of_event < TIMESTAMP '2026-05-08 00:00:00' THEN bte.ticket_fare END), 2 ) AS asp_change FROM transaction.bus_ticket_events bte INNER JOIN universe u ON bte.rb_user_id = u.rb_user_id WHERE bte.date_of_issue >= TIMESTAMP '2026-05-01 00:00:00' AND bte.date_of_issue < TIMESTAMP '2026-06-18 00:00:00' AND bte.event_type = 101 AND bte.country_code = 'IND';
