WITH params AS (
    SELECT
        TIMESTAMP '2026-05-01 00:00:00' AS txn_start,
        TIMESTAMP '2026-06-01 00:00:00' AS txn_end,
        TIMESTAMP '2026-05-01 00:00:00' AS srp_start,
        TIMESTAMP '2026-06-01 00:00:00' AS srp_end,
        TIMESTAMP '2026-06-01 00:00:00' AS comfort_srp_start,
        TIMESTAMP '2026-06-04 00:00:00' AS comfort_srp_end,
        0.80 AS asp_pct_threshold
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

route_base_flags AS (
    SELECT
        srd.src_id AS source_id,
        srd.dest_id AS destination_id,
        srd.route_id,
        MAX(CASE WHEN LOWER(COALESCE(srd.bus_type, '')) LIKE '%volvo%' THEN 1 ELSE 0 END)
            AS is_volvo,
        MAX(CASE WHEN LOWER(COALESCE(srd.bus_type, '')) LIKE '%bharat benz%' THEN 1 ELSE 0 END)
            AS is_bharat_benz,
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

comfort_routes AS (
    SELECT
        srd.route_id,
        CAST(
            element_at(
                srd.persuasion_score,
                array_position(srd.persuasion_id, '4401')
            ) AS DOUBLE
        ) AS comfort_score
    FROM user_interaction.search_route_details srd
    CROSS JOIN params p
    WHERE srd.__time >= p.comfort_srp_start
      AND srd.__time < p.comfort_srp_end
      AND srd.channel IN ('MOBILE_APP')
      AND srd.os IN ('Android')
      AND srd.bu = 'BUS'
      AND srd.country = 'IND'
      AND srd.route_id IS NOT NULL
      AND srd.persuasion_id IS NOT NULL
      AND srd.persuasion_score IS NOT NULL
      AND CONTAINS(srd.persuasion_id, '4401')
      AND array_position(srd.persuasion_id, '4401') IS NOT NULL
),

comfort_bucketed AS (
    SELECT
        cr.route_id,
        cr.comfort_score,
        CAST(ROUND(cr.comfort_score) AS INTEGER) AS comfort_score_bucket
    FROM comfort_routes cr
    WHERE cr.comfort_score IS NOT NULL
),

comfort_route_flags AS (
    SELECT DISTINCT
        cb.route_id,
        1 AS is_comfort_8_9
    FROM comfort_bucketed cb
    WHERE cb.comfort_score_bucket IN (8, 9)
),

routes_joined AS (
    SELECT
        rab.source_id,
        rab.destination_id,
        rab.route_id,
        rab.asp_bucket,
        rab.route_tin_count,
        COALESCE(rbf.is_volvo, 0) AS is_volvo,
        COALESCE(rbf.is_bharat_benz, 0) AS is_bharat_benz,
        COALESCE(rbf.is_toilet, 0) AS is_toilet,
        COALESCE(crf.is_comfort_8_9, 0) AS is_comfort_8_9
    FROM route_asp_bucketed rab
    LEFT JOIN route_base_flags rbf
        ON rab.source_id = rbf.source_id
       AND rab.destination_id = rbf.destination_id
       AND rab.route_id = rbf.route_id
    LEFT JOIN comfort_route_flags crf
        ON rab.route_id = crf.route_id
)

SELECT
    rj.source_id,
    src.location_name AS source_city,
    rj.destination_id,
    dst.location_name AS destination_city,

    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_volvo = 1 THEN rj.route_id END)
        AS lt_80_volvo_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_toilet = 1 THEN rj.route_id END)
        AS lt_80_toilet_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_comfort_8_9 = 1 THEN rj.route_id END)
        AS lt_80_comfort_8_9_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_bharat_benz = 1 THEN rj.route_id END)
        AS lt_80_bharat_benz_routes,
    COUNT(DISTINCT CASE
        WHEN rj.asp_bucket = 'LT_80_ASP_PCT'
         AND (rj.is_volvo = 1 OR rj.is_bharat_benz = 1 OR rj.is_toilet = 1 OR rj.is_comfort_8_9 = 1)
        THEN rj.route_id
    END) AS lt_80_any_amenity_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' THEN rj.route_id END)
        AS lt_80_total_routes,

    SUM(CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_volvo = 1 THEN rj.route_tin_count ELSE 0 END)
        AS lt_80_volvo_txns,
    SUM(CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_toilet = 1 THEN rj.route_tin_count ELSE 0 END)
        AS lt_80_toilet_txns,
    SUM(CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_comfort_8_9 = 1 THEN rj.route_tin_count ELSE 0 END)
        AS lt_80_comfort_8_9_txns,
    SUM(CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' AND rj.is_bharat_benz = 1 THEN rj.route_tin_count ELSE 0 END)
        AS lt_80_bharat_benz_txns,
    SUM(CASE WHEN rj.asp_bucket = 'LT_80_ASP_PCT' THEN rj.route_tin_count ELSE 0 END)
        AS lt_80_total_txns,

    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_volvo = 1 THEN rj.route_id END)
        AS gte_80_volvo_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_toilet = 1 THEN rj.route_id END)
        AS gte_80_toilet_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_comfort_8_9 = 1 THEN rj.route_id END)
        AS gte_80_comfort_8_9_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_bharat_benz = 1 THEN rj.route_id END)
        AS gte_80_bharat_benz_routes,
    COUNT(DISTINCT CASE
        WHEN rj.asp_bucket = 'GTE_80_ASP_PCT'
         AND (rj.is_volvo = 1 OR rj.is_bharat_benz = 1 OR rj.is_toilet = 1 OR rj.is_comfort_8_9 = 1)
        THEN rj.route_id
    END) AS gte_80_any_amenity_routes,
    COUNT(DISTINCT CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' THEN rj.route_id END)
        AS gte_80_total_routes,

    SUM(CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_volvo = 1 THEN rj.route_tin_count ELSE 0 END)
        AS gte_80_volvo_txns,
    SUM(CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_toilet = 1 THEN rj.route_tin_count ELSE 0 END)
        AS gte_80_toilet_txns,
    SUM(CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_comfort_8_9 = 1 THEN rj.route_tin_count ELSE 0 END)
        AS gte_80_comfort_8_9_txns,
    SUM(CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' AND rj.is_bharat_benz = 1 THEN rj.route_tin_count ELSE 0 END)
        AS gte_80_bharat_benz_txns,
    SUM(CASE WHEN rj.asp_bucket = 'GTE_80_ASP_PCT' THEN rj.route_tin_count ELSE 0 END)
        AS gte_80_total_txns

FROM routes_joined rj
LEFT JOIN lis.config_locations src
    ON rj.source_id = src.id
   AND src.location_type = 'CITY'
   AND src.is_expired = 0
LEFT JOIN lis.config_locations dst
    ON rj.destination_id = dst.id
   AND dst.location_type = 'CITY'
   AND dst.is_expired = 0
GROUP BY
    rj.source_id,
    src.location_name,
    rj.destination_id,
    dst.location_name
ORDER BY
    rj.source_id,
    rj.destination_id
