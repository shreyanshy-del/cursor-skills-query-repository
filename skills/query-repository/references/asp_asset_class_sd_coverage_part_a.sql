WITH params AS (
    SELECT
        TIMESTAMP '2026-05-01 00:00:00' AS txn_start,
        TIMESTAMP '2026-06-01 00:00:00' AS txn_end,
        TIMESTAMP '2026-05-01 00:00:00' AS srp_start,
        TIMESTAMP '2026-06-01 00:00:00' AS srp_end,
        0.80 AS asp_pct_threshold,
        8.0 AS comfort_score_min
),

route_asp AS (
    SELECT
        bte.source_location_id AS source_id,
        bte.destination_location_id AS destination_id,
        bte.route_id,
        AVG(CAST(bte.seat_price[1] AS DOUBLE)) AS route_asp,
        COUNT(DISTINCT bte.tin) AS route_tin_count
    FROM transaction.bus_ticket_events bte
    CROSS JOIN params p
    WHERE bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.time_of_event >= p.txn_start
      AND bte.time_of_event < p.txn_end
      AND bte.source_location_id IS NOT NULL
      AND bte.destination_location_id IS NOT NULL
      AND bte.route_id IS NOT NULL
      AND bte.seat_price IS NOT NULL
      AND CARDINALITY(bte.seat_price) > 0
    GROUP BY
        1, 2, 3
),

route_asp_bucketed AS (
    SELECT
        ra.*,
        PERCENT_RANK() OVER (
            PARTITION BY ra.source_id, ra.destination_id
            ORDER BY ra.route_asp
        ) AS asp_percentile_rank,
        CASE
            WHEN PERCENT_RANK() OVER (
                PARTITION BY ra.source_id, ra.destination_id
                ORDER BY ra.route_asp
            ) >= p.asp_pct_threshold
            THEN 'GTE_80_ASP_PCT'
            ELSE 'LT_80_ASP_PCT'
        END AS asp_bucket
    FROM route_asp ra
    CROSS JOIN params p
),

route_asset_flags AS (
    SELECT
        srd.src_id AS source_id,
        srd.dest_id AS destination_id,
        srd.route_id,
        MAX(CASE WHEN LOWER(COALESCE(srd.bus_type, '')) LIKE '%volvo%' THEN 1 ELSE 0 END)
            AS is_volvo,
        MAX(CASE WHEN LOWER(COALESCE(srd.bus_type, '')) LIKE '%bharat benz%' THEN 1 ELSE 0 END)
            AS is_bharat_benz,
        MAX(CASE WHEN CAST(srd.as_seat_score AS DOUBLE) > p.comfort_score_min THEN 1 ELSE 0 END)
            AS is_comfort,
        MAX(CASE WHEN CONTAINS(srd.persuasion_id, '537') THEN 1 ELSE 0 END)
            AS is_toilet
    FROM user_interaction.search_route_details srd
    CROSS JOIN params p
    WHERE srd.__time >= p.srp_start
      AND srd.__time < p.srp_end
      AND srd.country = 'IND'
      AND srd.route_id IS NOT NULL
      AND srd.src_id IS NOT NULL
      AND srd.dest_id IS NOT NULL
    GROUP BY
        1, 2, 3
),

route_asset_long AS (
    SELECT source_id, destination_id, route_id, 'Volvo' AS asset_class
    FROM route_asset_flags
    WHERE is_volvo = 1

    UNION ALL

    SELECT source_id, destination_id, route_id, 'Bharat Benz' AS asset_class
    FROM route_asset_flags
    WHERE is_bharat_benz = 1

    UNION ALL

    SELECT source_id, destination_id, route_id, 'Comfort' AS asset_class
    FROM route_asset_flags
    WHERE is_comfort = 1

    UNION ALL

    SELECT source_id, destination_id, route_id, 'Toilet' AS asset_class
    FROM route_asset_flags
    WHERE is_toilet = 1
),

sd_asp_bucket_totals AS (
    SELECT
        source_id,
        destination_id,
        asp_bucket,
        COUNT(DISTINCT route_id) AS total_routes_in_sd_asp_bucket,
        SUM(route_tin_count) AS total_txns_in_sd_asp_bucket
    FROM route_asp_bucketed
    GROUP BY
        1, 2, 3
),

route_enriched AS (
    SELECT
        ral.source_id,
        ral.destination_id,
        ral.asset_class,
        ral.route_id,
        rab.asp_bucket,
        rab.route_asp,
        rab.route_tin_count
    FROM route_asset_long ral
    INNER JOIN route_asp_bucketed rab
        ON ral.source_id = rab.source_id
       AND ral.destination_id = rab.destination_id
       AND ral.route_id = rab.route_id
)

SELECT
    re.source_id,
    src.location_name AS source_city,
    re.destination_id,
    dst.location_name AS destination_city,
    re.asp_bucket,
    sabt.total_routes_in_sd_asp_bucket,
    sabt.total_txns_in_sd_asp_bucket,
    re.asset_class,
    COUNT(DISTINCT re.route_id) AS routes_with_asset_class_in_bucket,
    ROUND(
        100.0 * COUNT(DISTINCT re.route_id)
        / NULLIF(sabt.total_routes_in_sd_asp_bucket, 0),
        2
    ) AS asset_class_route_share_pct_in_bucket,
    SUM(re.route_tin_count) AS total_txns_with_asset_in_bucket,
    ROUND(
        100.0 * SUM(re.route_tin_count)
        / NULLIF(sabt.total_txns_in_sd_asp_bucket, 0),
        2
    ) AS asset_class_txn_share_pct_in_bucket,
    ROUND(AVG(re.route_asp), 2) AS avg_route_asp_with_asset
FROM route_enriched re
INNER JOIN sd_asp_bucket_totals sabt
    ON re.source_id = sabt.source_id
   AND re.destination_id = sabt.destination_id
   AND re.asp_bucket = sabt.asp_bucket
LEFT JOIN lis.config_locations src
    ON re.source_id = src.id
   AND src.location_type = 'CITY'
   AND src.is_expired = 0
LEFT JOIN lis.config_locations dst
    ON re.destination_id = dst.id
   AND dst.location_type = 'CITY'
   AND dst.is_expired = 0
GROUP BY
    re.source_id,
    src.location_name,
    re.destination_id,
    dst.location_name,
    re.asp_bucket,
    sabt.total_routes_in_sd_asp_bucket,
    sabt.total_txns_in_sd_asp_bucket,
    re.asset_class
ORDER BY
    re.source_id,
    re.destination_id,
    re.asp_bucket,
    re.asset_class
