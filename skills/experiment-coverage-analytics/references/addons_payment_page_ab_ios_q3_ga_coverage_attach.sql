-- ADDONS_PAYMENT_PAGE_AB_IOS — Q3: GA Coverage (Transacted/Seen) + Attach for TG/TI/FC
-- event_group: ab_exp_addon_payment | event_src: iOS
--
-- Seen     = session saw addon on CI (CIAddonShown) OR Payment callout (PaymentPageLoad)
-- Transacted = session confirmed a ticket (confirm_order_details status=200)
-- Coverage (Transacted/Seen) = confirmed_among_seen / seen
-- Attach (GA) = PayNow carrying Cust info_{Addon} or Payment_{Addon} / seen
-- Also reports AddonAdded widget attach as secondary

WITH date_params AS (
    SELECT
        TIMESTAMP '2026-08-17 00:00:00' AS start_ts,
        TIMESTAMP '2026-08-20 18:30:00' AS end_ts
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

ga AS (
    SELECT
        CAST(DATE_TRUNC('day', AT_TIMEZONE(ux.__time, 'Asia/Kolkata')) AS DATE) AS date,
        sv.exp_variant,
        ux.mri_session_id,
        CAST(ux.event_name AS VARCHAR) AS event_name_str,
        COALESCE(ux.event_value, '') AS event_value
    FROM user_interaction.ui_ux_events ux
    INNER JOIN session_variant sv
        ON ux.mri_session_id = sv.mri_session_id
    CROSS JOIN date_params d
    WHERE ux.__time >= d.start_ts
      AND ux.__time < d.end_ts
      AND ux.header_country = 'IND'
      AND ux.header_bu = 'BUS'
      AND ux.event_src = 'iOS'
      AND ux.event_group = 'ab_exp_addon_payment'
      AND sv.exp_variant IN ('V0', 'V1', 'V2', 'V3', 'V4', 'V5')
),

session_flags AS (
    SELECT
        date,
        exp_variant,
        mri_session_id,

        MAX(CASE
            WHEN event_name_str = 'AddonPayment_CIAddonShown'
              OR event_name_str LIKE '%AddonPayment_PaymentPageLoad%'
            THEN 1 ELSE 0 END) AS any_addon_surface,

        MAX(CASE
            WHEN (event_name_str = 'AddonPayment_CIAddonShown'
                  OR event_name_str LIKE '%AddonPayment_PaymentPageLoad%')
             AND (
                event_value LIKE '%TI%'
                OR event_name_str LIKE '%TI_No%'
                OR event_name_str LIKE '%TI_Yes%'
             )
            THEN 1 ELSE 0 END) AS seen_ti,

        MAX(CASE
            WHEN (event_name_str = 'AddonPayment_CIAddonShown'
                  OR event_name_str LIKE '%AddonPayment_PaymentPageLoad%')
             AND (
                event_value LIKE '%TG%'
                OR event_name_str LIKE '%TG_No%'
                OR event_name_str LIKE '%TG_Yes%'
             )
            THEN 1 ELSE 0 END) AS seen_tg,

        MAX(CASE
            WHEN (event_name_str = 'AddonPayment_CIAddonShown'
                  OR event_name_str LIKE '%AddonPayment_PaymentPageLoad%')
             AND (
                event_value LIKE '%FC%'
                OR event_name_str LIKE '%FC_No%'
                OR event_name_str LIKE '%FC_Yes%'
             )
            THEN 1 ELSE 0 END) AS seen_fc,

        MAX(CASE
            WHEN event_name_str = 'AddonPayment_PayNow'
             AND (event_value LIKE '%Cust info_TI%' OR event_value LIKE '%Payment_TI%')
            THEN 1 ELSE 0 END) AS paynow_ti,

        MAX(CASE
            WHEN event_name_str = 'AddonPayment_PayNow'
             AND (event_value LIKE '%Cust info_TG%' OR event_value LIKE '%Payment_TG%')
            THEN 1 ELSE 0 END) AS paynow_tg,

        MAX(CASE
            WHEN event_name_str = 'AddonPayment_PayNow'
             AND (event_value LIKE '%Cust info_FC%' OR event_value LIKE '%Payment_FC%')
            THEN 1 ELSE 0 END) AS paynow_fc,

        MAX(CASE
            WHEN event_name_str LIKE '%AddonPayment_AddonAdded%'
             AND event_value LIKE '%TI_Added%'
            THEN 1 ELSE 0 END) AS added_ti,

        MAX(CASE
            WHEN event_name_str LIKE '%AddonPayment_AddonAdded%'
             AND event_value LIKE '%TG_Added%'
            THEN 1 ELSE 0 END) AS added_tg,

        MAX(CASE
            WHEN event_name_str LIKE '%AddonPayment_AddonAdded%'
             AND event_value LIKE '%FC_Added%'
            THEN 1 ELSE 0 END) AS added_fc,

        MAX(CASE WHEN event_name_str = 'AddonPayment_SRPPageLoad' THEN 1 ELSE 0 END) AS srp_page,
        MAX(CASE WHEN event_name_str = 'AddonPayment_CIAddonShown' THEN 1 ELSE 0 END) AS ci_shown,
        MAX(CASE WHEN event_name_str LIKE '%AddonPayment_PaymentPageLoad%' THEN 1 ELSE 0 END) AS pay_page,
        MAX(CASE WHEN event_name_str = 'AddonPayment_PayNow' THEN 1 ELSE 0 END) AS pay_now
    FROM ga
    GROUP BY 1, 2, 3
),

confirmed AS (
    SELECT DISTINCT mri_session_id
    FROM user_interaction.confirm_order_details conf
    CROSS JOIN date_params d
    WHERE conf.__time >= d.start_ts
      AND conf.__time < d.end_ts
      AND conf.country = 'IND'
      AND conf.status = 200
      AND conf.tin IS NOT NULL
      AND conf.tin NOT IN ('', 'null')
),

joined AS (
    SELECT
        f.*,
        CASE WHEN c.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS is_confirmed
    FROM session_flags f
    LEFT JOIN confirmed c
        ON f.mri_session_id = c.mri_session_id
)

SELECT
    date,
    exp_variant,

    COUNT(DISTINCT mri_session_id) AS ga_sessions,
    SUM(ci_shown) AS ci_addon_shown_sessions,
    SUM(pay_page) AS payment_page_sessions,
    SUM(pay_now) AS paynow_sessions,
    SUM(is_confirmed) AS confirmed_sessions,

    -- TI
    SUM(seen_ti) AS ti_seen,
    SUM(CASE WHEN seen_ti = 1 THEN is_confirmed ELSE 0 END) AS ti_transacted,
    ROUND(100.0 * SUM(CASE WHEN seen_ti = 1 THEN is_confirmed ELSE 0 END)
          / NULLIF(SUM(seen_ti), 0), 1) AS ti_coverage_transacted_over_seen_pct,
    SUM(paynow_ti) AS ti_paynow_attach,
    ROUND(100.0 * SUM(paynow_ti) / NULLIF(SUM(seen_ti), 0), 1) AS ti_ga_attach_pct,
    SUM(added_ti) AS ti_widget_added,

    -- TG
    SUM(seen_tg) AS tg_seen,
    SUM(CASE WHEN seen_tg = 1 THEN is_confirmed ELSE 0 END) AS tg_transacted,
    ROUND(100.0 * SUM(CASE WHEN seen_tg = 1 THEN is_confirmed ELSE 0 END)
          / NULLIF(SUM(seen_tg), 0), 1) AS tg_coverage_transacted_over_seen_pct,
    SUM(paynow_tg) AS tg_paynow_attach,
    ROUND(100.0 * SUM(paynow_tg) / NULLIF(SUM(seen_tg), 0), 1) AS tg_ga_attach_pct,
    SUM(added_tg) AS tg_widget_added,

    -- FC
    SUM(seen_fc) AS fc_seen,
    SUM(CASE WHEN seen_fc = 1 THEN is_confirmed ELSE 0 END) AS fc_transacted,
    ROUND(100.0 * SUM(CASE WHEN seen_fc = 1 THEN is_confirmed ELSE 0 END)
          / NULLIF(SUM(seen_fc), 0), 1) AS fc_coverage_transacted_over_seen_pct,
    SUM(paynow_fc) AS fc_paynow_attach,
    ROUND(100.0 * SUM(paynow_fc) / NULLIF(SUM(seen_fc), 0), 1) AS fc_ga_attach_pct,
    SUM(added_fc) AS fc_widget_added,

    -- GA funnel throughput (among AB sessions that fired any addon-payment event)
    ROUND(100.0 * SUM(ci_shown) / NULLIF(COUNT(DISTINCT mri_session_id), 0), 1) AS pct_ci_shown,
    ROUND(100.0 * SUM(pay_page) / NULLIF(SUM(ci_shown), 0), 1) AS pct_ci_to_paypage,
    ROUND(100.0 * SUM(pay_now) / NULLIF(SUM(pay_page), 0), 1) AS pct_paypage_to_paynow,
    ROUND(100.0 * SUM(is_confirmed) / NULLIF(SUM(pay_now), 0), 1) AS pct_paynow_to_confirm
FROM joined
GROUP BY 1, 2
ORDER BY 1, 2;
