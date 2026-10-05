-- Insurance Lite AB — RAP/FC/TG/TI coverage + attach + revenue/unit
WITH date_params AS (
    SELECT
        TIMESTAMP '2026-08-18 00:00:00' AS start_ts,
        TIMESTAMP '2026-08-21 00:00:00' AS end_ts
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
addon_rev AS (
    SELECT
        order_uuid,
        SUM(CASE
            WHEN CAST(item_type AS VARCHAR) LIKE '%RAP%' OR CAST(tags AS VARCHAR) LIKE '%RAP%'
            THEN CAST(COALESCE(final_amount, amount, price, 0) AS DOUBLE) ELSE 0 END) AS rap_rev,
        SUM(CASE
            WHEN CAST(item_type AS VARCHAR) LIKE '%FC%' OR CAST(tags AS VARCHAR) LIKE '%FC_IND%'
            THEN CAST(COALESCE(final_amount, amount, price, 0) AS DOUBLE) ELSE 0 END) AS fc_rev,
        SUM(CASE
            WHEN CAST(item_type AS VARCHAR) LIKE '%TG%' OR CAST(tags AS VARCHAR) LIKE '%TG_IND%'
            THEN CAST(COALESCE(final_amount, amount, price, 0) AS DOUBLE) ELSE 0 END) AS tg_rev,
        SUM(CASE
            WHEN CAST(tags AS VARCHAR) LIKE '%TI_IND%'
            THEN CAST(COALESCE(final_amount, amount, price, 0) AS DOUBLE) ELSE 0 END) AS ti_rev
    FROM transaction.addon_item
    CROSS JOIN date_params d
    WHERE 1 = 1
    GROUP BY 1
),
neon AS (
    SELECT
        DATE(b.date_of_issue) AS date,
        sv.exp_variant,
        CAST(b.addons AS VARCHAR) AS addons_str,
        b.tags,
        COALESCE(r.rap_rev, 0) AS rap_rev,
        COALESCE(r.fc_rev, 0) AS fc_rev,
        COALESCE(r.tg_rev, 0) AS tg_rev,
        COALESCE(r.ti_rev, 0) AS ti_rev,
        CASE WHEN CONTAINS(b.tags, 'RAP_IND') OR CONTAINS(b.tags, 'RAP_TI_IND') THEN 1 ELSE 0 END AS rap_cov,
        CASE WHEN CONTAINS(b.tags, 'FC_IND_6') OR CONTAINS(b.tags, 'FC_IND_12') OR CONTAINS(b.tags, 'FC_PILGRIM_IND_24') THEN 1 ELSE 0 END AS fc_cov,
        CASE WHEN CONTAINS(b.tags, 'TG_IND') THEN 1 ELSE 0 END AS tg_cov,
        CASE
            WHEN CONTAINS(b.tags, 'TI_IND_5.0') OR CONTAINS(b.tags, 'TI_IND_8.0')
              OR CONTAINS(b.tags, 'TI_IND_10.0') OR CONTAINS(b.tags, 'TI_IND_15.0')
            THEN 1 ELSE 0 END AS ti_cov,
        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%RAP_IND%' OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%RAP_TI_IND%' THEN 1 ELSE 0 END AS rap_sold,
        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%FC_IND_6%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%FC_IND_12%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%FC_PILGRIM_IND_24%' THEN 1 ELSE 0 END AS fc_sold,
        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%TG_IND%' THEN 1 ELSE 0 END AS tg_sold,
        CASE WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_5.0%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_8.0%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_10.0%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_15.0%' THEN 1 ELSE 0 END AS ti_sold
    FROM transaction.bus_ticket_events b
    INNER JOIN session_variant sv ON b.mri_session_id = sv.mri_session_id
    LEFT JOIN addon_rev r ON b.order_uuid = r.order_uuid
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
    COUNT(*) AS tickets,
    SUM(rap_cov) AS rap_cov, SUM(rap_sold) AS rap_sold,
    ROUND(100.0 * SUM(rap_sold) / NULLIF(SUM(rap_cov), 0), 1) AS rap_attach_pct,
    SUM(fc_cov) AS fc_cov, SUM(fc_sold) AS fc_sold,
    ROUND(100.0 * SUM(fc_sold) / NULLIF(SUM(fc_cov), 0), 1) AS fc_attach_pct,
    SUM(tg_cov) AS tg_cov, SUM(tg_sold) AS tg_sold,
    ROUND(100.0 * SUM(tg_sold) / NULLIF(SUM(tg_cov), 0), 1) AS tg_attach_pct,
    SUM(ti_cov) AS ti_cov, SUM(ti_sold) AS ti_sold,
    ROUND(100.0 * SUM(ti_sold) / NULLIF(SUM(ti_cov), 0), 1) AS ti_attach_pct,
    ROUND(SUM(CASE WHEN rap_sold = 1 THEN rap_rev ELSE 0 END) / NULLIF(SUM(rap_sold), 0), 2) AS rap_rev_per_unit,
    ROUND(SUM(CASE WHEN fc_sold = 1 THEN fc_rev ELSE 0 END) / NULLIF(SUM(fc_sold), 0), 2) AS fc_rev_per_unit,
    ROUND(SUM(CASE WHEN tg_sold = 1 THEN tg_rev ELSE 0 END) / NULLIF(SUM(tg_sold), 0), 2) AS tg_rev_per_unit,
    ROUND(SUM(CASE WHEN ti_sold = 1 THEN ti_rev ELSE 0 END) / NULLIF(SUM(ti_sold), 0), 2) AS ti_rev_per_unit,
    ROUND(SUM(rap_rev), 0) AS rap_rev_total,
    ROUND(SUM(fc_rev), 0) AS fc_rev_total,
    ROUND(SUM(tg_rev), 0) AS tg_rev_total,
    ROUND(SUM(ti_rev), 0) AS ti_rev_total
FROM neon
GROUP BY 1, 2
ORDER BY 1, 2
