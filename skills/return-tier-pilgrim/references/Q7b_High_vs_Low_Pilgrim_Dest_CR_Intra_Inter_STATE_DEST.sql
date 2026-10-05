-- =============================================================================
-- High vs Low Pilgrim Destination CR × Intra/Inter (STATE) — DEST LEVEL
-- Intra = same state | Inter = different state
-- CR = tin / SRP sessions | Android IND | 24 Aug – 6 Sep 2026 IST
-- =============================================================================

WITH pilgrim AS (
  SELECT dest_id, pilgrim_city, high_low FROM (VALUES
      (CAST(759 AS INTEGER), 'Amritsar', 'High'),
      (CAST(247 AS INTEGER), 'Annavaram', 'High'),
      (CAST(75103 AS INTEGER), 'Beas', 'High'),
      (CAST(879 AS INTEGER), 'Chitradurga', 'High'),
      (CAST(1242 AS INTEGER), 'Chotila', 'High'),
      (CAST(520 AS INTEGER), 'Dwarakatirumula', 'High'),
      (CAST(1528 AS INTEGER), 'Jawala Ji', 'High'),
      (CAST(77687 AS INTEGER), 'Kurukshetra', 'High'),
      (CAST(489 AS INTEGER), 'Marthandam', 'High'),
      (CAST(1459 AS INTEGER), 'Nakhatrana', 'High'),
      (CAST(501 AS INTEGER), 'Palani', 'High'),
      (CAST(76187 AS INTEGER), 'Pandharpur', 'High'),
      (CAST(842 AS INTEGER), 'Rishikesh', 'High'),
      (CAST(1496 AS INTEGER), 'Shegaon (Buldhana)', 'High'),
      (CAST(133 AS INTEGER), 'SriKalahasthi', 'High'),
      (CAST(177 AS INTEGER), 'Sringeri', 'High'),
      (CAST(1351 AS INTEGER), 'Srirangam', 'High'),
      (CAST(663 AS INTEGER), 'Tiruchendur', 'High'),
      (CAST(71756 AS INTEGER), 'Tirupati', 'High'),
      (CAST(293 AS INTEGER), 'Tiruvannamalai', 'High'),
      (CAST(77093 AS INTEGER), 'Tuljapur', 'High'),
      (CAST(70030 AS INTEGER), 'Unjha', 'High'),
      (CAST(196420 AS INTEGER), 'Vemulawada', 'High'),
      (CAST(70346 AS INTEGER), 'Abu Road', 'Low'),
      (CAST(808 AS INTEGER), 'Ajmer', 'Low'),
      (CAST(83409 AS INTEGER), 'Akkalkot', 'Low'),
      (CAST(216354 AS INTEGER), 'Aland', 'Low'),
      (CAST(84832 AS INTEGER), 'Allahabad', 'Low'),
      (CAST(975 AS INTEGER), 'Ambaji', 'Low'),
      (CAST(307614 AS INTEGER), 'Arunachalam', 'Low'),
      (CAST(289873 AS INTEGER), 'Arunachalam (tiruvannamalai)', 'Low'),
      (CAST(76480 AS INTEGER), 'Ayodhya', 'Low'),
      (CAST(204358 AS INTEGER), 'Badrinath(uttarakhand)', 'Low'),
      (CAST(298723 AS INTEGER), 'Bageshwar Dham', 'Low'),
      (CAST(142 AS INTEGER), 'Dharmasthala', 'Low'),
      (CAST(1136 AS INTEGER), 'Dwarka', 'Low'),
      (CAST(1061 AS INTEGER), 'Ganpatipule', 'Low'),
      (CAST(77167 AS INTEGER), 'Gaya', 'Low'),
      (CAST(275 AS INTEGER), 'Guruvayoor', 'Low'),
      (CAST(69526 AS INTEGER), 'Hampi', 'Low'),
      (CAST(802 AS INTEGER), 'Haridwar', 'Low'),
      (CAST(196 AS INTEGER), 'Horanadu', 'Low'),
      (CAST(77530 AS INTEGER), 'Jejuri', 'Low'),
      (CAST(200347 AS INTEGER), 'Joshimath', 'Low'),
      (CAST(305974 AS INTEGER), 'Kainchi dham', 'Low'),
      (CAST(735 AS INTEGER), 'Katra (jammu and kashmir)', 'Low'),
      (CAST(84848 AS INTEGER), 'Khajuraho', 'Low'),
      (CAST(197504 AS INTEGER), 'Khatushyamji', 'Low'),
      (CAST(68705 AS INTEGER), 'Kollur', 'Low'),
      (CAST(1343 AS INTEGER), 'Kukke Subramanya', 'Low'),
      (CAST(202212 AS INTEGER), 'Manikaran (Himachal Pradesh)', 'Low'),
      (CAST(711 AS INTEGER), 'Mantralaya', 'Low'),
      (CAST(78796 AS INTEGER), 'Mantralayam', 'Low'),
      (CAST(747 AS INTEGER), 'Mathura', 'Low'),
      (CAST(93580 AS INTEGER), 'Mayapur ISKCON', 'Low'),
      (CAST(77705 AS INTEGER), 'Mehandipur', 'Low'),
      (CAST(68871 AS INTEGER), 'Mookambika', 'Low'),
      (CAST(1148 AS INTEGER), 'Murdeshwar', 'Low'),
      (CAST(471 AS INTEGER), 'Nathdwara', 'Low'),
      (CAST(70983 AS INTEGER), 'Okha', 'Low'),
      (CAST(81826 AS INTEGER), 'Omkareshwar', 'Low'),
      (CAST(987 AS INTEGER), 'Palitana', 'Low'),
      (CAST(93189 AS INTEGER), 'Pamba', 'Low'),
      (CAST(196752 AS INTEGER), 'Pavagadh', 'Low'),
      (CAST(74690 AS INTEGER), 'Puri', 'Low'),
      (CAST(1219 AS INTEGER), 'Pushkar', 'Low'),
      (CAST(94515 AS INTEGER), 'Rahmatabad (Nellore Dist)', 'Low'),
      (CAST(1007 AS INTEGER), 'Rajapur (Maharashtra)', 'Low'),
      (CAST(65805 AS INTEGER), 'Ramdevra', 'Low'),
      (CAST(496 AS INTEGER), 'Rameswaram', 'Low'),
      (CAST(194482 AS INTEGER), 'Rampurhat', 'Low'),
      (CAST(69475 AS INTEGER), 'Sabarimala', 'Low'),
      (CAST(74130 AS INTEGER), 'Salasar', 'Low'),
      (CAST(215191 AS INTEGER), 'Sarangpur (gujarat)', 'Low'),
      (CAST(84310 AS INTEGER), 'Sehore(M.P)', 'Low'),
      (CAST(403 AS INTEGER), 'Shirdi', 'Low'),
      (CAST(1141 AS INTEGER), 'Somnath', 'Low'),
      (CAST(70628 AS INTEGER), 'Srisailam', 'Low'),
      (CAST(74708 AS INTEGER), 'Tarapith', 'Low'),
      (CAST(198750 AS INTEGER), 'Thirunallar (Pondicherry)', 'Low'),
      (CAST(94877 AS INTEGER), 'Tirumala', 'Low'),
      (CAST(1128 AS INTEGER), 'Tiruthanni', 'Low'),
      (CAST(534 AS INTEGER), 'Trimbakeshwar (Maharashtra)', 'Low'),
      (CAST(1001 AS INTEGER), 'Ujjain', 'Low'),
      (CAST(70429 AS INTEGER), 'Varanasi', 'Low'),
      (CAST(217 AS INTEGER), 'Velankanni', 'Low'),
      (CAST(94782 AS INTEGER), 'Vrindavan', 'Low'),
      (CAST(300439 AS INTEGER), 'Yadagirigutta', 'Low')
  ) AS t(dest_id, pilgrim_city, high_low)
),
city_state AS (
  SELECT
    c.id AS city_id,
    c.parent_location AS state_id
  FROM lis.config_locations c
  WHERE c.geo = 'IND'
    AND c.is_expired = 0
    AND UPPER(TRIM(c.location_type)) = 'CITY'
    AND c.parent_location IS NOT NULL
),
srp AS (
  SELECT
    p.high_low,
    p.dest_id,
    p.pilgrim_city,
    CASE
      WHEN src_st.state_id IS NULL OR dst_st.state_id IS NULL THEN 'Unknown'
      WHEN src_st.state_id = dst_st.state_id THEN 'Intra'
      ELSE 'Inter'
    END AS journey_type,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  INNER JOIN pilgrim p ON sd.dest_id = p.dest_id
  LEFT JOIN city_state src_st ON sd.src_id = src_st.city_id
  LEFT JOIN city_state dst_st ON sd.dest_id = dst_st.city_id
  WHERE sd.country = 'IND'
    AND sd.os = 'Android'
    AND sd.channel = 'MOBILE_APP'
    AND sd.mri_session_id IS NOT NULL
    AND sd.__time >= TIMESTAMP '2026-08-23 18:30:00'
    AND sd.__time <  TIMESTAMP '2026-09-06 18:30:00'
  GROUP BY 1, 2, 3, 4, 5
),
txn AS (
  SELECT
    p.high_low,
    p.dest_id,
    p.pilgrim_city,
    CASE
      WHEN src_st.state_id IS NULL OR dst_st.state_id IS NULL THEN 'Unknown'
      WHEN src_st.state_id = dst_st.state_id THEN 'Intra'
      ELSE 'Inter'
    END AS journey_type,
    b.tin
  FROM transaction.bus_ticket_events b
  INNER JOIN pilgrim p ON b.destination_location_id = p.dest_id
  LEFT JOIN city_state src_st ON b.source_location_id = src_st.city_id
  LEFT JOIN city_state dst_st ON b.destination_location_id = dst_st.city_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.tin IS NOT NULL
    AND b.sales_channel IN ('RB:MOBILEWEB#droidapp', 'DROIDAPP')
    AND b.date_of_issue >= TIMESTAMP '2026-08-23 18:30:00'
    AND b.date_of_issue <  TIMESTAMP '2026-09-06 18:30:00'
  GROUP BY 1, 2, 3, 4, 5
),
srp_agg AS (
  SELECT high_low, dest_id, pilgrim_city, journey_type,
         COUNT(DISTINCT mri_session_id) AS srp_sessions
  FROM srp
  WHERE journey_type IN ('Intra', 'Inter')
  GROUP BY 1, 2, 3, 4
),
txn_agg AS (
  SELECT high_low, dest_id, pilgrim_city, journey_type,
         COUNT(DISTINCT tin) AS transactions
  FROM txn
  WHERE journey_type IN ('Intra', 'Inter')
  GROUP BY 1, 2, 3, 4
)
SELECT
  s.high_low,
  s.dest_id,
  s.pilgrim_city,
  s.journey_type,
  s.srp_sessions,
  COALESCE(t.transactions, 0) AS transactions,
  ROUND(100.0 * COALESCE(t.transactions, 0) / NULLIF(s.srp_sessions, 0), 2) AS cr_pct
FROM srp_agg s
LEFT JOIN txn_agg t
  ON s.high_low = t.high_low
 AND s.dest_id = t.dest_id
 AND s.journey_type = t.journey_type
ORDER BY s.high_low, s.pilgrim_city, s.journey_type;
