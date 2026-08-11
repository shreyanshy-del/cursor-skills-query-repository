-- =============================================================================
-- Android LOB funnel — optimized
-- Engine: Trino / Presto
--
-- Optimizations vs original:
--   1. Single scan of ui_ux_events (android cohort + offer filter merged)
--   2. offer_sessions materialized once; downstream steps use INNER JOIN
--   3. Each fact table scanned once with GROUP BY session (no repeated DISTINCT)
--   4. One UNION ALL block from pre-aggregated step CTEs
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-07 18:30:00' AS t_start,
        TIMESTAMP '2026-06-08 18:30:00' AS t_end
),

/* One pass: first event_src = Android + qualifying offer-section row */
offer_sessions AS (
    SELECT mri_session_id
    FROM (
        SELECT
            u.mri_session_id,
            min_by(
                COALESCE(NULLIF(TRIM(u.event_src), ''), 'UNKNOWN'),
                u.__time
            ) AS first_event_src,
            MAX(
                CASE
                    WHEN u.event_group NOT IN ('offer_click_event')
                     AND u.event_name NOT IN ('lob tile displayed')
                     AND u.event_src = 'Android'
                    THEN 1
                    ELSE 0
                END
            ) AS has_qualifying_event
        FROM user_interaction.ui_ux_events u
        CROSS JOIN params p
        WHERE u.__time >= p.t_start
          AND u.__time <  p.t_end
          AND u.mri_session_id IS NOT NULL
          AND u.header_bu = 'BUS'
          AND u.selected_country = 'India'
        GROUP BY 1
    ) s
    WHERE s.first_event_src = 'Android'
      AND s.has_qualifying_event = 1
),

step_srp AS (
    SELECT sd.mri_session_id
    FROM user_interaction.search_details sd
    INNER JOIN offer_sessions os
        ON sd.mri_session_id = os.mri_session_id
    CROSS JOIN params p
    WHERE sd.__time >= p.t_start
      AND sd.__time <  p.t_end
      AND sd.status = 200
      AND sd.country = 'IND'
    GROUP BY 1
),

step_sl AS (
    SELECT s.mri_session_id
    FROM user_interaction.seat_layout_details s
    INNER JOIN offer_sessions os
        ON s.mri_session_id = os.mri_session_id
    CROSS JOIN params p
    WHERE s.__time >= p.t_start
      AND s.__time <  p.t_end
    GROUP BY 1
),

step_ci AS (
    SELECT c.mri_session_id
    FROM user_interaction.cust_info_details c
    INNER JOIN offer_sessions os
        ON c.mri_session_id = os.mri_session_id
    CROSS JOIN params p
    WHERE c.__time >= p.t_start
      AND c.__time <  p.t_end
    GROUP BY 1
),

step_payload AS (
    SELECT co.mri_session_id
    FROM user_interaction.create_order_details co
    INNER JOIN offer_sessions os
        ON co.mri_session_id = os.mri_session_id
    CROSS JOIN params p
    WHERE co.__time >= p.t_start
      AND co.__time <  p.t_end
    GROUP BY 1
),

step_pay AS (
    SELECT mp.mri_session_id
    FROM user_interaction.make_payment_details mp
    INNER JOIN offer_sessions os
        ON mp.mri_session_id = os.mri_session_id
    CROSS JOIN params p
    WHERE mp.__time >= p.t_start
      AND mp.__time <  p.t_end
    GROUP BY 1
),

step_tin AS (
    SELECT cf.mri_session_id
    FROM user_interaction.confirm_order_details cf
    INNER JOIN offer_sessions os
        ON cf.mri_session_id = os.mri_session_id
    CROSS JOIN params p
    WHERE cf.__time >= p.t_start
      AND cf.__time <  p.t_end
      AND cf.country = 'IND'
      AND cf.error_code = 'CONFIRMED'
      AND cf.status_str = 'SUCCESS'
      AND NULLIF(TRIM(cf.tin), '') IS NOT NULL
      AND LOWER(TRIM(cf.tin)) <> 'null'
    GROUP BY 1
)

SELECT 1 AS step_order, 'Step 1: Offer Section (LOB)' AS funnel_step, COUNT(*) AS sessions
FROM offer_sessions

UNION ALL

SELECT 2, 'Step 2: SRP', COUNT(*)
FROM step_srp

UNION ALL

SELECT 3, 'Step 3: Seat Layout', COUNT(*)
FROM step_sl

UNION ALL

SELECT 4, 'Step 4: Cust Info', COUNT(*)
FROM step_ci

UNION ALL

SELECT 5, 'Step 5: Payload', COUNT(*)
FROM step_payload

UNION ALL

SELECT 6, 'Step 6: Pay', COUNT(*)
FROM step_pay

UNION ALL

SELECT 7, 'Step 7: TIN (Confirmed)', COUNT(*)
FROM step_tin

ORDER BY step_order;
