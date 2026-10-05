-- =============================================================================
-- Pilgrim Circuits (Sessions Growth % YoY sheet) — OVERALL queries
-- Scope: all sources → listed pilgrim destinations (NO Top-10 SD filter)
-- Window CR: last 14 IST days | IND | MOBILE_APP | Android
-- Window Inv: next 14 DOJ days | Direct = persuasion 584
-- NOTE: Nanded (Hazur Sahib) not in dest mapping — omitted
--
-- Q1–Q4  : OVERALL × cut (DBD / user_type / Long-Short / Intra-Inter)
-- Q1c–Q4c: circuit × cut (optional break)
-- Q5     : inventory dest × DBD
-- Q5b    : inventory FULLY OVERALL × DBD
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q0 | Destination list (scoped circuits from growth sheet)
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
)
SELECT growth_bucket, circuit, dest_id, dest_name, group_label
FROM pilgrim_dest
ORDER BY growth_bucket, circuit, dest_name;

-- -----------------------------------------------------------------------------
-- Q1 | DBD Level | OVERALL
-- Grain: OVERALL (all sources → scoped pilgrim dests) × cut
-- No Top-10 SD filter
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    CASE
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) > 2 THEN 'DBD 2+'
      ELSE 'Other'
    END AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2
),
confirm AS (
  SELECT DISTINCT c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id
GROUP BY 1
ORDER BY 1;

-- -----------------------------------------------------------------------------
-- Q2 | User Type Level | OVERALL
-- Grain: OVERALL (all sources → scoped pilgrim dests) × cut
-- No Top-10 SD filter
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    UPPER(COALESCE(sd.user_type, 'UNKNOWN')) AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2
),
confirm AS (
  SELECT DISTINCT c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id
GROUP BY 1
ORDER BY 1;

-- -----------------------------------------------------------------------------
-- Q3 | Long vs Short | OVERALL
-- Grain: OVERALL (all sources → scoped pilgrim dests) × cut
-- No Top-10 SD filter
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    CASE WHEN sr.src_id IS NOT NULL THEN 'Short' ELSE 'Long' END AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2
),
confirm AS (
  SELECT DISTINCT c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id
GROUP BY 1
ORDER BY 1;

-- -----------------------------------------------------------------------------
-- Q4 | Intra vs Inter | OVERALL
-- Grain: OVERALL (all sources → scoped pilgrim dests) × cut
-- No Top-10 SD filter
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    CASE WHEN src_p.dest_id IS NOT NULL THEN 'Intra' ELSE 'Inter' END AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2
),
confirm AS (
  SELECT DISTINCT c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id
GROUP BY 1
ORDER BY 1;

-- -----------------------------------------------------------------------------
-- Q1c | DBD Level | Circuit
-- Grain: circuit × cut | all SDs into pilgrim dests in that circuit
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    pd.growth_bucket,
    pd.circuit,
    CASE
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, sd.__time)), DATE(sd.doj)) > 2 THEN 'DBD 2+'
      ELSE 'Other'
    END AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT DISTINCT pd.circuit, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.growth_bucket,
  b.circuit,
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id AND b.circuit = c.circuit
GROUP BY 1, 2, 3
ORDER BY b.growth_bucket, b.circuit, b.cut;

-- -----------------------------------------------------------------------------
-- Q2c | User Type Level | Circuit
-- Grain: circuit × cut | all SDs into pilgrim dests in that circuit
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    pd.growth_bucket,
    pd.circuit,
    UPPER(COALESCE(sd.user_type, 'UNKNOWN')) AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT DISTINCT pd.circuit, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.growth_bucket,
  b.circuit,
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id AND b.circuit = c.circuit
GROUP BY 1, 2, 3
ORDER BY b.growth_bucket, b.circuit, b.cut;

-- -----------------------------------------------------------------------------
-- Q3c | Long vs Short | Circuit
-- Grain: circuit × cut | all SDs into pilgrim dests in that circuit
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    pd.growth_bucket,
    pd.circuit,
    CASE WHEN sr.src_id IS NOT NULL THEN 'Short' ELSE 'Long' END AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT DISTINCT pd.circuit, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.growth_bucket,
  b.circuit,
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id AND b.circuit = c.circuit
GROUP BY 1, 2, 3
ORDER BY b.growth_bucket, b.circuit, b.cut;

-- -----------------------------------------------------------------------------
-- Q4c | Intra vs Inter | Circuit
-- Grain: circuit × cut | all SDs into pilgrim dests in that circuit
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id FROM lis.short_route_sds WHERE cohort = '2026'
),
base AS (
  SELECT
    pd.growth_bucket,
    pd.circuit,
    CASE WHEN src_p.dest_id IS NOT NULL THEN 'Intra' ELSE 'Inter' END AS cut,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT DISTINCT pd.circuit, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
)
SELECT
  b.growth_bucket,
  b.circuit,
  b.cut,
  COUNT(DISTINCT b.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id)
    / NULLIF(COUNT(DISTINCT b.mri_session_id), 0), 2) AS cr_pct
FROM base b
LEFT JOIN confirm c ON b.mri_session_id = c.mri_session_id AND b.circuit = c.circuit
GROUP BY 1, 2, 3
ORDER BY b.growth_bucket, b.circuit, b.cut;

-- -----------------------------------------------------------------------------
-- Q5 | Inventory OVERALL × DBD (any source → scoped pilgrim destinations)
-- No Top-10 SD filter
-- Grain: dest_id × dbd  (also use Q5b for fully rolled-up Overall × DBD)
-- Direct = CONTAINS(persuasion_id, '584') on search_route_details
-- Window: next 14 DOJ days
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CURRENT_DATE AS inv_start_d,
    CURRENT_DATE + INTERVAL '14' DAY AS inv_end_d
),
inv_dedup AS (
  SELECT
    pd.circuit,
    pd.growth_bucket,
    pd.dest_id,
    pd.dest_name,
    i.doj,
    i.route_id,
    i.service_id,
    CASE
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) > 2 THEN 'DBD 2+'
    END AS dbd,
    CASE
      WHEN COALESCE(i.is_sleeper, FALSE) AND COALESCE(i.is_seater, FALSE) THEN 'Hybrid'
      WHEN COALESCE(i.is_sleeper, FALSE) AND NOT COALESCE(i.is_seater, FALSE) THEN 'Sleeper'
      WHEN COALESCE(i.is_seater, FALSE) AND NOT COALESCE(i.is_sleeper, FALSE) THEN 'Seater'
    END AS seat_type,
    MAX_BY(i.available_seats, i.date_of_change) AS available_seats,
    MAX_BY(i.total_seats, i.date_of_change) AS total_seats
  FROM inventory.inventory i
  INNER JOIN pilgrim_dest pd ON i.destination_id = pd.dest_id
  CROSS JOIN params p
  WHERE i.country_code = 'IND'
    AND i.bus_tag = 'ENABLED'
    AND i.doj >= p.inv_start_d
    AND i.doj <  p.inv_end_d
    AND (COALESCE(i.is_sleeper, FALSE) OR COALESCE(i.is_seater, FALSE))
  GROUP BY 1,2,3,4,5,6,7,8,9
),
direct_routes AS (
  SELECT DISTINCT CAST(srd.route_id AS BIGINT) AS route_id
  FROM user_interaction.search_route_details srd
  INNER JOIN (SELECT DISTINCT route_id FROM inv_dedup) ir
    ON CAST(srd.route_id AS BIGINT) = ir.route_id
  CROSS JOIN params p
  WHERE srd.__time >= CAST(p.inv_start_d - INTERVAL '7' DAY AS TIMESTAMP)
    AND srd.__time <  CAST(p.inv_end_d AS TIMESTAMP)
    AND srd.country = 'IND'
    AND CONTAINS(srd.persuasion_id, '584')
),
tagged AS (
  SELECT
    d.*,
    CASE WHEN dr.route_id IS NOT NULL THEN 'Direct' ELSE 'Via' END AS route_type
  FROM inv_dedup d
  LEFT JOIN direct_routes dr ON CAST(d.route_id AS BIGINT) = dr.route_id
  WHERE d.dbd IS NOT NULL AND d.seat_type IS NOT NULL
),
txn_routes AS (
  SELECT
    pd.dest_id,
    CASE
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) > 2 THEN 'DBD 2+'
    END AS dbd,
    COUNT(DISTINCT bte.route_id) AS transacting_inventory
  FROM transaction.bus_ticket_events bte
  INNER JOIN pilgrim_dest pd
    ON CAST(bte.destination_location_id AS INTEGER) = pd.dest_id
  CROSS JOIN params p
  WHERE bte.country_code = 'IND'
    AND bte.event_type = 101
    AND CAST(bte.date_of_journey AS DATE) >= p.inv_start_d
    AND CAST(bte.date_of_journey AS DATE) <  p.inv_end_d
    AND bte.time_of_event >= CAST(p.inv_start_d - INTERVAL '60' DAY AS TIMESTAMP)
    AND bte.time_of_event <  CAST(p.inv_end_d AS TIMESTAMP)
    AND bte.route_id IS NOT NULL
  GROUP BY 1, 2
)
SELECT
  tg.growth_bucket,
  tg.circuit,
  tg.dest_id,
  tg.dest_name,
  tg.dbd,
  COUNT(DISTINCT tg.route_id) AS total_inventory,
  COALESCE(MAX(tr.transacting_inventory), 0) AS transacting_inventory,
  COUNT(DISTINCT CASE WHEN tg.available_seats > 0 THEN tg.route_id END) AS available_inventory,
  SUM(tg.total_seats) AS total_seats,
  SUM(tg.available_seats) AS available_seats,
  COUNT(DISTINCT CASE WHEN tg.seat_type = 'Sleeper' THEN tg.route_id END) AS inventory_sleeper,
  COUNT(DISTINCT CASE WHEN tg.seat_type = 'Seater'  THEN tg.route_id END) AS inventory_seater,
  COUNT(DISTINCT CASE WHEN tg.seat_type = 'Hybrid'  THEN tg.route_id END) AS inventory_hybrid,
  COUNT(DISTINCT CASE WHEN tg.route_type = 'Direct' THEN tg.route_id END) AS inventory_direct,
  COUNT(DISTINCT CASE WHEN tg.route_type = 'Via'    THEN tg.route_id END) AS inventory_via
FROM tagged tg
LEFT JOIN txn_routes tr ON tg.dest_id = tr.dest_id AND tg.dbd = tr.dbd
GROUP BY 1,2,3,4,5
ORDER BY tg.growth_bucket, tg.circuit, tg.dest_name, tg.dbd;

-- -----------------------------------------------------------------------------
-- Q5b | Inventory FULLY OVERALL × DBD (all scoped pilgrim dests rolled up)
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT dest_id, dest_name, group_label, circuit, growth_bucket FROM (
    VALUES
      (CAST(70346 AS INTEGER), 'Abu Road', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(808 AS INTEGER), 'Ajmer', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'A_Low', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(216354 AS INTEGER), 'Aland', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(69526 AS INTEGER), 'Hampi', 'A_Low', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(802 AS INTEGER), 'Haridwar', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(196 AS INTEGER), 'Horanadu', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'A_Low', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'A_Low', 'Vaishno Devi & North Shakti Circuit', 'C_Good_2026'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68705 AS INTEGER), 'Kollur', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(747 AS INTEGER), 'Mathura', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'A_Low', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(70983 AS INTEGER), 'Okha', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(74690 AS INTEGER), 'Puri', 'A_Low', 'Puri-Bhubaneswar Circuit', 'C_Good_2026'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'A_Low', 'Ajmer-Pushkar-Nathdwara Circuit', 'A_Low_SRP_2026'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'A_Low', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'A_Low', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(74130 AS INTEGER), 'Salasar', 'A_Low', 'Khatu Shyam-Salasar-Mehandipur Circuit', 'B_Low_JulAug'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(403 AS INTEGER), 'Shirdi', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1141 AS INTEGER), 'Somnath', 'A_Low', 'Dwarka-Somnath Circuit', 'C_Good_2026'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'A_Low', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'A_Low', 'Shirdi-Nashik-Trimbakeshwar Circuit', 'A_Low_SRP_2026'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'A_Low', 'Ujjain-Omkareshwar Circuit', 'C_Good_2026'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'A_Low', 'Kashi-Prayag-Ayodhya Circuit', 'C_Good_2026'),
      (CAST(217 AS INTEGER), 'Velankanni', 'A_Low', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'A_Low', 'Mathura-Vrindavan (Braj) Circuit', 'B_Low_JulAug'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'A_Low', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(759 AS INTEGER), 'Amritsar', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(247 AS INTEGER), 'Annavaram', 'B_High', 'Srisailam-Mantralayam Circuit', 'C_Good_2026'),
      (CAST(75103 AS INTEGER), 'Beas', 'B_High', 'Sikh Heritage Circuit', 'B_Low_JulAug'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'B_High', 'Hampi-Gadag Circuit', 'B_Low_JulAug'),
      (CAST(489 AS INTEGER), 'Marthandam', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(501 AS INTEGER), 'Palani', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'B_High', 'Char Dham & Himalayan Circuit', 'C_Good_2026'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'B_High', 'Kolhapur-Konkan Circuit', 'B_Low_JulAug'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(177 AS INTEGER), 'Sringeri', 'B_High', 'Kollur-Udupi-Dharmasthala Circuit', 'C_Good_2026'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'B_High', 'Rameswaram-Madurai-Kanyakumari Circuit', 'A_Low_SRP_2026'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'B_High', 'Tirupati (Tirumala) Circuit', 'A_Low_SRP_2026'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'B_High', 'Kanchipuram-Chidambaram-Thanjavur Circuit', 'A_Low_SRP_2026'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'B_High', 'Pandharpur-Tuljapur-Akkalkot Circuit', 'B_Low_JulAug')
  ) AS t(dest_id, dest_name, group_label, circuit, growth_bucket)
),
params AS (
  SELECT
    CURRENT_DATE AS inv_start_d,
    CURRENT_DATE + INTERVAL '14' DAY AS inv_end_d
),
inv_dedup AS (
  SELECT
    i.doj,
    i.route_id,
    i.service_id,
    CASE
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(i.doj AS DATE)) > 2 THEN 'DBD 2+'
    END AS dbd,
    CASE
      WHEN COALESCE(i.is_sleeper, FALSE) AND COALESCE(i.is_seater, FALSE) THEN 'Hybrid'
      WHEN COALESCE(i.is_sleeper, FALSE) AND NOT COALESCE(i.is_seater, FALSE) THEN 'Sleeper'
      WHEN COALESCE(i.is_seater, FALSE) AND NOT COALESCE(i.is_sleeper, FALSE) THEN 'Seater'
    END AS seat_type,
    MAX_BY(i.available_seats, i.date_of_change) AS available_seats,
    MAX_BY(i.total_seats, i.date_of_change) AS total_seats
  FROM inventory.inventory i
  INNER JOIN pilgrim_dest pd ON i.destination_id = pd.dest_id
  CROSS JOIN params p
  WHERE i.country_code = 'IND'
    AND i.bus_tag = 'ENABLED'
    AND i.doj >= p.inv_start_d
    AND i.doj <  p.inv_end_d
    AND (COALESCE(i.is_sleeper, FALSE) OR COALESCE(i.is_seater, FALSE))
  GROUP BY 1,2,3,4,5
),
direct_routes AS (
  SELECT DISTINCT CAST(srd.route_id AS BIGINT) AS route_id
  FROM user_interaction.search_route_details srd
  INNER JOIN (SELECT DISTINCT route_id FROM inv_dedup) ir
    ON CAST(srd.route_id AS BIGINT) = ir.route_id
  CROSS JOIN params p
  WHERE srd.__time >= CAST(p.inv_start_d - INTERVAL '7' DAY AS TIMESTAMP)
    AND srd.__time <  CAST(p.inv_end_d AS TIMESTAMP)
    AND srd.country = 'IND'
    AND CONTAINS(srd.persuasion_id, '584')
),
tagged AS (
  SELECT
    d.*,
    CASE WHEN dr.route_id IS NOT NULL THEN 'Direct' ELSE 'Via' END AS route_type
  FROM inv_dedup d
  LEFT JOIN direct_routes dr ON CAST(d.route_id AS BIGINT) = dr.route_id
  WHERE d.dbd IS NOT NULL AND d.seat_type IS NOT NULL
),
txn_routes AS (
  SELECT
    CASE
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', CURRENT_DATE, CAST(bte.date_of_journey AS DATE)) > 2 THEN 'DBD 2+'
    END AS dbd,
    COUNT(DISTINCT bte.route_id) AS transacting_inventory
  FROM transaction.bus_ticket_events bte
  INNER JOIN pilgrim_dest pd
    ON CAST(bte.destination_location_id AS INTEGER) = pd.dest_id
  CROSS JOIN params p
  WHERE bte.country_code = 'IND'
    AND bte.event_type = 101
    AND CAST(bte.date_of_journey AS DATE) >= p.inv_start_d
    AND CAST(bte.date_of_journey AS DATE) <  p.inv_end_d
    AND bte.time_of_event >= CAST(p.inv_start_d - INTERVAL '60' DAY AS TIMESTAMP)
    AND bte.time_of_event <  CAST(p.inv_end_d AS TIMESTAMP)
    AND bte.route_id IS NOT NULL
  GROUP BY 1
)
SELECT
  tg.dbd,
  COUNT(DISTINCT tg.route_id) AS total_inventory,
  COALESCE(MAX(tr.transacting_inventory), 0) AS transacting_inventory,
  COUNT(DISTINCT CASE WHEN tg.available_seats > 0 THEN tg.route_id END) AS available_inventory,
  SUM(tg.total_seats) AS total_seats,
  SUM(tg.available_seats) AS available_seats,
  COUNT(DISTINCT CASE WHEN tg.seat_type = 'Sleeper' THEN tg.route_id END) AS inventory_sleeper,
  COUNT(DISTINCT CASE WHEN tg.seat_type = 'Seater'  THEN tg.route_id END) AS inventory_seater,
  COUNT(DISTINCT CASE WHEN tg.seat_type = 'Hybrid'  THEN tg.route_id END) AS inventory_hybrid,
  COUNT(DISTINCT CASE WHEN tg.route_type = 'Direct' THEN tg.route_id END) AS inventory_direct,
  COUNT(DISTINCT CASE WHEN tg.route_type = 'Via'    THEN tg.route_id END) AS inventory_via
FROM tagged tg
LEFT JOIN txn_routes tr ON tg.dbd = tr.dbd
GROUP BY 1
ORDER BY tg.dbd;
