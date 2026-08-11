-- Query B: Total confirmed TINs from bus_ticket_events approach (RTC operators only)
WITH date_filter AS (
    SELECT
        TIMESTAMP '2026-05-20 00:00:00' AS start_dt,
        TIMESTAMP '2026-06-11 00:00:00' AS end_dt
),

rtc_city_pairs AS (
    SELECT DISTINCT
        b.source_location_id,
        b.destination_location_id
    FROM transaction.bus_ticket_events b
    CROSS JOIN date_filter d
    WHERE b.date_of_issue >= d.start_dt
      AND b.date_of_issue <  d.end_dt
      AND b.event_class = 2
      AND b.event_type = 101
      AND b.country_code = 'IND'
      AND b.operator_id IN (16426, 15443, 24978, 32272)
),

confirmed AS (
    SELECT
        b.operator_id,
        b.tin,
        CASE
            WHEN b.operator_id = 16426 THEN 'WBTC'
            WHEN b.operator_id = 15443 THEN 'WBSTC'
            WHEN b.operator_id = 24978 THEN 'NBSTC'
            WHEN b.operator_id = 32272 THEN 'SBSTC'
        END AS operator_segment
    FROM transaction.bus_ticket_events b
    CROSS JOIN date_filter d
    INNER JOIN rtc_city_pairs cp
        ON b.source_location_id = cp.source_location_id
       AND b.destination_location_id = cp.destination_location_id
    WHERE b.date_of_issue >= d.start_dt
      AND b.date_of_issue <  d.end_dt
      AND b.event_class = 2
      AND b.event_type = 101
      AND b.country_code = 'IND'
      AND b.operator_id IN (16426, 15443, 24978, 32272)
)

SELECT
    COALESCE(operator_segment, 'ALL_RTC') AS operator_name,
    COUNT(DISTINCT tin) AS total_tins
FROM confirmed
GROUP BY GROUPING SETS ((operator_segment), ())
ORDER BY operator_name NULLS LAST
