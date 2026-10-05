-- Athena saved query (Product_B2C_Intl)
-- ID: c2f142bc-a00a-4234-a259-ab35b0f43804
-- Name: Students AB Events check - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT -- event_src, event_name, event_value, screen_name, source, type, COUNT(DISTINCT mri_session_id) distinct_sessions -- , COUNT(mri_session_id) instances FROM user_interaction.ui_ux_events WHERE __time >= TIMESTAMP '2026-03-31 18:30:00' AND __time < TIMESTAMP '2026-04-07 18:30:00' AND header_bu = 'BUS' AND selected_country = 'India' AND event_src IN ('Android') -- AND event_name NOT IN ('location widget') -- AND screen_name = 'boarding point screen' -- AND event_name LIKE '%tudent%' AND event_name IN ('Student-tuple_clicked', 'Student_Deal_section', 'no_of_tuples', 'student_card', 'CTA_action', 'ErrorMessageShown', 'Hurrayshown', 't&c_clicked', 'seatlayout_deeplinkedEntry', 'student_details_shown', 'studentSharedMode', 'HowItWorks', 'contextual onboarding screen viewed', 'login completed' ) AND variantname = 'V2' AND event_group = 'ab_student_deal' AND app_version >='81.70.00' GROUP BY 1, 2, 3, 4, 5 -- GROUP BY 1, 2, 3 -- ORDER BY session_count DESC
