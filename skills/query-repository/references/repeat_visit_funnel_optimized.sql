-- =============================================================================
-- Repeat-visit funnel (optimized)
-- Engine: Trino / Presto
--
-- Optimizations vs original:
--   1. Single filtered scan each of search_route_details and seat_layout_details
--   2. Merged sl_sessions + session_routes (eliminates 2nd seat_layout scan)
--   3. Pre-computed casts on filtered base CTEs (route_id, doj)
--   4. Filter non-transacted rows before ROW_NUMBER window
--   5. Split visit2 CTE so visit_pairs joins a small set, not full ranked_visits
--   6. One aggregation pass for criteria 1/2/3 counts (no duplicate UNION joins)
--   7. NOT EXISTS anti-join for transacted sessions
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-06 18:30:00' AS t_start,
        TIMESTAMP '2026-06-09 18:30:00' AS t_end
),

transacted_sessions AS (
    SELECT cf.mri_session_id
    FROM user_interaction.confirm_order_details cf
    CROSS JOIN params p
    WHERE cf.__time >= p.t_start
      AND cf.__time < p.t_end
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
        TRY_CAST(rd.doj AS DATE) AS doj
    FROM user_interaction.search_route_details rd
    CROSS JOIN params p
    WHERE rd.__time >= p.t_start
      AND rd.__time < p.t_end
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
      AND sl.__time < p.t_end
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
      AND sd.__time < p.t_end
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

route_attrs AS (
    SELECT
        srs.mri_session_id,
        srs.mri_client_id,
        srs.t_sl,
        min_by(rd.doj, rd.__time) AS doj,
        min_by(rd.src_id, rd.__time) AS src_id,
        min_by(rd.dest_id, rd.__time) AS dest_id
    FROM session_route_summary srs
    INNER JOIN session_routes sr
        ON sr.mri_session_id = srs.mri_session_id
       AND sr.mri_client_id = srs.mri_client_id
    INNER JOIN filtered_rd rd
        ON rd.mri_session_id = sr.mri_session_id
       AND rd.route_id = sr.route_id
       AND rd.doj = sr.doj
       AND rd.__time <= srs.t_sl
    GROUP BY 1, 2, 3
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
        v1.mri_session_id AS visit1_session_id,
        (v2.src_id = v1.src_id AND v2.dest_id = v1.dest_id) AS flag_same_sd,
        (v2.doj = v1.doj) AS flag_same_doj,
        (CARDINALITY(ARRAY_INTERSECT(v1.route_ids, v2.route_ids)) > 0) AS flag_same_route_id
    FROM visit1 v1
    INNER JOIN visit2 v2
        ON v1.mri_client_id = v2.mri_client_id
       AND v1.mri_session_id <> v2.mri_session_id
),

aggregated AS (
    SELECT
        v1.user_type,
        COUNT(DISTINCT v1.mri_session_id) AS criteria_1_sessions,
        COUNT(DISTINCT vp.visit1_session_id) AS criteria_2_sessions,
        COUNT(DISTINCT CASE WHEN vp.flag_same_sd THEN vp.visit1_session_id END) AS same_sd_sessions,
        COUNT(DISTINCT CASE WHEN vp.flag_same_doj AND vp.flag_same_sd THEN vp.visit1_session_id END) AS same_doj_sd_sessions,
        COUNT(DISTINCT CASE WHEN vp.flag_same_doj AND vp.flag_same_sd AND vp.flag_same_route_id THEN vp.visit1_session_id END) AS same_doj_sd_route_sessions
    FROM visit1 v1
    LEFT JOIN visit_pairs vp
        ON v1.mri_session_id = vp.visit1_session_id
    GROUP BY 1
),

funnel_rows AS (
    SELECT user_type, 1 AS funnel_order, 'Same SD' AS criteria_3_definition,
           criteria_1_sessions, criteria_2_sessions, same_sd_sessions AS criteria_3_sessions
    FROM aggregated
    UNION ALL
    SELECT user_type, 2, 'Same DOJ + Same SD',
           criteria_1_sessions, criteria_2_sessions, same_doj_sd_sessions
    FROM aggregated
    UNION ALL
    SELECT user_type, 3, 'Same DOJ + Same SD + Same Route ID',
           criteria_1_sessions, criteria_2_sessions, same_doj_sd_route_sessions
    FROM aggregated
)

SELECT
    user_type,
    'First Visit > 2 Route_id Count' AS criteria_1,
    criteria_1_sessions AS criteria_1_session_count,
    'Visited Again (different mri_session_id)' AS criteria_2,
    criteria_2_sessions AS criteria_2_session_count,
    criteria_3_definition AS criteria_3,
    criteria_3_sessions AS criteria_3_session_count,
    ROUND(100.0 * criteria_2_sessions / NULLIF(criteria_1_sessions, 0), 2) AS pct_c1_to_c2,
    ROUND(100.0 * criteria_3_sessions / NULLIF(criteria_2_sessions, 0), 2) AS pct_c2_to_c3
FROM funnel_rows
ORDER BY
    CASE user_type WHEN 'New' THEN 1 WHEN 'Returning' THEN 2 WHEN 'Guest' THEN 3 END,
    funnel_order;
