-- Athena saved query (Product_B2C_Intl)
-- ID: 23d68ac4-2aa7-41da-a6bb-2d5ff1949e39
-- Name: language Switch back - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH base AS ( SELECT DISTINCT CAST(DATE_TRUNC('day', "__time") AS DATE) AS doi, rb_user_id, language FROM "user_interaction"."search_route_details" WHERE __time >= TIMESTAMP '2025-10-01 18:30:00' AND __time < TIMESTAMP '2026-01-01 18:30:00' -- AND channel IN ('MOBILE_APP', 'MOBILE_WEB', 'WEB_DIRECT') AND os = 'Android' AND country = 'IND' AND rb_user_id > 0 -- LIMIT 100 ), lang_count AS ( SELECT rb_user_id, COUNT(DISTINCT language) language_count FROM base GROUP BY 1 ) SELECT language_count, COUNT(DISTINCT rb_user_id) user_count FROM lang_count GROUP BY 1 ORDER BY 1 -- SELECT -- language, COUNT(DISTINCT rb_user_id) user_count -- FROM "user_interaction"."search_route_details" -- WHERE __time >= TIMESTAMP '2025-10-01 18:30:00' -- AND __time < TIMESTAMP '2026-01-01 18:30:00' -- -- AND channel IN ('MOBILE_APP', 'MOBILE_WEB', 'WEB_DIRECT') -- AND os = 'Android' -- AND country = 'IND' -- AND rb_user_id > 0 -- GROUP BY 1
