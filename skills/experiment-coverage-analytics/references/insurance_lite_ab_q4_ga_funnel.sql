-- Optional GA funnel for Insurance Lite AB (ui_ux_events)
-- event_group: ab_exp_Insurance_Lite
-- Events: IL_addon_SRP loaded, IL_addon_shown, IL_attach_type, IL_paynow_click, IL_Purchased
-- Cohort in event_name array: "Addon purchaser" / "Addon non-purchaser"
-- Join channel_exp_info variant via search_route_details on mri_session_id

WITH date_params AS (
    SELECT
        TIMESTAMP '2026-08-18 00:00:00' AS start_ts,
        TIMESTAMP '2026-08-20 18:30:00' AS end_ts
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
)

SELECT
    CAST(DATE_TRUNC('day', AT_TIMEZONE(ux.__time, 'Asia/Kolkata')) AS DATE) AS date_ist,
    sv.exp_variant,
    CASE
        WHEN CONTAINS(CAST(ux.event_name AS VARCHAR), 'Addon non-purchaser') THEN 'Addon non-purchaser'
        WHEN CONTAINS(CAST(ux.event_name AS VARCHAR), 'Addon purchaser') THEN 'Addon purchaser'
        ELSE 'unknown_cohort'
    END AS purchaser_cohort,
    CASE
        WHEN CONTAINS(CAST(ux.event_name AS VARCHAR), 'IL_Purchased') THEN 'IL_Purchased'
        WHEN CONTAINS(CAST(ux.event_name AS VARCHAR), 'IL_paynow_click') THEN 'IL_paynow_click'
        WHEN CONTAINS(CAST(ux.event_name AS VARCHAR), 'IL_attach_type') THEN 'IL_attach_type'
        WHEN CONTAINS(CAST(ux.event_name AS VARCHAR), 'IL_addon_shown') THEN 'IL_addon_shown'
        WHEN CONTAINS(CAST(ux.event_name AS VARCHAR), 'IL_addon_SRP') THEN 'IL_addon_SRP_loaded'
        ELSE CAST(ux.event_name AS VARCHAR)
    END AS stage,
    COUNT(*) AS events,
    COUNT(DISTINCT ux.mri_session_id) AS sessions
FROM user_interaction.ui_ux_events ux
INNER JOIN session_variant sv
    ON ux.mri_session_id = sv.mri_session_id
CROSS JOIN date_params d
WHERE ux.__time >= d.start_ts
  AND ux.__time < d.end_ts
  AND ux.header_country = 'IND'
  AND ux.header_bu = 'BUS'
  AND ux.event_src = 'Android'
  AND ux.event_group = 'ab_exp_Insurance_Lite'
  AND sv.exp_variant IN ('V0', 'V1', 'V2', 'V3')
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4;
