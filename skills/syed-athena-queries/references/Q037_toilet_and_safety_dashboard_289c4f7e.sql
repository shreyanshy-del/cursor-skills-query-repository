-- Athena saved query (Product_B2C_Intl)
-- ID: 289c4f7e-de5d-4084-a55a-e8fc341df8e1
-- Name: Toilet and Safety Dashboard - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT -- DISTINCT event_name, event_value CAST(DATE_TRUNC('day', at_timezone(__time, 'Asia/Kolkata')) AS DATE) AS doi, event_src, event_name, event_value, -- 'Overall' AS event_value, -- variantname, COUNT(DISTINCT mri_session_id) session_count FROM "user_interaction"."ui_ux_events" WHERE __time >= TIMESTAMP '2026-07-01 18:30:00' AND __time < TIMESTAMP '2026-07-13 18:30:00' -- AND event_group = 'ab_exp_srp_price' AND UPPER(event_src) IN ('ANDROID', 'IOS') AND event_name IN ('safetyDetailsShow', 'safetyDetailsLoaded', 'DMSloaded', 'ToiletShown', 'emergencyShown', 'rearEmergencyShown', 'roofEmergencyShown') -- AND event_name IN ('safetyDetailsShow') GROUP BY 1, 2 , 3 , 4 -- , 5 -- LIMIT 100
