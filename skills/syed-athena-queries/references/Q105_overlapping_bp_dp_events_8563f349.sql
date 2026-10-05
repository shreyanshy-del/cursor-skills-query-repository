-- Athena saved query (Product_B2C_Intl)
-- ID: 8563f349-a7db-4838-9177-017daa42c340
-- Name: Overlapping BP DP events - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT -- event_name -- operator_id, bus_operator screen_name, event_name, -- CASE WHEN event_name = 'search information' THEN 'search information' ELSE event_value END AS event_value, -- usertype, COUNT(DISTINCT mri_session_id) session_count, COUNT(DISTINCT mri_client_id) client_id_count FROM user_interaction.ui_ux_events u WHERE __time >= TIMESTAMP '2026-03-15 18:30:00' AND __time < TIMESTAMP '2026-03-25 18:30:00' AND header_bu = 'BUS' AND selected_country = 'India' AND event_src = 'Android' -- AND event_name NOT IN ('location widget') AND screen_name IN ('boarding point screen', 'dropping point screen', 'cust info', 'sl load') -- AND event_name IN ('alternate_bp_shown') AND event_name IN ('alternate_bp_shown', 'alternate_bp_selected', 'alternate_bp_shown', 'alternate_Dp_selected', 'CI_with_alternateBP', 'alternatebpshown_clickedback') -- and app_version >='81.70.00' -- LIMIT 1000 GROUP BY 1, 2 -- , 3 -- , 4 ORDER BY session_count DESC
