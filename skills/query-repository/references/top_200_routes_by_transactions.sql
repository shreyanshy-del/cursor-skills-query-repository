-- Top 200 Routes by confirmed transactions (distinct TINs)
-- Source: transaction.bus_ticket_events
-- Route grain: source_location_id × destination_location_id (city-to-city SD pair)
-- Change ts_start / ts_end in params as needed

WITH params AS (
    SELECT
        TIMESTAMP '2025-05-20 00:00:00' AS ts_start,
        TIMESTAMP '2026-05-20 18:30:00' AS ts_end
),

route_transactions AS (
    SELECT
        t.source_location_id,
        t.destination_location_id,
        MAX(t.source_location)      AS source_location,
        MAX(t.destination_location) AS destination_location,
        CAST(t.source_location_id AS VARCHAR)
            || '_' || CAST(t.destination_location_id AS VARCHAR) AS sd_id,
        COUNT(DISTINCT t.tin) AS transactions
    FROM transaction.bus_ticket_events t
    CROSS JOIN params p
    WHERE t.date_of_issue >= p.ts_start
      AND t.date_of_issue < p.ts_end
      AND t.country_code = 'IND'
      AND t.tin IS NOT NULL
      AND t.tin <> ''
      AND t.tin <> 'null'
      AND t.event_type = 101
      AND t.event_class = 2
      AND t.source_location_id IS NOT NULL
      AND t.destination_location_id IS NOT NULL
    GROUP BY 1, 2
)

SELECT
    p.ts_start,
    p.ts_end,
    r.route_rank,
    r.source_location_id,
    r.destination_location_id,
    r.source_location,
    r.destination_location,
    r.sd_id,
    r.transactions
FROM (
    SELECT
        source_location_id,
        destination_location_id,
        source_location,
        destination_location,
        sd_id,
        transactions,
        ROW_NUMBER() OVER (ORDER BY transactions DESC) AS route_rank
    FROM route_transactions
) r
CROSS JOIN params p
WHERE r.route_rank <= 200
ORDER BY r.route_rank;
