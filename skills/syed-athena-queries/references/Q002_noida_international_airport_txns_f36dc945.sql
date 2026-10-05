-- Athena saved query (Product_B2C_Intl)
-- ID: f36dc945-bfe7-4689-a442-148315c3c491
-- Name: Noida International Airport txns - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

-- SELECT * FROM "lis"."config_locations" -- WHERE -- id IN (733, 320224, 322489) -- OR location_name IN ('Noida International Airport') OR location_name LIKE ('Noida'); SELECT -- boarding_point_id DATE(date_add('minute', 330, date_of_issue)) AS doi, COUNT(DISTINCT CASE WHEN source_location = 'Noida International Airport' THEN tin END) AS src_Noida_International_Airport_tins, COUNT(DISTINCT CASE WHEN destination_location = 'Noida International Airport' THEN tin END) AS dest_Noida_International_Airport_tins, COUNT(DISTINCT CASE WHEN boarding_point = 'Noida International Airport' THEN tin END) AS bp_Noida_International_Airport_tins, COUNT(DISTINCT CASE WHEN dropping_point = 'Noida International Airport' THEN tin END) AS dp_Noida_International_Airport_tins, COUNT(DISTINCT CASE WHEN source_location_id = 733 THEN tin END) AS source_Delhi_tins, COUNT(DISTINCT CASE WHEN destination_location_id = 733 THEN tin END) AS dest_Delhi_tins FROM "transaction"."bus_ticket_events" WHERE date_of_issue >= TIMESTAMP '2026-06-01 18:30:00' AND date_of_issue < TIMESTAMP '2026-06-24 18:30:00' AND tin IS NOT NULL AND country_code = 'IND' AND event_class = 2 AND event_type = 101 GROUP BY 1 ORDER BY 1
