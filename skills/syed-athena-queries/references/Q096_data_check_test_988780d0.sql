-- Athena saved query (Product_B2C_Intl)
-- ID: 988780d0-5803-483f-ad18-1de8c667b07e
-- Name: Data Check & Test - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT channel_exp_info FROM "user_interaction"."search_route_details" s -- LEFT JOIN short_routes sr ON s.src_id = sr.src_id AND s.dest_id = sr.dest_id WHERE s.__time >= TIMESTAMP '2026-03-28 18:30:00' AND s.__time < TIMESTAMP '2026-03-29 18:30:00' AND s.channel IN ('MOBILE_APP') LIMIT 100
