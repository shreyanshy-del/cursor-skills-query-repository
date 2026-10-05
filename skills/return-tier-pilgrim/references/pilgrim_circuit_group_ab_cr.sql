-- Circuit × Group A/B | multi-circuit tagging
-- Rule: dest city is tagged to EVERY circuit where it appears as Destination
--        on any Route in Pilgrim SD to Circuit mapping.xlsx
-- (same city can map to multiple circuits; sessions can double-count across circuits)
-- Window: last 14 IST days | IND | Android
-- Metrics: srp_sessions, confirm_sessions, cr_pct, transactions, transacting_route_ids, seats

WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit'),
      (CAST(975 AS INTEGER), 'Ambaji', 'A_Low', 'Ambaji-Palitana Circuit'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'A_Low', 'Unmapped'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'A_Low', 'Unmapped'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit'),
      (CAST(77167 AS INTEGER), 'Gaya', 'A_Low', 'Gaya Circuit'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'A_Low', 'Guruvayoor-Sabarimala Circuit'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'A_Low', 'Maihar-Amarkantak Circuit'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'A_Low', 'Himachal Shakti & Kangra Valley Circuit'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'A_Low', 'Tarapith-Mayapur Circuit'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit'),
      (CAST(987 AS INTEGER), 'Palitana', 'A_Low', 'Ambaji-Palitana Circuit'),
      (CAST(93189 AS INTEGER), 'Pamba', 'A_Low', 'Guruvayoor-Sabarimala Circuit'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'A_Low', 'Ambaji-Palitana Circuit'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'A_Low', 'Other / Regional Routes'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'A_Low', 'Tarapith-Mayapur Circuit'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'A_Low', 'Guruvayoor-Sabarimala Circuit'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'A_Low', 'Ambaji-Palitana Circuit'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Other / Regional Routes'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'A_Low', 'Tarapith-Mayapur Circuit'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit'),
      (CAST(1242 AS INTEGER), 'Chotila', 'B_High', 'Ambaji-Palitana Circuit'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'B_High', 'Unmapped'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'B_High', 'Himachal Shakti & Kangra Valley Circuit'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'B_High', 'Kurukshetra Circuit'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'B_High', 'Other / Regional Routes'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit'),
      (CAST(70030 AS INTEGER), 'Unjha', 'B_High', 'Ambaji-Palitana Circuit'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'B_High', 'Unmapped')
  ) AS t(dest_id, dest_name, group_label, circuit)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT pd.circuit, pd.group_label, sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT pd.circuit, pd.group_label, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2, 3
),
cr AS (
  SELECT
    s.circuit,
    s.group_label,
    COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
    COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
    ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
      / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
  FROM srp s
  LEFT JOIN confirm c
    ON s.mri_session_id = c.mri_session_id
   AND s.circuit = c.circuit
   AND s.group_label = c.group_label
  GROUP BY 1, 2
),
txns AS (
  SELECT
    pd.circuit,
    pd.group_label,
    COUNT(DISTINCT bte.tin) AS transactions,
    COUNT(DISTINCT bte.route_id) AS transacting_route_ids,
    COALESCE(SUM(bte.seat_count), 0) AS seats
  FROM transaction.bus_ticket_events bte
  INNER JOIN pilgrim_dest pd
    ON CAST(bte.destination_location_id AS INTEGER) = pd.dest_id
  CROSS JOIN params p
  WHERE bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.time_of_event >= p.window_start AND bte.time_of_event < p.window_end
    AND bte.sales_channel = 'RB:MOBILEWEB#droidapp'
    AND bte.route_id IS NOT NULL
  GROUP BY 1, 2
)
SELECT
  COALESCE(cr.circuit, txns.circuit) AS circuit,
  COALESCE(cr.group_label, txns.group_label) AS group_label,
  COALESCE(cr.srp_sessions, 0) AS srp_sessions,
  COALESCE(cr.confirm_sessions, 0) AS confirm_sessions,
  cr.cr_pct,
  COALESCE(txns.transactions, 0) AS transactions,
  COALESCE(txns.transacting_route_ids, 0) AS transacting_route_ids,
  COALESCE(txns.seats, 0) AS seats
FROM cr
FULL OUTER JOIN txns
  ON cr.circuit = txns.circuit AND cr.group_label = txns.group_label
ORDER BY circuit, group_label;
