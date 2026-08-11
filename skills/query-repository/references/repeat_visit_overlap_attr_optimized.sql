-- Repeat-visit overlap + attribute match (optimized)
-- Cohort: Same SD, non-transacted Visit1 (>=2 SL routes) + Visit2
-- Segments: overlap_group (No Same Routes | 0-50% | 50-100%) x revisit_gap (<6h | >=6h)
-- Metrics: same price +/-100, same rating +/-0.2, same bus_type (any route pair V1 vs V2)

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-06 18:30:00' AS t_start,  -- 7 Jun 00:00 IST
        TIMESTAMP '2026-06-09 18:30:00' AS t_end     -- 10 Jun 00:00 IST
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
        rd.bus_type
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

session_route_detail AS (
    SELECT
        sr.mri_session_id,
        sr.mri_client_id,
        sr.route_id,
        sr.doj,
        sr.t_sl,
        min_by(rd.src_id, rd.__time) AS src_id,
        min_by(rd.dest_id, rd.__time) AS dest_id,
        COALESCE(
            TRY_CAST(min_by(rd.wt_price, rd.__time) AS DOUBLE),
            TRY_CAST(array_min(min_by(rd.fare_list, rd.__time)) AS DOUBLE)
        ) AS route_price,
        TRY_CAST(min_by(rd.total_ratings, rd.__time) AS DOUBLE) AS route_rating,
        UPPER(TRIM(COALESCE(min_by(rd.bus_type, rd.__time), ''))) AS bus_type
    FROM session_routes sr
    INNER JOIN filtered_rd rd
        ON rd.mri_session_id = sr.mri_session_id
       AND rd.route_id = sr.route_id
       AND rd.doj = sr.doj
       AND rd.__time <= sr.t_sl
    GROUP BY 1, 2, 3, 4, 5
),

session_route_summary AS (
    SELECT
        mri_session_id,
        mri_client_id,
        MIN(t_sl) AS t_sl,
        COUNT(DISTINCT route_id) AS distinct_route_count,
        ARRAY_AGG(DISTINCT route_id) AS route_ids,
        min_by(doj, t_sl) AS doj,
        min_by(src_id, t_sl) AS src_id,
        min_by(dest_id, t_sl) AS dest_id
    FROM session_route_detail
    GROUP BY 1, 2
),

non_transacted_visits AS (
    SELECT
        srs.mri_session_id,
        srs.mri_client_id,
        COALESCE(sut.user_type, 'Unknown') AS user_type,
        srs.t_sl AS visit_time,
        srs.doj,
        srs.src_id,
        srs.dest_id,
        srs.distinct_route_count,
        srs.route_ids,
        ROW_NUMBER() OVER (
            PARTITION BY srs.mri_client_id
            ORDER BY srs.t_sl, srs.mri_session_id
        ) AS visit_num
    FROM session_route_summary srs
    LEFT JOIN session_user_type sut
        ON srs.mri_session_id = sut.mri_session_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM transacted_sessions ts
        WHERE ts.mri_session_id = srs.mri_session_id
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
        visit_time,
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
        v1.visit_time AS visit1_time,
        v2.visit_time AS visit2_time,
        v1.distinct_route_count AS visit1_route_count,
        v1.route_ids AS visit1_route_ids,
        v2.route_ids AS visit2_route_ids,
        CARDINALITY(ARRAY_INTERSECT(v1.route_ids, v2.route_ids)) AS same_route_id_count,
        ROUND(
            100.0 * CARDINALITY(ARRAY_INTERSECT(v1.route_ids, v2.route_ids))
            / NULLIF(v1.distinct_route_count, 0),
            2
        ) AS overlap_pct
    FROM visit1 v1
    INNER JOIN visit2 v2
        ON v1.mri_client_id = v2.mri_client_id
       AND v1.mri_session_id <> v2.mri_session_id
       AND v2.src_id = v1.src_id
       AND v2.dest_id = v1.dest_id
),

cohort_sessions AS (
    SELECT visit1_session_id AS mri_session_id FROM visit_pairs
    UNION
    SELECT visit2_session_id FROM visit_pairs
),

pair_route_flags AS (
    SELECT
        vp.visit1_session_id,
        vp.visit2_session_id,
        MAX(
            CASE
                WHEN r1.route_price IS NOT NULL
                 AND r2.route_price IS NOT NULL
                 AND ABS(r1.route_price - r2.route_price) <= 100
                    THEN 1 ELSE 0
            END
        ) AS flag_same_price,
        MAX(
            CASE
                WHEN r1.route_rating IS NOT NULL
                 AND r2.route_rating IS NOT NULL
                 AND ABS(r1.route_rating - r2.route_rating) <= 0.2
                    THEN 1 ELSE 0
            END
        ) AS flag_same_rating,
        MAX(
            CASE
                WHEN r1.bus_type <> ''
                 AND r2.bus_type <> ''
                 AND r1.bus_type = r2.bus_type
                    THEN 1 ELSE 0
            END
        ) AS flag_same_bus_type
    FROM visit_pairs vp
    INNER JOIN session_route_detail r1
        ON r1.mri_session_id = vp.visit1_session_id
       AND contains(vp.visit1_route_ids, r1.route_id)
    INNER JOIN session_route_detail r2
        ON r2.mri_session_id = vp.visit2_session_id
       AND contains(vp.visit2_route_ids, r2.route_id)
    INNER JOIN cohort_sessions cs1
        ON cs1.mri_session_id = r1.mri_session_id
    INNER JOIN cohort_sessions cs2
        ON cs2.mri_session_id = r2.mri_session_id
    GROUP BY 1, 2
),

instances AS (
    SELECT
        vp.user_type,
        vp.mri_client_id,
        vp.visit1_session_id,
        vp.visit2_session_id,
        CASE
            WHEN vp.same_route_id_count = 0 THEN 'No Same Routes'
            WHEN vp.overlap_pct > 0 AND vp.overlap_pct <= 50 THEN '0-50%'
            WHEN vp.overlap_pct > 50 AND vp.overlap_pct <= 100 THEN '50-100%'
            ELSE 'Unknown'
        END AS overlap_group,
        CASE
            WHEN vp.same_route_id_count = 0 THEN 1
            WHEN vp.overlap_pct > 0 AND vp.overlap_pct <= 50 THEN 2
            WHEN vp.overlap_pct > 50 AND vp.overlap_pct <= 100 THEN 3
            ELSE 99
        END AS overlap_order,
        CASE
            WHEN date_diff('hour', vp.visit1_time, vp.visit2_time) < 6 THEN '<6 Hours'
            ELSE '>=6 Hours'
        END AS revisit_gap_cut,
        CASE
            WHEN date_diff('hour', vp.visit1_time, vp.visit2_time) < 6 THEN 1
            ELSE 2
        END AS revisit_gap_order,
        COALESCE(prf.flag_same_price, 0) AS flag_same_price,
        COALESCE(prf.flag_same_rating, 0) AS flag_same_rating,
        COALESCE(prf.flag_same_bus_type, 0) AS flag_same_bus_type
    FROM visit_pairs vp
    LEFT JOIN pair_route_flags prf
        ON vp.visit1_session_id = prf.visit1_session_id
       AND vp.visit2_session_id = prf.visit2_session_id
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
)

SELECT
    i.user_type,
    ub.visit1_user_count,
    ub.revisit_user_count,
    ROUND(100.0 * ub.revisit_user_count / NULLIF(ub.visit1_user_count, 0), 2) AS pct_visit1_to_revisit,
    i.overlap_group,
    i.revisit_gap_cut,
    COUNT(*) AS base_instances,
    COUNT(DISTINCT i.mri_client_id) AS base_users,
    SUM(i.flag_same_price) AS same_price_instances,
    ROUND(100.0 * SUM(i.flag_same_price) / NULLIF(COUNT(*), 0), 2) AS pct_same_price,
    SUM(i.flag_same_rating) AS same_rating_instances,
    ROUND(100.0 * SUM(i.flag_same_rating) / NULLIF(COUNT(*), 0), 2) AS pct_same_rating,
    SUM(i.flag_same_bus_type) AS same_bus_type_instances,
    ROUND(100.0 * SUM(i.flag_same_bus_type) / NULLIF(COUNT(*), 0), 2) AS pct_same_bus_type
FROM instances i
INNER JOIN user_bases ub
    ON i.user_type = ub.user_type
GROUP BY
    i.user_type,
    ub.visit1_user_count,
    ub.revisit_user_count,
    i.overlap_group,
    i.overlap_order,
    i.revisit_gap_cut,
    i.revisit_gap_order
ORDER BY
    CASE i.user_type WHEN 'New' THEN 1 WHEN 'Returning' THEN 2 WHEN 'Guest' THEN 3 END,
    i.overlap_order,
    i.revisit_gap_order;
