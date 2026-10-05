-- Athena saved query (Product_B2C_Intl)
-- ID: 5f96461b-dc38-4ea1-b409-c5a4fb2f8c04
-- Name: Bus Images Unique routeids - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT CAST(DATE_TRUNC('day', at_timezone(__time, 'Asia/Kolkata')) AS DATE) AS doi, route_id_train_no route_id FROM "user_interaction"."ui_ux_events" WHERE __time >= TIMESTAMP '2026-05-26 18:30:00' AND __time < TIMESTAMP '2026-06-07 18:30:00' AND app_code > 859110 -- AND event_group = 'NewBusImageLoaded' AND event_name IN ('NewBusImageLoaded') GROUP BY 1, 2
