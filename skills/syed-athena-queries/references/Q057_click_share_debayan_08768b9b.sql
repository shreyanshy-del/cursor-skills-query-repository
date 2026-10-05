-- Athena saved query (Product_B2C_Intl)
-- ID: 08768b9b-c415-4d51-99b1-55badf08a798
-- Name: Click Share Debayan - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

/* Original */ SELECT DATE(__time) AS event_date, (position + 1) AS actual_position, count(route_id) as click_flag FROM user_interaction.seat_layout_details WHERE country = 'IND' AND channel = 'MOBILE_APP' AND __time >= TIMESTAMP '2026-05-01 00:00:00' AND __time < TIMESTAMP '2026-05-08 00:00:00' AND mri_session_id IS NOT NULL AND route_id IS NOT NULL GROUP BY 1,2; /* Modified */ SELECT CASE WHEN tuple_position <= 20 THEN CAST(tuple_position AS VARCHAR) WHEN tuple_position > 20 THEN '20 +' ELSE '' END AS tuple_position, -- COUNT(DISTINCT CASE WHEN saleschannel = 'iOS' THEN mri_session_id END) AS iOS_sessions, -- COUNT(DISTINCT CASE WHEN saleschannel = 'Android' THEN mri_session_id END) AS Android_sessions, COUNT(DISTINCT CASE WHEN saleschannel = 'iOS' THEN mri_uuid END) AS iOS_clicks, COUNT(DISTINCT CASE WHEN saleschannel = 'Android' THEN mri_uuid END) AS Android_clicks FROM ( SELECT DATE(__time) AS event_date, os AS saleschannel, route_id, -- mri_session_id, mri_uuid, MIN(position + 1) AS tuple_position FROM user_interaction.seat_layout_details WHERE country = 'IND' AND channel = 'MOBILE_APP' AND __time >= TIMESTAMP '2026-05-01 00:00:00' AND __time < TIMESTAMP '2026-05-08 00:00:00' AND mri_session_id IS NOT NULL AND route_id IS NOT NULL GROUP BY 1, 2, 3, 4 ) GROUP BY 1
