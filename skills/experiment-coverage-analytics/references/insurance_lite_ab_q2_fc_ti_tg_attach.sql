-- Insurance Lite AB (INSURANCE_LITE_AB) — Query 2: FC / TI / TG attach across variants
-- Channel: Android IND | Confirmed tickets: transaction.bus_ticket_events event_type=101
-- Variants: V0/V1 control, V2 Insurance Lite (~₹8) for addon non-purchasers
-- Tags: TI_IND_5/8/10/15, TG_IND, FC_IND_* ; Attach = addons JSON contains tag

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

neon AS (
    SELECT
        DATE(b.date_of_issue) AS date,
        sv.exp_variant,
        b.addons,
        b.tags
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
),

variant_day AS (
    SELECT
        date,
        exp_variant,
        COUNT(*) AS confirmed_tickets,

        -- Travel Insurance by price tag
        SUM(CASE WHEN CONTAINS(tags, 'TI_IND_5.0')  THEN 1 ELSE 0 END) AS ti5_coverage,
        SUM(CASE WHEN addons LIKE '%"tags"%TI_IND_5.0%'  THEN 1 ELSE 0 END) AS ti5_attach,
        SUM(CASE WHEN CONTAINS(tags, 'TI_IND_8.0')  THEN 1 ELSE 0 END) AS ti8_coverage,
        SUM(CASE WHEN addons LIKE '%"tags"%TI_IND_8.0%'  THEN 1 ELSE 0 END) AS ti8_attach,
        SUM(CASE WHEN CONTAINS(tags, 'TI_IND_10.0') THEN 1 ELSE 0 END) AS ti10_coverage,
        SUM(CASE WHEN addons LIKE '%"tags"%TI_IND_10.0%' THEN 1 ELSE 0 END) AS ti10_attach,
        SUM(CASE WHEN CONTAINS(tags, 'TI_IND_15.0') THEN 1 ELSE 0 END) AS ti15_coverage,
        SUM(CASE WHEN addons LIKE '%"tags"%TI_IND_15.0%' THEN 1 ELSE 0 END) AS ti15_attach,

        -- Any TI (all price points incl lite)
        SUM(CASE
            WHEN CONTAINS(tags, 'TI_IND_5.0')
              OR CONTAINS(tags, 'TI_IND_8.0')
              OR CONTAINS(tags, 'TI_IND_10.0')
              OR CONTAINS(tags, 'TI_IND_15.0')
            THEN 1 ELSE 0 END) AS ti_any_coverage,
        SUM(CASE
            WHEN addons LIKE '%"tags"%TI_IND_5.0%'
              OR addons LIKE '%"tags"%TI_IND_8.0%'
              OR addons LIKE '%"tags"%TI_IND_10.0%'
              OR addons LIKE '%"tags"%TI_IND_15.0%'
            THEN 1 ELSE 0 END) AS ti_any_attach,

        -- Travel Guarantee
        SUM(CASE WHEN CONTAINS(tags, 'TG_IND') THEN 1 ELSE 0 END) AS tg_coverage,
        SUM(CASE WHEN addons LIKE '%"tags"%TG_IND%' THEN 1 ELSE 0 END) AS tg_attach,

        -- Free Cancellation (exact tags from base attach query)
        SUM(CASE
            WHEN CONTAINS(tags, 'FC_IND_6')
              OR CONTAINS(tags, 'FC_IND_12')
              OR CONTAINS(tags, 'FC_PILGRIM_IND_24')
            THEN 1 ELSE 0 END) AS fc_coverage,
        SUM(CASE
            WHEN CAST(addons AS VARCHAR) LIKE '%"tags"%FC_IND_6%'
              OR CAST(addons AS VARCHAR) LIKE '%"tags"%FC_IND_12%'
              OR CAST(addons AS VARCHAR) LIKE '%"tags"%FC_PILGRIM_IND_24%'
            THEN 1 ELSE 0 END) AS fc_attach
    FROM neon
    GROUP BY 1, 2
),

tot AS (
    SELECT date, SUM(confirmed_tickets) AS total_confirmed
    FROM variant_day
    GROUP BY 1
)

SELECT
    v.date,
    v.exp_variant,
    v.confirmed_tickets,
    ROUND(100.0 * v.confirmed_tickets / NULLIF(t.total_confirmed, 0), 2) AS traffic_share_pct,

    v.ti_any_coverage,
    v.ti_any_attach,
    ROUND(100.0 * v.ti_any_coverage / NULLIF(v.confirmed_tickets, 0), 1) AS ti_any_coverage_pct,
    CASE WHEN v.ti_any_coverage = 0 THEN NULL
         ELSE ROUND(100.0 * v.ti_any_attach / v.ti_any_coverage, 1)
    END AS ti_any_attach_pct,

    v.ti5_coverage, v.ti5_attach,
    ROUND(100.0 * v.ti5_coverage / NULLIF(v.confirmed_tickets, 0), 1) AS ti5_coverage_pct,
    CASE WHEN v.ti5_coverage = 0 THEN NULL ELSE ROUND(100.0 * v.ti5_attach / v.ti5_coverage, 1) END AS ti5_attach_pct,

    v.ti8_coverage, v.ti8_attach,
    ROUND(100.0 * v.ti8_coverage / NULLIF(v.confirmed_tickets, 0), 1) AS ti8_coverage_pct,
    CASE WHEN v.ti8_coverage = 0 THEN NULL ELSE ROUND(100.0 * v.ti8_attach / v.ti8_coverage, 1) END AS ti8_attach_pct,

    v.ti10_coverage, v.ti10_attach,
    ROUND(100.0 * v.ti10_coverage / NULLIF(v.confirmed_tickets, 0), 1) AS ti10_coverage_pct,
    CASE WHEN v.ti10_coverage = 0 THEN NULL ELSE ROUND(100.0 * v.ti10_attach / v.ti10_coverage, 1) END AS ti10_attach_pct,

    v.ti15_coverage, v.ti15_attach,
    ROUND(100.0 * v.ti15_coverage / NULLIF(v.confirmed_tickets, 0), 1) AS ti15_coverage_pct,
    CASE WHEN v.ti15_coverage = 0 THEN NULL ELSE ROUND(100.0 * v.ti15_attach / v.ti15_coverage, 1) END AS ti15_attach_pct,

    v.tg_coverage, v.tg_attach,
    ROUND(100.0 * v.tg_coverage / NULLIF(v.confirmed_tickets, 0), 1) AS tg_coverage_pct,
    CASE WHEN v.tg_coverage = 0 THEN NULL ELSE ROUND(100.0 * v.tg_attach / v.tg_coverage, 1) END AS tg_attach_pct,

    v.fc_coverage, v.fc_attach,
    ROUND(100.0 * v.fc_coverage / NULLIF(v.confirmed_tickets, 0), 1) AS fc_coverage_pct,
    CASE WHEN v.fc_coverage = 0 THEN NULL ELSE ROUND(100.0 * v.fc_attach / v.fc_coverage, 1) END AS fc_attach_pct

FROM variant_day v
JOIN tot t ON v.date = t.date
ORDER BY v.date, v.exp_variant;
