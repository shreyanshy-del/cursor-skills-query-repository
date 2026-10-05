-- Insurance Lite AB — Q3b: ASP across variants (overall)
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
        CAST(b.ticket_fare AS DOUBLE) AS ticket_fare,
        CAST(b.seat_count AS DOUBLE) AS seat_count,
        CAST(b.ticket_fare AS DOUBLE) / NULLIF(CAST(b.seat_count AS DOUBLE), 0) AS asp_per_seat,
        CASE
            WHEN CONTAINS(b.tags, 'TI_IND_5.0')
              OR CONTAINS(b.tags, 'TI_IND_8.0')
              OR CONTAINS(b.tags, 'TI_IND_10.0')
              OR CONTAINS(b.tags, 'TI_IND_15.0')
            THEN 1 ELSE 0
        END AS ti_coverage,
        CASE
            WHEN CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_5.0%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_8.0%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_10.0%'
              OR CAST(b.addons AS VARCHAR) LIKE '%"tags"%TI_IND_15.0%'
            THEN 1 ELSE 0
        END AS ti_attach
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
    ROUND(SUM(ticket_fare) / NULLIF(SUM(seat_count), 0), 2) AS asp,
    ROUND(AVG(asp_per_seat), 2) AS avg_asp_per_seat,
    SUM(ti_coverage) AS ti_coverage_count,
    SUM(ti_attach) AS ti_attach_count,
    ROUND(100.0 * SUM(ti_attach) / NULLIF(SUM(ti_coverage), 0), 2) AS ti_attach_pct
FROM neon
GROUP BY 1, 2
ORDER BY 1, 2
