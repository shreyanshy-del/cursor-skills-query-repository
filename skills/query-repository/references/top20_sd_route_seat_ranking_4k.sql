-- =============================================================================
-- Top 20 SDs × Top 20 Routes × Top 10 Seats  (~4,000 rows)
-- =============================================================================
-- Metrics per seat:
--   prob_sold_within_dbd2   = P(booked ≤ 2 days before departure)
--   prob_sold_beyond_dbd2   = P(booked > 2 days before departure)
--   asp_diff_abs / asp_diff_pct = median fare beyond DBD2 minus within DBD2
--
-- DBD 2 threshold = 48 hours before departure (same as original template).
-- Seat rank       = by median_hours_before_departure DESC (earliest-selling seats).
-- SD / route rank = by confirmed TIN volume on transaction.bus_ticket_events.
-- =============================================================================

WITH params AS (
    SELECT
        DATE '2025-04-01' AS inv_start_doj,
        DATE '2025-05-01' AS inv_end_doj,
        TIMESTAMP '2025-03-01 00:00:00' AS txn_start,
        TIMESTAMP '2025-05-01 00:00:00' AS txn_end,
        48 AS dbd2_hours_threshold
),

/* ---------------------------------------------------------------------------
   Step 1 — Top 20 SD pairs by confirmed booking volume
   --------------------------------------------------------------------------- */
top_sds AS (
    SELECT
        b.source_location_id AS source_id,
        b.destination_location_id AS destination_id,
        COUNT(DISTINCT b.tin) AS sd_bookings,
        ROW_NUMBER() OVER (
            ORDER BY COUNT(DISTINCT b.tin) DESC
        ) AS sd_rank
    FROM transaction.bus_ticket_events b
    CROSS JOIN params p
    WHERE b.country_code = 'IND'
      AND b.event_type = 101
      AND b.time_of_event >= p.txn_start
      AND b.time_of_event < p.txn_end
      AND b.source_location_id IS NOT NULL
      AND b.destination_location_id IS NOT NULL
    GROUP BY
        1, 2
),

/* ---------------------------------------------------------------------------
   Step 2 — Top 20 routes within each Top-20 SD
   --------------------------------------------------------------------------- */
top_routes AS (
    SELECT
        t.source_id,
        t.destination_id,
        t.sd_rank,
        t.sd_bookings,
        b.route_id,
        COUNT(DISTINCT b.tin) AS route_bookings,
        ROW_NUMBER() OVER (
            PARTITION BY t.source_id, t.destination_id
            ORDER BY COUNT(DISTINCT b.tin) DESC
        ) AS route_rank_within_sd
    FROM transaction.bus_ticket_events b
    INNER JOIN top_sds t
        ON b.source_location_id = t.source_id
       AND b.destination_location_id = t.destination_id
    CROSS JOIN params p
    WHERE t.sd_rank <= 20
      AND b.country_code = 'IND'
      AND b.event_type = 101
      AND b.time_of_event >= p.txn_start
      AND b.time_of_event < p.txn_end
      AND b.route_id IS NOT NULL
    GROUP BY
        1, 2, 3, 4, 5
),

eligible_routes AS (
    SELECT *
    FROM top_routes
    WHERE route_rank_within_sd <= 20
),

/* ---------------------------------------------------------------------------
   Step 3 — Seat-level booking timing & fare (from original template)
   --------------------------------------------------------------------------- */
first_booking AS (
    SELECT
        i.doj,
        i.route_id,
        i.seat_number,
        MIN(i.date_of_change) AS first_booked_time
    FROM inventory.inventory_seat_wise_price i
    INNER JOIN eligible_routes er
        ON i.route_id = er.route_id
    CROSS JOIN params p
    WHERE i.seat_availabilty_status = 'BOOKED'
      AND i.doj BETWEEN p.inv_start_doj AND p.inv_end_doj
    GROUP BY
        1, 2, 3
),

last_available_before_booking AS (
    SELECT
        a.doj,
        a.route_id,
        a.seat_number,
        b.first_booked_time,
        a.date_of_change AS last_available_time,
        a.net_fare,
        ROW_NUMBER() OVER (
            PARTITION BY a.doj, a.route_id, a.seat_number
            ORDER BY a.date_of_change DESC
        ) AS rn
    FROM inventory.inventory_seat_wise_price a
    INNER JOIN first_booking b
        ON a.doj = b.doj
       AND a.route_id = b.route_id
       AND a.seat_number = b.seat_number
    CROSS JOIN params p
    WHERE a.seat_availabilty_status = 'AVAILABLE'
      AND a.date_of_change < b.first_booked_time
      AND a.doj BETWEEN p.inv_start_doj AND p.inv_end_doj
),

seat_level AS (
    SELECT
        sl.doj,
        sl.route_id,
        sl.seat_number,
        sl.first_booked_time,
        sl.last_available_time,
        sl.net_fare AS fare_before_booking,
        date_diff(
            'hour',
            sl.first_booked_time,
            CAST(sl.doj AS timestamp)
        ) AS hours_before_departure
    FROM last_available_before_booking sl
    CROSS JOIN params p
    WHERE sl.rn = 1
),

seat_median AS (
    SELECT
        er.source_id,
        er.destination_id,
        er.sd_rank,
        er.sd_bookings,
        er.route_rank_within_sd,
        er.route_bookings,
        sl.route_id,
        sl.seat_number,

        approx_percentile(sl.hours_before_departure, 0.5) AS median_hours_before_departure,

        COUNT(DISTINCT sl.doj) AS booked_doj_count,

        COUNT(DISTINCT CASE
            WHEN sl.hours_before_departure > p.dbd2_hours_threshold THEN sl.doj
        END) AS booked_beyond_dbd2_doj_count,

        COUNT(DISTINCT CASE
            WHEN sl.hours_before_departure <= p.dbd2_hours_threshold THEN sl.doj
        END) AS booked_within_dbd2_doj_count,

        approx_percentile(
            CASE
                WHEN sl.hours_before_departure > p.dbd2_hours_threshold
                THEN sl.fare_before_booking
            END,
            0.5
        ) AS median_fare_beyond_dbd2,

        approx_percentile(
            CASE
                WHEN sl.hours_before_departure <= p.dbd2_hours_threshold
                THEN sl.fare_before_booking
            END,
            0.5
        ) AS median_fare_within_dbd2

    FROM seat_level sl
    INNER JOIN eligible_routes er
        ON sl.route_id = er.route_id
    CROSS JOIN params p
    GROUP BY
        1, 2, 3, 4, 5, 6, 7, 8
),

ranked AS (
    SELECT
        sm.*,

        ROW_NUMBER() OVER (
            PARTITION BY sm.route_id
            ORDER BY sm.median_hours_before_departure DESC
        ) AS seat_rank,

        ROUND(
            100.0 * sm.booked_within_dbd2_doj_count
            / NULLIF(sm.booked_doj_count, 0),
            2
        ) AS prob_sold_within_dbd2_pct,

        ROUND(
            100.0 * sm.booked_beyond_dbd2_doj_count
            / NULLIF(sm.booked_doj_count, 0),
            2
        ) AS prob_sold_beyond_dbd2_pct,

        ROUND(
            sm.median_fare_beyond_dbd2 - sm.median_fare_within_dbd2,
            2
        ) AS asp_diff_abs,

        ROUND(
            100.0 * (
                sm.median_fare_beyond_dbd2 - sm.median_fare_within_dbd2
            ) / NULLIF(sm.median_fare_within_dbd2, 0),
            2
        ) AS asp_diff_pct

    FROM seat_median sm
)

SELECT
    r.sd_rank,
    r.source_id,
    src.location_name AS source_city,
    r.destination_id,
    dst.location_name AS destination_city,
    r.sd_bookings,
    r.route_rank_within_sd,
    r.route_id,
    r.route_bookings,
    r.seat_rank,
    r.seat_number,
    r.median_hours_before_departure,
    r.booked_doj_count,
    r.booked_within_dbd2_doj_count,
    r.booked_beyond_dbd2_doj_count,
    r.prob_sold_within_dbd2_pct,
    r.prob_sold_beyond_dbd2_pct,
    r.median_fare_beyond_dbd2,
    r.median_fare_within_dbd2,
    r.asp_diff_abs,
    r.asp_diff_pct

FROM ranked r

LEFT JOIN lis.config_locations src
    ON r.source_id = src.id
   AND src.location_type = 'CITY'
   AND src.is_expired = 0

LEFT JOIN lis.config_locations dst
    ON r.destination_id = dst.id
   AND dst.location_type = 'CITY'
   AND dst.is_expired = 0

WHERE r.seat_rank <= 10

ORDER BY
    r.sd_rank,
    r.route_rank_within_sd,
    r.seat_rank;
