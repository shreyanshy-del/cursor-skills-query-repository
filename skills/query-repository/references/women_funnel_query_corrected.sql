-- Women Funnel Query (corrected)
-- Fixes vs original broken query:
--   1. SRP window 7 days (matches working query; 3 days was too thin for Female + p40-p65)
--   2. session_group_counts from session_dim at session grain (not sxr_target route grain)
--   3. Explicit is_reddeal flag for pricing (deal_type = 'REDDEAL')
--   4. Step totals = OR of age-gated individuals within each step (matches breakup columns)

WITH params AS (
    SELECT
        CAST(CURRENT_DATE - INTERVAL '7' DAY AS TIMESTAMP)   AS srp_start,
        CAST(CURRENT_DATE AS TIMESTAMP)                       AS srp_end,
        CAST(CURRENT_DATE - INTERVAL '2' MONTH AS TIMESTAMP) AS clean_start,
        CAST(CURRENT_DATE AS TIMESTAMP)                       AS clean_end,
        CAST(CURRENT_DATE - INTERVAL '365' DAY AS TIMESTAMP) AS txn_start,
        CAST(CURRENT_DATE AS TIMESTAMP)                       AS txn_end,
        0.80 AS asp_pct_threshold
),

hardcoded_top20 AS (
    SELECT route_id
    FROM (
        VALUES
            ('122-123'), ('123-122'), ('122-124'), ('124-122'), ('123-141'),
            ('141-123'), ('123-126'), ('126-123'), ('122-141'), ('141-122'),
            ('124-134'), ('134-124'), ('123-71929'), ('123-602'), ('122-71756'),
            ('602-123'), ('71929-123'), ('733-1439'), ('71756-122'), ('1439-733')
    ) AS t(route_id)
),

top20_sd_pairs AS (
    SELECT
        route_id AS sd_route_id,
        CAST(split_part(route_id, '-', 1) AS BIGINT) AS src_id,
        CAST(split_part(route_id, '-', 2) AS BIGINT) AS dest_id
    FROM hardcoded_top20
),

srp_min AS (
    SELECT
        srd.mri_session_id,
        srd.rb_user_id,
        CAST(srd.__time AS TIMESTAMP) AS event_ts,
        srd.src_id,
        srd.dest_id,
        CONCAT(CAST(srd.src_id AS VARCHAR), '-', CAST(srd.dest_id AS VARCHAR)) AS sd_route_id,
        srd.kafka_offset
    FROM user_interaction.search_route_details srd
    CROSS JOIN params p
    WHERE srd.country = 'IND'
      AND srd.__time >= p.srp_start
      AND srd.__time < p.srp_end
      AND srd.mri_session_id IS NOT NULL
      AND srd.src_id IS NOT NULL
      AND srd.dest_id IS NOT NULL
),

first_sd_per_session AS (
    SELECT
        mri_session_id,
        rb_user_id,
        sd_route_id,
        src_id,
        dest_id
    FROM (
        SELECT
            s.*,
            ROW_NUMBER() OVER (
                PARTITION BY s.mri_session_id
                ORDER BY s.event_ts ASC, COALESCE(s.kafka_offset, 0) ASC
            ) AS rn
        FROM srp_min s
    ) x
    WHERE rn = 1
),

base_sessions AS (
    SELECT
        f.mri_session_id,
        f.rb_user_id,
        f.sd_route_id AS base_sd_route_id,
        f.src_id AS base_src_id,
        f.dest_id AS base_dest_id
    FROM first_sd_per_session f
    INNER JOIN hardcoded_top20 h
        ON f.sd_route_id = h.route_id
),

srd_base AS (
    SELECT
        srd.mri_session_id,
        srd.rb_user_id,
        bs.base_sd_route_id AS sd_route_id,
        bs.base_src_id AS src_id,
        bs.base_dest_id AS dest_id,
        CAST(srd.route_id AS VARCHAR) AS tuple_route_id,
        TRY_CAST(srd.operator_id AS BIGINT) AS operator_id_norm,
        srd.deal_type,
        srd.cohort_type,
        srd.cohort_display_type,
        srd.persuasion_id,
        srd.persuasion_score,
        srd.child_fare,
        srd.bus_type,
        srd.channel,
        srd.os,
        srd.bu,
        CAST(srd.__time AS DATE) AS srp_date,
        TRY_CAST(srd.doj AS DATE) AS doj_date
    FROM user_interaction.search_route_details srd
    INNER JOIN base_sessions bs
        ON srd.mri_session_id = bs.mri_session_id
       AND srd.src_id = bs.base_src_id
       AND srd.dest_id = bs.base_dest_id
    CROSS JOIN params p
    WHERE srd.country = 'IND'
      AND srd.__time >= p.srp_start
      AND srd.__time < p.srp_end
      AND srd.route_id IS NOT NULL
),

session_route_flags AS (
    SELECT
        s.mri_session_id,
        s.rb_user_id,
        s.sd_route_id,
        s.src_id,
        s.dest_id,
        s.tuple_route_id,

        MAX(CASE
            WHEN UPPER(COALESCE(CAST(s.deal_type AS VARCHAR), '')) = 'REDDEAL' THEN 1
            ELSE 0
        END) AS is_reddeal,

        MAX(CASE
            WHEN REGEXP_LIKE(
                LOWER(COALESCE(CAST(s.deal_type AS VARCHAR), '') || ' ' || COALESCE(s.cohort_type, '') || ' ' || COALESCE(s.cohort_display_type, '')),
                'reddeal|primo|bo\s*offer|student'
            ) THEN 1 ELSE 0
        END) AS is_best_deal_student,

        MAX(CASE
            WHEN REGEXP_LIKE(
                LOWER(COALESCE(CAST(s.deal_type AS VARCHAR), '') || ' ' || COALESCE(s.cohort_type, '') || ' ' || COALESCE(s.cohort_display_type, '')),
                'reddeal|primo|bo\s*offer|group'
            ) THEN 1 ELSE 0
        END) AS is_best_deal_group,

        MAX(CASE
            WHEN s.operator_id_norm IN (
                29714,10193,17748,16704,17619,23927,27461,21501,2,6494,3687,1123344,19867,8571,
                18112,27566,31831,30426,23971,29676,27192,17597,20437,17496,15647,27727,3315,20259,
                23222,25736,3419,20820,21963,26086,17664,22663,19504,31401,29542,31608,22848,8336,
                32018,25166,19959,20240,16937,29666,22876
            ) THEN 1 ELSE 0
        END) AS is_trip_rewards,

        MAX(CASE WHEN s.persuasion_id IS NOT NULL AND CONTAINS(s.persuasion_id, '635') THEN 1 ELSE 0 END) AS has_women_travelling,
        MAX(CASE WHEN s.persuasion_id IS NOT NULL AND CONTAINS(s.persuasion_id, '618') THEN 1 ELSE 0 END) AS has_highly_rated_by_women,
        MAX(CASE WHEN s.persuasion_id IS NOT NULL AND CONTAINS(s.persuasion_id, '142') THEN 1 ELSE 0 END) AS has_ontime,
        MAX(CASE WHEN s.persuasion_id IS NOT NULL AND CONTAINS(s.persuasion_id, '541') THEN 1 ELSE 0 END) AS has_fdc_541,
        MAX(CASE WHEN s.persuasion_id IS NOT NULL AND CONTAINS(s.persuasion_id, '632') THEN 1 ELSE 0 END) AS has_ftc_632,
        MAX(CASE WHEN s.persuasion_id IS NOT NULL AND (CONTAINS(s.persuasion_id, '541') OR CONTAINS(s.persuasion_id, '632')) THEN 1 ELSE 0 END) AS has_fdc_ftc,
        MAX(CASE WHEN LOWER(COALESCE(s.bus_type, '')) LIKE '%volvo%' THEN 1 ELSE 0 END) AS is_volvo,
        MAX(CASE WHEN LOWER(COALESCE(s.bus_type, '')) LIKE '%bharat benz%' THEN 1 ELSE 0 END) AS is_bharat_benz,
        MAX(CASE WHEN s.persuasion_id IS NOT NULL AND CONTAINS(s.persuasion_id, '537') THEN 1 ELSE 0 END) AS is_toilet,
        MAX(CASE
            WHEN s.channel = 'MOBILE_APP'
             AND s.os = 'Android'
             AND s.bu = 'BUS'
             AND s.persuasion_id IS NOT NULL
             AND s.persuasion_score IS NOT NULL
             AND CONTAINS(s.persuasion_id, '4401')
             AND array_position(s.persuasion_id, '4401') IS NOT NULL
             AND CAST(
                    ROUND(
                        TRY_CAST(
                            element_at(s.persuasion_score, array_position(s.persuasion_id, '4401')) AS DOUBLE
                        )
                    ) AS INTEGER
                 ) IN (8, 9)
            THEN 1 ELSE 0
        END) AS is_comfort_8_9,
        MAX(CASE WHEN s.doj_date IS NOT NULL AND date_diff('day', s.srp_date, s.doj_date) BETWEEN 0 AND 1 THEN 1 ELSE 0 END) AS has_dbd_0_1,
        MAX(CASE WHEN s.doj_date IS NOT NULL AND date_diff('day', s.srp_date, s.doj_date) = 2 THEN 1 ELSE 0 END) AS has_dbd_2,
        AVG(s.child_fare) AS avg_child_fare
    FROM srd_base s
    GROUP BY 1, 2, 3, 4, 5, 6
),

session_route_capped AS (
    SELECT *
    FROM (
        SELECT
            srf.*,
            ROW_NUMBER() OVER (
                PARTITION BY srf.mri_session_id
                ORDER BY srf.tuple_route_id
            ) AS rn
        FROM session_route_flags srf
    ) t
    WHERE t.rn <= 20
),

candidate_routes AS (
    SELECT DISTINCT src_id, dest_id, tuple_route_id
    FROM session_route_capped
),

tuple_asp_pct AS (
    SELECT
        s.mri_session_id,
        PERCENT_RANK() OVER (
            PARTITION BY s.sd_route_id
            ORDER BY s.avg_child_fare
        ) AS asp_pct
    FROM session_route_capped s
    WHERE s.avg_child_fare IS NOT NULL
),

session_asp_bucket AS (
    SELECT
        mri_session_id,
        CASE WHEN AVG(asp_pct) BETWEEN 0.40 AND 0.65 THEN 'p40-p65' ELSE 'Other' END AS asp_personalization
    FROM tuple_asp_pct
    GROUP BY 1
),

txn_profile_raw AS (
    SELECT
        t.rb_user_id,
        CASE
            WHEN UPPER(CAST(element_at(t.travellers_gender, 1) AS VARCHAR)) = 'MALE' THEN 'Male'
            WHEN UPPER(CAST(element_at(t.travellers_gender, 1) AS VARCHAR)) = 'FEMALE' THEN 'Female'
            ELSE 'Unknown'
        END AS gender,
        TRY_CAST(element_at(t.travellers_age, 1) AS INTEGER) AS age_years,
        ROW_NUMBER() OVER (
            PARTITION BY t.rb_user_id
            ORDER BY CAST(t.date_of_issue AS TIMESTAMP) DESC
        ) AS rn
    FROM transaction.bus_ticket_events t
    INNER JOIN (SELECT DISTINCT rb_user_id FROM base_sessions WHERE rb_user_id IS NOT NULL) u
        ON t.rb_user_id = u.rb_user_id
    CROSS JOIN params p
    WHERE t.date_of_issue >= p.txn_start
      AND t.date_of_issue < p.txn_end
      AND t.country_code = 'IND'
      AND t.tin IS NOT NULL
      AND t.event_type = 101
      AND t.event_class = 2
      AND t.rb_user_id > 0
),

txn_profile AS (
    SELECT rb_user_id, gender, age_years
    FROM txn_profile_raw
    WHERE rn = 1
),

session_dim AS (
    SELECT
        bs.mri_session_id,
        COALESCE(tp.gender, 'Unknown') AS gender,
        CASE
            WHEN tp.age_years IS NOT NULL AND tp.age_years < 27 THEN 'GenZ_Student'
            WHEN tp.age_years IS NOT NULL AND tp.age_years BETWEEN 27 AND 60 THEN 'Others'
            WHEN tp.age_years IS NOT NULL AND tp.age_years > 60 THEN 'Senior_Citizen'
            ELSE 'Others'
        END AS age_bracket,
        COALESCE(sa.asp_personalization, 'Other') AS asp_personalization
    FROM base_sessions bs
    LEFT JOIN txn_profile tp ON bs.rb_user_id = tp.rb_user_id
    LEFT JOIN session_asp_bucket sa ON bs.mri_session_id = sa.mri_session_id
),

route_asp AS (
    SELECT
        bte.source_location_id AS source_id,
        bte.destination_location_id AS destination_id,
        CAST(bte.route_id AS VARCHAR) AS tuple_route_id,
        AVG(CAST(bte.seat_price[1] AS DOUBLE)) AS route_asp
    FROM transaction.bus_ticket_events bte
    INNER JOIN candidate_routes cr
        ON bte.source_location_id = cr.src_id
       AND bte.destination_location_id = cr.dest_id
       AND CAST(bte.route_id AS VARCHAR) = cr.tuple_route_id
    CROSS JOIN params p
    WHERE bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.time_of_event >= p.txn_start
      AND bte.time_of_event < p.txn_end
      AND bte.seat_price IS NOT NULL
      AND CARDINALITY(bte.seat_price) > 0
    GROUP BY 1, 2, 3
),

route_asp_bucketed AS (
    SELECT
        ra.source_id,
        ra.destination_id,
        ra.tuple_route_id,
        CASE
            WHEN PERCENT_RANK() OVER (PARTITION BY ra.source_id, ra.destination_id ORDER BY ra.route_asp) >= p.asp_pct_threshold
            THEN 1 ELSE 0
        END AS is_gte_80
    FROM route_asp ra
    CROSS JOIN params p
),

value_pick_route_flags AS (
    SELECT
        rab.source_id,
        rab.destination_id,
        rab.tuple_route_id,
        CASE WHEN rab.is_gte_80 = 0 AND rf.is_toilet = 1 THEN 1 ELSE 0 END AS is_toilet_lt80,
        CASE WHEN rab.is_gte_80 = 0 AND rf.is_comfort_8_9 = 1 THEN 1 ELSE 0 END AS is_comfort_lt80,
        CASE WHEN rab.is_gte_80 = 0 AND (rf.is_volvo = 1 OR rf.is_bharat_benz = 1) THEN 1 ELSE 0 END AS is_volvo_bb_lt80,
        CASE WHEN rab.is_gte_80 = 0 AND (rf.is_toilet = 1 OR rf.is_comfort_8_9 = 1 OR rf.is_volvo = 1 OR rf.is_bharat_benz = 1) THEN 1 ELSE 0 END AS is_value_pick_any
    FROM route_asp_bucketed rab
    LEFT JOIN (
        SELECT
            src_id AS source_id,
            dest_id AS destination_id,
            tuple_route_id,
            MAX(is_toilet) AS is_toilet,
            MAX(is_comfort_8_9) AS is_comfort_8_9,
            MAX(is_volvo) AS is_volvo,
            MAX(is_bharat_benz) AS is_bharat_benz
        FROM session_route_capped
        GROUP BY 1, 2, 3
    ) rf
      ON rab.source_id = rf.source_id
     AND rab.destination_id = rf.destination_id
     AND rab.tuple_route_id = rf.tuple_route_id
),

sd_sessions_2m AS (
    SELECT DISTINCT
        CONCAT(CAST(srd.src_id AS VARCHAR), '-', CAST(srd.dest_id AS VARCHAR)) AS sd_route_id,
        srd.mri_session_id
    FROM user_interaction.search_route_details srd
    INNER JOIN top20_sd_pairs p2
        ON srd.src_id = p2.src_id
       AND srd.dest_id = p2.dest_id
    CROSS JOIN params p
    WHERE srd.country = 'IND'
      AND srd.__time >= p.clean_start
      AND srd.__time < p.clean_end
      AND srd.mri_session_id IS NOT NULL
),

urt_2m AS (
    SELECT
        urt.mri_session_id,
        urt.identifiers,
        urt.review_tags,
        urt.sentiments
    FROM ugc.user_review_tags urt
    CROSS JOIN params p
    WHERE urt.country = 'IND'
      AND CAST(urt.doj AS TIMESTAMP) >= p.clean_start
      AND CAST(urt.doj AS TIMESTAMP) < p.clean_end
      AND urt.mri_session_id IN (SELECT DISTINCT mri_session_id FROM sd_sessions_2m)
),

clean_reviews AS (
    SELECT
        s.sd_route_id,
        CASE
            WHEN regexp_like(COALESCE(u.identifiers, ''), '(^|,)(35|50)(,|$)')
              OR LOWER(COALESCE(u.review_tags, '')) LIKE '%clean%'
            THEN 1 ELSE 0
        END AS is_clean_review,
        CASE WHEN regexp_like(COALESCE(u.sentiments, ''), '(^|,)(1)(,|$)') THEN 1 ELSE 0 END AS good_flag,
        CASE WHEN regexp_like(COALESCE(u.sentiments, ''), '(^|,)(2)(,|$)') THEN 1 ELSE 0 END AS bad_flag
    FROM sd_sessions_2m s
    INNER JOIN urt_2m u
        ON s.mri_session_id = u.mri_session_id
),

clean_route_agg AS (
    SELECT
        h.route_id AS sd_route_id,
        COALESCE(SUM(CASE WHEN c.is_clean_review = 1 THEN 1 ELSE 0 END), 0) AS total_reviews,
        COALESCE(SUM(CASE WHEN c.is_clean_review = 1 AND c.good_flag = 1 THEN 1 ELSE 0 END), 0) AS good_reviews,
        COALESCE(SUM(CASE WHEN c.is_clean_review = 1 AND c.bad_flag = 1 THEN 1 ELSE 0 END), 0) AS bad_reviews
    FROM hardcoded_top20 h
    LEFT JOIN clean_reviews c
        ON h.route_id = c.sd_route_id
    GROUP BY 1
),

clean_route_ranked AS (
    SELECT
        a.sd_route_id,
        ROW_NUMBER() OVER (
            ORDER BY
                CASE
                    WHEN a.total_reviews = 0 THEN -9999.0
                    ELSE ((a.good_reviews - a.bad_reviews) * 1.0 / a.total_reviews) * LN(1 + a.total_reviews)
                END DESC,
                a.total_reviews DESC,
                a.sd_route_id
        ) AS rank_order,
        COUNT(*) OVER () AS total_routes
    FROM clean_route_agg a
),

clean_route_label AS (
    SELECT
        r.sd_route_id,
        CASE WHEN r.rank_order <= GREATEST(1, CAST(CEIL(r.total_routes * 0.10) AS BIGINT)) THEN 1 ELSE 0 END AS is_top10_clean_route
    FROM clean_route_ranked r
),

sxr_fact AS (
    SELECT
        c.mri_session_id,
        c.sd_route_id,
        c.tuple_route_id,
        c.is_reddeal,
        c.is_best_deal_student,
        c.is_best_deal_group,
        c.is_trip_rewards,
        c.has_women_travelling,
        c.has_highly_rated_by_women,
        CASE WHEN c.has_women_travelling = 1 OR c.has_highly_rated_by_women = 1 THEN 1 ELSE 0 END AS women_quality_any,
        CASE WHEN c.is_toilet = 1 OR c.is_comfort_8_9 = 1 THEN 1 ELSE 0 END AS travel_hassle_free_any,
        COALESCE(v.is_toilet_lt80, 0) AS is_toilet_lt80,
        COALESCE(v.is_comfort_lt80, 0) AS is_comfort_lt80,
        COALESCE(v.is_volvo_bb_lt80, 0) AS is_volvo_bb_lt80,
        COALESCE(v.is_value_pick_any, 0) AS value_pick_any,
        COALESCE(cl.is_top10_clean_route, 0) AS hygiene_top10,
        c.has_dbd_0_1,
        c.has_dbd_2,
        c.has_fdc_541,
        c.has_ftc_632,
        c.has_fdc_ftc
    FROM session_route_capped c
    LEFT JOIN value_pick_route_flags v
        ON c.src_id = v.source_id
       AND c.dest_id = v.destination_id
       AND c.tuple_route_id = v.tuple_route_id
    LEFT JOIN clean_route_label cl
        ON c.sd_route_id = cl.sd_route_id
),

sxr_with_dim AS (
    SELECT
        f.*,
        d.gender,
        d.age_bracket,
        d.asp_personalization,

        /* Step 1 individuals: Pricing Nudge L1 (age-gated) */
        CASE
            WHEN d.age_bracket = 'GenZ_Student'
             AND (f.is_reddeal = 1 OR f.is_best_deal_student = 1) THEN 1 ELSE 0
        END AS ind_pricing_bestdeal_student,
        CASE
            WHEN d.age_bracket IN ('Senior_Citizen', 'Others')
             AND (f.is_reddeal = 1 OR f.is_best_deal_group = 1) THEN 1 ELSE 0
        END AS ind_pricing_bestdeal_group,
        CASE WHEN f.is_trip_rewards = 1 THEN 1 ELSE 0 END AS ind_pricing_trip_reward,

        /* Step 2 individuals: Quality (age-gated) */
        CASE WHEN d.age_bracket <> 'Senior_Citizen' AND f.has_women_travelling = 1 THEN 1 ELSE 0 END AS ind_quality_women_travelling,
        CASE WHEN d.age_bracket <> 'Senior_Citizen' AND f.has_highly_rated_by_women = 1 THEN 1 ELSE 0 END AS ind_quality_highly_rated_women,
        CASE WHEN d.age_bracket <> 'Senior_Citizen' AND f.women_quality_any = 1 THEN 1 ELSE 0 END AS ind_quality_women_any,
        CASE WHEN d.age_bracket = 'Senior_Citizen' AND f.travel_hassle_free_any = 1 THEN 1 ELSE 0 END AS ind_quality_travel_hassle_free,

        /* Step 3 individuals: Fall Back 1 (age-gated) */
        CASE WHEN d.age_bracket <> 'Senior_Citizen' AND f.value_pick_any = 1 THEN 1 ELSE 0 END AS ind_fb1_value_pick,
        CASE WHEN d.age_bracket = 'Senior_Citizen' AND f.women_quality_any = 1 THEN 1 ELSE 0 END AS ind_fb1_women_quality,
        CASE WHEN d.age_bracket <> 'Senior_Citizen' AND f.is_toilet_lt80 = 1 THEN 1 ELSE 0 END AS ind_fb1_toilet_lt80,
        CASE WHEN d.age_bracket <> 'Senior_Citizen' AND f.is_comfort_lt80 = 1 THEN 1 ELSE 0 END AS ind_fb1_comfort_lt80,
        CASE WHEN d.age_bracket <> 'Senior_Citizen' AND f.is_volvo_bb_lt80 = 1 THEN 1 ELSE 0 END AS ind_fb1_volvo_bb_lt80,

        /* Step 4a individuals: Fall Back 2 (dbd 0-1) */
        CASE WHEN f.hygiene_top10 = 1 THEN 1 ELSE 0 END AS ind_fb2_hygiene_top10,
        CASE WHEN f.has_dbd_0_1 = 1 THEN 1 ELSE 0 END AS ind_fb2_dbd_0_1,
        CASE WHEN f.hygiene_top10 = 1 AND f.has_dbd_0_1 = 1 THEN 1 ELSE 0 END AS ind_fb2_hygiene_and_dbd_0_1,

        /* Step 4b individuals: Fall Back 2 (dbd 2) */
        CASE WHEN f.has_fdc_541 = 1 AND f.has_dbd_2 = 1 THEN 1 ELSE 0 END AS ind_fb2_free_date_change,
        CASE WHEN f.has_ftc_632 = 1 AND f.has_dbd_2 = 1 THEN 1 ELSE 0 END AS ind_fb2_free_cancel,
        CASE WHEN f.has_fdc_ftc = 1 AND f.has_dbd_2 = 1 THEN 1 ELSE 0 END AS ind_fb2_fdc_ftc_dbd2
    FROM sxr_fact f
    INNER JOIN session_dim d
        ON f.mri_session_id = d.mri_session_id
),

sxr_step_totals AS (
    SELECT
        x.*,
        CASE
            WHEN x.ind_pricing_bestdeal_student = 1
              OR x.ind_pricing_bestdeal_group = 1
              OR x.ind_pricing_trip_reward = 1 THEN 1 ELSE 0
        END AS step_pricing_total,
        CASE
            WHEN x.ind_quality_women_travelling = 1
              OR x.ind_quality_highly_rated_women = 1
              OR x.ind_quality_women_any = 1
              OR x.ind_quality_travel_hassle_free = 1 THEN 1 ELSE 0
        END AS step_quality_total,
        CASE
            WHEN x.ind_fb1_value_pick = 1
              OR x.ind_fb1_women_quality = 1
              OR x.ind_fb1_toilet_lt80 = 1
              OR x.ind_fb1_comfort_lt80 = 1
              OR x.ind_fb1_volvo_bb_lt80 = 1 THEN 1 ELSE 0
        END AS step_fallback1_total,
        CASE
            WHEN x.ind_fb2_hygiene_top10 = 1
              OR x.ind_fb2_dbd_0_1 = 1
              OR x.ind_fb2_hygiene_and_dbd_0_1 = 1 THEN 1 ELSE 0
        END AS step_fallback2_dbd_0_1_total,
        CASE
            WHEN x.ind_fb2_free_date_change = 1
              OR x.ind_fb2_free_cancel = 1
              OR x.ind_fb2_fdc_ftc_dbd2 = 1 THEN 1 ELSE 0
        END AS step_fallback2_dbd_2_total
    FROM sxr_with_dim x
),

sxr_target AS (
    SELECT *
    FROM sxr_step_totals
    WHERE gender = 'Female'
      AND asp_personalization = 'p40-p65'
),

target_buckets AS (
    SELECT
        'Female' AS gender,
        age_bracket,
        'p40-p65' AS asp_personalization
    FROM (
        VALUES ('GenZ_Student'), ('Senior_Citizen'), ('Others')
    ) t(age_bracket)
),

session_group_counts AS (
    SELECT
        gender,
        age_bracket,
        asp_personalization,
        COUNT(*) AS top20_route_sessions
    FROM session_dim
    WHERE gender = 'Female'
      AND asp_personalization = 'p40-p65'
    GROUP BY 1, 2, 3
),

event_group_counts AS (
    SELECT
        gender,
        age_bracket,
        asp_personalization,
        COUNT(*) AS session_x_route_events_capped_20,

        SUM(step_pricing_total) AS pricing_nudge_l1_event_count,
        SUM(step_quality_total) AS quality_event_count,
        SUM(step_fallback1_total) AS fallback1_event_count,
        SUM(step_fallback2_dbd_0_1_total) AS fallback2_dbd_0_1_event_count,
        SUM(step_fallback2_dbd_2_total) AS fallback2_dbd_2_event_count,

        SUM(ind_pricing_bestdeal_student) AS pricing_best_deal_student_event_count,
        SUM(ind_pricing_bestdeal_group) AS pricing_best_deal_group_event_count,
        SUM(ind_pricing_trip_reward) AS pricing_trip_reward_event_count,
        SUM(ind_quality_women_travelling) AS quality_women_travelling_event_count,
        SUM(ind_quality_highly_rated_women) AS quality_highly_rated_women_event_count,
        SUM(ind_quality_women_any) AS quality_women_any_event_count,
        SUM(ind_quality_travel_hassle_free) AS quality_travel_hassle_free_event_count,
        SUM(ind_fb1_value_pick) AS fallback1_value_pick_event_count,
        SUM(ind_fb1_women_quality) AS fallback1_women_quality_event_count,
        SUM(ind_fb1_toilet_lt80) AS fallback1_toilet_lt80_event_count,
        SUM(ind_fb1_comfort_lt80) AS fallback1_comfort_lt80_event_count,
        SUM(ind_fb1_volvo_bb_lt80) AS fallback1_volvo_bb_lt80_event_count,
        SUM(ind_fb2_hygiene_top10) AS fallback2_hygiene_top10_event_count,
        SUM(ind_fb2_dbd_0_1) AS fallback2_dbd_0_1_base_event_count,
        SUM(ind_fb2_free_date_change) AS fallback2_free_date_change_541_event_count,
        SUM(ind_fb2_free_cancel) AS fallback2_free_cancel_632_event_count
    FROM sxr_target
    GROUP BY 1, 2, 3
)

SELECT
    tb.gender AS "Gender",
    tb.age_bracket AS "Age Bracket",
    tb.asp_personalization AS "Personalization",
    COALESCE(sg.top20_route_sessions, 0) AS "Top 20 Route Sessions",
    COALESCE(eg.session_x_route_events_capped_20, 0) AS "Session X Route_id (Capped 20)",
    COALESCE(eg.pricing_nudge_l1_event_count, 0) AS "Pricing Nudge - L1",
    COALESCE(eg.quality_event_count, 0) AS "Quality",
    COALESCE(eg.fallback1_event_count, 0) AS "Fall Back 1",
    COALESCE(eg.fallback2_dbd_0_1_event_count, 0) AS "Fall Back 2(dbd,0-1)",
    COALESCE(eg.fallback2_dbd_2_event_count, 0) AS "Fall Back 2(dbd,2)",
    COALESCE(eg.pricing_best_deal_student_event_count, 0) AS "Breakup | Pricing BestDeal Student",
    COALESCE(eg.pricing_best_deal_group_event_count, 0) AS "Breakup | Pricing BestDeal Group",
    COALESCE(eg.pricing_trip_reward_event_count, 0) AS "Breakup | Pricing TripReward",
    COALESCE(eg.quality_women_travelling_event_count, 0) AS "Breakup | Quality WomenTravelling(635)",
    COALESCE(eg.quality_highly_rated_women_event_count, 0) AS "Breakup | Quality HighlyRatedWomen(618)",
    COALESCE(eg.quality_women_any_event_count, 0) AS "Breakup | Quality WomenAny",
    COALESCE(eg.quality_travel_hassle_free_event_count, 0) AS "Breakup | Quality TravelHassleFree",
    COALESCE(eg.fallback1_value_pick_event_count, 0) AS "Breakup | FB1 ValuePickAny",
    COALESCE(eg.fallback1_women_quality_event_count, 0) AS "Breakup | FB1 WomenQualityAny",
    COALESCE(eg.fallback1_toilet_lt80_event_count, 0) AS "Breakup | FB1 Toilet LT80",
    COALESCE(eg.fallback1_comfort_lt80_event_count, 0) AS "Breakup | FB1 Comfort LT80",
    COALESCE(eg.fallback1_volvo_bb_lt80_event_count, 0) AS "Breakup | FB1 Volvo/BB LT80",
    COALESCE(eg.fallback2_hygiene_top10_event_count, 0) AS "Breakup | FB2(0-1) HygieneTop10",
    COALESCE(eg.fallback2_dbd_0_1_base_event_count, 0) AS "Breakup | FB2(0-1) DBD0-1 Base",
    COALESCE(eg.fallback2_free_date_change_541_event_count, 0) AS "Breakup | FB2(2) FreeDateChange(541)",
    COALESCE(eg.fallback2_free_cancel_632_event_count, 0) AS "Breakup | FB2(2) FreeCancel(632)"
FROM target_buckets tb
LEFT JOIN session_group_counts sg
    ON tb.gender = sg.gender
   AND tb.age_bracket = sg.age_bracket
   AND tb.asp_personalization = sg.asp_personalization
LEFT JOIN event_group_counts eg
    ON tb.gender = eg.gender
   AND tb.age_bracket = eg.age_bracket
   AND tb.asp_personalization = eg.asp_personalization
ORDER BY tb.age_bracket;
