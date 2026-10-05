-- Athena saved query (Product_B2C_Intl)
-- ID: 3a3fbaa8-6d97-4406-82ea-b3e5e55dd464
-- Name: Connecting Services Searched and Transacted Users - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT FROM "user_interaction"."search_route_details" s WHERE s.__time >= TIMESTAMP '2026-05-15 18:30:00' AND s.__time < TIMESTAMP '2026-06-15 18:30:00' AND channel = 'MOBILE_APP' AND os = 'iOS' AND tp_channel = 'INVALID' AND country = 'IND' AND DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, __time)), doj) = 0
