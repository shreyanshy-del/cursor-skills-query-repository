-- =============================================================================
-- RTC TRANSACTIONS (aligned with Conversion Funnel query)
-- Period: 2026-05-20 to 2026-06-11 (exclusive end)
--
-- confirm_tins here = confirm_tins in Funnel query (same confirmed_tickets CTE)
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
),

tagged AS (
    SELECT
        issue_date,
        source_location_id,
        destination_location_id,
        source_location,
        destination_location,
        operator_name,
        sort_order,
        COALESCE(NULLIF(user_type, ''), 'UNKNOWN') AS user_type,
        tin,
        seat_count,
        travellers_gender,
        seat_price
    FROM confirmed_tickets
),

passenger_gender AS (
    SELECT
        t.issue_date,
        t.operator_name,
        t.user_type,
        UPPER(TRIM(gender_value)) AS gender
    FROM tagged t
    CROSS JOIN UNNEST(t.travellers_gender) AS u(gender_value)
    WHERE t.travellers_gender IS NOT NULL
      AND CARDINALITY(t.travellers_gender) > 0
      AND TRIM(gender_value) <> ''
),

gender_agg AS (
    SELECT
        issue_date,
        operator_name,
        user_type,
        SUM(CASE WHEN gender = 'MALE'   THEN 1 ELSE 0 END) AS male_count,
        SUM(CASE WHEN gender = 'FEMALE' THEN 1 ELSE 0 END) AS female_count,
        SUM(CASE WHEN gender IN ('MALE', 'FEMALE') THEN 1 ELSE 0 END) AS total_passengers
    FROM passenger_gender
    GROUP BY 1, 2, 3
),

seat_fare AS (
    SELECT
        t.issue_date,
        t.operator_name,
        t.user_type,
        CASE
            WHEN seat_fare_value = 0 THEN 'Free'
            ELSE 'Non_Free'
        END AS fare_bucket
    FROM tagged t
    CROSS JOIN UNNEST(t.seat_price) AS u(seat_fare_value)
    WHERE t.seat_price IS NOT NULL
      AND CARDINALITY(t.seat_price) > 0
),

fare_agg AS (
    SELECT
        issue_date,
        operator_name,
        user_type,
        SUM(CASE WHEN fare_bucket = 'Free'     THEN 1 ELSE 0 END) AS free_seats,
        SUM(CASE WHEN fare_bucket = 'Non_Free' THEN 1 ELSE 0 END) AS non_free_seats,
        COUNT(*) AS total_fare_seats
    FROM seat_fare
    GROUP BY 1, 2, 3
),

volume_agg AS (
    SELECT
        issue_date,
        operator_name,
        sort_order,
        user_type,
        COUNT(DISTINCT tin) AS confirmed_transactions,
        SUM(seat_count) AS seats_sold,
        COUNT(DISTINCT CONCAT(
            CAST(source_location_id AS VARCHAR), '-',
            CAST(destination_location_id AS VARCHAR)
        )) AS distinct_city_pairs
    FROM tagged
    GROUP BY 1, 2, 3, 4
)

SELECT
    v.issue_date,
    v.operator_name,
    v.operator_name AS operator_segment,
    v.user_type,
    v.confirmed_transactions,
    v.seats_sold,
    v.distinct_city_pairs,
    COALESCE(g.male_count, 0)   AS male_count,
    COALESCE(g.female_count, 0) AS female_count,
    ROUND(100.0 * COALESCE(g.male_count, 0)
        / NULLIF(g.total_passengers, 0), 2) AS male_share_pct,
    ROUND(100.0 * COALESCE(g.female_count, 0)
        / NULLIF(g.total_passengers, 0), 2) AS female_share_pct,
    COALESCE(f.free_seats, 0)     AS free_seats,
    COALESCE(f.non_free_seats, 0) AS non_free_seats,
    COALESCE(f.total_fare_seats, 0) AS total_fare_seats,
    ROUND(100.0 * COALESCE(f.free_seats, 0)
        / NULLIF(f.total_fare_seats, 0), 2) AS free_seats_pct,
    ROUND(100.0 * COALESCE(f.non_free_seats, 0)
        / NULLIF(f.total_fare_seats, 0), 2) AS non_free_seats_pct
FROM volume_agg v
LEFT JOIN gender_agg g
    ON v.issue_date = g.issue_date
   AND v.operator_name = g.operator_name
   AND v.user_type = g.user_type
LEFT JOIN fare_agg f
    ON v.issue_date = f.issue_date
   AND v.operator_name = f.operator_name
   AND v.user_type = f.user_type
ORDER BY
    v.issue_date,
    v.sort_order,
    CASE v.user_type
        WHEN 'NEW'       THEN 1
        WHEN 'RETURNING' THEN 2
        WHEN 'GUEST'     THEN 3
        ELSE 4
    END
