-- Athena saved query (Product_B2C_Intl)
-- ID: 0e6902e5-563d-4de5-966c-f782754d564b
-- Name: UGC Rating vs Return Behavior - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH universe AS ( SELECT rb_user_id, MIN(time_of_event) AS first_txn_time FROM transaction.bus_ticket_events WHERE date_of_issue >= TIMESTAMP '2026-05-01 00:00:00' AND date_of_issue < TIMESTAMP '2026-05-08 00:00:00' AND time_of_event >= TIMESTAMP '2026-05-01 00:00:00' AND time_of_event < TIMESTAMP '2026-05-08 00:00:00' AND event_type = 101 AND country_code = 'IND' AND rb_user_id > 0 GROUP BY 1 ), returned AS ( SELECT DISTINCT u.rb_user_id FROM universe u INNER JOIN transaction.bus_ticket_events bte ON bte.rb_user_id = u.rb_user_id WHERE bte.date_of_issue >= TIMESTAMP '2026-05-01 00:00:00' AND bte.date_of_issue < TIMESTAMP '2026-06-18 00:00:00' AND bte.time_of_event > u.first_txn_time AND bte.event_type = 101 AND bte.country_code = 'IND' ) SELECT COUNT(*) AS user_count, COUNT(r.rb_user_id) AS returned_transact_users, ROUND(100.0 * COUNT(r.rb_user_id) / COUNT(*), 2) AS pct_returned_transact FROM universe u LEFT JOIN returned r ON u.rb_user_id = r.rb_user_id;
