WITH target_routes AS (
    SELECT *
    FROM (
        VALUES
            (122, 123),  -- Bengaluru -> Chennai
            (123, 122),  -- Chennai -> Bengaluru
            (124, 122),  -- Hyderabad -> Bengaluru
            (122, 124),  -- Bengaluru -> Hyderabad
            (123, 141),  -- Chennai -> Coimbatore
            (141, 123),  -- Coimbatore -> Chennai
            (123, 126),  -- Chennai -> Madurai
            (126, 123),  -- Madurai -> Chennai
            (141, 122),  -- Coimbatore -> Bengaluru
            (122, 141),  -- Bengaluru -> Coimbatore
            (124, 134),  -- Hyderabad -> Vijayawada
            (134, 124),  -- Vijayawada -> Hyderabad
            (123, 71929),  -- Chennai -> Tiruchirapalli
            (123, 602),  -- Chennai -> Salem
            (733, 1439),  -- Delhi -> Lucknow
            (130, 624),  -- Pune -> Nagpur
            (313, 979),  -- Indore -> Bhopal
            (733, 777),  -- Delhi -> Dehradun
            (807, 733),  -- Jaipur (Rajasthan) -> Delhi
            (130, 462),  -- Pune -> Mumbai
            (123, 696),  -- Chennai -> Tirunelveli
            (733, 78027),  -- Delhi -> Gorakhpur (uttar pradesh)
            (733, 807),  -- Delhi -> Jaipur (Rajasthan)
            (462, 130),  -- Mumbai -> Pune
            (124, 248),  -- Hyderabad -> Visakhapatnam
            (130, 309),  -- Pune -> Aurangabad (Maharashtra)
            (123, 690),  -- Chennai -> Nagercoil
            (122, 126),  -- Bengaluru -> Madurai
            (126, 122),  -- Madurai -> Bengaluru
            (122, 95222),  -- Bengaluru -> Mangaluru
            (74820, 69802),  -- Kolkata -> Durgapur (West Bengal)
            (124, 123),  -- Hyderabad -> Chennai
            (123, 458),  -- Chennai -> Hosur
            (130, 124),  -- Pune -> Hyderabad
            (124, 130),  -- Hyderabad -> Pune
            (123, 124),  -- Chennai -> Hyderabad
            (123, 698),  -- Chennai -> Thoothukudi
            (130, 575),  -- Pune -> Latur
            (462, 76079),  -- Mumbai -> Kolhapur(Maharashtra)
            (124, 131),  -- Hyderabad -> Nellore
            (122, 131),  -- Bengaluru -> Nellore
            (122, 216),  -- Bengaluru -> Ernakulam
            (134, 122),  -- Vijayawada -> Bengaluru
            (123, 233),  -- Chennai -> Pondicherry
            (122, 134),  -- Bengaluru -> Vijayawada
            (123, 236),  -- Chennai -> Erode
            (733, 833),  -- Delhi -> Chandigarh
            (124, 462),  -- Hyderabad -> Mumbai
            (122, 233),  -- Bengaluru -> Pondicherry
            (130, 313),  -- Pune -> Indore
            (313, 130),  -- Indore -> Pune
            (124, 135),  -- Hyderabad -> Ongole
            (122, 71929),  -- Bengaluru -> Tiruchirapalli
            (462, 124),  -- Mumbai -> Hyderabad
            (123, 235),  -- Chennai -> Tirupur
            (126, 141),  -- Madurai -> Coimbatore
            (124, 137),  -- Hyderabad -> Guntur (Andhra Pradesh)
            (141, 126),  -- Coimbatore -> Madurai
            (130, 122),  -- Pune -> Bengaluru
            (122, 130),  -- Bengaluru -> Pune
            (122, 602),  -- Bengaluru -> Salem
            (130, 76079),  -- Pune -> Kolhapur(Maharashtra)
            (124, 284),  -- Hyderabad -> Kadapa
            (122, 74661),  -- Bengaluru -> Kozhikode
            (313, 462),  -- Indore -> Mumbai
            (124, 71757),  -- Hyderabad -> Rajahmundry
            (122, 95083),  -- Bengaluru -> Belagavi
            (462, 309),  -- Mumbai -> Aurangabad (Maharashtra)
            (733, 1377),  -- Delhi -> Kanpur (Uttar Pradesh)
            (134, 248),  -- Vijayawada -> Visakhapatnam
            (462, 313),  -- Mumbai -> Indore
            (122, 995),  -- Bengaluru -> Thrissur
            (74820, 74676),  -- Kolkata -> Bhubaneswar
            (70015, 807),  -- Gurugram (Gurgaon) -> Jaipur (Rajasthan)
            (551, 472),  -- Ahmedabad -> Rajkot (Gujarat)
            (807, 70015),  -- Jaipur (Rajasthan) -> Gurugram (Gurgaon)
            (122, 462),  -- Bengaluru -> Mumbai
            (462, 122),  -- Mumbai -> Bengaluru
            (122, 236),  -- Bengaluru -> Erode
            (124, 624),  -- Hyderabad -> Nagpur
            (122, 71425),  -- Bengaluru -> Thiruvananthapuram
            (130, 95083),  -- Pune -> Belagavi
            (141, 696),  -- Coimbatore -> Tirunelveli
            (141, 71929),  -- Coimbatore -> Tiruchirapalli
            (122, 137),  -- Bengaluru -> Guntur (Andhra Pradesh)
            (124, 74676),  -- Hyderabad -> Bhubaneswar
            (462, 624),  -- Mumbai -> Nagpur
            (122, 284),  -- Bengaluru -> Kadapa
            (551, 313),  -- Ahmedabad -> Indore
            (733, 313),  -- Delhi -> Indore
            (313, 733),  -- Indore -> Delhi
            (313, 551),  -- Indore -> Ahmedabad
            (130, 473),  -- Pune -> Surat
            (122, 235),  -- Bengaluru -> Tirupur
            (130, 444),  -- Pune -> Nashik
            (807, 470),  -- Jaipur (Rajasthan) -> Udaipur
            (551, 473),  -- Ahmedabad -> Surat
            (123, 216),  -- Chennai -> Ernakulam
            (141, 690),  -- Coimbatore -> Nagercoil
            (130, 551),  -- Pune -> Ahmedabad
            (122, 690),  -- Bengaluru -> Nagercoil
            (551, 130),  -- Ahmedabad -> Pune
            (134, 123),  -- Vijayawada -> Chennai
            (122, 696),  -- Bengaluru -> Tirunelveli
            (141, 458),  -- Coimbatore -> Hosur
            (141, 698),  -- Coimbatore -> Thoothukudi
            (141, 233),  -- Coimbatore -> Pondicherry
            (122, 125),  -- Bengaluru -> Kurnool
            (124, 125),  -- Hyderabad -> Kurnool
            (807, 1439),  -- Jaipur (Rajasthan) -> Lucknow
            (551, 470),  -- Ahmedabad -> Udaipur
            (122, 135),  -- Bengaluru -> Ongole
            (733, 737),  -- Delhi -> Jalandhar
            (733, 736),  -- Delhi -> Ludhiana
            (123, 134),  -- Chennai -> Vijayawada
            (122, 248),  -- Bengaluru -> Visakhapatnam
            (551, 462),  -- Ahmedabad -> Mumbai
            (122, 74676),  -- Bengaluru -> Bhubaneswar
            (733, 551),  -- Delhi -> Ahmedabad
            (551, 1003),  -- Ahmedabad -> Vadodara
            (462, 551),  -- Mumbai -> Ahmedabad
            (70015, 1439),  -- Gurugram (Gurgaon) -> Lucknow
            (123, 71425),  -- Chennai -> Thiruvananthapuram
            (313, 70024),  -- Indore -> Jabalpur
            (313, 624),  -- Indore -> Nagpur
            (551, 733),  -- Ahmedabad -> Delhi
            (141, 216),  -- Coimbatore -> Ernakulam
            (807, 551),  -- Jaipur (Rajasthan) -> Ahmedabad
            (733, 1290),  -- Delhi -> Agra
            (551, 807),  -- Ahmedabad -> Jaipur (Rajasthan)
            (462, 95083),  -- Mumbai -> Belagavi
            (807, 313),  -- Jaipur (Rajasthan) -> Indore
            (733, 74699),  -- Delhi -> Patna (Bihar)
            (807, 1169),  -- Jaipur (Rajasthan) -> Jodhpur
            (759, 833),  -- Amritsar -> Chandigarh
            (759, 733),  -- Amritsar -> Delhi
            (76480, 733),  -- Ayodhya -> Delhi
            (122, 210),  -- Bengaluru -> Goa
            (122, 558),  -- Bengaluru -> Kannur (Kerala)
            (122, 254),  -- Bengaluru -> Ooty
            (122, 1013),  -- Bengaluru -> Palakkad
            (122, 66007),  -- Bengaluru -> Thanjavur
            (122, 71756),  -- Bengaluru -> Tirupati
            (122, 293),  -- Bengaluru -> Tiruvannamalai
            (122, 154),  -- Bengaluru -> Udupi
            (122, 960),  -- Bengaluru -> Vellore
            (122, 86882),  -- Bengaluru -> 86882
            (517, 124),  -- Bhadrachalam -> Hyderabad
            (827, 807),  -- Bikaner -> Jaipur (Rajasthan)
            (833, 759),  -- Chandigarh -> Amritsar
            (833, 734),  -- Chandigarh -> Jammu (j and k)
            (123, 231),  -- Chennai -> Chidambaram
            (123, 427),  -- Chennai -> Kumbakonam
            (123, 489),  -- Chennai -> Marthandam
            (123, 466),  -- Chennai -> Mayiladuthurai
            (123, 501),  -- Chennai -> Palani
            (123, 66007),  -- Chennai -> Thanjavur
            (123, 663),  -- Chennai -> Tiruchendur
            (123, 71756),  -- Chennai -> Tirupati
            (123, 293),  -- Chennai -> Tiruvannamalai
            (231, 123),  -- Chidambaram -> Chennai
            (141, 663),  -- Coimbatore -> Tiruchendur
            (733, 759),  -- Delhi -> Amritsar
            (733, 76480),  -- Delhi -> Ayodhya
            (733, 1514),  -- Delhi -> Haldwani
            (733, 802),  -- Delhi -> Haridwar
            (733, 734),  -- Delhi -> Jammu (j and k)
            (733, 197688),  -- Delhi -> Kasol
            (733, 197504),  -- Delhi -> KHATTUSHYAMJI DHAM Bus Teminal
            (733, 757),  -- Delhi -> Manali
            (733, 771),  -- Delhi -> Nainital
            (733, 309423),  -- Delhi -> 309423
            (733, 842),  -- Delhi -> Rishikesh
            (733, 1285),  -- Delhi -> Shimla
            (733, 1001),  -- Delhi -> Ujjain
            (733, 70429),  -- Delhi -> Varanasi
            (65768, 733),  -- Dharamshala (Himachal Pradesh) -> Delhi
            (74706, 74820),  -- Digha -> Kolkata
            (210, 122),  -- Goa -> Bengaluru
            (210, 462),  -- Goa -> Mumbai
            (210, 130),  -- Goa -> Pune
            (71958, 313),  -- Gwalior -> Indore
            (1514, 733),  -- Haldwani -> Delhi
            (802, 733),  -- Haridwar -> Delhi
            (124, 517),  -- Hyderabad -> Bhadrachalam
            (124, 71756),  -- Hyderabad -> Tirupati
            (313, 71958),  -- Indore -> Gwalior
            (313, 1001),  -- Indore -> Ujjain
            (807, 827),  -- Jaipur (Rajasthan) -> Bikaner
            (734, 833),  -- Jammu (j and k) -> Chandigarh
            (734, 733),  -- Jammu (j and k) -> Delhi
            (558, 122),  -- Kannur (Kerala) -> Bengaluru
            (197688, 733),  -- Kasol -> Delhi
            (735, 733),  -- Katra (jammu and kashmir) -> Delhi
            (197504, 733),  -- KHATTUSHYAMJI DHAM Bus Teminal -> Delhi
            (74820, 74706),  -- Kolkata -> Digha
            (74820, 74694),  -- Kolkata -> Siliguri
            (427, 123),  -- Kumbakonam -> Chennai
            (757, 733),  -- Manali -> Delhi
            (82467, 74820),  -- Mandarmani -> Kolkata
            (489, 123),  -- Marthandam -> Chennai
            (466, 123),  -- Mayiladuthurai -> Chennai
            (462, 210),  -- Mumbai -> Goa
            (624, 361),  -- Nagpur -> Nanded
            (361, 624),  -- Nanded -> Nagpur
            (361, 130),  -- Nanded -> Pune
            (1013, 122),  -- Palakkad -> Bengaluru
            (501, 123),  -- Palani -> Chennai
            (309423, 733),  -- 309423 -> Delhi
            (130, 210),  -- Pune -> Goa
            (130, 361),  -- Pune -> Nanded
            (130, 750),  -- Pune -> Ratnagiri (Maharashtra)
            (842, 733),  -- Rishikesh -> Delhi
            (1285, 733),  -- Shimla -> Delhi
            (74694, 74820),  -- Siliguri -> Kolkata
            (66007, 122),  -- Thanjavur -> Bengaluru
            (66007, 123),  -- Thanjavur -> Chennai
            (663, 123),  -- Tiruchendur -> Chennai
            (71756, 122),  -- Tirupati -> Bengaluru
            (71756, 123),  -- Tirupati -> Chennai
            (71756, 124),  -- Tirupati -> Hyderabad
            (71756, 134),  -- Tirupati -> Vijayawada
            (293, 122),  -- Tiruvannamalai -> Bengaluru
            (154, 122),  -- Udupi -> Bengaluru
            (1001, 979),  -- Ujjain -> Bhopal
            (1001, 733),  -- Ujjain -> Delhi
            (70429, 733),  -- Varanasi -> Delhi
            (960, 122),  -- Vellore -> Bengaluru
            (86882, 122),  -- 86882 -> Bengaluru
            (134, 71756)  -- Vijayawada -> Tirupati
    ) AS t(source_location_id, destination_location_id)
),
target_operators AS (
    SELECT *
    FROM (
        VALUES
            (31790),
            (33727),
            (34184),
            (22022),
            (22958),
            (34683),
            (29097),
            (36671),
            (29318),
            (19972),
            (22330),
            (25765),
            (21796),
            (33412),
            (26785),
            (34757),
            (33317),
            (30713),
            (31496),
            (16663),
            (30333),
            (8905),
            (30101),
            (16359),
            (15821),
            (36076),
            (24363),
            (23510),
            (30188),
            (31498),
            (29576),
            (30149),
            (28232),
            (35560),
            (10188),
            (34460),
            (26320),
            (8515),
            (28088),
            (37054),
            (23392),
            (32300),
            (33079),
            (18585),
            (31017),
            (31833),
            (23175),
            (34700),
            (20175),
            (30712),
            (9964),
            (18955),
            (15721),
            (31084),
            (35695),
            (17210),
            (26319),
            (15536),
            (31235),
            (19870),
            (36382),
            (26643),
            (27871),
            (34719),
            (26502),
            (27427),
            (31249),
            (34893),
            (31285),
            (16779),
            (25945),
            (25087),
            (23451),
            (16552),
            (15409),
            (30574),
            (17283),
            (35918),
            (18878),
            (4093),
            (18334),
            (9206),
            (16496),
            (17060),
            (20544),
            (20660),
            (35497),
            (24519),
            (7251),
            (30831),
            (4153),
            (33089),
            (10105),
            (31035),
            (8482),
            (10933),
            (21148),
            (18794),
            (32260),
            (18689),
            (19368),
            (31779),
            (30253),
            (16565),
            (36779),
            (22686),
            (30841),
            (27619),
            (31782),
            (28034),
            (10878),
            (25611),
            (32224),
            (35407),
            (33697),
            (9694),
            (35550),
            (4484),
            (32129),
            (24511),
            (33340),
            (3620),
            (3827),
            (15931),
            (10654),
            (23154),
            (30737),
            (15625),
            (31971),
            (34838),
            (30235),
            (34611),
            (34760),
            (20207),
            (5368),
            (28031),
            (15929),
            (10039),
            (11210),
            (16410),
            (36824),
            (29979),
            (35369),
            (34967),
            (34157),
            (30642),
            (31186),
            (33019),
            (25044),
            (27853),
            (28148),
            (29421),
            (19098),
            (20518),
            (33418),
            (33168),
            (17629),
            (25456),
            (28110),
            (23968),
            (24006),
            (20277),
            (35276),
            (25475),
            (23867),
            (36562),
            (30412),
            (30807),
            (34092),
            (30214),
            (36649),
            (18925),
            (28091),
            (17951),
            (29192),
            (32148),
            (18979),
            (17556),
            (33299),
            (30622),
            (31517),
            (34379),
            (20134),
            (33429),
            (30407),
            (31923),
            (33018),
            (33071),
            (35666),
            (34655),
            (31524),
            (22677),
            (16856),
            (19980),
            (15850),
            (19351),
            (29927),
            (5269),
            (17342),
            (18339),
            (27623),
            (27906),
            (23492),
            (32436),
            (37012),
            (25640),
            (23947),
            (26471),
            (27425),
            (19258),
            (33444),
            (32157),
            (20054),
            (30725),
            (31522),
            (36641),
            (18984),
            (18956),
            (19648),
            (30158),
            (31815),
            (35068),
            (29534),
            (35635),
            (31023),
            (33302),
            (34927),
            (36425),
            (20575),
            (34553),
            (31021),
            (29484),
            (36112),
            (33243),
            (9771),
            (19671),
            (25491),
            (9138),
            (31465),
            (21793),
            (20074),
            (32072),
            (30183),
            (27252),
            (23295),
            (30119),
            (22724),
            (24308),
            (33748),
            (25876),
            (31041),
            (4662),
            (23250),
            (32060),
            (29452),
            (16163),
            (31624),
            (37108),
            (26083),
            (19133),
            (29308),
            (31866),
            (24554),
            (26324),
            (29357),
            (18540),
            (35122),
            (36608),
            (27799),
            (19603),
            (23949),
            (30586),
            (6414),
            (31937),
            (33078),
            (26626),
            (34504),
            (37069),
            (32145),
            (22954),
            (25933),
            (25926),
            (4779),
            (32295),
            (21971),
            (35234),
            (18012),
            (11300),
            (29975),
            (34544),
            (20065),
            (15863),
            (18294),
            (26870),
            (29261),
            (9790),
            (33617),
            (36750),
            (30098),
            (33618),
            (5621),
            (30171),
            (16547),
            (22717),
            (27299),
            (34824),
            (32082),
            (29637),
            (4251),
            (33789),
            (17633),
            (10705),
            (31489),
            (20257),
            (27838),
            (25867),
            (8747),
            (17938),
            (16733),
            (35198),
            (29555),
            (25073),
            (18312),
            (24470),
            (20353),
            (20015),
            (22314),
            (17031),
            (22714),
            (31898),
            (31510),
            (31333),
            (32096),
            (32456),
            (19571),
            (2472),
            (27662),
            (20011),
            (36857),
            (34791),
            (21342),
            (20310),
            (8336),
            (26849),
            (31457),
            (34505),
            (29526),
            (6087),
            (17707),
            (34776),
            (35387),
            (26413),
            (21123),
            (17657),
            (21734),
            (16982),
            (4861),
            (11046),
            (32405),
            (29288),
            (24389),
            (22758),
            (35639),
            (33620),
            (30745),
            (17934),
            (31568),
            (29208),
            (31967),
            (34793),
            (18973),
            (10342),
            (21569),
            (22836),
            (30614),
            (31961),
            (29693),
            (22156),
            (35269),
            (21249),
            (22557),
            (32017),
            (11216),
            (35621),
            (16797),
            (33410),
            (33277),
            (20393),
            (30513),
            (29023),
            (27136),
            (25286),
            (35980),
            (36337),
            (19695),
            (23264),
            (23213),
            (28040),
            (23873),
            (30054)
    ) AS t(operator_id)
),
svoc_users AS (
    SELECT DISTINCT
        TRY_CAST(rb_userid AS BIGINT) AS rb_user_id,
        TRY_CAST(age AS INTEGER) AS age
    FROM svoc.svoc_booker
    WHERE rb_userid IS NOT NULL
      AND TRY_CAST(age AS INTEGER) <= 23
),

/* Funnel window: last 30 days IST (UTC = IST - 5:30) */
params AS (
    SELECT
        CAST(CURRENT_DATE - INTERVAL '30' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
        CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),

srp_deduped AS (
    SELECT DISTINCT
        s.mri_session_id,
        s.route_id,
        s.src_id,
        s.dest_id,
        s.operator_id
    FROM user_interaction.search_route_details s
    CROSS JOIN params p
    INNER JOIN target_routes r
        ON s.src_id = r.source_location_id
       AND s.dest_id = r.destination_location_id
    INNER JOIN target_operators o
        ON s.operator_id = o.operator_id
    INNER JOIN svoc_users u
        ON s.rb_user_id = u.rb_user_id
    WHERE s.__time >= p.window_start
      AND s.__time < p.window_end
      AND s.country = 'IND'
      AND s.rb_user_id > 0
),

sl_deduped AS (
    SELECT
        sl.mri_session_id,
        sl.route_id,
        sl.op_id AS operator_id
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN params p
    WHERE sl.__time >= p.window_start
      AND sl.__time < p.window_end
      AND sl.country = 'IND'
    GROUP BY 1, 2, 3
),

mpax_deduped AS (
    SELECT
        c.mri_session_id,
        c.route_id,
        c.operator_id
    FROM user_interaction.cust_info_details c
    CROSS JOIN params p
    WHERE c.__time >= p.window_start
      AND c.__time < p.window_end
      AND c.country = 'IND'
    GROUP BY 1, 2, 3
),

orderinfo_deduped AS (
    SELECT
        oi.mri_session_id,
        oi.route_id,
        oi.operator_id
    FROM user_interaction.order_info_details oi
    CROSS JOIN params p
    WHERE oi.__time >= p.window_start
      AND oi.__time < p.window_end
      AND oi.country = 'IND'
    GROUP BY 1, 2, 3
),

confirm_deduped AS (
    SELECT
        conf.mri_session_id,
        conf.route_id,
        conf.operator_id,
        COUNT(DISTINCT conf.tin) AS tin_count
    FROM user_interaction.confirm_order_details conf
    CROSS JOIN params p
    WHERE conf.__time >= p.window_start
      AND conf.__time < p.window_end
      AND conf.country = 'IND'
      AND conf.status = 200
      AND conf.tin IS NOT NULL
      AND conf.tin NOT IN ('', 'null')
    GROUP BY 1, 2, 3
)

SELECT
    srp.src_id,
    srp.dest_id,
    srp.operator_id,
    COUNT(DISTINCT srp.mri_session_id) AS srpload,
    COUNT(DISTINCT sl.mri_session_id) AS slland,
    COUNT(DISTINCT pax.mri_session_id) AS custinfo,
    COUNT(DISTINCT oi.mri_session_id) AS payland,
    COUNT(DISTINCT conf.mri_session_id) AS confirm,
    COALESCE(SUM(conf.tin_count), 0) AS tin,
    CAST(COUNT(DISTINCT conf.mri_session_id) AS DOUBLE)
        / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0) AS cr_session,
    CAST(COALESCE(SUM(conf.tin_count), 0) AS DOUBLE)
        / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0) AS cr_tin
FROM srp_deduped srp
LEFT JOIN sl_deduped sl
    ON srp.mri_session_id = sl.mri_session_id
   AND srp.route_id = sl.route_id
   AND srp.operator_id = sl.operator_id
LEFT JOIN mpax_deduped pax
    ON srp.mri_session_id = pax.mri_session_id
   AND srp.route_id = pax.route_id
   AND srp.operator_id = pax.operator_id
LEFT JOIN orderinfo_deduped oi
    ON srp.mri_session_id = oi.mri_session_id
   AND srp.route_id = oi.route_id
   AND srp.operator_id = oi.operator_id
LEFT JOIN confirm_deduped conf
    ON srp.mri_session_id = conf.mri_session_id
   AND srp.route_id = conf.route_id
   AND srp.operator_id = conf.operator_id
GROUP BY
    srp.src_id,
    srp.dest_id,
    srp.operator_id
ORDER BY
    cr_session DESC,
    srpload DESC;
