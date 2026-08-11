WITH params AS (
    SELECT
        TIMESTAMP '2026-05-01 00:00:00' AS txn_start,
        TIMESTAMP '2026-06-01 00:00:00' AS txn_end,
        TIMESTAMP '2026-05-01 00:00:00' AS srp_start,
        TIMESTAMP '2026-06-01 00:00:00' AS srp_end,
        0.80 AS asp_pct_threshold
),

route_asp AS (
    SELECT
        bte.source_location_id AS source_id,
        bte.destination_location_id AS destination_id,
        bte.route_id,
        MAX(bte.operator_id) AS operator_id,
        AVG(CAST(bte.seat_price[1] AS DOUBLE)) AS route_asp
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

route_enriched AS (
    SELECT
        ral.source_id,
        ral.destination_id,
        ral.asset_class,
        ral.route_id,
        rab.asp_bucket,
        rab.operator_id
    FROM route_asset_long ral
    INNER JOIN route_asp_bucketed rab
        ON ral.source_id = rab.source_id
       AND ral.destination_id = rab.destination_id
       AND ral.route_id = rab.route_id
),

review_vfm AS (
    SELECT DISTINCT
        bte.operator_id
    FROM transaction.bus_ticket_events bte
    INNER JOIN (
        SELECT tin
        FROM ugc.review
        WHERE REGEXP_LIKE(
            LOWER(COALESCE(review, '') || ' ' || COALESCE(moderated_review, '')),
            'value (for|of) money'
        )
    ) rev
        ON bte.tin = rev.tin
    CROSS JOIN params p
    WHERE bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.time_of_event >= p.txn_start
      AND bte.time_of_event < p.txn_end
      AND bte.operator_id IS NOT NULL
)

SELECT
    re.source_id,
    src.location_name AS source_city,
    re.destination_id,
    dst.location_name AS destination_city,
    re.asset_class,
    re.asp_bucket,
    COUNT(DISTINCT re.operator_id) AS total_distinct_operators,
    COUNT(DISTINCT CASE WHEN vfm.operator_id IS NOT NULL THEN re.operator_id END)
        AS operators_with_value_for_money,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN vfm.operator_id IS NOT NULL THEN re.operator_id END)
        / NULLIF(COUNT(DISTINCT re.operator_id), 0),
        2
    ) AS operator_vfm_share_pct,
    ARRAY_JOIN(
        ARRAY_SORT(
            ARRAY_AGG(DISTINCT op.allow_travels_name)
                FILTER (WHERE vfm.operator_id IS NOT NULL)
        ),
        ' | '
    ) AS value_for_money_operator_names
FROM route_enriched re
LEFT JOIN review_vfm vfm
    ON re.operator_id = vfm.operator_id
LEFT JOIN lis.operators op
    ON re.operator_id = op.operator_id
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
    re.asset_class,
    re.asp_bucket
ORDER BY
    re.source_id,
    re.destination_id,
    re.asset_class,
    re.asp_bucket
