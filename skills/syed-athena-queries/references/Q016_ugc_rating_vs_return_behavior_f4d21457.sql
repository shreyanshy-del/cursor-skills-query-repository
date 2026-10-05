-- Athena saved query (Product_B2C_Intl)
-- ID: f4d21457-8256-4770-a182-0529f37f563b
-- Name: UGC Rating vs Return Behavior - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH universe AS ( SELECT DISTINCT rb_user_id FROM transaction.bus_ticket_events WHERE date_of_issue >= TIMESTAMP '2026-05-01 00:00:00' AND date_of_issue < TIMESTAMP '2026-05-08 00:00:00' AND time_of_event >= TIMESTAMP '2026-05-01 00:00:00' AND time_of_event < TIMESTAMP '2026-05-08 00:00:00' AND event_type = 101 AND country_code = 'IND' AND rb_user_id > 0 ), route_txns AS ( SELECT bte.rb_user_id, bte.source_location, bte.destination_location, COUNT(DISTINCT bte.tin) AS txn_count FROM transaction.bus_ticket_events bte INNER JOIN universe u ON bte.rb_user_id = u.rb_user_id WHERE bte.date_of_issue >= TIMESTAMP '2026-05-01 00:00:00' AND bte.date_of_issue < TIMESTAMP '2026-06-18 00:00:00' AND bte.event_type = 101 AND bte.country_code = 'IND' AND bte.source_location IS NOT NULL AND bte.destination_location IS NOT NULL GROUP BY 1, 2, 3 ) SELECT (SELECT COUNT(*) FROM universe) AS user_count, COUNT(DISTINCT rb_user_id) AS repeat_user_count, ROUND( 100.0 * COUNT(DISTINCT rb_user_id) / (SELECT COUNT(*) FROM universe), 2 ) AS pct_repeat_same_route FROM route_txns WHERE txn_count >= 2;
