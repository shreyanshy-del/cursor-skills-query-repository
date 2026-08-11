WITH params AS (
    SELECT
        TIMESTAMP '2026-05-01 00:00:00' AS txn_start,
        TIMESTAMP '2026-06-01 00:00:00' AS txn_end,
        TIMESTAMP '2026-05-01 00:00:00' AS srp_start,
        TIMESTAMP '2026-06-01 00:00:00' AS srp_end,
        0.80 AS asp_pct_threshold,
        200 AS top_n_sds
),

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

eligible_sds AS (
    SELECT
        source_id,
        destination_id,
        sd_bookings,
        sd_rank
    FROM top_sds
    CROSS JOIN params p
    WHERE sd_rank <= p.top_n_sds
),

route_asp AS (
    SELECT
        bte.source_location_id AS source_id,
        bte.destination_location_id AS destination_id,
        bte.route_id,
        MAX(bte.operator_id) AS operator_id,
        AVG(CAST(bte.seat_price[1] AS DOUBLE)) AS route_asp
    FROM transaction.bus_ticket_events bte
    INNER JOIN eligible_sds es
        ON bte.source_location_id = es.source_id
       AND bte.destination_location_id = es.destination_id
    CROSS JOIN params p
    WHERE bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.time_of_event >= p.txn_start
      AND bte.time_of_event < p.txn_end
      AND bte.route_id IS NOT NULL
      AND bte.seat_price IS NOT NULL
      AND CARDINALITY(bte.seat_price) > 0
    GROUP BY
        1, 2, 3
),

route_asp_bucketed AS (
    SELECT
        ra.*,
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
        MAX(CASE WHEN srd.as_seat_score IS NOT NULL THEN 1 ELSE 0 END)
            AS is_comfort,
        MAX(CASE WHEN CONTAINS(srd.persuasion_id, '537') THEN 1 ELSE 0 END)
            AS is_toilet
    FROM user_interaction.search_route_details srd
    INNER JOIN eligible_sds es
        ON srd.src_id = es.source_id
       AND srd.dest_id = es.destination_id
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

route_operator_asset AS (
    SELECT
        es.sd_rank,
        es.sd_bookings,
        rab.source_id,
        rab.destination_id,
        rab.asp_bucket,
        ral.asset_class,
        rab.operator_id,
        COALESCE(op.allow_travels_name, CAST(rab.operator_id AS VARCHAR)) AS operator_name
    FROM route_asp_bucketed rab
    INNER JOIN eligible_sds es
        ON rab.source_id = es.source_id
       AND rab.destination_id = es.destination_id
    INNER JOIN route_asset_long ral
        ON rab.source_id = ral.source_id
       AND rab.destination_id = ral.destination_id
       AND rab.route_id = ral.route_id
    LEFT JOIN lis.operators op
        ON rab.operator_id = op.operator_id
    WHERE rab.operator_id IS NOT NULL
),

sd_route_operators AS (
    SELECT
        es.sd_rank,
        es.sd_bookings,
        rab.source_id,
        rab.destination_id,
        rab.asp_bucket,
        rab.operator_id,
        COALESCE(op.allow_travels_name, CAST(rab.operator_id AS VARCHAR)) AS operator_name
    FROM route_asp_bucketed rab
    INNER JOIN eligible_sds es
        ON rab.source_id = es.source_id
       AND rab.destination_id = es.destination_id
    LEFT JOIN lis.operators op
        ON rab.operator_id = op.operator_id
    WHERE rab.operator_id IS NOT NULL
),

sd_operator_totals AS (
    SELECT
        sd_rank,
        sd_bookings,
        source_id,
        destination_id,
        COUNT(DISTINCT CASE WHEN asp_bucket = 'LT_80_ASP_PCT' THEN operator_id END)
            AS total_distinct_operators_sd_lt_80,
        COUNT(DISTINCT CASE WHEN asp_bucket = 'GTE_80_ASP_PCT' THEN operator_id END)
            AS total_distinct_operators_sd_gte_80,
        COUNT(DISTINCT operator_id) AS total_distinct_operators_sd_both_asp_groups,
        ARRAY_JOIN(
            ARRAY_SORT(
                ARRAY_AGG(DISTINCT operator_name)
                    FILTER (WHERE asp_bucket = 'LT_80_ASP_PCT')
            ),
            ' | '
        ) AS operator_names_sd_lt_80,
        ARRAY_JOIN(
            ARRAY_SORT(
                ARRAY_AGG(DISTINCT operator_name)
                    FILTER (WHERE asp_bucket = 'GTE_80_ASP_PCT')
            ),
            ' | '
        ) AS operator_names_sd_gte_80,
        ARRAY_JOIN(
            ARRAY_SORT(ARRAY_AGG(DISTINCT operator_name)),
            ' | '
        ) AS operator_names_sd_both_asp_groups
    FROM sd_route_operators
    GROUP BY
        1, 2, 3, 4
)

SELECT
    roa.sd_rank,
    roa.source_id,
    src.location_name AS source_city,
    roa.destination_id,
    dst.location_name AS destination_city,
    roa.sd_bookings,
    roa.asset_class,
    COUNT(DISTINCT CASE WHEN roa.asp_bucket = 'LT_80_ASP_PCT' THEN roa.operator_id END)
        AS distinct_operators_asset_lt_80,
    ARRAY_JOIN(
        ARRAY_SORT(
            ARRAY_AGG(DISTINCT roa.operator_name)
                FILTER (WHERE roa.asp_bucket = 'LT_80_ASP_PCT')
        ),
        ' | '
    ) AS operator_names_asset_lt_80,
    COUNT(DISTINCT CASE WHEN roa.asp_bucket = 'GTE_80_ASP_PCT' THEN roa.operator_id END)
        AS distinct_operators_asset_gte_80,
    ARRAY_JOIN(
        ARRAY_SORT(
            ARRAY_AGG(DISTINCT roa.operator_name)
                FILTER (WHERE roa.asp_bucket = 'GTE_80_ASP_PCT')
        ),
        ' | '
    ) AS operator_names_asset_gte_80,
    COUNT(DISTINCT roa.operator_id) AS distinct_operators_asset_both_asp_groups,
    ARRAY_JOIN(
        ARRAY_SORT(ARRAY_AGG(DISTINCT roa.operator_name)),
        ' | '
    ) AS operator_names_asset_both_asp_groups,
    sot.total_distinct_operators_sd_lt_80,
    sot.operator_names_sd_lt_80,
    sot.total_distinct_operators_sd_gte_80,
    sot.operator_names_sd_gte_80,
    sot.total_distinct_operators_sd_both_asp_groups,
    sot.operator_names_sd_both_asp_groups
FROM route_operator_asset roa
INNER JOIN sd_operator_totals sot
    ON roa.sd_rank = sot.sd_rank
   AND roa.source_id = sot.source_id
   AND roa.destination_id = sot.destination_id
LEFT JOIN lis.config_locations src
    ON roa.source_id = src.id
   AND src.location_type = 'CITY'
   AND src.is_expired = 0
LEFT JOIN lis.config_locations dst
    ON roa.destination_id = dst.id
   AND dst.location_type = 'CITY'
   AND dst.is_expired = 0
GROUP BY
    roa.sd_rank,
    roa.source_id,
    src.location_name,
    roa.destination_id,
    dst.location_name,
    roa.sd_bookings,
    roa.asset_class,
    sot.total_distinct_operators_sd_lt_80,
    sot.operator_names_sd_lt_80,
    sot.total_distinct_operators_sd_gte_80,
    sot.operator_names_sd_gte_80,
    sot.total_distinct_operators_sd_both_asp_groups,
    sot.operator_names_sd_both_asp_groups
ORDER BY
    roa.sd_rank,
    roa.asset_class
