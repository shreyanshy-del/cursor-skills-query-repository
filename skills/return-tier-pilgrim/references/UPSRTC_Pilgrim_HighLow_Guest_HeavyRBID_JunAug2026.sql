-- UPSRTC 25946 | IND | Jun-Aug 2026 IST | Pilgrim dest High/Low from user list
-- Guest = rb_user_id IS NULL
-- Heavy = named rb_user_id >=15 distinct sessions same IST day + same SD + same operator

-- 1A Guest High vs Low AGG
WITH pilgrim AS (
  SELECT dest_id, high_low FROM (VALUES
    (CAST(71756 AS INTEGER), 'High'),
    (CAST(489 AS INTEGER), 'High'),
    (CAST(133 AS INTEGER), 'High'),
    (CAST(1459 AS INTEGER), 'High'),
    (CAST(177 AS INTEGER), 'High'),
    (CAST(759 AS INTEGER), 'High'),
    (CAST(75103 AS INTEGER), 'High'),
    (CAST(842 AS INTEGER), 'High'),
    (CAST(77093 AS INTEGER), 'High'),
    (CAST(520 AS INTEGER), 'High'),
    (CAST(501 AS INTEGER), 'High'),
    (CAST(1528 AS INTEGER), 'High'),
    (CAST(196420 AS INTEGER), 'High'),
    (CAST(247 AS INTEGER), 'High'),
    (CAST(293 AS INTEGER), 'High'),
    (CAST(879 AS INTEGER), 'High'),
    (CAST(76187 AS INTEGER), 'High'),
    (CAST(77687 AS INTEGER), 'High'),
    (CAST(663 AS INTEGER), 'High'),
    (CAST(1496 AS INTEGER), 'High'),
    (CAST(70030 AS INTEGER), 'High'),
    (CAST(1242 AS INTEGER), 'High'),
    (CAST(1351 AS INTEGER), 'High'),
    (CAST(93580 AS INTEGER), 'Low'),
    (CAST(217 AS INTEGER), 'Low'),
    (CAST(403 AS INTEGER), 'Low'),
    (CAST(496 AS INTEGER), 'Low'),
    (CAST(471 AS INTEGER), 'Low'),
    (CAST(1001 AS INTEGER), 'Low'),
    (CAST(216354 AS INTEGER), 'Low'),
    (CAST(1128 AS INTEGER), 'Low'),
    (CAST(802 AS INTEGER), 'Low'),
    (CAST(808 AS INTEGER), 'Low'),
    (CAST(275 AS INTEGER), 'Low'),
    (CAST(94782 AS INTEGER), 'Low'),
    (CAST(987 AS INTEGER), 'Low'),
    (CAST(70628 AS INTEGER), 'Low'),
    (CAST(1148 AS INTEGER), 'Low'),
    (CAST(198750 AS INTEGER), 'Low'),
    (CAST(142 AS INTEGER), 'Low'),
    (CAST(78796 AS INTEGER), 'Low'),
    (CAST(77705 AS INTEGER), 'Low'),
    (CAST(1061 AS INTEGER), 'Low'),
    (CAST(76480 AS INTEGER), 'Low'),
    (CAST(197504 AS INTEGER), 'Low'),
    (CAST(70429 AS INTEGER), 'Low'),
    (CAST(1007 AS INTEGER), 'Low'),
    (CAST(975 AS INTEGER), 'Low'),
    (CAST(747 AS INTEGER), 'Low'),
    (CAST(83409 AS INTEGER), 'Low'),
    (CAST(84832 AS INTEGER), 'Low'),
    (CAST(94515 AS INTEGER), 'Low'),
    (CAST(1136 AS INTEGER), 'Low'),
    (CAST(298723 AS INTEGER), 'Low'),
    (CAST(70346 AS INTEGER), 'Low'),
    (CAST(69526 AS INTEGER), 'Low'),
    (CAST(93189 AS INTEGER), 'Low'),
    (CAST(84310 AS INTEGER), 'Low'),
    (CAST(1343 AS INTEGER), 'Low'),
    (CAST(1141 AS INTEGER), 'Low'),
    (CAST(81826 AS INTEGER), 'Low'),
    (CAST(196752 AS INTEGER), 'Low'),
    (CAST(68705 AS INTEGER), 'Low'),
    (CAST(70983 AS INTEGER), 'Low'),
    (CAST(1219 AS INTEGER), 'Low'),
    (CAST(94877 AS INTEGER), 'Low'),
    (CAST(735 AS INTEGER), 'Low'),
    (CAST(305974 AS INTEGER), 'Low'),
    (CAST(534 AS INTEGER), 'Low'),
    (CAST(74130 AS INTEGER), 'Low'),
    (CAST(74690 AS INTEGER), 'Low'),
    (CAST(196 AS INTEGER), 'Low'),
    (CAST(202212 AS INTEGER), 'Low'),
    (CAST(77167 AS INTEGER), 'Low'),
    (CAST(204358 AS INTEGER), 'Low'),
    (CAST(194482 AS INTEGER), 'Low'),
    (CAST(215191 AS INTEGER), 'Low'),
    (CAST(300439 AS INTEGER), 'Low'),
    (CAST(74708 AS INTEGER), 'Low'),
    (CAST(65805 AS INTEGER), 'Low'),
    (CAST(200347 AS INTEGER), 'Low'),
    (CAST(77530 AS INTEGER), 'Low'),
    (CAST(84848 AS INTEGER), 'Low'),
    (CAST(711 AS INTEGER), 'Low'),
    (CAST(69475 AS INTEGER), 'Low'),
    (CAST(68871 AS INTEGER), 'Low'),
    (CAST(307614 AS INTEGER), 'Low'),
    (CAST(289873 AS INTEGER), 'Low')
  ) AS t(dest_id, high_low)
), searches AS (
  SELECT
    p.high_low,
    COUNT(DISTINCT sd.mri_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY p.high_low
), bookings AS (
  SELECT
    p.high_low,
    COUNT(DISTINCT bte.tin) AS transactions,
    SUM(bte.seat_count) AS seats
  FROM transaction.bus_ticket_events AS bte
  INNER JOIN pilgrim AS p ON bte.destination_location_id = p.dest_id
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND bte.operator_id = 25946
  GROUP BY p.high_low
)
SELECT
  COALESCE(s.high_low, b.high_low) AS high_low,
  COALESCE(s.sessions, 0) AS sessions,
  COALESCE(s.guest_sessions, 0) AS guest_sessions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(s.guest_sessions AS DOUBLE) * 100.0 / s.sessions ELSE 0 END AS guest_share_pct,
  COALESCE(b.transactions, 0) AS transactions,
  COALESCE(b.seats, 0) AS seats,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.sessions ELSE 0 END AS cr_pct
FROM searches AS s
FULL OUTER JOIN bookings AS b ON s.high_low = b.high_low
ORDER BY high_low
LIMIT 20;

-- 1B Guest Dest level
WITH pilgrim AS (
  SELECT dest_id, pilgrim_city, high_low FROM (VALUES
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
    (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Low'),
    (CAST(217 AS INTEGER), 'Velankanni', 'Low'),
    (CAST(403 AS INTEGER), 'Shirdi', 'Low'),
    (CAST(496 AS INTEGER), 'Rameswaram', 'Low'),
    (CAST(471 AS INTEGER), 'Nathdwara', 'Low'),
    (CAST(1001 AS INTEGER), 'Ujjain', 'Low'),
    (CAST(216354 AS INTEGER), 'Aland', 'Low'),
    (CAST(1128 AS INTEGER), 'Tiruthanni', 'Low'),
    (CAST(802 AS INTEGER), 'Haridwar', 'Low'),
    (CAST(808 AS INTEGER), 'Ajmer', 'Low'),
    (CAST(275 AS INTEGER), 'Guruvayoor', 'Low'),
    (CAST(94782 AS INTEGER), 'Vrindavan', 'Low'),
    (CAST(987 AS INTEGER), 'Palitana', 'Low'),
    (CAST(70628 AS INTEGER), 'Srisailam', 'Low'),
    (CAST(1148 AS INTEGER), 'Murdeshwar', 'Low'),
    (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Low'),
    (CAST(142 AS INTEGER), 'Dharmasthala', 'Low'),
    (CAST(78796 AS INTEGER), 'Mantralayam', 'Low'),
    (CAST(77705 AS INTEGER), 'Mehandipur', 'Low'),
    (CAST(1061 AS INTEGER), 'Ganpatipule', 'Low'),
    (CAST(76480 AS INTEGER), 'Ayodhya', 'Low'),
    (CAST(197504 AS INTEGER), 'Khatushyamji', 'Low'),
    (CAST(70429 AS INTEGER), 'Varanasi', 'Low'),
    (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Low'),
    (CAST(975 AS INTEGER), 'Ambaji', 'Low'),
    (CAST(747 AS INTEGER), 'Mathura', 'Low'),
    (CAST(83409 AS INTEGER), 'Akkalkot', 'Low'),
    (CAST(84832 AS INTEGER), 'Allahabad', 'Low'),
    (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Low'),
    (CAST(1136 AS INTEGER), 'Dwarka', 'Low'),
    (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Low'),
    (CAST(70346 AS INTEGER), 'Abu Road', 'Low'),
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
  ) AS t(dest_id, pilgrim_city, high_low)
), searches AS (
  SELECT
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY sd.dest_id
), bookings AS (
  SELECT
    bte.destination_location_id AS dest_id,
    COUNT(DISTINCT bte.tin) AS transactions,
    SUM(bte.seat_count) AS seats
  FROM transaction.bus_ticket_events AS bte
  INNER JOIN pilgrim AS p ON bte.destination_location_id = p.dest_id
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND bte.operator_id = 25946
  GROUP BY bte.destination_location_id
)
SELECT
  p.dest_id,
  p.pilgrim_city,
  p.high_low,
  COALESCE(s.sessions, 0) AS sessions,
  COALESCE(s.guest_sessions, 0) AS guest_sessions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(s.guest_sessions AS DOUBLE) * 100.0 / s.sessions ELSE 0 END AS guest_share_pct,
  COALESCE(b.transactions, 0) AS transactions,
  COALESCE(b.seats, 0) AS seats,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.sessions ELSE 0 END AS cr_pct
FROM pilgrim AS p
LEFT JOIN searches AS s ON p.dest_id = s.dest_id
LEFT JOIN bookings AS b ON p.dest_id = b.dest_id
ORDER BY p.high_low, COALESCE(s.sessions, 0) DESC
LIMIT 500;

-- 1C Guest SD level
WITH pilgrim AS (
  SELECT dest_id, pilgrim_city, high_low FROM (VALUES
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
    (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Low'),
    (CAST(217 AS INTEGER), 'Velankanni', 'Low'),
    (CAST(403 AS INTEGER), 'Shirdi', 'Low'),
    (CAST(496 AS INTEGER), 'Rameswaram', 'Low'),
    (CAST(471 AS INTEGER), 'Nathdwara', 'Low'),
    (CAST(1001 AS INTEGER), 'Ujjain', 'Low'),
    (CAST(216354 AS INTEGER), 'Aland', 'Low'),
    (CAST(1128 AS INTEGER), 'Tiruthanni', 'Low'),
    (CAST(802 AS INTEGER), 'Haridwar', 'Low'),
    (CAST(808 AS INTEGER), 'Ajmer', 'Low'),
    (CAST(275 AS INTEGER), 'Guruvayoor', 'Low'),
    (CAST(94782 AS INTEGER), 'Vrindavan', 'Low'),
    (CAST(987 AS INTEGER), 'Palitana', 'Low'),
    (CAST(70628 AS INTEGER), 'Srisailam', 'Low'),
    (CAST(1148 AS INTEGER), 'Murdeshwar', 'Low'),
    (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Low'),
    (CAST(142 AS INTEGER), 'Dharmasthala', 'Low'),
    (CAST(78796 AS INTEGER), 'Mantralayam', 'Low'),
    (CAST(77705 AS INTEGER), 'Mehandipur', 'Low'),
    (CAST(1061 AS INTEGER), 'Ganpatipule', 'Low'),
    (CAST(76480 AS INTEGER), 'Ayodhya', 'Low'),
    (CAST(197504 AS INTEGER), 'Khatushyamji', 'Low'),
    (CAST(70429 AS INTEGER), 'Varanasi', 'Low'),
    (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Low'),
    (CAST(975 AS INTEGER), 'Ambaji', 'Low'),
    (CAST(747 AS INTEGER), 'Mathura', 'Low'),
    (CAST(83409 AS INTEGER), 'Akkalkot', 'Low'),
    (CAST(84832 AS INTEGER), 'Allahabad', 'Low'),
    (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Low'),
    (CAST(1136 AS INTEGER), 'Dwarka', 'Low'),
    (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Low'),
    (CAST(70346 AS INTEGER), 'Abu Road', 'Low'),
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
  ) AS t(dest_id, pilgrim_city, high_low)
), searches AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY sd.src_id, sd.dest_id
), bookings AS (
  SELECT
    bte.source_location_id AS src_id,
    bte.destination_location_id AS dest_id,
    COUNT(DISTINCT bte.tin) AS transactions,
    SUM(bte.seat_count) AS seats
  FROM transaction.bus_ticket_events AS bte
  INNER JOIN pilgrim AS p ON bte.destination_location_id = p.dest_id
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND bte.operator_id = 25946
  GROUP BY bte.source_location_id, bte.destination_location_id
)
SELECT
  COALESCE(s.src_id, b.src_id) AS src_id,
  src.location_name AS source_city,
  COALESCE(s.dest_id, b.dest_id) AS dest_id,
  p.pilgrim_city,
  p.high_low,
  COALESCE(s.sessions, 0) AS sessions,
  COALESCE(s.guest_sessions, 0) AS guest_sessions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(s.guest_sessions AS DOUBLE) * 100.0 / s.sessions ELSE NULL END AS guest_share_pct,
  COALESCE(b.transactions, 0) AS transactions,
  COALESCE(b.seats, 0) AS seats,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.sessions ELSE NULL END AS cr_pct
FROM searches AS s
FULL OUTER JOIN bookings AS b
  ON s.src_id = b.src_id AND s.dest_id = b.dest_id
INNER JOIN pilgrim AS p
  ON p.dest_id = COALESCE(s.dest_id, b.dest_id)
LEFT JOIN lis.config_locations AS src
  ON src.id = COALESCE(s.src_id, b.src_id)
  AND src.location_type = 'CITY' AND src.is_expired = 0
ORDER BY p.high_low, COALESCE(s.sessions, 0) DESC
LIMIT 2000;

-- 2A Heavy High vs Low AGG
WITH pilgrim AS (
  SELECT dest_id, high_low FROM (VALUES
    (CAST(71756 AS INTEGER), 'High'),
    (CAST(489 AS INTEGER), 'High'),
    (CAST(133 AS INTEGER), 'High'),
    (CAST(1459 AS INTEGER), 'High'),
    (CAST(177 AS INTEGER), 'High'),
    (CAST(759 AS INTEGER), 'High'),
    (CAST(75103 AS INTEGER), 'High'),
    (CAST(842 AS INTEGER), 'High'),
    (CAST(77093 AS INTEGER), 'High'),
    (CAST(520 AS INTEGER), 'High'),
    (CAST(501 AS INTEGER), 'High'),
    (CAST(1528 AS INTEGER), 'High'),
    (CAST(196420 AS INTEGER), 'High'),
    (CAST(247 AS INTEGER), 'High'),
    (CAST(293 AS INTEGER), 'High'),
    (CAST(879 AS INTEGER), 'High'),
    (CAST(76187 AS INTEGER), 'High'),
    (CAST(77687 AS INTEGER), 'High'),
    (CAST(663 AS INTEGER), 'High'),
    (CAST(1496 AS INTEGER), 'High'),
    (CAST(70030 AS INTEGER), 'High'),
    (CAST(1242 AS INTEGER), 'High'),
    (CAST(1351 AS INTEGER), 'High'),
    (CAST(93580 AS INTEGER), 'Low'),
    (CAST(217 AS INTEGER), 'Low'),
    (CAST(403 AS INTEGER), 'Low'),
    (CAST(496 AS INTEGER), 'Low'),
    (CAST(471 AS INTEGER), 'Low'),
    (CAST(1001 AS INTEGER), 'Low'),
    (CAST(216354 AS INTEGER), 'Low'),
    (CAST(1128 AS INTEGER), 'Low'),
    (CAST(802 AS INTEGER), 'Low'),
    (CAST(808 AS INTEGER), 'Low'),
    (CAST(275 AS INTEGER), 'Low'),
    (CAST(94782 AS INTEGER), 'Low'),
    (CAST(987 AS INTEGER), 'Low'),
    (CAST(70628 AS INTEGER), 'Low'),
    (CAST(1148 AS INTEGER), 'Low'),
    (CAST(198750 AS INTEGER), 'Low'),
    (CAST(142 AS INTEGER), 'Low'),
    (CAST(78796 AS INTEGER), 'Low'),
    (CAST(77705 AS INTEGER), 'Low'),
    (CAST(1061 AS INTEGER), 'Low'),
    (CAST(76480 AS INTEGER), 'Low'),
    (CAST(197504 AS INTEGER), 'Low'),
    (CAST(70429 AS INTEGER), 'Low'),
    (CAST(1007 AS INTEGER), 'Low'),
    (CAST(975 AS INTEGER), 'Low'),
    (CAST(747 AS INTEGER), 'Low'),
    (CAST(83409 AS INTEGER), 'Low'),
    (CAST(84832 AS INTEGER), 'Low'),
    (CAST(94515 AS INTEGER), 'Low'),
    (CAST(1136 AS INTEGER), 'Low'),
    (CAST(298723 AS INTEGER), 'Low'),
    (CAST(70346 AS INTEGER), 'Low'),
    (CAST(69526 AS INTEGER), 'Low'),
    (CAST(93189 AS INTEGER), 'Low'),
    (CAST(84310 AS INTEGER), 'Low'),
    (CAST(1343 AS INTEGER), 'Low'),
    (CAST(1141 AS INTEGER), 'Low'),
    (CAST(81826 AS INTEGER), 'Low'),
    (CAST(196752 AS INTEGER), 'Low'),
    (CAST(68705 AS INTEGER), 'Low'),
    (CAST(70983 AS INTEGER), 'Low'),
    (CAST(1219 AS INTEGER), 'Low'),
    (CAST(94877 AS INTEGER), 'Low'),
    (CAST(735 AS INTEGER), 'Low'),
    (CAST(305974 AS INTEGER), 'Low'),
    (CAST(534 AS INTEGER), 'Low'),
    (CAST(74130 AS INTEGER), 'Low'),
    (CAST(74690 AS INTEGER), 'Low'),
    (CAST(196 AS INTEGER), 'Low'),
    (CAST(202212 AS INTEGER), 'Low'),
    (CAST(77167 AS INTEGER), 'Low'),
    (CAST(204358 AS INTEGER), 'Low'),
    (CAST(194482 AS INTEGER), 'Low'),
    (CAST(215191 AS INTEGER), 'Low'),
    (CAST(300439 AS INTEGER), 'Low'),
    (CAST(74708 AS INTEGER), 'Low'),
    (CAST(65805 AS INTEGER), 'Low'),
    (CAST(200347 AS INTEGER), 'Low'),
    (CAST(77530 AS INTEGER), 'Low'),
    (CAST(84848 AS INTEGER), 'Low'),
    (CAST(711 AS INTEGER), 'Low'),
    (CAST(69475 AS INTEGER), 'Low'),
    (CAST(68871 AS INTEGER), 'Low'),
    (CAST(307614 AS INTEGER), 'Low'),
    (CAST(289873 AS INTEGER), 'Low')
  ) AS t(dest_id, high_low)
), daily_user_sd AS (
  SELECT
    sd.rb_user_id,
    sd.src_id,
    sd.dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) AS day_ist
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY
    sd.rb_user_id, sd.src_id, sd.dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata'))
  HAVING COUNT(DISTINCT sd.mri_session_id) >= 15
), heavy AS (
  SELECT
    p.high_low,
    COUNT(DISTINCT sd.mri_session_id) AS heavy_sessions,
    COUNT(DISTINCT sd.rb_user_id) AS heavy_rbids
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  INNER JOIN daily_user_sd AS du
    ON sd.rb_user_id = du.rb_user_id
    AND sd.src_id = du.src_id
    AND sd.dest_id = du.dest_id
    AND DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) = du.day_ist
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY p.high_low
), searches AS (
  SELECT
    p.high_low,
    COUNT(DISTINCT sd.mri_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY p.high_low
), bookings AS (
  SELECT
    p.high_low,
    COUNT(DISTINCT bte.tin) AS transactions
  FROM transaction.bus_ticket_events AS bte
  INNER JOIN pilgrim AS p ON bte.destination_location_id = p.dest_id
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND bte.operator_id = 25946
  GROUP BY p.high_low
)
SELECT
  s.high_low,
  s.sessions,
  s.guest_sessions,
  CAST(s.guest_sessions AS DOUBLE) * 100.0 / NULLIF(s.sessions, 0) AS guest_share_pct,
  COALESCE(h.heavy_sessions, 0) AS heavy_rbid_sessions,
  CAST(COALESCE(h.heavy_sessions, 0) AS DOUBLE) * 100.0 / NULLIF(s.sessions, 0) AS heavy_share_pct,
  COALESCE(h.heavy_rbids, 0) AS heavy_rbids,
  COALESCE(b.transactions, 0) AS transactions,
  CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / NULLIF(s.sessions, 0) AS cr_pct
FROM searches AS s
LEFT JOIN heavy AS h ON s.high_low = h.high_low
LEFT JOIN bookings AS b ON s.high_low = b.high_low
ORDER BY s.high_low
LIMIT 20;

-- 2B Heavy Dest level
WITH pilgrim AS (
  SELECT dest_id, pilgrim_city, high_low FROM (VALUES
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
    (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Low'),
    (CAST(217 AS INTEGER), 'Velankanni', 'Low'),
    (CAST(403 AS INTEGER), 'Shirdi', 'Low'),
    (CAST(496 AS INTEGER), 'Rameswaram', 'Low'),
    (CAST(471 AS INTEGER), 'Nathdwara', 'Low'),
    (CAST(1001 AS INTEGER), 'Ujjain', 'Low'),
    (CAST(216354 AS INTEGER), 'Aland', 'Low'),
    (CAST(1128 AS INTEGER), 'Tiruthanni', 'Low'),
    (CAST(802 AS INTEGER), 'Haridwar', 'Low'),
    (CAST(808 AS INTEGER), 'Ajmer', 'Low'),
    (CAST(275 AS INTEGER), 'Guruvayoor', 'Low'),
    (CAST(94782 AS INTEGER), 'Vrindavan', 'Low'),
    (CAST(987 AS INTEGER), 'Palitana', 'Low'),
    (CAST(70628 AS INTEGER), 'Srisailam', 'Low'),
    (CAST(1148 AS INTEGER), 'Murdeshwar', 'Low'),
    (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Low'),
    (CAST(142 AS INTEGER), 'Dharmasthala', 'Low'),
    (CAST(78796 AS INTEGER), 'Mantralayam', 'Low'),
    (CAST(77705 AS INTEGER), 'Mehandipur', 'Low'),
    (CAST(1061 AS INTEGER), 'Ganpatipule', 'Low'),
    (CAST(76480 AS INTEGER), 'Ayodhya', 'Low'),
    (CAST(197504 AS INTEGER), 'Khatushyamji', 'Low'),
    (CAST(70429 AS INTEGER), 'Varanasi', 'Low'),
    (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Low'),
    (CAST(975 AS INTEGER), 'Ambaji', 'Low'),
    (CAST(747 AS INTEGER), 'Mathura', 'Low'),
    (CAST(83409 AS INTEGER), 'Akkalkot', 'Low'),
    (CAST(84832 AS INTEGER), 'Allahabad', 'Low'),
    (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Low'),
    (CAST(1136 AS INTEGER), 'Dwarka', 'Low'),
    (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Low'),
    (CAST(70346 AS INTEGER), 'Abu Road', 'Low'),
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
  ) AS t(dest_id, pilgrim_city, high_low)
), daily_user_sd AS (
  SELECT
    sd.rb_user_id,
    sd.src_id,
    sd.dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) AS day_ist
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY
    sd.rb_user_id, sd.src_id, sd.dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata'))
  HAVING COUNT(DISTINCT sd.mri_session_id) >= 15
), heavy AS (
  SELECT
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS heavy_sessions,
    COUNT(DISTINCT sd.rb_user_id) AS heavy_rbids
  FROM user_interaction.search_details AS sd
  INNER JOIN daily_user_sd AS du
    ON sd.rb_user_id = du.rb_user_id
    AND sd.src_id = du.src_id
    AND sd.dest_id = du.dest_id
    AND DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) = du.day_ist
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY sd.dest_id
), searches AS (
  SELECT
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY sd.dest_id
), bookings AS (
  SELECT
    bte.destination_location_id AS dest_id,
    COUNT(DISTINCT bte.tin) AS transactions
  FROM transaction.bus_ticket_events AS bte
  INNER JOIN pilgrim AS p ON bte.destination_location_id = p.dest_id
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND bte.operator_id = 25946
  GROUP BY bte.destination_location_id
)
SELECT
  p.dest_id,
  p.pilgrim_city,
  p.high_low,
  COALESCE(s.sessions, 0) AS sessions,
  COALESCE(s.guest_sessions, 0) AS guest_sessions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(s.guest_sessions AS DOUBLE) * 100.0 / s.sessions ELSE 0 END AS guest_share_pct,
  COALESCE(h.heavy_sessions, 0) AS heavy_rbid_sessions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(COALESCE(h.heavy_sessions, 0) AS DOUBLE) * 100.0 / s.sessions ELSE 0 END AS heavy_share_pct,
  COALESCE(h.heavy_rbids, 0) AS heavy_rbids,
  COALESCE(b.transactions, 0) AS transactions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.sessions ELSE 0 END AS cr_pct
FROM pilgrim AS p
LEFT JOIN searches AS s ON p.dest_id = s.dest_id
LEFT JOIN heavy AS h ON p.dest_id = h.dest_id
LEFT JOIN bookings AS b ON p.dest_id = b.dest_id
ORDER BY p.high_low, COALESCE(s.sessions, 0) DESC
LIMIT 500;

-- 2C Heavy SD level
WITH pilgrim AS (
  SELECT dest_id, pilgrim_city, high_low FROM (VALUES
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
    (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Low'),
    (CAST(217 AS INTEGER), 'Velankanni', 'Low'),
    (CAST(403 AS INTEGER), 'Shirdi', 'Low'),
    (CAST(496 AS INTEGER), 'Rameswaram', 'Low'),
    (CAST(471 AS INTEGER), 'Nathdwara', 'Low'),
    (CAST(1001 AS INTEGER), 'Ujjain', 'Low'),
    (CAST(216354 AS INTEGER), 'Aland', 'Low'),
    (CAST(1128 AS INTEGER), 'Tiruthanni', 'Low'),
    (CAST(802 AS INTEGER), 'Haridwar', 'Low'),
    (CAST(808 AS INTEGER), 'Ajmer', 'Low'),
    (CAST(275 AS INTEGER), 'Guruvayoor', 'Low'),
    (CAST(94782 AS INTEGER), 'Vrindavan', 'Low'),
    (CAST(987 AS INTEGER), 'Palitana', 'Low'),
    (CAST(70628 AS INTEGER), 'Srisailam', 'Low'),
    (CAST(1148 AS INTEGER), 'Murdeshwar', 'Low'),
    (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Low'),
    (CAST(142 AS INTEGER), 'Dharmasthala', 'Low'),
    (CAST(78796 AS INTEGER), 'Mantralayam', 'Low'),
    (CAST(77705 AS INTEGER), 'Mehandipur', 'Low'),
    (CAST(1061 AS INTEGER), 'Ganpatipule', 'Low'),
    (CAST(76480 AS INTEGER), 'Ayodhya', 'Low'),
    (CAST(197504 AS INTEGER), 'Khatushyamji', 'Low'),
    (CAST(70429 AS INTEGER), 'Varanasi', 'Low'),
    (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Low'),
    (CAST(975 AS INTEGER), 'Ambaji', 'Low'),
    (CAST(747 AS INTEGER), 'Mathura', 'Low'),
    (CAST(83409 AS INTEGER), 'Akkalkot', 'Low'),
    (CAST(84832 AS INTEGER), 'Allahabad', 'Low'),
    (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Low'),
    (CAST(1136 AS INTEGER), 'Dwarka', 'Low'),
    (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Low'),
    (CAST(70346 AS INTEGER), 'Abu Road', 'Low'),
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
  ) AS t(dest_id, pilgrim_city, high_low)
), daily_user_sd AS (
  SELECT
    sd.rb_user_id,
    sd.src_id,
    sd.dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) AS day_ist
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY
    sd.rb_user_id, sd.src_id, sd.dest_id,
    DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata'))
  HAVING COUNT(DISTINCT sd.mri_session_id) >= 15
), heavy AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS heavy_sessions,
    COUNT(DISTINCT sd.rb_user_id) AS heavy_rbids
  FROM user_interaction.search_details AS sd
  INNER JOIN daily_user_sd AS du
    ON sd.rb_user_id = du.rb_user_id
    AND sd.src_id = du.src_id
    AND sd.dest_id = du.dest_id
    AND DATE_TRUNC('DAY', AT_TIMEZONE(sd.__time, 'Asia/Kolkata')) = du.day_ist
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
    AND sd.rb_user_id IS NOT NULL
  GROUP BY sd.src_id, sd.dest_id
), searches AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS guest_sessions
  FROM user_interaction.search_details AS sd
  INNER JOIN pilgrim AS p ON sd.dest_id = p.dest_id
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY sd.src_id, sd.dest_id
), bookings AS (
  SELECT
    bte.source_location_id AS src_id,
    bte.destination_location_id AS dest_id,
    COUNT(DISTINCT bte.tin) AS transactions
  FROM transaction.bus_ticket_events AS bte
  INNER JOIN pilgrim AS p ON bte.destination_location_id = p.dest_id
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND bte.operator_id = 25946
  GROUP BY bte.source_location_id, bte.destination_location_id
)
SELECT
  COALESCE(s.src_id, b.src_id) AS src_id,
  src.location_name AS source_city,
  COALESCE(s.dest_id, b.dest_id) AS dest_id,
  p.pilgrim_city,
  p.high_low,
  COALESCE(s.sessions, 0) AS sessions,
  COALESCE(s.guest_sessions, 0) AS guest_sessions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(s.guest_sessions AS DOUBLE) * 100.0 / s.sessions ELSE NULL END AS guest_share_pct,
  COALESCE(h.heavy_sessions, 0) AS heavy_rbid_sessions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(COALESCE(h.heavy_sessions, 0) AS DOUBLE) * 100.0 / s.sessions ELSE NULL END AS heavy_share_pct,
  COALESCE(h.heavy_rbids, 0) AS heavy_rbids,
  COALESCE(b.transactions, 0) AS transactions,
  CASE WHEN COALESCE(s.sessions, 0) > 0
    THEN CAST(COALESCE(b.transactions, 0) AS DOUBLE) * 100.0 / s.sessions ELSE NULL END AS cr_pct
FROM searches AS s
FULL OUTER JOIN bookings AS b
  ON s.src_id = b.src_id AND s.dest_id = b.dest_id
LEFT JOIN heavy AS h
  ON h.src_id = COALESCE(s.src_id, b.src_id) AND h.dest_id = COALESCE(s.dest_id, b.dest_id)
INNER JOIN pilgrim AS p
  ON p.dest_id = COALESCE(s.dest_id, b.dest_id)
LEFT JOIN lis.config_locations AS src
  ON src.id = COALESCE(s.src_id, b.src_id)
  AND src.location_type = 'CITY' AND src.is_expired = 0
WHERE COALESCE(s.sessions, 0) >= 50
ORDER BY p.high_low, COALESCE(h.heavy_sessions, 0) DESC, COALESCE(s.sessions, 0) DESC
LIMIT 2000;