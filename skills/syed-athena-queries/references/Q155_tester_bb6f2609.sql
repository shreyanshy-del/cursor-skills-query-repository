-- Athena saved query (Product_B2C_Intl)
-- ID: bb6f2609-1e42-48d4-bf45-8e25a77d3b61
-- Name: Tester - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT srp.channel_exp_info FROM "user_interaction"."search_route_details" srp WHERE srp.os = 'Android' AND srp.country = 'IND' AND srp.__time >= TIMESTAMP '2025-11-30 18:30:00' AND srp.__time < TIMESTAMP '2025-12-01 18:30:00' AND contains(srp.channel_exp_info, 'EXPRESS_TAG_SRP_AB:V2') LIMIT 1000 -- GROUP BY 1, 2, 3, 4 -- , 5 -- ORDER BY 1, 2
