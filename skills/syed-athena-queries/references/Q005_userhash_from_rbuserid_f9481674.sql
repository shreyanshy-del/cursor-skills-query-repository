-- Athena saved query (Product_B2C_Intl)
-- ID: f9481674-f650-432c-80a8-35c6600118fa
-- Name: userhash from rbuserid - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT userhash FROM "svoc"."svoc_booker" WHERE rb_userid IN (SELECT DISTINCT CAST(rb_user_id AS VARCHAR) FROM ( SELECT DISTINCT a.mri_session_id,b.tin as prime_tin,a.source_location,a.destination_location, a.tin,prime_src_location,prime_dst_location,prime_source,prime_destination, DATE(date_add('minute', 330, a.date_of_journey)) AS doj,a.order_uuid,a.rb_user_id,a.leg, a.sales_channel,a.operator_id,DATE(date_add('minute', 330, a.date_of_issue)) as doi,a.seat_count,a.ticket_fare,layover_dp_time,layover_bp_time FROM transaction.bus_ticket_events a INNER JOIN transaction.bus_journey_events b ON a.order_uuid = b.order_uuid WHERE a.date_of_issue >= TIMESTAMP '2026-05-25 18:30:00' AND a.date_of_issue < TIMESTAMP '2026-06-23 18:30:00' AND a.is_journey = true AND a.tin IS NOT NULL AND a.rb_user_id > 0 AND a.country_code = 'IND' AND contains(b.tags, 'RBCONNECTED') AND a.leg in (1,2) and b.tin is not null ORDER BY mri_session_id ))
