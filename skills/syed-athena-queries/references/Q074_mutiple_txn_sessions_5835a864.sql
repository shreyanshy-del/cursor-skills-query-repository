-- Athena saved query (Product_B2C_Intl)
-- ID: 5835a864-8a92-4c33-851e-93c6a5e28193
-- Name: Mutiple txn sessions - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT CASE WHEN txn_count = 1 THEN 'Single Txn Session' ELSE 'Multiple Txn Session' END AS txn_count, COUNT(DISTINCT mri_session_id) sessions FROM ( SELECT mri_session_id, COUNT(DISTINCT tin) txn_count FROM "transaction"."bus_ticket_events" t WHERE date_of_issue >= TIMESTAMP '2026-04-27 00:00:00' AND date_of_issue < TIMESTAMP '2026-05-05 00:00:00' AND country_code = 'IND' AND tin IS NOT NULL -- AND event_class = 2 AND event_type = 101 GROUP BY 1 ) a GROUP BY 1 ORDER BY 1
