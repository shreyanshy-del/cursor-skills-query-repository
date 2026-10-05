-- Athena saved query (Product_B2C_Intl)
-- ID: 8ba86db7-dd78-40c1-80ad-ac71973596d5
-- Name: Free Seat Data - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT CAST(DATE_TRUNC('day', at_timezone(time_of_event, 'Asia/Kolkata')) AS DATE) AS doi, CASE WHEN sales_channel = 'RB:MOBILEWEB#droidapp' THEN 'Android' WHEN sales_channel = 'RB:MOBILEWEB#iosapp' THEN 'iOS' WHEN sales_channel = 'WEBDIRECT' THEN 'Desktop' WHEN sales_channel = 'MOBILEWEB' THEN 'MobWeb' END AS sales_channel, operator_id, CASE WHEN operator_id = 15443 THEN 'WBSTC' WHEN operator_id = 16426 THEN 'WBTC (CTC)' WHEN operator_id = 32272 THEN 'SBSTC' WHEN operator_id = 24978 THEN 'NBSTC' ELSE 'NA' END AS rtc_name, CASE WHEN cardinality( filter(seat_price, x -> x > 0) ) = 0 THEN 'Only Free' WHEN cardinality( filter(seat_price, x -> x = 0) ) > 0 AND cardinality( filter(seat_price, x -> x > 0) ) > 0 THEN 'Free + Paid' ELSE 'Only Paid' END AS fare_type, COUNT(DISTINCT tin) AS txn_count FROM "transaction"."bus_ticket_events" WHERE 1 = 1 AND time_of_event >= TIMESTAMP '2026-06-03 18:30:00' AND time_of_event < TIMESTAMP '2026-06-07 18:30:00' AND country_code = 'IND' AND operator_id IN (15443, 16426, 32272, 24978) AND sales_channel IN ('RB:MOBILEWEB#iosapp', 'RB:MOBILEWEB#droidapp', 'WEBDIRECT', 'MOBILEWEB') AND status = 'CONFIRMED' -- AND ticket_fare=0 AND event_class = 2 AND event_type = 101 GROUP BY 1, 2, 3 , 4 , 5 -- , 6, 7 ORDER BY 1, 2, 6 DESC
