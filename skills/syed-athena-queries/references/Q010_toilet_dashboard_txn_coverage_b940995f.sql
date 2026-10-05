-- Athena saved query (Product_B2C_Intl)
-- ID: b940995f-4c86-49f8-9909-dd733584de85
-- Name: Toilet Dashboard - Txn Coverage - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT CASE WHEN regexp_like(TRIM(assembly_name), '(?i)^RedBus\.Vendor\.') THEN regexp_extract(TRIM(assembly_name), '(?i)^RedBus\.Vendor\.(.+)$', 1) ELSE TRIM(assembly_name) END AS gds_name, srd.operator_id, bo.bo_name, COUNT(DISTINCT srd.route_id) AS total_route_id, COUNT(DISTINCT CASE WHEN CONTAINS(srd.persuasion_id, '537') THEN srd.route_id END) AS toilet_route_id, COUNT(DISTINCT bte.tin) AS absolute_transaction_count, COUNT(DISTINCT CASE WHEN CONTAINS(srd.persuasion_id, '537') THEN bte.tin END) AS absolute_transaction_count_537 FROM user_interaction.search_route_details AS srd LEFT JOIN transaction.bus_ticket_events AS bte ON srd.mri_session_id = bte.mri_session_id AND srd.route_id = bte.route_id AND bte.event_type = 101 AND bte.country_code = 'IND' AND bte.time_of_event >= CAST('2026-07-04 00:00:00' AS TIMESTAMP) AND bte.time_of_event < CAST('2026-07-05 00:00:00' AS TIMESTAMP) LEFT JOIN "lis"."bo_mappings" AS bo ON bo.vendor_id = srd.operator_id LEFT JOIN "lis"."vendor" v ON v.id = srd.operator_id WHERE srd.__time >= CAST('2026-07-04 00:00:00' AS TIMESTAMP) AND srd.__time < CAST('2026-07-05 00:00:00' AS TIMESTAMP) AND srd.country = 'IND' AND v.geo = 'IND' -- AND srd.operator_id > 0 GROUP BY 1, 2, 3 ORDER BY 4 DESC
