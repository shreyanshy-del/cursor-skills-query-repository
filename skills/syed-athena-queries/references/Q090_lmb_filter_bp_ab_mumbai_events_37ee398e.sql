-- Athena saved query (Product_B2C_Intl)
-- ID: 37ee398e-d9c6-4359-97fe-db9cb3e0f087
-- Name: LMB_FILTER_BP AB Mumbai Events- Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT -- event_name -- operator_id, bus_operator -- CASE -- WHEN channel_exp_info IS NULL THEN 'null' -- WHEN channel_exp_info LIKE('%LMB_FILTER_BP:V0%') THEN 'V0' -- WHEN channel_exp_info LIKE('%LMB_FILTER_BP:V1%') THEN 'V1' -- WHEN channel_exp_info LIKE('%LMB_FILTER_BP:V2%') THEN 'V2' -- WHEN channel_exp_info LIKE('%LMB_FILTER_BP:V3%') THEN 'V3' -- WHEN channel_exp_info LIKE('%LMB_FILTER_BP:V4%') THEN 'V4' -- ELSE 'others' -- END AS exp_Variant, event_group, screen_name, event_name, -- CASE WHEN event_name = 'search information' THEN 'search information' ELSE event_value END AS event_value, -- usertype, COUNT(DISTINCT mri_session_id) session_count, COUNT(DISTINCT mri_client_id) client_id_count FROM user_interaction.ui_ux_events u WHERE __time >= TIMESTAMP '2026-03-17 18:30:00' AND __time < TIMESTAMP '2026-03-31 18:30:00' AND header_bu = 'BUS' AND selected_country = 'India' AND event_src = 'Android' -- AND event_group IN ('ab_exp_BPselection') -- AND event_name IN ('SRP_BP_selection_loaded', 'SRP_BP_selected', 'SRP_BP_selection_closed', 'LMB filter BP clicked', 'LMB filter loaded', 'LMB filter BP cupdated', 'added BP names', 'removed BP names') AND -- and app_version >='81.70.00' -- LIMIT 1000 GROUP BY 1, 2 , 3 -- , 4 ORDER BY session_count DESC
