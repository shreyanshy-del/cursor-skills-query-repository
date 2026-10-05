-- =============================================================================
-- Pilgrim Destination CR — 8 queries (High / Medium / Low Band)
-- Cohort: listed pilgrim dest_ids | Source = Any
-- Window: last 14 IST days | IND | MOBILE_APP | Android
--
-- Intra  = src_id also in pilgrim list (pilgrim → pilgrim)
-- Inter  = src_id NOT in pilgrim list
-- Short/Long via lis.short_route_sds (cohort 2026)
-- CR = confirm sessions / SRP sessions × 100
--
-- Q1–Q4 : grain = pilgrim destination (dest_id) + band
-- Q5–Q8 : grain = Band aggregated (High / Medium / Low)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q1 | Intra vs Inter  |  Pilgrim Destination Level
-- Intra = src also in pilgrim list | Inter = otherwise
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    pd.dest_id,
    pd.dest_name,
    pd.band,
    CASE WHEN src_p.dest_id IS NOT NULL THEN 'Intra' ELSE 'Inter' END AS route_group,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4, 5
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.band,
  s.route_group,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3, 4
ORDER BY s.band, s.dest_name, s.route_group;


-- -----------------------------------------------------------------------------
-- Q2 | User Type  |  Pilgrim Destination Level
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    pd.dest_id,
    pd.dest_name,
    pd.band,
    CASE UPPER(TRIM(COALESCE(sd.user_type, '')))
      WHEN 'NEW' THEN 'New'
      WHEN 'RETURNING' THEN 'Returning'
      WHEN 'RETURN' THEN 'Returning'
      WHEN 'GUEST' THEN 'Guest'
      ELSE 'Unknown'
    END AS user_type,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4, 5
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.band,
  s.user_type,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3, 4
ORDER BY s.band, s.dest_name, s.user_type;


-- -----------------------------------------------------------------------------
-- Q3 | DBD  |  Pilgrim Destination Level
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    pd.dest_id,
    pd.dest_name,
    pd.band,
    CASE
      WHEN sd.doj IS NULL THEN 'Unknown'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 3 THEN 'DBD 3'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 4 THEN 'DBD 4'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 5 THEN 'DBD 5'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) > 5 THEN 'DBD 5+'
      ELSE 'Unknown'
    END AS dbd,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4, 5
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.band,
  s.dbd,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3, 4
ORDER BY s.band, s.dest_name, s.dbd;


-- -----------------------------------------------------------------------------
-- Q4 | Long / Short  |  Pilgrim Destination Level
-- Short = SD present in lis.short_route_sds (cohort 2026)
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id
  FROM lis.short_route_sds
  WHERE cohort = '2026'
),
srp AS (
  SELECT
    pd.dest_id,
    pd.dest_name,
    pd.band,
    CASE WHEN sr.src_id IS NOT NULL THEN 'Short' ELSE 'Long' END AS route_length,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3, 4, 5
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.band,
  s.route_length,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3, 4
ORDER BY s.band, s.dest_name, s.route_length;


-- -----------------------------------------------------------------------------
-- Q5 | Intra vs Inter  |  Band Aggregated (High / Medium / Low)
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    pd.band,
    CASE WHEN src_p.dest_id IS NOT NULL THEN 'Intra' ELSE 'Inter' END AS route_group,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT pd.band, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.band,
  s.route_group,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.band = c.band
GROUP BY 1, 2
ORDER BY CASE s.band WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 ELSE 4 END, s.route_group;


-- -----------------------------------------------------------------------------
-- Q6 | User Type  |  Band Aggregated (High / Medium / Low)
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    pd.band,
    CASE UPPER(TRIM(COALESCE(sd.user_type, '')))
      WHEN 'NEW' THEN 'New'
      WHEN 'RETURNING' THEN 'Returning'
      WHEN 'RETURN' THEN 'Returning'
      WHEN 'GUEST' THEN 'Guest'
      ELSE 'Unknown'
    END AS user_type,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT pd.band, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.band,
  s.user_type,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.band = c.band
GROUP BY 1, 2
ORDER BY CASE s.band WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 ELSE 4 END, s.user_type;


-- -----------------------------------------------------------------------------
-- Q7 | DBD  |  Band Aggregated (High / Medium / Low)
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    pd.band,
    CASE
      WHEN sd.doj IS NULL THEN 'Unknown'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 3 THEN 'DBD 3'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 4 THEN 'DBD 4'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 5 THEN 'DBD 5'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) > 5 THEN 'DBD 5+'
      ELSE 'Unknown'
    END AS dbd,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT pd.band, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.band,
  s.dbd,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.band = c.band
GROUP BY 1, 2
ORDER BY CASE s.band WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 ELSE 4 END, s.dbd;


-- -----------------------------------------------------------------------------
-- Q8 | Long / Short  |  Band Aggregated (High / Medium / Low)
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Medium'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Medium'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Medium'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Medium'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Medium'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Medium'),
      (CAST(216354 AS INTEGER), 'Aland', 'Medium'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Medium'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Medium'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Medium'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Medium'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Medium'),
      (CAST(987 AS INTEGER), 'Palitana', 'Medium'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Medium'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Medium'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Medium'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Medium'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Medium'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Medium'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Medium'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Medium'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Medium'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Medium'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Medium'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Medium'),
      (CAST(747 AS INTEGER), 'Mathura', 'Medium'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Medium'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Medium'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Medium'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Medium'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Medium'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Medium'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low')
  ) AS t(dest_id, dest_name, band)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id
  FROM lis.short_route_sds
  WHERE cohort = '2026'
),
srp AS (
  SELECT
    pd.band,
    CASE WHEN sr.src_id IS NOT NULL THEN 'Short' ELSE 'Long' END AS route_length,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  CROSS JOIN params p
  WHERE sd.country = 'IND'
    AND sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT pd.band, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.country = 'IND'
    AND c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.band,
  s.route_length,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.band = c.band
GROUP BY 1, 2
ORDER BY CASE s.band WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 ELSE 4 END, s.route_length;
