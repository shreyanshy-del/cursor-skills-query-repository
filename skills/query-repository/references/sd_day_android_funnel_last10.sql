-- Android Day-on-Day IST Conversion Funnel Throughput
-- Grain: search_date_ist x src_id x dest_id
-- Window: last 10 days IST (no DBD / LMB cuts)
-- Country: IND | Channel: MOBILE_APP | OS: Android

WITH target_routes AS (
    SELECT *
    FROM (
        VALUES
            (122, 123),
            (123, 122),
            (124, 122),
            (122, 124),
            (123, 141),
            (141, 123),
            (123, 126),
            (126, 123),
            (141, 122),
            (122, 141),
            (124, 134),
            (134, 124),
            (123, 71929),
            (123, 602),
            (733, 1439),
            (130, 624),
            (313, 979),
            (733, 777),
            (807, 733),
            (130, 462),
            (123, 696),
            (733, 78027),
            (733, 807),
            (462, 130),
            (124, 248),
            (130, 309),
            (123, 690),
            (122, 126),
            (126, 122),
            (122, 95222),
            (74820, 69802),
            (124, 123),
            (123, 458),
            (130, 124),
            (124, 130),
            (123, 124),
            (123, 698),
            (130, 575),
            (462, 76079),
            (124, 131),
            (122, 131),
            (122, 216),
            (134, 122),
            (123, 233),
            (122, 134),
            (123, 236),
            (733, 833),
            (124, 462),
            (122, 233),
            (130, 313),
            (313, 130),
            (124, 135),
            (122, 71929),
            (462, 124),
            (123, 235),
            (126, 141),
            (124, 137),
            (141, 126),
            (130, 122),
            (122, 130),
            (122, 602),
            (130, 76079),
            (124, 284),
            (122, 74661),
            (313, 462),
            (124, 71757),
            (122, 95083),
            (462, 309),
            (733, 1377),
            (134, 248),
            (462, 313),
            (122, 995),
            (74820, 74676),
            (70015, 807),
            (551, 472),
            (807, 70015),
            (122, 462),
            (462, 122),
            (122, 236),
            (124, 624),
            (122, 71425),
            (130, 95083),
            (141, 696),
            (141, 71929),
            (122, 137),
            (124, 74676),
            (462, 624),
            (122, 284),
            (551, 313),
            (733, 313),
            (313, 733),
            (313, 551),
            (130, 473),
            (122, 235),
            (130, 444),
            (807, 470),
            (551, 473),
            (123, 216),
            (141, 690),
            (130, 551),
            (122, 690),
            (551, 130),
            (134, 123),
            (122, 696),
            (141, 458),
            (141, 698),
            (141, 233),
            (122, 125),
            (124, 125),
            (807, 1439),
            (551, 470),
            (122, 135),
            (733, 737),
            (733, 736),
            (123, 134),
            (122, 248),
            (551, 462),
            (122, 74676),
            (733, 551),
            (551, 1003),
            (462, 551),
            (70015, 1439),
            (123, 71425),
            (313, 70024),
            (313, 624),
            (551, 733),
            (141, 216),
            (807, 551),
            (733, 1290),
            (551, 807),
            (462, 95083),
            (807, 313),
            (733, 74699),
            (807, 1169),
            (759, 833),
            (759, 733),
            (76480, 733),
            (122, 210),
            (122, 558),
            (122, 254),
            (122, 1013),
            (122, 66007),
            (122, 71756),
            (122, 293),
            (122, 154),
            (122, 960),
            (122, 86882),
            (517, 124),
            (827, 807),
            (833, 759),
            (833, 734),
            (123, 231),
            (123, 427),
            (123, 489),
            (123, 466),
            (123, 501),
            (123, 66007),
            (123, 663),
            (123, 71756),
            (123, 293),
            (231, 123),
            (141, 663),
            (733, 759),
            (733, 76480),
            (733, 1514),
            (733, 802),
            (733, 734),
            (733, 197688),
            (733, 197504),
            (733, 757),
            (733, 771),
            (733, 309423),
            (733, 842),
            (733, 1285),
            (733, 1001),
            (733, 70429),
            (65768, 733),
            (74706, 74820),
            (210, 122),
            (210, 462),
            (210, 130),
            (71958, 313),
            (1514, 733),
            (802, 733),
            (124, 517),
            (124, 71756),
            (313, 71958),
            (313, 1001),
            (807, 827),
            (734, 833),
            (734, 733),
            (558, 122),
            (197688, 733),
            (735, 733),
            (197504, 733),
            (74820, 74706),
            (74820, 74694),
            (427, 123),
            (757, 733),
            (82467, 74820),
            (489, 123),
            (466, 123),
            (462, 210),
            (624, 361),
            (361, 624),
            (361, 130),
            (1013, 122),
            (501, 123),
            (309423, 733),
            (130, 210),
            (130, 361),
            (130, 750),
            (842, 733),
            (1285, 733),
            (74694, 74820),
            (66007, 122),
            (66007, 123),
            (663, 123),
            (71756, 122),
            (71756, 123),
            (71756, 124),
            (71756, 134),
            (293, 122),
            (154, 122),
            (1001, 979),
            (1001, 733),
            (70429, 733),
            (960, 122),
            (86882, 122),
            (134, 71756)
    ) AS t(source_location_id, destination_location_id)
),
params AS (
    SELECT
        -- Last 10 IST calendar days including today
        CAST(CURRENT_DATE - INTERVAL '9' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
        CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
    SELECT
        CAST(sd.__time + INTERVAL '330' MINUTE AS DATE) AS search_date_ist,
        sd.src_id,
        sd.dest_id,
        sd.mri_session_id
    FROM user_interaction.search_details sd
    INNER JOIN target_routes tr
        ON sd.src_id = tr.source_location_id
       AND sd.dest_id = tr.destination_location_id
    CROSS JOIN params p
    WHERE sd.__time >= p.window_start
      AND sd.__time < p.window_end
      AND sd.channel = 'MOBILE_APP'
      AND sd.os = 'Android'
      AND sd.country = 'IND'
    GROUP BY 1, 2, 3, 4
),
sl AS (
    SELECT mri_session_id
    FROM user_interaction.seat_layout_details
    CROSS JOIN params p
    WHERE __time >= p.window_start
      AND __time < p.window_end
      AND country = 'IND'
    GROUP BY 1
),
mpax AS (
    SELECT mri_session_id
    FROM user_interaction.cust_info_details
    CROSS JOIN params p
    WHERE __time >= p.window_start
      AND __time < p.window_end
    GROUP BY 1
),
tco AS (
    SELECT mri_session_id
    FROM user_interaction.create_order_details
    CROSS JOIN params p
    WHERE __time >= p.window_start
      AND __time < p.window_end
    GROUP BY 1
),
confirm AS (
    SELECT
        mri_session_id,
        route_id,
        doj,
        src_id,
        dest_id,
        tin
    FROM user_interaction.confirm_order_details
    CROSS JOIN params p
    WHERE __time >= p.window_start
      AND __time < p.window_end
      AND channel = 'MOBILE_APP'
      AND os = 'Android'
      AND country = 'IND'
      AND error_code = 'CONFIRMED'
      AND status_str = 'SUCCESS'
      AND tin IS NOT NULL
      AND tin <> ''
      AND tin <> 'null'
    GROUP BY 1, 2, 3, 4, 5, 6
),
funnel AS (
    SELECT
        s.search_date_ist,
        s.src_id,
        s.dest_id,
        s.mri_session_id,
        MAX(CASE WHEN sl.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS reached_sl,
        MAX(CASE WHEN mpax.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS reached_mpax,
        MAX(CASE WHEN tco.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS reached_tco,
        MAX(CASE WHEN c.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS reached_confirm
    FROM srp s
    LEFT JOIN sl ON s.mri_session_id = sl.mri_session_id
    LEFT JOIN mpax ON s.mri_session_id = mpax.mri_session_id
    LEFT JOIN tco ON s.mri_session_id = tco.mri_session_id
    LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id
    GROUP BY 1, 2, 3, 4
)
SELECT
    search_date_ist,
    src_id,
    dest_id,
    COUNT(*) AS srp_sessions,
    SUM(reached_sl) AS sl_sessions,
    SUM(reached_mpax) AS mpax_sessions,
    SUM(reached_tco) AS tco_sessions,
    SUM(reached_confirm) AS confirm_sessions,
    ROUND(100.0 * SUM(reached_sl) / NULLIF(COUNT(*), 0), 2) AS srp_to_sl_pct,
    ROUND(100.0 * SUM(reached_mpax) / NULLIF(SUM(reached_sl), 0), 2) AS sl_to_mpax_pct,
    ROUND(100.0 * SUM(reached_tco) / NULLIF(SUM(reached_mpax), 0), 2) AS mpax_to_tco_pct,
    ROUND(100.0 * SUM(reached_confirm) / NULLIF(SUM(reached_tco), 0), 2) AS tco_to_confirm_pct,
    ROUND(100.0 * SUM(reached_confirm) / NULLIF(COUNT(*), 0), 2) AS srp_to_confirm_pct
FROM funnel
GROUP BY 1, 2, 3
ORDER BY search_date_ist, src_id, dest_id
