WITH ritual_map AS (
    SELECT *
    FROM values(
        'DestinationID Int32, Place String, ritual1_mins Nullable(UInt16), ritual2_mins Nullable(UInt16)',
        (71756,'Tirupati',180,NULL),
        (70628,'Srisailam',1080,NULL),
        (517,'Bhadrachalam',540,NULL),
        (78796,'Mantralayam',390,NULL),
        (133,'SriKalahasthi',360,1080),
        (247,'Annavaram',360,1080),
        (94877,'Tirumala',180,NULL),
        (196420,'Vemulawada',300,1200),
        (94509,'Ranasthalam',1110,NULL),
        (77167,'Gaya',330,NULL),
        (1136,'Dwarka',1170,NULL),
        (1141,'Somnath',1140,NULL),
        (70030,'Unjha',690,NULL),
        (975,'Ambaji',720,1140),
        (70983,'Okha',1140,NULL),
        (1157,'Virpur(gujarat)',1140,NULL),
        (735,'Katra (jammu and kashmir)',380,1160),
        (1148,'Murdeshwar',1140,NULL),
        (177,'Sringeri',1230,NULL),
        (69526,'Hampi',1140,NULL),
        (275,'Guruvayoor',180,NULL),
        (69475,'Sabarimala',1320,NULL),
        (1001,'Ujjain',240,NULL),
        (84310,'Sehore(M.P)',1140,NULL),
        (403,'Shirdi',270,NULL),
        (77093,'Tuljapur',300,NULL),
        (83409,'Akkalkot',330,NULL),
        (534,'Trimbakeshwar (Maharashtra)',420,NULL),
        (77620,'Bhimashankar',300,NULL),
        (78324,'Shirdi Package',270,NULL),
        (197504,'Khatushyamji',270,NULL),
        (471,'Nathdwara',675,NULL),
        (70346,'Abu Road',360,NULL),
        (663,'Tiruchendur',300,NULL),
        (427,'Kumbakonam',360,NULL),
        (489,'Marthandam',1110,NULL),
        (501,'Palani',340,NULL),
        (68747,'Kanchipuram',1140,NULL),
        (520,'Dwarakatirumula',270,NULL),
        (70429,'Varanasi',1125,NULL),
        (76480,'Ayodhya',1140,NULL),
        (747,'Mathura',330,NULL),
        (84832,'Allahabad',330,NULL),
        (94782,'Vrindavan',660,NULL),
        (802,'Haridwar',1110,NULL),
        (204358,'Badrinath(uttarakhand)',270,NULL),
        (93580,'Mayapur ISKCON',270,NULL),
        (74708,'Tarapith',1110,NULL),
        (194482,'Rampurhat',1110,NULL),
        (74690,'Puri',300,NULL),
        (636,'Dharmavaram',630,750),
        (711,'Mantralaya',480,NULL),
        (94515,'Rahmatabad (Nellore Dist)',600,720),
        (300439,'Yadagirigutta',330,390),
        (134,'Vijayawada',240,NULL),
        (65815,'Ankleshwar',330,360),
        (1459,'Nakhatrana',360,NULL),
        (987,'Palitana',360,NULL),
        (196752,'Pavagadh',300,NULL),
        (1528,'Jawala Ji',1080,NULL),
        (202212,'Manikaran (Himachal Pradesh)',300,NULL),
        (669,'Gadag',330,NULL),
        (142,'Dharmasthala',720,NULL),
        (879,'Chitradurga',360,NULL),
        (1343,'Kukke Subramanya',360,NULL),
        (68705,'Kollur',480,NULL),
        (189,'Sonda',510,NULL),
        (196,'Horanadu',1260,NULL),
        (93189,'Pamba',240,NULL),
        (81826,'Omkareshwar',1080,NULL),
        (298723,'Bageshwar Dham',1140,NULL),
        (1061,'Ganpatipule',330,NULL),
        (750,'Rajapur (Ratnagiri)',180,NULL),
        (1007,'Rajapur (Maharashtra)',180,NULL),
        (77530,'Jejuri',300,NULL),
        (198750,'Thirunallar (Pondicherry)',360,NULL),
        (759,'Amritsar',270,NULL),
        (75103,'Beas',420,NULL),
        (808,'Ajmer',810,NULL),
        (77705,'Mehandipur',360,NULL),
        (1219,'Pushkar',360,NULL),
        (74130,'Salasar',330,NULL),
        (65805,'Ramdevra',300,NULL),
        (66007,'Thanjavur',1050,NULL),
        (960,'Vellore',1080,NULL),
        (466,'Mayiladuthurai',1110,NULL),
        (217,'Velankanni',1050,NULL),
        (496,'Rameswaram',300,NULL),
        (576,'Vaideeswaran Koil',540,720),
        (80438,'Kulasekharapatnam',1050,NULL),
        (1351,'Srirangam',360,NULL),
        (842,'Rishikesh',360,1110),
        (305974,'Kainchi dham',405,1125),
        (200347,'Joshimath',390,1140)
    )
),
base AS (
    SELECT
        b.DestinationID,
        r.Place,
        b.RouteID,
        toHour(addMinutes(b.DateOfIssue, 330)) * 60
            + toMinute(addMinutes(b.DateOfIssue, 330)) AS doi_ist_min,
        r.ritual1_mins,
        r.ritual2_mins
    FROM oms_db.bus_ticket_issued b
    INNER JOIN ritual_map r
        ON b.DestinationID = r.DestinationID
    WHERE b.Year = 2026
      AND b.DateOfIssue >= now() - INTERVAL 30 DAY
)
SELECT
    DestinationID AS destination_id,
    Place AS destination,

    countIf(ritual1_mins IS NOT NULL) AS overall_txn_ritual1_dest,
    countIf(
        ritual1_mins IS NOT NULL
        AND doi_ist_min >= toInt32(assumeNotNull(ritual1_mins)) - 60
        AND doi_ist_min < toInt32(assumeNotNull(ritual1_mins))
    ) AS txn_t_minus_1h_ritual1,
    round(100.0 * txn_t_minus_1h_ritual1 / nullIf(overall_txn_ritual1_dest, 0), 2)
        AS txn_share_t_minus_1h_ritual1_pct,

    uniqExactIf(RouteID, ritual1_mins IS NOT NULL) AS overall_route_ids_ritual1_dest,
    uniqExactIf(
        RouteID,
        ritual1_mins IS NOT NULL
        AND doi_ist_min >= toInt32(assumeNotNull(ritual1_mins)) - 60
        AND doi_ist_min < toInt32(assumeNotNull(ritual1_mins))
    ) AS route_ids_t_minus_1h_ritual1,
    round(100.0 * route_ids_t_minus_1h_ritual1 / nullIf(overall_route_ids_ritual1_dest, 0), 2)
        AS route_id_share_t_minus_1h_ritual1_pct,

    countIf(ritual2_mins IS NOT NULL) AS overall_txn_ritual2_dest,
    countIf(
        ritual2_mins IS NOT NULL
        AND doi_ist_min >= toInt32(assumeNotNull(ritual2_mins)) - 60
        AND doi_ist_min < toInt32(assumeNotNull(ritual2_mins))
    ) AS txn_t_minus_1h_ritual2,
    round(100.0 * txn_t_minus_1h_ritual2 / nullIf(overall_txn_ritual2_dest, 0), 2)
        AS txn_share_t_minus_1h_ritual2_pct,

    uniqExactIf(RouteID, ritual2_mins IS NOT NULL) AS overall_route_ids_ritual2_dest,
    uniqExactIf(
        RouteID,
        ritual2_mins IS NOT NULL
        AND doi_ist_min >= toInt32(assumeNotNull(ritual2_mins)) - 60
        AND doi_ist_min < toInt32(assumeNotNull(ritual2_mins))
    ) AS route_ids_t_minus_1h_ritual2,
    round(100.0 * route_ids_t_minus_1h_ritual2 / nullIf(overall_route_ids_ritual2_dest, 0), 2)
        AS route_id_share_t_minus_1h_ritual2_pct
FROM base
GROUP BY
    DestinationID,
    Place
ORDER BY
    overall_txn_ritual1_dest DESC;
