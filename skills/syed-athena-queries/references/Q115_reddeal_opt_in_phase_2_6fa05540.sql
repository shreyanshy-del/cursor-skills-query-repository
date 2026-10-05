-- Athena saved query (Product_B2C_Intl)
-- ID: 6fa05540-497d-4757-a6d9-3c30c2ab7429
-- Name: Reddeal opt in phase 2 - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH reddeal_data AS ( SELECT date (__time) as Date, event_name, event_value, variantname, campaign_type AS redDeals, usertype, app_version, mri_session_id FROM user_interaction.ui_ux_events WHERE __time >= TIMESTAMP '2026-03-22 00:00:00' AND __time < TIMESTAMP '2026-03-26 00:00:00' AND header_bu = 'BUS' AND selected_country = 'India' AND event_src = 'Android' and event_group = 'ab_exp_redDealOptin' and app_version >='81.3.5' GROUP BY 1,2,3,4,5,6,7,8 ), purchase_data AS ( SELECT mri_session_id FROM user_interaction.ui_ux_events WHERE __time >= TIMESTAMP '2026-03-22 00:00:00' AND __time < TIMESTAMP '2026-03-26 00:00:00' AND header_bu = 'BUS' AND selected_country = 'India' AND event_src = 'Android' AND event_group in ('purchase','PURCHASE') ) SELECT a.Date, a.event_name, a.event_value, -- Toggle this a.variantname, a.redDeals, -- Toggle this a.usertype, a.app_Version, COUNT(DISTINCT a.mri_session_id) AS abload_sessions, COUNT(DISTINCT s.mri_session_id) AS ty_sessions FROM reddeal_data a left outer join purchase_data s ON a.mri_session_id = s.mri_session_id GROUP BY 1,2,3,4,5 ,6,7 -- Toggle this ORDER BY 1
