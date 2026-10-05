-- Insurance Lite AB (INSURANCE_LITE_AB) — Query 1: Funnel throughputs across variants
-- Channel: Android IND | Variants: V0/V1/V2/V3 | Window: adjust date_params
-- Source: user_interaction.* joined via mri_session_id; confirmed via confirm_order_details

WITH date_params AS (
    SELECT
        TIMESTAMP '2026-08-18 00:00:00' AS start_ts,
        TIMESTAMP '2026-08-21 00:00:00' AS end_ts
),

session_variant AS (
    SELECT
        s.mri_session_id,
        MAX(
            CASE
                WHEN CONTAINS(s.channel_exp_info, 'INSURANCE_LITE_AB:V0') THEN 'V0'
                WHEN CONTAINS(s.channel_exp_info, 'INSURANCE_LITE_AB:V1') THEN 'V1'
                WHEN CONTAINS(s.channel_exp_info, 'INSURANCE_LITE_AB:V2') THEN 'V2'
                WHEN CONTAINS(s.channel_exp_info, 'INSURANCE_LITE_AB:V3') THEN 'V3'
                ELSE 'others'
            END
        ) AS exp_variant
    FROM user_interaction.search_route_details s
    CROSS JOIN date_params d
    WHERE s.__time >= d.start_ts
      AND s.__time < d.end_ts
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os = 'Android'
      AND s.tp_channel = 'INVALID'
      AND s.akamai_bot IS NULL
    GROUP BY 1
),

srp_deduped AS (
    SELECT DISTINCT
        CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE) AS date,
        s.mri_session_id,
        s.route_id,
        sv.exp_variant
    FROM user_interaction.search_route_details s
    INNER JOIN session_variant sv
        ON s.mri_session_id = sv.mri_session_id
    CROSS JOIN date_params d
    WHERE s.__time >= d.start_ts
      AND s.__time < d.end_ts
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os = 'Android'
      AND s.tp_channel = 'INVALID'
      AND s.akamai_bot IS NULL
      AND sv.exp_variant IN ('V0', 'V1', 'V2', 'V3')
),

sl_deduped AS (
    SELECT mri_session_id, route_id
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN date_params d
    WHERE sl.__time >= d.start_ts
      AND sl.__time < d.end_ts
      AND sl.country = 'IND'
    GROUP BY 1, 2
),

mpax_deduped AS (
    SELECT mri_session_id, route_id
    FROM user_interaction.cust_info_details ci
    CROSS JOIN date_params d
    WHERE ci.__time >= d.start_ts
      AND ci.__time < d.end_ts
      AND ci.country = 'IND'
    GROUP BY 1, 2
),

tco_deduped AS (
    SELECT mri_session_id, route_id
    FROM user_interaction.create_order_details co
    CROSS JOIN date_params d
    WHERE co.__time >= d.start_ts
      AND co.__time < d.end_ts
      AND co.country = 'IND'
    GROUP BY 1, 2
),

orderinfo_deduped AS (
    SELECT mri_session_id, route_id
    FROM user_interaction.order_info_details oi
    CROSS JOIN date_params d
    WHERE oi.__time >= d.start_ts
      AND oi.__time < d.end_ts
      AND oi.country = 'IND'
    GROUP BY 1, 2
),

confirm_deduped AS (
    SELECT
        mri_session_id,
        route_id,
        COUNT(DISTINCT tin) AS tin_count
    FROM user_interaction.confirm_order_details conf
    CROSS JOIN date_params d
    WHERE conf.__time >= d.start_ts
      AND conf.__time < d.end_ts
      AND conf.country = 'IND'
      AND conf.status = 200
      AND conf.tin IS NOT NULL
      AND conf.tin NOT IN ('', 'null')
    GROUP BY 1, 2
)

SELECT
    srp.date,
    srp.exp_variant,
    COUNT(DISTINCT srp.mri_session_id) AS srpload,
    COUNT(DISTINCT sl.mri_session_id) AS slload,
    COUNT(DISTINCT pax.mri_session_id) AS custinfo_sessions,
    COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
    COUNT(DISTINCT oi.mri_session_id) AS payment_land_sessions,
    COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions,
    SUM(conf.tin_count) AS tins,
    ROUND(100.0 * COUNT(DISTINCT sl.mri_session_id)   / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS srp_to_sl_pct,
    ROUND(100.0 * COUNT(DISTINCT pax.mri_session_id)  / NULLIF(COUNT(DISTINCT sl.mri_session_id), 0), 2) AS sl_to_ci_pct,
    ROUND(100.0 * COUNT(DISTINCT tco.mri_session_id)  / NULLIF(COUNT(DISTINCT pax.mri_session_id), 0), 2) AS ci_to_tco_pct,
    ROUND(100.0 * COUNT(DISTINCT oi.mri_session_id)   / NULLIF(COUNT(DISTINCT tco.mri_session_id), 0), 2) AS tco_to_pay_pct,
    ROUND(100.0 * COUNT(DISTINCT conf.mri_session_id) / NULLIF(COUNT(DISTINCT oi.mri_session_id), 0), 2) AS pay_to_confirm_pct,
    ROUND(100.0 * COUNT(DISTINCT conf.mri_session_id) / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS srp_to_confirm_cr_pct
FROM srp_deduped srp
LEFT JOIN sl_deduped sl
    ON srp.mri_session_id = sl.mri_session_id AND srp.route_id = sl.route_id
LEFT JOIN mpax_deduped pax
    ON srp.mri_session_id = pax.mri_session_id AND srp.route_id = pax.route_id
LEFT JOIN tco_deduped tco
    ON srp.mri_session_id = tco.mri_session_id AND srp.route_id = tco.route_id
LEFT JOIN orderinfo_deduped oi
    ON srp.mri_session_id = oi.mri_session_id AND srp.route_id = oi.route_id
LEFT JOIN confirm_deduped conf
    ON srp.mri_session_id = conf.mri_session_id AND srp.route_id = conf.route_id
GROUP BY 1, 2
ORDER BY 1, 2;
