-- ADDONS_PAYMENT_PAGE_AB_IOS — Q2: Ticket-level Coverage & Attach of TG/TI/FC across variants
-- Coverage = tags contain addon (eligible/shown on confirmed ticket)
-- Attach   = addons JSON contains tag (purchased)
-- Attach%  = attach / coverage | Coverage% = coverage / confirmed
-- Channel: iOS IND | sales_channel RB:MOBILEWEB#iosapp | event_type=101

WITH date_params AS (
    SELECT
        TIMESTAMP '2026-08-17 00:00:00' AS start_ts,
        TIMESTAMP '2026-08-20 18:30:00' AS end_ts
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
                WHEN CONTAINS(s.channel_exp_info, 'ADDONS_PAYMENT_PAGE_AB_IOS:V0') THEN 'V0'
                WHEN CONTAINS(s.channel_exp_info, 'ADDONS_PAYMENT_PAGE_AB_IOS:V1') THEN 'V1'
                WHEN CONTAINS(s.channel_exp_info, 'ADDONS_PAYMENT_PAGE_AB_IOS:V2') THEN 'V2'
                WHEN CONTAINS(s.channel_exp_info, 'ADDONS_PAYMENT_PAGE_AB_IOS:V3') THEN 'V3'
                WHEN CONTAINS(s.channel_exp_info, 'ADDONS_PAYMENT_PAGE_AB_IOS:V4') THEN 'V4'
                WHEN CONTAINS(s.channel_exp_info, 'ADDONS_PAYMENT_PAGE_AB_IOS:V5') THEN 'V5'
                ELSE 'others'
            END
        ) AS exp_variant
    FROM user_interaction.search_route_details s
    CROSS JOIN date_params d
    WHERE s.__time >= d.start_ts
      AND s.__time < d.end_ts
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os = 'iOS'
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
      AND b.sales_channel = 'RB:MOBILEWEB#iosapp'
      AND b.country_code = 'IND'
      AND b.status = 'CONFIRMED'
      AND b.event_type = 101
      AND b.operator_id NOT IN (SELECT op_id FROM excluded_ops)
      AND sv.exp_variant IN ('V0', 'V1', 'V2', 'V3', 'V4', 'V5')
),

variant_day AS (
    SELECT
        date,
        exp_variant,
        COUNT(*) AS confirmed_tickets,

        SUM(CASE
            WHEN CONTAINS(tags, 'TI_IND_5.0')
              OR CONTAINS(tags, 'TI_IND_8.0')
              OR CONTAINS(tags, 'TI_IND_10.0')
              OR CONTAINS(tags, 'TI_IND_15.0')
            THEN 1 ELSE 0 END) AS ti_coverage,
        SUM(CASE
            WHEN addons LIKE '%"tags"%TI_IND_5.0%'
              OR addons LIKE '%"tags"%TI_IND_8.0%'
              OR addons LIKE '%"tags"%TI_IND_10.0%'
              OR addons LIKE '%"tags"%TI_IND_15.0%'
            THEN 1 ELSE 0 END) AS ti_attach,

        SUM(CASE WHEN CONTAINS(tags, 'TG_IND') THEN 1 ELSE 0 END) AS tg_coverage,
        SUM(CASE WHEN addons LIKE '%"tags"%TG_IND%' THEN 1 ELSE 0 END) AS tg_attach,

        SUM(CASE WHEN CONTAINS(tags, 'FC_IND') THEN 1 ELSE 0 END) AS fc_coverage,
        SUM(CASE WHEN addons LIKE '%"tags"%FC_IND%' THEN 1 ELSE 0 END) AS fc_attach
    FROM neon
    GROUP BY 1, 2
)

SELECT
    date,
    exp_variant,
    confirmed_tickets,

    ti_coverage,
    ti_attach,
    ROUND(100.0 * ti_coverage / NULLIF(confirmed_tickets, 0), 1) AS ti_coverage_pct,
    CASE WHEN ti_coverage = 0 THEN NULL
         ELSE ROUND(100.0 * ti_attach / ti_coverage, 1) END AS ti_attach_pct,

    tg_coverage,
    tg_attach,
    ROUND(100.0 * tg_coverage / NULLIF(confirmed_tickets, 0), 1) AS tg_coverage_pct,
    CASE WHEN tg_coverage = 0 THEN NULL
         ELSE ROUND(100.0 * tg_attach / tg_coverage, 1) END AS tg_attach_pct,

    fc_coverage,
    fc_attach,
    ROUND(100.0 * fc_coverage / NULLIF(confirmed_tickets, 0), 1) AS fc_coverage_pct,
    CASE WHEN fc_coverage = 0 THEN NULL
         ELSE ROUND(100.0 * fc_attach / fc_coverage, 1) END AS fc_attach_pct
FROM variant_day
ORDER BY date, exp_variant;
