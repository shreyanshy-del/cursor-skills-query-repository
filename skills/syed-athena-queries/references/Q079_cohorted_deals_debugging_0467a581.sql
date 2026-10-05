-- Athena saved query (Product_B2C_Intl)
-- ID: 0467a581-ed67-4429-bda1-ee475c329823
-- Name: COHORTED Deals Debugging - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

( SELECT mri_session_id, __time, 'srp' AS page, route_id, doj, cohort_type, cohort_display_type, '' user_origin, CAST((position + offset + 1) AS VARCHAR) tuple_pos FROM "user_interaction"."search_route_details" srp WHERE __time > TIMESTAMP '2026-03-31 18:30:00' AND __time < TIMESTAMP '2026-04-01 18:30:00' AND os = 'iOS' AND mri_session_id = 'iOSM10082579-7169-49A0-A961-E70055A132A8' ) UNION ALL ( SELECT mri_session_id, __time, 'sl' AS page, route_id, CAST(doj AS DATE) doj, '' cohort_type, '' cohort_display_type, user_origin, '' tuple_pos FROM "user_interaction"."seat_layout_details" sl WHERE __time > TIMESTAMP '2026-03-31 18:30:00' AND __time < TIMESTAMP '2026-04-01 18:30:00' AND os = 'iOS' AND mri_session_id = 'iOSM10082579-7169-49A0-A961-E70055A132A8' ) ORDER BY __time ASC
