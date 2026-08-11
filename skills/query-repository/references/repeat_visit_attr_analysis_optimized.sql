-- =============================================================================
-- Repeat-visit attribute analysis (optimized)
-- Engine: Trino / Presto
--
-- Cohort: Same SD + Same DOJ, Visit 1 (>=2 SL routes, non-transacted) + Visit 2
--
-- Segments:
--   journey_duration_cut : Visit 1 median route duration < 6h vs >= 6h
--   route_share_bucket   : No Same Routes | < 50% Route Share | >= 50% Route Share
--
-- Metrics per instance (any V1 route vs any V2 route):
--   Price +/-100 | Rating +/-0.2 | Same bus_type | Duration +/-2h
--
-- Optimizations:
--   1. Single filtered scan each of search_route_details and seat_layout_details
--   2. One route_enriched pass (session + route attrs); no double RD join
--   3. NOT EXISTS anti-join for transacted sessions
--   4. Non-transacted filter before ROW_NUMBER window
--   5. Slim visit2 CTE for smaller pairing join
--   6. ARRAY_INTERSECT computed once in visit_pairs
--   7. cohort_route_attrs limits attr join to revisit sessions only
--   8. Single-pass MAX aggregation for attribute flags (one route-pair scan)
--   9. metric_long UNION ALL unpivot (Trino-safe; avoids ROW unnest alias errors)
--  10. Combined user_base + revisit_user_base in one aggregation
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-06 18:30:00' AS t_start,
        TIMESTAMP '2026-06-10 18:30:00' AS t_end
),

transacted_sessions AS (
    SELECT cf.mri_session_id
    FROM user_interaction.confirm_order_details cf
    CROSS JOIN params p
    WHERE cf.__time >= p.t_start
      AND cf.__time <  p.t_end
      AND cf.country = 'IND'
      AND cf.error_code = 'CONFIRMED'
      AND cf.status_str = 'SUCCESS'
      AND cf.tin IS NOT NULL
      AND NULLIF(TRIM(CAST(cf.tin AS VARCHAR)), '') IS NOT NULL
      AND LOWER(TRIM(CAST(cf.tin AS VARCHAR))) <> 'null'
    GROUP BY 1
),

filtered_rd AS (
    SELECT
        rd.mri_session_id,
        rd.__time,
        rd.user_type,
        rd.src_id,
        rd.dest_id,
        TRY_CAST(TRIM(CAST(rd.route_id AS VARCHAR)) AS BIGINT) AS route_id,
        TRY_CAST(rd.doj AS DATE) AS doj,
        rd.wt_price,
        rd.fare_list,
        rd.total_ratings,
        rd.bus_type,
        rd.departure_time,
        rd.arrival_time
    FROM user_interaction.search_route_details rd
    CROSS JOIN params p
    WHERE rd.__time >= p.t_start
      AND rd.__time <  p.t_end
      AND rd.country = 'IND'
      AND rd.event_type = 'Search-Routes'
      AND rd.status < 400
      AND (rd.akamai_bot IS NULL OR rd.akamai_bot = '')
      AND rd.mri_session_id IS NOT NULL
),

filtered_sl AS (
    SELECT
        sl.mri_session_id,
        sl.mri_client_id,
        sl.__time,
        TRY_CAST(TRIM(CAST(sl.route_id AS VARCHAR)) AS BIGINT) AS route_id,
        TRY_CAST(sl.doj AS DATE) AS doj
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN params p
    WHERE sl.__time >= p.t_start
      AND sl.__time <  p.t_end
      AND sl.country = 'IND'
      AND sl.mri_client_id IS NOT NULL
      AND sl.mri_session_id IS NOT NULL
      AND sl.route_id IS NOT NULL
      AND sl.doj IS NOT NULL
      AND NULLIF(TRIM(CAST(sl.doj AS VARCHAR)), '') IS NOT NULL
      AND REGEXP_LIKE(TRIM(CAST(sl.route_id AS VARCHAR)), '^[0-9]+$')
),

srp_sessions AS (
    SELECT
        sd.mri_session_id,
        MIN(sd.__time) AS t_srp
    FROM user_interaction.search_details sd
    CROSS JOIN params p
    WHERE sd.__time >= p.t_start
      AND sd.__time <  p.t_end
      AND sd.country = 'IND'
      AND sd.status = 200
      AND sd.mri_session_id IS NOT NULL
    GROUP BY 1
),

session_user_type AS (
    SELECT
        s.mri_session_id,
        CASE UPPER(TRIM(COALESCE(min_by(rd.user_type, rd.__time), '')))
            WHEN 'NEW' THEN 'New'
            WHEN 'RETURNING' THEN 'Returning'
            WHEN 'RETURN' THEN 'Returning'
            WHEN 'GUEST' THEN 'Guest'
            ELSE 'Unknown'
        END AS user_type
    FROM srp_sessions s
    INNER JOIN filtered_rd rd
        ON rd.mri_session_id = s.mri_session_id
       AND rd.__time >= s.t_srp
    GROUP BY 1
),

session_routes AS (
    SELECT
        s.mri_session_id,
        sl.mri_client_id,
        sl.route_id,
        sl.doj,
        MIN(sl.__time) AS t_sl
    FROM srp_sessions s
    INNER JOIN filtered_sl sl
        ON sl.mri_session_id = s.mri_session_id
       AND sl.__time >= s.t_srp
    GROUP BY 1, 2, 3, 4
),

session_route_summary AS (
    SELECT
        mri_session_id,
        mri_client_id,
        MIN(t_sl) AS t_sl,
        COUNT(DISTINCT route_id) AS distinct_route_count,
        ARRAY_AGG(DISTINCT route_id) AS route_ids
    FROM session_routes
    GROUP BY 1, 2
),

route_enriched AS (
    SELECT
        sr.mri_session_id,
        sr.mri_client_id,
        sr.route_id,
        sr.doj,
        sr.t_sl,
        min_by(rd.src_id, rd.__time) AS src_id,
        min_by(rd.dest_id, rd.__time) AS dest_id,
        min_by(rd.wt_price, rd.__time) AS wt_price,
        min_by(rd.fare_list, rd.__time) AS fare_list,
        min_by(rd.total_ratings, rd.__time) AS total_ratings,
        min_by(rd.bus_type, rd.__time) AS bus_type,
        min_by(rd.departure_time, rd.__time) AS departure_time,
        min_by(rd.arrival_time, rd.__time) AS arrival_time
    FROM session_routes sr
    INNER JOIN filtered_rd rd
        ON rd.mri_session_id = sr.mri_session_id
       AND rd.route_id = sr.route_id
       AND rd.doj = sr.doj
       AND rd.__time <= sr.t_sl
    GROUP BY 1, 2, 3, 4, 5
),

route_level_attrs AS (
    SELECT
        mri_session_id,
        route_id,
        COALESCE(
            TRY_CAST(wt_price AS DOUBLE),
            TRY_CAST(array_min(fare_list) AS DOUBLE)
        ) AS route_price,
        TRY_CAST(total_ratings AS DOUBLE) AS route_rating,
        UPPER(TRIM(COALESCE(bus_type, ''))) AS bus_type,
        1.0 * date_diff('minute', departure_time, arrival_time) / 60.0 AS journey_duration_hours
    FROM route_enriched
),

route_attrs AS (
    SELECT
        mri_session_id,
        mri_client_id,
        MIN(t_sl) AS t_sl,
        min_by(doj, route_id) AS doj,
        min_by(src_id, route_id) AS src_id,
        min_by(dest_id, route_id) AS dest_id
    FROM route_enriched
    GROUP BY 1, 2
),

non_transacted_visits AS (
    SELECT
        ra.mri_session_id,
        ra.mri_client_id,
        COALESCE(sut.user_type, 'Unknown') AS user_type,
        ra.t_sl AS visit_time,
        ra.doj,
        ra.src_id,
        ra.dest_id,
        srs.distinct_route_count,
        srs.route_ids,
        ROW_NUMBER() OVER (
            PARTITION BY ra.mri_client_id
            ORDER BY ra.t_sl, ra.mri_session_id
        ) AS visit_num
    FROM route_attrs ra
    INNER JOIN session_route_summary srs
        ON ra.mri_session_id = srs.mri_session_id
       AND ra.mri_client_id = srs.mri_client_id
    LEFT JOIN session_user_type sut
        ON ra.mri_session_id = sut.mri_session_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM transacted_sessions ts
        WHERE ts.mri_session_id = ra.mri_session_id
    )
),

visit1 AS (
    SELECT *
    FROM non_transacted_visits
    WHERE visit_num = 1
      AND distinct_route_count >= 2
      AND user_type IN ('New', 'Returning', 'Guest')
),

visit2 AS (
    SELECT
        mri_client_id,
        mri_session_id,
        doj,
        src_id,
        dest_id,
        route_ids
    FROM non_transacted_visits
    WHERE visit_num = 2
),

visit_pairs AS (
    SELECT
        v1.user_type,
        v1.mri_client_id,
        v1.mri_session_id AS visit1_session_id,
        v2.mri_session_id AS visit2_session_id,
        v1.distinct_route_count AS visit1_route_count,
        v1.route_ids AS visit1_route_ids,
        v2.route_ids AS visit2_route_ids,
        CARDINALITY(ARRAY_INTERSECT(v1.route_ids, v2.route_ids)) AS same_route_id_count
    FROM visit1 v1
    INNER JOIN visit2 v2
        ON v1.mri_client_id = v2.mri_client_id
       AND v1.mri_session_id <> v2.mri_session_id
       AND v2.doj = v1.doj
       AND v2.src_id = v1.src_id
       AND v2.dest_id = v1.dest_id
),

visit1_duration AS (
    SELECT
        v1.mri_session_id AS visit1_session_id,
        approx_percentile(rla.journey_duration_hours, 0.5) AS visit1_median_journey_hours
    FROM visit1 v1
    INNER JOIN route_level_attrs rla
        ON rla.mri_session_id = v1.mri_session_id
       AND contains(v1.route_ids, rla.route_id)
    WHERE rla.journey_duration_hours IS NOT NULL
    GROUP BY 1
),

instances AS (
    SELECT
        vp.user_type,
        vp.mri_client_id,
        vp.visit1_session_id,
        vp.visit2_session_id,
        vp.visit1_route_count,
        vp.visit1_route_ids,
        vp.visit2_route_ids,
        vp.same_route_id_count,
        CASE
            WHEN vd.visit1_median_journey_hours < 6 THEN '< 6 Hours'
            ELSE '>= 6 Hours'
        END AS journey_duration_cut,
        CASE
            WHEN vp.same_route_id_count = 0 THEN 'No Same Routes'
            WHEN 100.0 * vp.same_route_id_count / NULLIF(vp.visit1_route_count, 0) < 50
                THEN '< 50% Route Share'
            ELSE '>= 50% Route Share'
        END AS route_share_bucket,
        CASE
            WHEN vp.same_route_id_count = 0 THEN 1
            WHEN 100.0 * vp.same_route_id_count / NULLIF(vp.visit1_route_count, 0) < 50 THEN 2
            ELSE 3
        END AS route_share_order
    FROM visit_pairs vp
    LEFT JOIN visit1_duration vd
        ON vp.visit1_session_id = vd.visit1_session_id
),

cohort_sessions AS (
    SELECT visit1_session_id AS mri_session_id FROM visit_pairs
    UNION
    SELECT visit2_session_id FROM visit_pairs
),

cohort_route_attrs AS (
    SELECT rla.*
    FROM route_level_attrs rla
    INNER JOIN cohort_sessions cs
        ON rla.mri_session_id = cs.mri_session_id
),

instance_attr_flags AS (
    SELECT
        i.visit1_session_id,
        i.visit2_session_id,
        i.user_type,
        i.journey_duration_cut,
        i.route_share_bucket,
        i.route_share_order,
        MAX(
            CASE
                WHEN r1.route_price IS NOT NULL
                 AND r2.route_price IS NOT NULL
                 AND ABS(r1.route_price - r2.route_price) <= 100
                    THEN 1 ELSE 0
            END
        ) AS price_match_yes,
        MAX(
            CASE
                WHEN r1.route_rating IS NOT NULL
                 AND r2.route_rating IS NOT NULL
                 AND ABS(r1.route_rating - r2.route_rating) <= 0.2
                    THEN 1 ELSE 0
            END
        ) AS rating_match_yes,
        MAX(
            CASE
                WHEN r1.bus_type <> ''
                 AND r2.bus_type <> ''
                 AND r1.bus_type = r2.bus_type
                    THEN 1 ELSE 0
            END
        ) AS bus_type_match_yes,
        MAX(
            CASE
                WHEN r1.journey_duration_hours IS NOT NULL
                 AND r2.journey_duration_hours IS NOT NULL
                 AND ABS(r1.journey_duration_hours - r2.journey_duration_hours) <= 2
                    THEN 1 ELSE 0
            END
        ) AS duration_match_yes
    FROM instances i
    INNER JOIN cohort_route_attrs r1
        ON r1.mri_session_id = i.visit1_session_id
       AND contains(i.visit1_route_ids, r1.route_id)
    INNER JOIN cohort_route_attrs r2
        ON r2.mri_session_id = i.visit2_session_id
       AND contains(i.visit2_route_ids, r2.route_id)
    GROUP BY 1, 2, 3, 4, 5, 6
),

user_bases AS (
    SELECT
        v1.user_type,
        COUNT(DISTINCT v1.mri_client_id) AS visit1_user_count,
        COUNT(DISTINCT vp.mri_client_id) AS revisit_user_count
    FROM visit1 v1
    LEFT JOIN visit_pairs vp
        ON v1.user_type = vp.user_type
       AND v1.mri_client_id = vp.mri_client_id
    GROUP BY 1
),

segment_base AS (
    SELECT
        user_type,
        journey_duration_cut,
        route_share_bucket,
        route_share_order,
        COUNT(*) AS segment_instance_count
    FROM instances
    GROUP BY 1, 2, 3, 4
),

metric_long AS (
    SELECT
        user_type,
        journey_duration_cut,
        route_share_bucket,
        route_share_order,
        'Price' AS metric_name,
        1 AS metric_order,
        IF(price_match_yes = 1, 'Yes', 'No') AS match_flag
    FROM instance_attr_flags
    UNION ALL
    SELECT
        user_type,
        journey_duration_cut,
        route_share_bucket,
        route_share_order,
        'Rating',
        2,
        IF(rating_match_yes = 1, 'Yes', 'No')
    FROM instance_attr_flags
    UNION ALL
    SELECT
        user_type,
        journey_duration_cut,
        route_share_bucket,
        route_share_order,
        'Bus Type',
        3,
        IF(bus_type_match_yes = 1, 'Yes', 'No')
    FROM instance_attr_flags
    UNION ALL
    SELECT
        user_type,
        journey_duration_cut,
        route_share_bucket,
        route_share_order,
        'Duration',
        4,
        IF(duration_match_yes = 1, 'Yes', 'No')
    FROM instance_attr_flags
)

SELECT
    ml.user_type,
    ub.visit1_user_count,
    ub.revisit_user_count,
    ROUND(100.0 * ub.revisit_user_count / NULLIF(ub.visit1_user_count, 0), 2) AS pct_visit1_to_revisit,
    ml.journey_duration_cut,
    ml.route_share_bucket,
    sb.segment_instance_count,
    ml.metric_name,
    ml.match_flag,
    COUNT(*) AS instance_count,
    ROUND(
        100.0 * COUNT(*) / NULLIF(sb.segment_instance_count, 0),
        2
    ) AS pct_within_segment
FROM metric_long ml
INNER JOIN user_bases ub
    ON ml.user_type = ub.user_type
INNER JOIN segment_base sb
    ON ml.user_type = sb.user_type
   AND ml.journey_duration_cut = sb.journey_duration_cut
   AND ml.route_share_bucket = sb.route_share_bucket
GROUP BY
    ml.user_type,
    ub.visit1_user_count,
    ub.revisit_user_count,
    ml.journey_duration_cut,
    ml.route_share_bucket,
    sb.segment_instance_count,
    ml.route_share_order,
    ml.metric_name,
    ml.metric_order,
    ml.match_flag
ORDER BY
    CASE ml.user_type WHEN 'New' THEN 1 WHEN 'Returning' THEN 2 WHEN 'Guest' THEN 3 END,
    CASE ml.journey_duration_cut WHEN '< 6 Hours' THEN 1 ELSE 2 END,
    ml.route_share_order,
    ml.metric_order,
    CASE ml.match_flag WHEN 'Yes' THEN 1 ELSE 2 END;

-- =============================================================================
-- Fallbacks if needed:
--
-- 1) array_min unavailable:
--    COALESCE(TRY_CAST(wt_price AS DOUBLE),
--             (SELECT MIN(x) FROM UNNEST(fare_list) AS t(x)))
--
-- 2) contains() unavailable — replace with:
--    INNER JOIN UNNEST(visit1_route_ids) AS v1(route_id) ON r1.route_id = v1.route_id
--
-- 3) ARRAY_INTERSECT unavailable:
--    (SELECT COUNT(*) FROM UNNEST(v1.route_ids) t1(rid)
--     INNER JOIN UNNEST(v2.route_ids) t2(rid) ON t1.rid = t2.rid)
-- =============================================================================
