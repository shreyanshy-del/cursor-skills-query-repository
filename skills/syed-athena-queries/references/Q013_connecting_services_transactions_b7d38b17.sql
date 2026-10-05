-- Athena saved query (Product_B2C_Intl)
-- ID: b7d38b17-d69d-47ee-9a4f-a7f4c8e2337f
-- Name: Connecting Services Transactions - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

-- SELECT doi, -- COUNT(DISTINCT prime_tin) txn_count, -- COUNT(DISTINCT rb_user_id) user_count -- FROM ( SELECT a.mri_session_id,b.tin as prime_tin,a.source_location,a.destination_location, a.tin,prime_src_location,prime_dst_location,prime_source,prime_destination, DATE(date_add('minute', 330, a.date_of_journey)) AS doj,a.order_uuid,a.rb_user_id,a.leg, a.sales_channel,a.operator_id,DATE(date_add('minute', 330, a.date_of_issue)) as doi,a.seat_count,a.ticket_fare,layover_dp_time,layover_bp_time FROM transaction.bus_ticket_events a INNER JOIN transaction.bus_journey_events b ON a.order_uuid = b.order_uuid WHERE a.date_of_issue >= TIMESTAMP '2026-05-25 18:30:00' AND a.date_of_issue < TIMESTAMP '2026-06-24 18:30:00' AND a.is_journey = true AND a.tin IS NOT NULL AND a.country_code = 'IND' AND contains(b.tags, 'RBCONNECTED') AND a.leg in (1,2) and b.tin is not null -- ) -- GROUP BY 1 -- ORDER BY 1
