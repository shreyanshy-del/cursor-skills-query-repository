-- Athena saved query (Product_B2C_Intl)
-- ID: e31f72b3-a8a9-41f9-bd97-2ccc92f19c1c
-- Name: Students who clicked on Share - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

WITH share_clicked AS ( SELECT DISTINCT mri_session_id FROM user_interaction.ui_ux_events WHERE __time >= TIMESTAMP '2026-04-29 18:30:00' AND __time < TIMESTAMP '2026-05-05 18:30:00' AND header_bu = 'BUS' AND selected_country = 'India' AND event_src = 'Android' AND event_name IN ('studentSharedMode') AND event_group = 'ab_student_deal' ) -- , -- tins AS ( SELECT DISTINCT t.mri_session_id, order_uuid, streak_id, (source_location ||'-'|| destination_location) route, 'Shared' AS Clicked_Share, CASE WHEN streak_id = '' THEN 'Yes' ELSE 'No' END AS Group_Created FROM "transaction"."bus_ticket_events" t JOIN share_clicked s ON s.mri_session_id = t.mri_session_id WHERE date_of_issue >= TIMESTAMP '2026-04-29 18:30:00' AND date_of_issue < TIMESTAMP '2026-05-05 18:30:00' AND country_code = 'IND' AND tin IS NOT NULL AND event_class = 2 AND event_type = 101 -- )
