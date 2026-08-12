-- Android Same Day LMB vs Other — Conversion Funnel Throughput
-- Grain: booking_type (SameDay LMB | Other)
-- Window: last 10 IST calendar days
-- Country: IND | Channel: MOBILE_APP | OS: Android
-- Joins: session (+ doj for confirm) only — no route_id, no experiment variant
--
-- SameDay LMB = search DOJ is same IST calendar day AND search hour IST in 17–23

WITH params AS (
    SELECT
        CAST(CURRENT_DATE - INTERVAL '9' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
        CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),

srp AS (
    SELECT
        sd.__time AS srpdate,
        sd.doj AS srpdoj,
        sd.mri_session_id AS srpsession
    FROM user_interaction.search_details sd
    CROSS JOIN params p
    WHERE sd.__time >= p.window_start
      AND sd.__time < p.window_end
      AND sd.channel = 'MOBILE_APP'
      AND sd.os = 'Android'
      AND sd.country = 'IND'
    GROUP BY 1, 2, 3
),

sl AS (
    SELECT
        sl.mri_session_id AS slsession
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN params p
    WHERE sl.__time >= p.window_start
      AND sl.__time < p.window_end
      AND sl.country = 'IND'
    GROUP BY 1
),

mpax AS (
    SELECT
        c.mri_session_id AS paxsession
    FROM user_interaction.cust_info_details c
    CROSS JOIN params p
    WHERE c.__time >= p.window_start
      AND c.__time < p.window_end
      AND c.country = 'IND'
    GROUP BY 1
),

tco AS (
    SELECT
        t.mri_session_id AS tcosession
    FROM user_interaction.create_order_details t
    CROSS JOIN params p
    WHERE t.__time >= p.window_start
      AND t.__time < p.window_end
      AND t.channel = 'MOBILE_APP'
      AND t.country = 'IND'
    GROUP BY 1
),

confirm AS (
    SELECT
        cf.mri_session_id AS confirmsession,
        cf.tin,
        cf.doj AS confirmdoj
    FROM user_interaction.confirm_order_details cf
    CROSS JOIN params p
    WHERE cf.__time >= p.window_start
      AND cf.__time < p.window_end
      AND cf.country = 'IND'
      AND cf.error_code = 'CONFIRMED'
      AND cf.status_str = 'SUCCESS'
      AND cf.tin IS NOT NULL
      AND cf.tin <> ''
      AND cf.tin <> 'null'
    GROUP BY 1, 2, 3
)

SELECT
    CASE
        WHEN DATE_DIFF(
                 'day',
                 DATE(DATE_ADD('minute', 330, srp.srpdate)),
                 CAST(srp.srpdoj AS DATE)
             ) = 0
         AND EXTRACT(hour FROM DATE_ADD('minute', 330, srp.srpdate)) IN (17, 18, 19, 20, 21, 22, 23)
        THEN 'SameDay LMB'
        ELSE 'Other'
    END AS booking_type,
    COUNT(DISTINCT srp.srpsession) AS srpsession,
    COUNT(DISTINCT sl.slsession) AS slsession,
    COUNT(DISTINCT mpax.paxsession) AS paxsession,
    COUNT(DISTINCT tco.tcosession) AS tcosession,
    COUNT(DISTINCT confirm.confirmsession) AS confirmsession,
    COUNT(DISTINCT confirm.tin) AS tin,
    ROUND(100.0 * COUNT(DISTINCT sl.slsession) / NULLIF(COUNT(DISTINCT srp.srpsession), 0), 2) AS srp_to_sl_pct,
    ROUND(100.0 * COUNT(DISTINCT mpax.paxsession) / NULLIF(COUNT(DISTINCT sl.slsession), 0), 2) AS sl_to_mpax_pct,
    ROUND(100.0 * COUNT(DISTINCT tco.tcosession) / NULLIF(COUNT(DISTINCT mpax.paxsession), 0), 2) AS mpax_to_tco_pct,
    ROUND(100.0 * COUNT(DISTINCT confirm.confirmsession) / NULLIF(COUNT(DISTINCT tco.tcosession), 0), 2) AS tco_to_confirm_pct,
    ROUND(100.0 * COUNT(DISTINCT confirm.confirmsession) / NULLIF(COUNT(DISTINCT srp.srpsession), 0), 2) AS srp_to_confirm_pct
FROM srp
LEFT JOIN sl
    ON srp.srpsession = sl.slsession
LEFT JOIN mpax
    ON srp.srpsession = mpax.paxsession
LEFT JOIN tco
    ON srp.srpsession = tco.tcosession
LEFT JOIN confirm
    ON srp.srpsession = confirm.confirmsession
   AND srp.srpdoj = confirm.confirmdoj
GROUP BY 1
ORDER BY 1
