-- =============================================================================
-- Pilgrim-as-Destination CR — 8 queries
-- Cohort: listed pilgrim dest_ids | Source = Any
-- Window: last 14 IST days | IND | MOBILE_APP | Android
--
-- Intra  = src_id also in pilgrim list
-- Inter  = src_id NOT in pilgrim list
-- Short/Long via lis.short_route_sds
--
-- Q1–Q4 : grain = pilgrim destination (dest_id)
-- Q5–Q8 : grain = ALL pilgrim destinations aggregated
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Q1 | Intra vs Inter  |  Pilgrim Destination Level
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
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
    CASE WHEN src_p.dest_id IS NOT NULL THEN 'Intra' ELSE 'Inter' END AS route_group,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  CROSS JOIN params p
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.route_group,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3
ORDER BY s.dest_name, s.route_group;


-- -----------------------------------------------------------------------------
-- Q2 | User Type  |  Pilgrim Destination Level
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
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
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.user_type,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3
ORDER BY s.dest_name, s.user_type;


-- -----------------------------------------------------------------------------
-- Q3 | DBD  |  Pilgrim Destination Level
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
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
    CASE
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
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.dbd,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3
ORDER BY s.dest_name, s.dbd;


-- -----------------------------------------------------------------------------
-- Q4 | Long vs Short Routes  |  Pilgrim Destination Level
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id
  FROM lis.short_route_sds
  -- WHERE cohort = '2026'   -- uncomment if needed
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
    CASE WHEN sr.src_id IS NOT NULL THEN 'Short Route' ELSE 'Long Route' END AS route_length,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  CROSS JOIN params p
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3, 4
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  s.dest_id,
  s.dest_name,
  s.route_length,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2, 3
ORDER BY s.dest_name, s.route_length;


-- -----------------------------------------------------------------------------
-- Q5 | Intra vs Inter  |  ALL Pilgrim Destinations Aggregated
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    CASE WHEN src_p.dest_id IS NOT NULL THEN 'Intra' ELSE 'Inter' END AS route_group,
    sd.dest_id,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN pilgrim_dest src_p ON sd.src_id = src_p.dest_id
  CROSS JOIN params p
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  'ALL_PILGRIM_DEST' AS grain,
  s.route_group,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2
ORDER BY s.route_group;


-- -----------------------------------------------------------------------------
-- Q6 | User Type  |  ALL Pilgrim Destinations Aggregated
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    CASE UPPER(TRIM(COALESCE(sd.user_type, '')))
      WHEN 'NEW' THEN 'New'
      WHEN 'RETURNING' THEN 'Returning'
      WHEN 'RETURN' THEN 'Returning'
      WHEN 'GUEST' THEN 'Guest'
      ELSE 'Unknown'
    END AS user_type,
    sd.dest_id,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  'ALL_PILGRIM_DEST' AS grain,
  s.user_type,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2
ORDER BY s.user_type;


-- -----------------------------------------------------------------------------
-- Q7 | DBD  |  ALL Pilgrim Destinations Aggregated
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    CASE
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 0 THEN 'DBD 0'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 1 THEN 'DBD 1'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 2 THEN 'DBD 2'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 3 THEN 'DBD 3'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 4 THEN 'DBD 4'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) = 5 THEN 'DBD 5'
      WHEN DATE_DIFF('day', DATE(sd.__time + INTERVAL '330' MINUTE), sd.doj) > 5 THEN 'DBD 5+'
      ELSE 'Unknown'
    END AS dbd,
    sd.dest_id,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  'ALL_PILGRIM_DEST' AS grain,
  s.dbd,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2
ORDER BY s.dbd;


-- -----------------------------------------------------------------------------
-- Q8 | Long vs Short Routes  |  ALL Pilgrim Destinations Aggregated
-- -----------------------------------------------------------------------------
WITH pilgrim_dest AS (
  SELECT * FROM (
    VALUES
      (CAST(93580 AS INTEGER),  'Mayapur ISKCON'),
      (CAST(217 AS INTEGER),    'Velankanni'),
      (CAST(403 AS INTEGER),    'Shirdi'),
      (CAST(496 AS INTEGER),    'Rameswaram'),
      (CAST(471 AS INTEGER),    'Nathdwara'),
      (CAST(1001 AS INTEGER),   'Ujjain'),
      (CAST(216354 AS INTEGER), 'Aland'),
      (CAST(1128 AS INTEGER),   'Tiruthanni'),
      (CAST(802 AS INTEGER),    'Haridwar'),
      (CAST(808 AS INTEGER),    'Ajmer'),
      (CAST(275 AS INTEGER),    'Guruvayoor'),
      (CAST(94782 AS INTEGER),  'Vrindavan'),
      (CAST(987 AS INTEGER),    'Palitana'),
      (CAST(70628 AS INTEGER),  'Srisailam'),
      (CAST(1148 AS INTEGER),   'Murdeshwar'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)'),
      (CAST(142 AS INTEGER),    'Dharmasthala'),
      (CAST(78796 AS INTEGER),  'Mantralayam'),
      (CAST(77705 AS INTEGER),  'Mehandipur'),
      (CAST(1061 AS INTEGER),   'Ganpatipule'),
      (CAST(76480 AS INTEGER),  'Ayodhya'),
      (CAST(197504 AS INTEGER), 'Khatushyamji'),
      (CAST(70429 AS INTEGER),  'Varanasi'),
      (CAST(1007 AS INTEGER),   'Rajapur (Maharashtra)'),
      (CAST(975 AS INTEGER),    'Ambaji'),
      (CAST(747 AS INTEGER),    'Mathura'),
      (CAST(83409 AS INTEGER),  'Akkalkot'),
      (CAST(84832 AS INTEGER),  'Allahabad'),
      (CAST(94515 AS INTEGER),  'Rahmatabad (Nellore Dist)'),
      (CAST(1136 AS INTEGER),   'Dwarka'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham'),
      (CAST(70346 AS INTEGER),  'Abu Road'),
      (CAST(69526 AS INTEGER),  'Hampi'),
      (CAST(93189 AS INTEGER),  'Pamba'),
      (CAST(84310 AS INTEGER),  'Sehore(M.P)'),
      (CAST(1343 AS INTEGER),   'Kukke Subramanya'),
      (CAST(1141 AS INTEGER),   'Somnath'),
      (CAST(81826 AS INTEGER),  'Omkareshwar'),
      (CAST(196752 AS INTEGER), 'Pavagadh'),
      (CAST(68705 AS INTEGER),  'Kollur'),
      (CAST(70983 AS INTEGER),  'Okha'),
      (CAST(1219 AS INTEGER),   'Pushkar'),
      (CAST(94877 AS INTEGER),  'Tirumala'),
      (CAST(735 AS INTEGER),    'Katra (jammu and kashmir)'),
      (CAST(305974 AS INTEGER), 'Kainchi dham'),
      (CAST(534 AS INTEGER),    'Trimbakeshwar (Maharashtra)'),
      (CAST(74130 AS INTEGER),  'Salasar'),
      (CAST(74690 AS INTEGER),  'Puri'),
      (CAST(196 AS INTEGER),    'Horanadu'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)'),
      (CAST(77167 AS INTEGER),  'Gaya'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)'),
      (CAST(194482 AS INTEGER), 'Rampurhat'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta'),
      (CAST(74708 AS INTEGER),  'Tarapith'),
      (CAST(65805 AS INTEGER),  'Ramdevra'),
      (CAST(200347 AS INTEGER), 'Joshimath'),
      (CAST(77530 AS INTEGER),  'Jejuri'),
      (CAST(84848 AS INTEGER),  'Khajuraho'),
      (CAST(711 AS INTEGER),    'Mantralaya'),
      (CAST(69475 AS INTEGER),  'Sabarimala'),
      (CAST(68871 AS INTEGER),  'Mookambika'),
      (CAST(307614 AS INTEGER), 'Arunachalam'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)')
  ) AS t(dest_id, dest_name)
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id
  FROM lis.short_route_sds
  -- WHERE cohort = '2026'   -- uncomment if needed
),
params AS (
  SELECT
    CAST(CURRENT_DATE - INTERVAL '13' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_start,
    CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE AS window_end
),
srp AS (
  SELECT
    CASE WHEN sr.src_id IS NOT NULL THEN 'Short Route' ELSE 'Long Route' END AS route_length,
    sd.dest_id,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim_dest pd ON sd.dest_id = pd.dest_id
  LEFT JOIN short_routes sr ON sd.src_id = sr.src_id AND sd.dest_id = sr.dest_id
  CROSS JOIN params p
  WHERE sd.__time >= p.window_start AND sd.__time < p.window_end
    AND sd.channel = 'MOBILE_APP' AND sd.os = 'Android' AND sd.country = 'IND'
  GROUP BY 1, 2, 3
),
confirm AS (
  SELECT c.dest_id, c.mri_session_id
  FROM user_interaction.confirm_order_details c
  INNER JOIN pilgrim_dest pd ON c.dest_id = pd.dest_id
  CROSS JOIN params p
  WHERE c.__time >= p.window_start AND c.__time < p.window_end
    AND c.channel = 'MOBILE_APP' AND c.os = 'Android' AND c.country = 'IND'
    AND c.status = 200 AND c.tin IS NOT NULL AND c.tin <> '' AND c.tin <> 'null'
  GROUP BY 1, 2
)
SELECT
  'ALL_PILGRIM_DEST' AS grain,
  s.route_length,
  COUNT(DISTINCT s.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT c.mri_session_id) AS confirm_sessions,
  ROUND(100.0 * COUNT(DISTINCT c.mri_session_id) / NULLIF(COUNT(DISTINCT s.mri_session_id), 0), 2) AS cr_pct
FROM srp s
LEFT JOIN confirm c ON s.mri_session_id = c.mri_session_id AND s.dest_id = c.dest_id
GROUP BY 1, 2
ORDER BY s.route_length;
