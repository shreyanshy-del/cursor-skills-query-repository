-- =============================================================================
-- SHARED BASE (use identically in Funnel + Transactions queries)
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

-- Single source of truth for confirmed TINs (BTE-only, same as Transactions query)
confirmed_tickets AS (
    SELECT
        CAST(b.date_of_issue AS DATE) AS issue_date,
        b.tin,
        b.operator_id,
        ro.operator_name,
        ro.sort_order,
        b.seat_count,
        b.source_location_id,
        b.destination_location_id,
        b.source_location,
        b.destination_location,
        b.travellers_gender,
        b.seat_price,
        UPPER(TRIM(b.user_type)) AS user_type
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
