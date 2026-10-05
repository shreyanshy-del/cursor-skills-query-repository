-- Insurance Lite AB — Part 1: TI-5 / TI-10 / TI-15 / TG / FC coverage (seen) vs attach
-- Variants: V0 / V1 / V2 / V3
-- V2 & V3: addon non-purchasers see TI_IND_5.0; purchasers see full addon set
-- Coverage = tag on ticket | Attach = tag in addons JSON | attach% = sold / seen

WITH date_params AS (
    SELECT
        TIMESTAMP '2026-08-18 00:00:00' AS start_ts,
        TIMESTAMP '2026-08-22 00:00:00' AS end_ts
),

excluded_ops AS (
    SELECT op_id FROM UNNEST(ARRAY[
        6392,7115,10283,11060,15130,15443,15499,16081,16227,16374,16426,16647,
        17101,17137,17889,18101,18491,24978,25187,25946,26936,27000,27455,28011,
        29176,29391,29479,32000,32245,32272,33000,34300,34400,35303
    ]) AS t(op_id)
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

neon AS (
    SELECT
        DATE(b.date_of_issue) AS date,
        sv.exp_variant,
        CAST(b.ticket_fare AS DOUBLE) AS ticket_fare,
        CAST(b.seat_count AS DOUBLE) AS seat_count,

        CASE WHEN CONTAINS(b.tags, 'TI_IND_5.0')  THEN 1 ELSE 0 END AS ti5_cov,
        CASE WHEN CONTAINS(b.tags, 'TI_IND_10.0') THEN 1 ELSE 0 END AS ti10_cov,
        CASE WHEN CONTAINS(b.tags, 'TI_IND_15.0') THEN 1 ELSE 0 END AS ti15_cov,

        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_5.0%'  THEN 1 ELSE 0 END AS ti5_sold,
        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_10.0%' THEN 1 ELSE 0 END AS ti10_sold,
        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_15.0%' THEN 1 ELSE 0 END AS ti15_sold,

        CASE WHEN CONTAINS(b.tags, 'TG_IND') THEN 1 ELSE 0 END AS tg_cov,
        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%TG_IND%' THEN 1 ELSE 0 END AS tg_sold,

        CASE
            WHEN CONTAINS(b.tags, 'FC_IND_6')
              OR CONTAINS(b.tags, 'FC_IND_12')
              OR CONTAINS(b.tags, 'FC_PILGRIM_IND_24')
            THEN 1 ELSE 0
        END AS fc_cov,
        CASE
            WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%FC_IND_6%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%FC_IND_12%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%FC_PILGRIM_IND_24%'
            THEN 1 ELSE 0
        END AS fc_sold
    FROM transaction.bus_ticket_events b
    INNER JOIN session_variant sv
        ON b.mri_session_id = sv.mri_session_id
    CROSS JOIN date_params d
    WHERE b.date_of_issue >= d.start_ts
      AND b.date_of_issue < d.end_ts
      AND b.sales_channel IN ('DROIDAPP', 'RB:MOBILEWEB#droidapp')
      AND b.country_code = 'IND'
      AND b.status = 'CONFIRMED'
      AND b.event_type = 101
      AND b.selected_language = 'en'
      AND b.operator_id NOT IN (SELECT op_id FROM excluded_ops)
      AND sv.exp_variant IN ('V0', 'V1', 'V2', 'V3')
)

SELECT
    date,
    exp_variant,
    COUNT(*) AS confirmed_tickets,

    SUM(ti5_cov)  AS ti5_seen,
    SUM(ti5_sold) AS ti5_attach,
    ROUND(100.0 * SUM(ti5_cov)  / NULLIF(COUNT(*), 0), 1) AS ti5_coverage_pct,
    ROUND(100.0 * SUM(ti5_sold) / NULLIF(SUM(ti5_cov), 0), 1) AS ti5_attach_pct,

    SUM(ti10_cov)  AS ti10_seen,
    SUM(ti10_sold) AS ti10_attach,
    ROUND(100.0 * SUM(ti10_cov)  / NULLIF(COUNT(*), 0), 1) AS ti10_coverage_pct,
    ROUND(100.0 * SUM(ti10_sold) / NULLIF(SUM(ti10_cov), 0), 1) AS ti10_attach_pct,

    SUM(ti15_cov)  AS ti15_seen,
    SUM(ti15_sold) AS ti15_attach,
    ROUND(100.0 * SUM(ti15_cov)  / NULLIF(COUNT(*), 0), 1) AS ti15_coverage_pct,
    ROUND(100.0 * SUM(ti15_sold) / NULLIF(SUM(ti15_cov), 0), 1) AS ti15_attach_pct,

    SUM(CASE WHEN ti5_cov + ti10_cov + ti15_cov > 0 THEN 1 ELSE 0 END) AS ti_any_seen,
    SUM(CASE WHEN ti5_sold + ti10_sold + ti15_sold > 0 THEN 1 ELSE 0 END) AS ti_any_attach,
    ROUND(100.0 * SUM(CASE WHEN ti5_sold + ti10_sold + ti15_sold > 0 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN ti5_cov + ti10_cov + ti15_cov > 0 THEN 1 ELSE 0 END), 0), 1) AS ti_any_attach_pct,

    SUM(tg_cov)  AS tg_seen,
    SUM(tg_sold) AS tg_attach,
    ROUND(100.0 * SUM(tg_cov)  / NULLIF(COUNT(*), 0), 1) AS tg_coverage_pct,
    ROUND(100.0 * SUM(tg_sold) / NULLIF(SUM(tg_cov), 0), 1) AS tg_attach_pct,

    SUM(fc_cov)  AS fc_seen,
    SUM(fc_sold) AS fc_attach,
    ROUND(100.0 * SUM(fc_cov)  / NULLIF(COUNT(*), 0), 1) AS fc_coverage_pct,
    ROUND(100.0 * SUM(fc_sold) / NULLIF(SUM(fc_cov), 0), 1) AS fc_attach_pct,

    ROUND(SUM(ticket_fare) / NULLIF(SUM(seat_count), 0), 2) AS asp
FROM neon
GROUP BY 1, 2
ORDER BY 1, 2;
