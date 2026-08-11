-- Gen Z (age 15–27) MOM CR: Confirmed TINs / SRP Sessions, by event_src
-- Month-level cohort: for analysis month M, age is determined from tickets in
--   [M − 12 months, M)  — e.g. May 2026 uses May 2025 through Apr 2026 (May 2026 excluded)
-- Funnel sessions (SRP + Confirm) are scoped to analysis month M only

WITH params AS (
    SELECT
        TIMESTAMP '2025-05-20 00:00:00' AS ts_start,
        TIMESTAMP '2026-05-20 18:30:00' AS ts_end
),

analysis_months AS (
    SELECT
        month_start AS analysis_month,
        DATE_FORMAT(month_start, '%Y-%b') AS month_period
    FROM params p
    CROSS JOIN UNNEST(
        SEQUENCE(
            DATE_TRUNC(
                'month',
                CAST(AT_TIMEZONE(p.ts_start, 'Asia/Kolkata') AS DATE)
            ),
            DATE_TRUNC(
                'month',
                CAST(AT_TIMEZONE(p.ts_end, 'Asia/Kolkata') AS DATE)
            ),
            INTERVAL '1' MONTH
        )
    ) AS t(month_start)
),

-- Per analysis month: users with age 15–27 on any confirm in the 12-month lookback (current month excluded)
genz_users_by_month AS (
    SELECT
        m.analysis_month,
        m.month_period,
        t.rb_user_id
    FROM analysis_months m
    INNER JOIN transaction.bus_ticket_events t
        ON t.date_of_issue >= m.analysis_month - INTERVAL '12' MONTH
       AND t.date_of_issue < m.analysis_month
       AND t.country_code = 'IND'
       AND t.tin IS NOT NULL
       AND t.event_type = 101
       AND t.event_class = 2
       AND t.rb_user_id > 0
       AND t.travellers_age[1] BETWEEN 15 AND 27
    GROUP BY 1, 2, 3
),

srp_deduped AS (
    SELECT DISTINCT
        s.mri_session_id,
        s.route_id,
        g.analysis_month,
        g.month_period,
        COALESCE(CAST(s.event_src AS VARCHAR), CAST(s.os AS VARCHAR), 'UNKNOWN') AS event_src
    FROM user_interaction.search_route_details s
    INNER JOIN genz_users_by_month g
        ON s.rb_user_id = g.rb_user_id
       AND CAST(AT_TIMEZONE(s.__time, 'Asia/Kolkata') AS DATE) >= g.analysis_month
       AND CAST(AT_TIMEZONE(s.__time, 'Asia/Kolkata') AS DATE) < g.analysis_month + INTERVAL '1' MONTH
    CROSS JOIN params p
    WHERE s.__time >= p.ts_start
      AND s.__time < p.ts_end
      AND s.country = 'IND'
      AND s.channel IN ('MOBILE_APP', 'MOBILE_WEB', 'WEB_DIRECT')
),

confirm_deduped AS (
    SELECT
        srp.mri_session_id,
        srp.route_id,
        srp.analysis_month,
        srp.month_period,
        srp.event_src,
        COUNT(DISTINCT c.tin) AS tin_count
    FROM srp_deduped srp
    INNER JOIN user_interaction.confirm_order_details c
        ON srp.mri_session_id = c.mri_session_id
       AND srp.route_id = c.route_id
    CROSS JOIN params p
    WHERE c.__time >= p.ts_start
      AND c.__time < p.ts_end
      AND c.country = 'IND'
      AND c.status = 200
      AND c.tin IS NOT NULL
      AND c.tin NOT IN ('', 'null')
      AND CAST(AT_TIMEZONE(c.__time, 'Asia/Kolkata') AS DATE) >= srp.analysis_month
      AND CAST(AT_TIMEZONE(c.__time, 'Asia/Kolkata') AS DATE) < srp.analysis_month + INTERVAL '1' MONTH
    GROUP BY 1, 2, 3, 4, 5
)

SELECT
    srp.month_period,
    srp.event_src,
    COUNT(DISTINCT srp.mri_session_id) AS srpload,
    SUM(conf.tin_count) AS tin,
    ROUND(100.0 * SUM(conf.tin_count) / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS tin_per_srp_pct
FROM srp_deduped srp
LEFT JOIN confirm_deduped conf
    ON srp.mri_session_id = conf.mri_session_id
   AND srp.route_id = conf.route_id
   AND srp.analysis_month = conf.analysis_month
   AND srp.event_src = conf.event_src
GROUP BY
    srp.month_period,
    srp.event_src
ORDER BY
    MIN(srp.analysis_month),
    srpload DESC;
