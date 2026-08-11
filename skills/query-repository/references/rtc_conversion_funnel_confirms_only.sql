-- =============================================================================
-- RTC CONVERSION FUNNEL — lightweight (confirms only, matches Transactions)
-- Run this first for TIN reconciliation; completes in seconds.
-- Period: 2026-05-20 to 2026-06-11 (exclusive end)
-- =============================================================================

WITH date_filter AS (
    SELECT
        TIMESTAMP '2026-05-20 00:00:00' AS start_dt,
        TIMESTAMP '2026-06-11 00:00:00' AS end_dt
),

rtc_operators AS (
    SELECT *
    FROM (VALUES
        ('WBTC',  16426, 1),
        ('WBSTC', 15443, 2),
        ('NBSTC', 24978, 3),
        ('SBSTC', 32272, 4)
    ) AS t(operator_name, operator_id, sort_order)
),

rtc_city_pairs AS (
    SELECT DISTINCT
        b.source_location_id AS src_id,
        b.destination_location_id AS dest_id
    FROM transaction.bus_ticket_events b
    CROSS JOIN date_filter d
    WHERE b.date_of_issue >= d.start_dt
      AND b.date_of_issue <  d.end_dt
      AND b.event_class = 2
      AND b.event_type = 101
      AND b.country_code = 'IND'
      AND b.operator_id IN (16426, 15443, 24978, 32272)
),

confirmed_tickets AS (
    SELECT
        CAST(b.date_of_issue AS DATE) AS issue_date,
        b.tin,
        ro.operator_name,
        ro.sort_order
    FROM transaction.bus_ticket_events b
    CROSS JOIN date_filter d
    INNER JOIN rtc_city_pairs cp
        ON b.source_location_id = cp.src_id
       AND b.destination_location_id = cp.dest_id
    INNER JOIN rtc_operators ro
        ON b.operator_id = ro.operator_id
    WHERE b.date_of_issue >= d.start_dt
      AND b.date_of_issue <  d.end_dt
      AND b.event_class = 2
      AND b.event_type = 101
      AND b.country_code = 'IND'
      AND b.tin IS NOT NULL
      AND TRIM(b.tin) <> ''
      AND LOWER(TRIM(b.tin)) <> 'null'
)

SELECT
    issue_date,
    operator_name,
    CASE operator_name
        WHEN 'WBTC'  THEN 16426
        WHEN 'WBSTC' THEN 15443
        WHEN 'NBSTC' THEN 24978
        WHEN 'SBSTC' THEN 32272
    END AS operator_id,
    COUNT(DISTINCT tin) AS confirm_tins
FROM confirmed_tickets
GROUP BY issue_date, operator_name, sort_order
ORDER BY issue_date, sort_order
