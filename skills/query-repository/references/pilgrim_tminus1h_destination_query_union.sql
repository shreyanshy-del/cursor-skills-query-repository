WITH ritual_map AS (
    SELECT toInt32(71756) AS DestinationID, 'Tirupati' AS Place, toNullable(toUInt16(180)) AS ritual1_mins, CAST(NULL, 'Nullable(UInt16)') AS ritual2_mins UNION ALL
    SELECT toInt32(70628), 'Srisailam', toNullable(toUInt16(1080)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(517), 'Bhadrachalam', toNullable(toUInt16(540)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(78796), 'Mantralayam', toNullable(toUInt16(390)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(133), 'SriKalahasthi', toNullable(toUInt16(360)), toNullable(toUInt16(1080)) UNION ALL
    SELECT toInt32(247), 'Annavaram', toNullable(toUInt16(360)), toNullable(toUInt16(1080)) UNION ALL
    SELECT toInt32(94877), 'Tirumala', toNullable(toUInt16(180)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(196420), 'Vemulawada', toNullable(toUInt16(300)), toNullable(toUInt16(1200)) UNION ALL
    SELECT toInt32(94509), 'Ranasthalam', toNullable(toUInt16(1110)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(77167), 'Gaya', toNullable(toUInt16(330)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1136), 'Dwarka', toNullable(toUInt16(1170)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1141), 'Somnath', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(70030), 'Unjha', toNullable(toUInt16(690)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(975), 'Ambaji', toNullable(toUInt16(720)), toNullable(toUInt16(1140)) UNION ALL
    SELECT toInt32(70983), 'Okha', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1157), 'Virpur(gujarat)', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(735), 'Katra (jammu and kashmir)', toNullable(toUInt16(380)), toNullable(toUInt16(1160)) UNION ALL
    SELECT toInt32(1148), 'Murdeshwar', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(177), 'Sringeri', toNullable(toUInt16(1230)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(69526), 'Hampi', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(275), 'Guruvayoor', toNullable(toUInt16(180)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(69475), 'Sabarimala', toNullable(toUInt16(1320)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1001), 'Ujjain', toNullable(toUInt16(240)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(84310), 'Sehore(M.P)', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(403), 'Shirdi', toNullable(toUInt16(270)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(77093), 'Tuljapur', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(83409), 'Akkalkot', toNullable(toUInt16(330)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(534), 'Trimbakeshwar (Maharashtra)', toNullable(toUInt16(420)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(77620), 'Bhimashankar', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(78324), 'Shirdi Package', toNullable(toUInt16(270)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(197504), 'Khatushyamji', toNullable(toUInt16(270)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(471), 'Nathdwara', toNullable(toUInt16(675)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(70346), 'Abu Road', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(663), 'Tiruchendur', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(427), 'Kumbakonam', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(489), 'Marthandam', toNullable(toUInt16(1110)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(501), 'Palani', toNullable(toUInt16(340)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(68747), 'Kanchipuram', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(520), 'Dwarakatirumula', toNullable(toUInt16(270)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(70429), 'Varanasi', toNullable(toUInt16(1125)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(76480), 'Ayodhya', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(747), 'Mathura', toNullable(toUInt16(330)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(84832), 'Allahabad', toNullable(toUInt16(330)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(94782), 'Vrindavan', toNullable(toUInt16(660)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(802), 'Haridwar', toNullable(toUInt16(1110)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(204358), 'Badrinath(uttarakhand)', toNullable(toUInt16(270)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(93580), 'Mayapur ISKCON', toNullable(toUInt16(270)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(74708), 'Tarapith', toNullable(toUInt16(1110)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(194482), 'Rampurhat', toNullable(toUInt16(1110)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(74690), 'Puri', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(636), 'Dharmavaram', toNullable(toUInt16(630)), toNullable(toUInt16(750)) UNION ALL
    SELECT toInt32(711), 'Mantralaya', toNullable(toUInt16(480)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(94515), 'Rahmatabad (Nellore Dist)', toNullable(toUInt16(600)), toNullable(toUInt16(720)) UNION ALL
    SELECT toInt32(300439), 'Yadagirigutta', toNullable(toUInt16(330)), toNullable(toUInt16(390)) UNION ALL
    SELECT toInt32(134), 'Vijayawada', toNullable(toUInt16(240)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(65815), 'Ankleshwar', toNullable(toUInt16(330)), toNullable(toUInt16(360)) UNION ALL
    SELECT toInt32(1459), 'Nakhatrana', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(987), 'Palitana', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(196752), 'Pavagadh', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1528), 'Jawala Ji', toNullable(toUInt16(1080)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(202212), 'Manikaran (Himachal Pradesh)', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(669), 'Gadag', toNullable(toUInt16(330)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(142), 'Dharmasthala', toNullable(toUInt16(720)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(879), 'Chitradurga', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1343), 'Kukke Subramanya', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(68705), 'Kollur', toNullable(toUInt16(480)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(189), 'Sonda', toNullable(toUInt16(510)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(196), 'Horanadu', toNullable(toUInt16(1260)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(93189), 'Pamba', toNullable(toUInt16(240)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(81826), 'Omkareshwar', toNullable(toUInt16(1080)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(298723), 'Bageshwar Dham', toNullable(toUInt16(1140)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1061), 'Ganpatipule', toNullable(toUInt16(330)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(750), 'Rajapur (Ratnagiri)', toNullable(toUInt16(180)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1007), 'Rajapur (Maharashtra)', toNullable(toUInt16(180)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(77530), 'Jejuri', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(198750), 'Thirunallar (Pondicherry)', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(759), 'Amritsar', toNullable(toUInt16(270)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(75103), 'Beas', toNullable(toUInt16(420)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(808), 'Ajmer', toNullable(toUInt16(810)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(77705), 'Mehandipur', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1219), 'Pushkar', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(74130), 'Salasar', toNullable(toUInt16(330)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(65805), 'Ramdevra', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(66007), 'Thanjavur', toNullable(toUInt16(1050)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(960), 'Vellore', toNullable(toUInt16(1080)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(466), 'Mayiladuthurai', toNullable(toUInt16(1110)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(217), 'Velankanni', toNullable(toUInt16(1050)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(496), 'Rameswaram', toNullable(toUInt16(300)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(576), 'Vaideeswaran Koil', toNullable(toUInt16(540)), toNullable(toUInt16(720)) UNION ALL
    SELECT toInt32(80438), 'Kulasekharapatnam', toNullable(toUInt16(1050)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(1351), 'Srirangam', toNullable(toUInt16(360)), CAST(NULL, 'Nullable(UInt16)') UNION ALL
    SELECT toInt32(842), 'Rishikesh', toNullable(toUInt16(360)), toNullable(toUInt16(1110)) UNION ALL
    SELECT toInt32(305974), 'Kainchi dham', toNullable(toUInt16(405)), toNullable(toUInt16(1125)) UNION ALL
    SELECT toInt32(200347), 'Joshimath', toNullable(toUInt16(390)), toNullable(toUInt16(1140))
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
