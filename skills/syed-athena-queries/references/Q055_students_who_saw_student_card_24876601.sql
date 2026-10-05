-- Athena saved query (Product_B2C_Intl)
-- ID: 24876601-4742-428c-82f3-df969253b4d2
-- Name: Students who saw student Card - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH target_sessions AS ( -- Get unique sessions that triggered the specific event first SELECT DISTINCT mri_session_id FROM user_interaction.ui_ux_events WHERE __time >= TIMESTAMP '2026-04-27 18:30:00' AND __time < TIMESTAMP '2026-05-05 18:30:00' AND header_bu = 'BUS' AND selected_country = 'India' AND event_src = 'Android' AND event_name = 'student_card' ), filtered_searches AS ( -- Get unique user IDs from those sessions SELECT DISTINCT s.rb_user_id FROM user_interaction.search_route_details s INNER JOIN target_sessions ts ON s.mri_session_id = ts.mri_session_id WHERE s.__time >= TIMESTAMP '2026-04-27 18:30:00' AND s.__time < TIMESTAMP '2026-05-05 18:30:00' AND s.country = 'IND' AND s.rb_user_id IS NOT NULL ) -- Final Join with SVOC (usually a smaller table compared to UI events) SELECT DISTINCT fs.rb_user_id, sb.userhash, sb.hash_mobile FROM filtered_searches fs JOIN "svoc"."svoc_booker" sb ON sb.rb_userid = CAST(fs.rb_user_id AS VARCHAR)
