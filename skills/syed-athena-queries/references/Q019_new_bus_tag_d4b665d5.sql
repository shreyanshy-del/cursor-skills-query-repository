-- Athena saved query (Product_B2C_Intl)
-- ID: d4b665d5-01cb-4741-8055-4e783935ab64
-- Name: New Bus Tag - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH rtc_ops AS ( SELECT DISTINCT CAST(vendor_id AS BIGINT) AS operator_id, bo_name FROM lis.bo_mappings WHERE is_rtc = 'RTC' ), new_bus AS ( SELECT DISTINCT route_id FROM "user_interaction"."search_route_details" s INNER JOIN rtc_ops r ON s.operator_id = r.operator_id WHERE s.__time >= TIMESTAMP '2026-06-01' AND s.__time < TIMESTAMP '2026-07-01' AND contains(s.persuasion_id, '68') AND s.country = 'IND' AND s.channel = 'MOBILE_APP' AND s.os = 'Android' ) -- , -- Txns AS ( SELECT t.operator_id, r.bo_name rtc_name, -- CASE WHEN s.route_id > 0 THEN 'New Bus' ELSE 'non-New Bus' END AS is_new_bus, COUNT(DISTINCT CASE WHEN s.route_id > 0 THEN tin END) AS new_bus_txm_count, COUNT(DISTINCT tin) txn_count FROM "transaction"."bus_ticket_events" t INNER JOIN rtc_ops r ON t.operator_id = r.operator_id LEFT JOIN new_bus s ON s.route_id = t.route_id WHERE t.date_of_issue >= DATE '2026-06-01' AND t.date_of_issue < DATE '2026-07-01' AND t.sales_channel = 'RB:MOBILEWEB#droidapp' AND t.country_code = 'IND' AND t.event_class = 2 AND t.event_type = 101 AND t.tin IS NOT NULL AND t.tin NOT IN ('','null') GROUP BY 1, 2 ORDER BY 4 DESC -- )
