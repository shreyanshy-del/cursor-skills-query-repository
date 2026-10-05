-- Athena saved query (Product_B2C_Intl)
-- ID: beebd356-ff5c-475a-8a8f-bfab48fd40b0
-- Name: Student same routeid multiple txns - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH agg AS ( SELECT MONTH(date_of_issue) month_of_issue, rb_user_id, date_of_journey, route_id, COUNT(DISTINCT tin) txn_count FROM transaction.bus_ticket_events AS bte WHERE 1=1 AND bte.time_of_event >= CAST('2026-01-01 00:00:00' AS TIMESTAMP) AND bte.time_of_event < CAST('2026-07-01 00:00:00' AS TIMESTAMP) AND bte.event_type = 101 AND bte.event_class = 2 AND tin IS NOT NULL AND rb_user_id > 0 AND bte.country_code = 'IND' AND bte.travellers_age[1] < 24 GROUP BY 1, 2, 3, 4 ) SELECT month_of_issue, CASE WHEN txn_count <= 5 THEN CAST(txn_count AS VARCHAR) ELSE '5+' END AS txn_count, COUNT(DISTINCT rb_user_id) user_count FROM agg GROUP BY 1, 2
