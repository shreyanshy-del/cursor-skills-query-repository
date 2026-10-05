-- Athena saved query (Product_B2C_Intl)
-- ID: 3e4d0f67-ae0d-4ee0-a611-2f8e3772ca0c
-- Name: 1 or 2 character name Tins - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT CASE WHEN t.sales_channel = 'RB:MOBILEWEB#droidapp' THEN 'Android' WHEN t.sales_channel = 'RB:MOBILEWEB#iosapp' THEN 'iOS' WHEN t.sales_channel = 'WEBDIRECT' THEN 'Desktop' WHEN t.sales_channel = 'MOBILEWEB' THEN 'MobWeb' END AS sales_channel, UPPER(t.user_type) AS user_type, COUNT(DISTINCT t.tin) Overall_Txn_Count, COUNT(DISTINCT CASE WHEN length(t.name) = 1 THEN t.tin END) AS "1 character named Txn_Count", COUNT(DISTINCT CASE WHEN length(t.name) = 2 THEN t.tin END) AS "2 character named Txn_Count" FROM "transaction"."bus_ticket_events" t WHERE t.time_of_event >= TIMESTAMP '2025-12-31 18:30:00' AND t.time_of_event < TIMESTAMP '2026-01-31 18:30:00' AND t.country_code = 'IND' AND t.event_class = 2 AND t.event_type = 101 AND business_unit IN ('REDBUS_IN') AND sales_channel IN ('RB:MOBILEWEB#droidapp', 'RB:MOBILEWEB#iosapp', 'WEBDIRECT', 'MOBILEWEB') GROUP BY 1,2 ORDER BY 1 DESC, 2, 3 DESC
