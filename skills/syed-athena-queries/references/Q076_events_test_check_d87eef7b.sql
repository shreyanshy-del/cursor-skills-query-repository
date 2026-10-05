-- Athena saved query (Product_B2C_Intl)
-- ID: d87eef7b-cacb-4d86-bb7b-de421df00e1b
-- Name: Events test / Check - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT * -- CAST(DATE_TRUNC('day', at_timezone(__time, 'Asia/Kolkata')) AS DATE) AS doi, -- event_src, event_name, -- 'Overall' AS event_value, -- variantname, -- COUNT(DISTINCT mri_session_id) session_count FROM "user_interaction"."ui_ux_events" WHERE __time >= TIMESTAMP '2026-04-11 13:30:00' AND __time < TIMESTAMP '2026-04-11 14:00:00' -- AND event_group = 'ab_exp_srp_price' AND event_name LIKE 'Back to SL' -- GROUP BY 1, 2, 3, 4, 5
