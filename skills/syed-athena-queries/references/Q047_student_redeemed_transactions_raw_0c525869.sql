-- Athena saved query (Product_B2C_Intl)
-- ID: 0c525869-3e2e-4a17-8dee-b41d58328a72
-- Name: Student redeemed transactions Raw - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT r.order_uuid, r.refund_reason AS group_identifier, r.refund_amount, r.org_unit_amount, t.tin, t.rb_user_id, t.streak_id, t.source_location_id, t.destination_location_id, (t.source_location ||'-'|| t.destination_location) AS route, t.operator_id, t.service_provider_name BO_Name, t.service_id, t.seat_count, t.user_type FROM "transaction"."bus_refund_events" r LEFT JOIN "transaction"."bus_ticket_events" t ON t.order_uuid = r.order_uuid WHERE 1 = 1 AND r.time_of_event >= TIMESTAMP '2026-04-07 00:00:00' AND r.time_of_event < TIMESTAMP '2026-04-28 18:30:00' AND t.time_of_event >= TIMESTAMP '2026-04-07 00:00:00' AND t.time_of_event < TIMESTAMP '2026-04-28 18:30:00' AND r.refund_category = 'STUDENT_REWARD_OFFER' AND r.refund_status = 'REFUND_SUCCESSFUL' AND r.refund_reference_no IS NOT NULL AND r.event_type = 304 AND t.country_code = 'IND' AND t.tin IS NOT NULL AND t.event_class = 2 AND t.event_type = 101
