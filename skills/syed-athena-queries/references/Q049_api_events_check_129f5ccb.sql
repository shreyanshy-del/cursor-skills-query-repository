-- Athena saved query (Product_B2C_Intl)
-- ID: 129f5ccb-1152-44e8-abe8-185f694d7d2b
-- Name: API events Check - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

select __time, event_src, event_type, src_id, dest_id, operator_id from user_interaction.api_events where __time > timestamp '2026-04-19 00:00:00' and __time < timestamp '2026-04-22 00:00:00' and event_src IN ('CAPI', 'Android') and mri_session_id = 'AM0d397739-72d0-3e38-943f-1008a450e30d' order by 1
