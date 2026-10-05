-- Athena saved query (Product_B2C_Intl)
-- ID: 0b1e1974-5922-41a5-916f-78a3f8dccda3
-- Name: Student - Users under 24 YO - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT travellers_age, rb_user_id -- MIN(DATE(date_of_issue)) first_date FROM "transaction"."bus_ticket_events" WHERE date_of_issue >= TIMESTAMP '2025-05-01' AND date_of_issue < TIMESTAMP '2026-05-20' AND country_code = 'IND' AND business_unit = 'REDBUS_IN' AND event_class = 2 AND event_type = 101 AND rb_user_id > 1 AND travellers_age[1] < 24 -- GROUP BY 1 -- limit 10;
