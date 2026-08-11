-- SRP → Confirm CR by Android / iOS (os field) — all users, no age / SD filter
-- SRP base: user_interaction.search_details
-- Input: cr_ts_start / cr_ts_end — funnel window
-- Output: platform → srpload, tin, tin_per_srp_pct

WITH params AS (
    SELECT
        TIMESTAMP '2026-05-01 00:00:00' AS cr_ts_start,
        TIMESTAMP '2026-05-31 00:00:00' AS cr_ts_end   -- exclusive
),

srp_keys AS (
    SELECT
        s.mri_session_id,
        CASE
            WHEN UPPER(TRIM(CAST(s.os AS VARCHAR))) = 'ANDROID'
                THEN 'Android'
            WHEN UPPER(TRIM(CAST(s.os AS VARCHAR))) IN ('IOS', 'IPHONE', 'IPAD')
                THEN 'iOS'
        END AS platform
    FROM user_interaction.search_details s
    CROSS JOIN params p
    WHERE s.__time >= p.cr_ts_start
      AND s.__time < p.cr_ts_end
      AND s.country = 'IND'
      AND s.channel IN ('MOBILE_APP', 'MOBILE_WEB', 'WEB_DIRECT')
      AND UPPER(TRIM(CAST(s.os AS VARCHAR))) IN ('ANDROID', 'IOS', 'IPHONE', 'IPAD')
    GROUP BY 1, 2
),

confirm_keys AS (
    SELECT
        k.mri_session_id,
        k.platform,
        c.tin
    FROM srp_keys k
    INNER JOIN user_interaction.confirm_order_details c
        ON k.mri_session_id = c.mri_session_id
    CROSS JOIN params p
    WHERE c.__time >= p.cr_ts_start
      AND c.__time < p.cr_ts_end
      AND c.country = 'IND'
      AND c.status = 200
      AND c.tin IS NOT NULL
      AND c.tin NOT IN ('', 'null')
)

SELECT
    k.platform,
    COUNT(DISTINCT k.mri_session_id) AS srpload,
    COUNT(DISTINCT ck.tin) AS tin,
    ROUND(100.0 * COUNT(DISTINCT ck.tin) / NULLIF(COUNT(DISTINCT k.mri_session_id), 0), 2) AS tin_per_srp_pct
FROM srp_keys k
LEFT JOIN confirm_keys ck
    ON k.mri_session_id = ck.mri_session_id
   AND k.platform = ck.platform
GROUP BY
    k.platform
ORDER BY
    k.platform;
