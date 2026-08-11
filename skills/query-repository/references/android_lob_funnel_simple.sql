-- =============================================================================
-- With LOB - session count per step by DBD, Tier, User_type, DRFM
-- Steps 8-10: Of confirmed TINs -> Offer Attached / No Offer Attached / Failure
-- Engine: Trino / Presto
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-05 18:30:00' AS t_start,
        TIMESTAMP '2026-06-06 18:30:00' AS t_end
),

android_sessions AS (
    SELECT u.mri_session_id
    FROM user_interaction.ui_ux_events u
    CROSS JOIN params p
    WHERE u.__time >= p.t_start
      AND u.__time <  p.t_end
      AND u.mri_session_id IS NOT NULL
      AND u.header_bu = 'BUS'
      AND u.selected_country = 'India'
    GROUP BY 1
    HAVING min_by(COALESCE(NULLIF(TRIM(u.event_src), ''), 'UNKNOWN'), u.__time) = 'Android'
),

offer_sessions AS (
    SELECT DISTINCT u.mri_session_id
    FROM user_interaction.ui_ux_events u
    CROSS JOIN params p
    WHERE u.__time >= p.t_start
      AND u.__time <  p.t_end
      AND u.mri_session_id IN (SELECT mri_session_id FROM android_sessions)
      AND u.event_group = 'offer_click_event'
      AND u.event_name = 'lob tile displayed'
      AND u.header_bu = 'BUS'
      AND u.selected_country = 'India'
      AND u.event_src = 'Android'
),
city_tier AS (
    SELECT tier, src_id
    FROM (VALUES
        ('Tier 1', 551),
        ('Tier 1', 76397),
        ('Tier 1', 122),
        ('Tier 1', 1304),
        ('Tier 1', 123),
        ('Tier 1', 141),
        ('Tier 1', 733),
        ('Tier 1', 94113),
        ('Tier 1', 82100),
        ('Tier 1', 70015),
        ('Tier 1', 201126),
        ('Tier 1', 124),
        ('Tier 1', 71145),
        ('Tier 1', 313),
        ('Tier 1', 807),
        ('Tier 1', 74820),
        ('Tier 1', 201665),
        ('Tier 1', 126),
        ('Tier 1', 462),
        ('Tier 1', 70633),
        ('Tier 1', 1429),
        ('Tier 1', 130),
        ('Tier 1', 95174),
        ('Tier 1', 215450),
        ('Tier 1', 933),
        ('Tier 1', 1339),
        ('Tier 1', 134),
        ('Tier 2', 1290),
        ('Tier 2', 309),
        ('Tier 2', 95083),
        ('Tier 2', 979),
        ('Tier 2', 74676),
        ('Tier 2', 833),
        ('Tier 2', 777),
        ('Tier 2', 69802),
        ('Tier 2', 216),
        ('Tier 2', 236),
        ('Tier 2', 78027),
        ('Tier 2', 137),
        ('Tier 2', 74701),
        ('Tier 2', 197696),
        ('Tier 2', 458),
        ('Tier 2', 70024),
        ('Tier 2', 737),
        ('Tier 2', 76451),
        ('Tier 2', 1169),
        ('Tier 2', 284),
        ('Tier 2', 1377),
        ('Tier 2', 76079),
        ('Tier 2', 1443),
        ('Tier 2', 74661),
        ('Tier 2', 125),
        ('Tier 2', 575),
        ('Tier 2', 1439),
        ('Tier 2', 736),
        ('Tier 2', 95222),
        ('Tier 2', 129),
        ('Tier 2', 690),
        ('Tier 2', 624),
        ('Tier 2', 444),
        ('Tier 2', 131),
        ('Tier 2', 135),
        ('Tier 2', 74699),
        ('Tier 2', 233),
        ('Tier 2', 70014),
        ('Tier 2', 71757),
        ('Tier 2', 472),
        ('Tier 2', 76431),
        ('Tier 2', 602),
        ('Tier 2', 473),
        ('Tier 2', 71425),
        ('Tier 2', 698),
        ('Tier 2', 995),
        ('Tier 2', 71929),
        ('Tier 2', 696),
        ('Tier 2', 235),
        ('Tier 2', 470),
        ('Tier 2', 1003),
        ('Tier 2', 248),
        ('Pilgrim', 70346),
        ('Pilgrim', 808),
        ('Pilgrim', 83409),
        ('Pilgrim', 216354),
        ('Pilgrim', 1585),
        ('Pilgrim', 217362),
        ('Pilgrim', 975),
        ('Pilgrim', 759),
        ('Pilgrim', 216346),
        ('Pilgrim', 65815),
        ('Pilgrim', 247),
        ('Pilgrim', 307614),
        ('Pilgrim', 289873),
        ('Pilgrim', 76480),
        ('Pilgrim', 204358),
        ('Pilgrim', 298723),
        ('Pilgrim', 82558),
        ('Pilgrim', 75103),
        ('Pilgrim', 517),
        ('Pilgrim', 265316),
        ('Pilgrim', 231),
        ('Pilgrim', 1529),
        ('Pilgrim', 879),
        ('Pilgrim', 217335),
        ('Pilgrim', 1242),
        ('Pilgrim', 71642),
        ('Pilgrim', 93968),
        ('Pilgrim', 74124),
        ('Pilgrim', 142),
        ('Pilgrim', 636),
        ('Pilgrim', 1136),
        ('Pilgrim', 520),
        ('Pilgrim', 669),
        ('Pilgrim', 1061),
        ('Pilgrim', 77167),
        ('Pilgrim', 275),
        ('Pilgrim', 69526),
        ('Pilgrim', 802),
        ('Pilgrim', 196),
        ('Pilgrim', 1528),
        ('Pilgrim', 77530),
        ('Pilgrim', 200347),
        ('Pilgrim', 305974),
        ('Pilgrim', 68747),
        ('Pilgrim', 735),
        ('Pilgrim', 84848),
        ('Pilgrim', 197504),
        ('Pilgrim', 216551),
        ('Pilgrim', 68705),
        ('Pilgrim', 1343),
        ('Pilgrim', 80438),
        ('Pilgrim', 427),
        ('Pilgrim', 77687),
        ('Pilgrim', 73533),
        ('Pilgrim', 196096),
        ('Pilgrim', 202212),
        ('Pilgrim', 711),
        ('Pilgrim', 78796),
        ('Pilgrim', 489),
        ('Pilgrim', 747),
        ('Pilgrim', 93580),
        ('Pilgrim', 466),
        ('Pilgrim', 77705),
        ('Pilgrim', 68871),
        ('Pilgrim', 1148),
        ('Pilgrim', 1459),
        ('Pilgrim', 361),
        ('Pilgrim', 471),
        ('Pilgrim', 70983),
        ('Pilgrim', 81826),
        ('Pilgrim', 501),
        ('Pilgrim', 987),
        ('Pilgrim', 93189),
        ('Pilgrim', 76187),
        ('Pilgrim', 196752),
        ('Pilgrim', 84832),
        ('Pilgrim', 74690),
        ('Pilgrim', 1219),
        ('Pilgrim', 94515),
        ('Pilgrim', 1007),
        ('Pilgrim', 65805),
        ('Pilgrim', 496),
        ('Pilgrim', 194482),
        ('Pilgrim', 94509),
        ('Pilgrim', 198868),
        ('Pilgrim', 842),
        ('Pilgrim', 69475),
        ('Pilgrim', 74130),
        ('Pilgrim', 215191),
        ('Pilgrim', 84310),
        ('Pilgrim', 1496),
        ('Pilgrim', 403),
        ('Pilgrim', 1141),
        ('Pilgrim', 189),
        ('Pilgrim', 133),
        ('Pilgrim', 177),
        ('Pilgrim', 1351),
        ('Pilgrim', 70628),
        ('Pilgrim', 74708),
        ('Pilgrim', 66007),
        ('Pilgrim', 198750),
        ('Pilgrim', 663),
        ('Pilgrim', 94877),
        ('Pilgrim', 71756),
        ('Pilgrim', 1128),
        ('Pilgrim', 293),
        ('Pilgrim', 534),
        ('Pilgrim', 77093),
        ('Pilgrim', 154),
        ('Pilgrim', 1001),
        ('Pilgrim', 70030),
        ('Pilgrim', 576),
        ('Pilgrim', 70429),
        ('Pilgrim', 217),
        ('Pilgrim', 960),
        ('Pilgrim', 196420),
        ('Pilgrim', 94782),
        ('Pilgrim', 300439),
        ('Leisure', 94200),
        ('Leisure', 69774),
        ('Leisure', 938),
        ('Leisure', 92453),
        ('Leisure', 827),
        ('Leisure', 195703),
        ('Leisure', 201669),
        ('Leisure', 81723),
        ('Leisure', 71696),
        ('Leisure', 93333),
        ('Leisure', 73527),
        ('Leisure', 1185),
        ('Leisure', 215824),
        ('Leisure', 75078),
        ('Leisure', 1419),
        ('Leisure', 1440),
        ('Leisure', 199106),
        ('Leisure', 65768),
        ('Leisure', 74706),
        ('Leisure', 1120),
        ('Leisure', 72506),
        ('Leisure', 74709),
        ('Leisure', 86958),
        ('Leisure', 210),
        ('Leisure', 197221),
        ('Leisure', 187),
        ('Leisure', 220192),
        ('Leisure', 1021),
        ('Leisure', 71958),
        ('Leisure', 1514),
        ('Leisure', 791),
        ('Leisure', 1171),
        ('Leisure', 734),
        ('Leisure', 298546),
        ('Leisure', 88286),
        ('Leisure', 606),
        ('Leisure', 558),
        ('Leisure', 68738),
        ('Leisure', 197688),
        ('Leisure', 77726),
        ('Leisure', 1603),
        ('Leisure', 90895),
        ('Leisure', 79819),
        ('Leisure', 227),
        ('Leisure', 212),
        ('Leisure', 197681),
        ('Leisure', 756),
        ('Leisure', 95184),
        ('Leisure', 722),
        ('Leisure', 74132),
        ('Leisure', 1244),
        ('Leisure', 445),
        ('Leisure', 1049),
        ('Leisure', 757),
        ('Leisure', 82467),
        ('Leisure', 1422),
        ('Leisure', 206),
        ('Leisure', 65769),
        ('Leisure', 304429),
        ('Leisure', 983),
        ('Leisure', 286),
        ('Leisure', 773),
        ('Leisure', 771),
        ('Leisure', 254),
        ('Leisure', 216190),
        ('Leisure', 1013),
        ('Leisure', 82554),
        ('Leisure', 260317),
        ('Leisure', 446),
        ('Leisure', 205),
        ('Leisure', 81930),
        ('Leisure', 215221),
        ('Leisure', 750),
        ('Leisure', 204216),
        ('Leisure', 201003),
        ('Leisure', 65954),
        ('Leisure', 93115),
        ('Leisure', 92578),
        ('Leisure', 1285),
        ('Leisure', 74694),
        ('Leisure', 204429),
        ('Leisure', 84913),
        ('Leisure', 204362),
        ('Leisure', 198236),
        ('Leisure', 202764),
        ('Leisure', 1045),
        ('Leisure', 289877),
        ('Leisure', 76140),
        ('Leisure', 86882),
        ('Leisure', 71261),
        ('Leisure', 166)
    ) AS t(tier, src_id)
),
session_user_ids AS (
    SELECT DISTINCT rd.rb_user_id AS ums_user_id
    FROM user_interaction.search_route_details rd
    CROSS JOIN params p
    WHERE rd.__time >= p.t_start
      AND rd.__time <  p.t_end
      AND rd.country = 'IND'
      AND rd.rb_user_id > 0
),

drfm_users AS (
    SELECT
        TRY_CAST(d.umsuserid AS BIGINT) AS umsuserid,
        CASE
            WHEN MAX(TRY_CAST(d.discaffinityrfm AS INTEGER)) BETWEEN 0 AND 3 THEN 'Low'
            WHEN MAX(TRY_CAST(d.discaffinityrfm AS INTEGER)) BETWEEN 4 AND 10 THEN 'Middle'
            WHEN MAX(TRY_CAST(d.discaffinityrfm AS INTEGER)) BETWEEN 11 AND 15 THEN 'High'
            ELSE 'Unknown'
        END AS drfm_cut
    FROM svoc.cltv_data d
    INNER JOIN session_user_ids u
        ON TRY_CAST(d.umsuserid AS BIGINT) = u.ums_user_id
    GROUP BY 1
),

session_attrs AS (
    SELECT
        base.mri_session_id,
        base.dbd,
        base.tier,
        base.user_type,
        COALESCE(d.drfm_cut, 'Unknown') AS drfm_cut
    FROM (
        SELECT
            rd.mri_session_id,
            min_by(
                CASE
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 0 THEN 'DBD 0'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 1 THEN 'DBD 1'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 2 THEN 'DBD 2'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 3 THEN 'DBD 3'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 4 THEN 'DBD 4'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 5 THEN 'DBD 5'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) > 5 THEN 'DBD 5+'
                    ELSE 'Unknown'
                END,
                rd.__time
            ) AS dbd,
            min_by(COALESCE(ct.tier, 'Other'), rd.__time) AS tier,
            min_by(
                CASE UPPER(TRIM(COALESCE(rd.user_type, '')))
                    WHEN 'NEW' THEN 'New'
                    WHEN 'RETURNING' THEN 'Returning'
                    WHEN 'RETURN' THEN 'Returning'
                    WHEN 'GUEST' THEN 'Guest'
                    ELSE 'Unknown'
                END,
                rd.__time
            ) AS user_type,
            min_by(rd.rb_user_id, rd.__time) AS ums_user_id
        FROM user_interaction.search_route_details rd
        CROSS JOIN params p
        LEFT JOIN city_tier ct
            ON TRY_CAST(rd.src_id AS BIGINT) = ct.src_id
        WHERE rd.__time >= p.t_start
          AND rd.__time <  p.t_end
          AND rd.mri_session_id IS NOT NULL
          AND rd.country = 'IND'
          AND rd.event_type = 'Search-Routes'
          AND rd.status < 400
          AND rd.rb_user_id > 0
        GROUP BY 1
    ) base
    LEFT JOIN drfm_users d
        ON base.ums_user_id = d.umsuserid
),

confirmed_tin_sessions AS (
    SELECT DISTINCT cf.mri_session_id
    FROM user_interaction.confirm_order_details cf
    CROSS JOIN params p
    WHERE cf.__time >= p.t_start
      AND cf.__time <  p.t_end
      AND cf.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
      AND cf.country = 'IND'
      AND cf.error_code = 'CONFIRMED'
      AND cf.status_str = 'SUCCESS'
      AND NULLIF(TRIM(cf.tin), '') IS NOT NULL
      AND LOWER(TRIM(cf.tin)) <> 'null'
),

-- One row per confirmed TIN: classify offer_status
tin_offer_cut AS (
    SELECT
        cf.mri_session_id,
        CASE
            WHEN BOOL_OR(oi.offer_status = 200) THEN 'Offer Attached'
            WHEN BOOL_AND(
                oi.mri_session_id IS NULL
                OR oi.offer_status IS NULL
                OR NULLIF(TRIM(CAST(oi.offer_status AS VARCHAR)), '') IS NULL
            ) THEN 'No Offer Attached'
            ELSE 'Failure'
        END AS offer_cut
    FROM confirmed_tin_sessions cf
    LEFT JOIN user_interaction.order_info_details oi
        ON cf.mri_session_id = oi.mri_session_id
       AND oi.country = 'IND'
    CROSS JOIN params p
    WHERE oi.mri_session_id IS NULL
       OR (oi.__time >= p.t_start AND oi.__time < p.t_end)
    GROUP BY cf.mri_session_id
)

SELECT
    COALESCE(sa.dbd, 'Unknown') AS dbd,
    COALESCE(sa.tier, 'Other') AS tier,
    COALESCE(sa.user_type, 'Unknown') AS user_type,
    COALESCE(sa.drfm_cut, 'Unknown') AS drfm_cut,
    1 AS step_order,
    'Step 1: Offer Section (LOB)' AS funnel_step,
    COUNT(DISTINCT o.mri_session_id) AS sessions
FROM offer_sessions o
LEFT JOIN session_attrs sa ON o.mri_session_id = sa.mri_session_id
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    2,
    'Step 2: SRP',
    COUNT(DISTINCT sd.mri_session_id)
FROM user_interaction.search_details sd
CROSS JOIN params p
LEFT JOIN session_attrs sa ON sd.mri_session_id = sa.mri_session_id
WHERE sd.__time >= p.t_start
  AND sd.__time <  p.t_end
  AND sd.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
  AND sd.status = 200
  AND sd.country = 'IND'
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    3,
    'Step 3: Seat Layout',
    COUNT(DISTINCT s.mri_session_id)
FROM user_interaction.seat_layout_details s
CROSS JOIN params p
LEFT JOIN session_attrs sa ON s.mri_session_id = sa.mri_session_id
WHERE s.__time >= p.t_start
  AND s.__time <  p.t_end
  AND s.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    4,
    'Step 4: Cust Info',
    COUNT(DISTINCT c.mri_session_id)
FROM user_interaction.cust_info_details c
CROSS JOIN params p
LEFT JOIN session_attrs sa ON c.mri_session_id = sa.mri_session_id
WHERE c.__time >= p.t_start
  AND c.__time <  p.t_end
  AND c.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    5,
    'Step 5: Payload',
    COUNT(DISTINCT co.mri_session_id)
FROM user_interaction.create_order_details co
CROSS JOIN params p
LEFT JOIN session_attrs sa ON co.mri_session_id = sa.mri_session_id
WHERE co.__time >= p.t_start
  AND co.__time <  p.t_end
  AND co.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    6,
    'Step 6: Pay',
    COUNT(DISTINCT mp.mri_session_id)
FROM user_interaction.make_payment_details mp
CROSS JOIN params p
LEFT JOIN session_attrs sa ON mp.mri_session_id = sa.mri_session_id
WHERE mp.__time >= p.t_start
  AND mp.__time <  p.t_end
  AND mp.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    7,
    'Step 7: TIN (Confirmed)',
    COUNT(DISTINCT cf.mri_session_id)
FROM confirmed_tin_sessions cf
LEFT JOIN session_attrs sa ON cf.mri_session_id = sa.mri_session_id
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    8,
    'Step 8: Offer Attached (of Confirmed TINs)',
    COUNT(DISTINCT t.mri_session_id)
FROM tin_offer_cut t
LEFT JOIN session_attrs sa ON t.mri_session_id = sa.mri_session_id
WHERE t.offer_cut = 'Offer Attached'
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    9,
    'Step 9: No Offer Attached (of Confirmed TINs)',
    COUNT(DISTINCT t.mri_session_id)
FROM tin_offer_cut t
LEFT JOIN session_attrs sa ON t.mri_session_id = sa.mri_session_id
WHERE t.offer_cut = 'No Offer Attached'
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    10,
    'Step 10: Offer Failure (of Confirmed TINs)',
    COUNT(DISTINCT t.mri_session_id)
FROM tin_offer_cut t
LEFT JOIN session_attrs sa ON t.mri_session_id = sa.mri_session_id
WHERE t.offer_cut = 'Failure'
GROUP BY 1, 2, 3, 4

ORDER BY step_order, dbd, tier, user_type, drfm_cut;
