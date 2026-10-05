WITH date_params AS (
  SELECT CAST('2026-08-02 00:00:00' AS TIMESTAMP) AS start_ts,
         CAST('2026-09-01 00:00:00' AS TIMESTAMP) AS end_ts
),
top100_source AS (
  SELECT CAST(src AS BIGINT) AS src_id, CAST(dst AS BIGINT) AS dest_id
  FROM (VALUES
    (70429,733),
    (70429,1439),
    (70429,807),
    (70429,124),
    (70429,74820),
    (70429,624),
    (70429,76480),
    (70429,76431),
    (70429,76451),
    (70429,313),
    (70429,1377),
    (70429,84832),
    (70429,1290),
    (70429,1429),
    (70429,462),
    (70429,747),
    (70429,93947),
    (70429,1001),
    (70429,216383),
    (70429,78027),
    (70429,979),
    (70429,74699),
    (70429,70014),
    (70429,833),
    (70429,70024),
    (70429,122),
    (70429,73534),
    (70429,74153),
    (70429,551),
    (70429,130),
    (70429,94782),
    (70429,90355),
    (70429,74676),
    (70429,70015),
    (70429,77521),
    (70429,77167),
    (70429,91608),
    (70429,777),
    (70429,78023),
    (70429,69802),
    (70429,736),
    (70429,216812),
    (70429,802),
    (70429,197105),
    (70429,73529),
    (70429,95026),
    (70429,737),
    (70429,1437),
    (70429,1603),
    (70429,73533),
    (70429,90189),
    (70429,90113),
    (70429,473),
    (70429,90329),
    (70429,76576),
    (70429,197682),
    (70429,1169),
    (70429,74672),
    (70429,1443),
    (70429,771),
    (70429,219717),
    (70429,1514),
    (70429,808),
    (70429,219652),
    (70429,74694),
    (70429,842),
    (70429,197702),
    (70429,74680),
    (70429,197504),
    (70429,93983),
    (70429,85962),
    (70429,95015),
    (70429,74678),
    (70429,443),
    (70429,78041),
    (70429,80302),
    (70429,123),
    (70429,734),
    (70429,1369),
    (70429,95032),
    (70429,92827),
    (70429,80303),
    (70429,93925),
    (70429,74690),
    (70429,470),
    (70429,200914),
    (70429,77726),
    (70429,218596),
    (70429,69774),
    (70429,74136),
    (70429,217335),
    (70429,79617),
    (70429,76479),
    (70429,95013),
    (70429,76481),
    (70429,95007),
    (70429,1513),
    (70429,472),
    (70429,444),
    (70429,94781)
  ) AS t(src, dst)
),
top100_destination AS (
  SELECT CAST(src AS BIGINT) AS src_id, CAST(dst AS BIGINT) AS dest_id
  FROM (VALUES
    (733,70429),
    (1439,70429),
    (74820,70429),
    (124,70429),
    (807,70429),
    (624,70429),
    (76451,70429),
    (76431,70429),
    (76480,70429),
    (1377,70429),
    (313,70429),
    (1429,70429),
    (84832,70429),
    (1290,70429),
    (93947,70429),
    (747,70429),
    (462,70429),
    (979,70429),
    (78027,70429),
    (70014,70429),
    (216383,70429),
    (122,70429),
    (74699,70429),
    (1001,70429),
    (833,70429),
    (73534,70429),
    (69802,70429),
    (70015,70429),
    (70024,70429),
    (551,70429),
    (130,70429),
    (77521,70429),
    (74153,70429),
    (216812,70429),
    (197105,70429),
    (74676,70429),
    (91608,70429),
    (78023,70429),
    (76576,70429),
    (77167,70429),
    (74672,70429),
    (777,70429),
    (736,70429),
    (73529,70429),
    (1169,70429),
    (90355,70429),
    (473,70429),
    (737,70429),
    (1437,70429),
    (85962,70429),
    (74680,70429),
    (802,70429),
    (94782,70429),
    (1443,70429),
    (92827,70429),
    (74678,70429),
    (90113,70429),
    (90189,70429),
    (1514,70429),
    (74694,70429),
    (1369,70429),
    (95032,70429),
    (95026,70429),
    (808,70429),
    (93983,70429),
    (90329,70429),
    (80302,70429),
    (842,70429),
    (76481,70429),
    (197702,70429),
    (470,70429),
    (443,70429),
    (74136,70429),
    (309,70429),
    (78041,70429),
    (80303,70429),
    (197682,70429),
    (95514,70429),
    (123,70429),
    (95015,70429),
    (94840,70429),
    (1513,70429),
    (81384,70429),
    (201126,70429),
    (219652,70429),
    (71958,70429),
    (93925,70429),
    (218596,70429),
    (73533,70429),
    (69774,70429),
    (88443,70429),
    (193660,70429),
    (94838,70429),
    (76479,70429),
    (84828,70429),
    (73532,70429),
    (219717,70429),
    (199630,70429),
    (221347,70429),
    (95483,70429)
  ) AS t(src, dst)
),
srp_base AS (
  SELECT DISTINCT s.mri_session_id, s.route_id, s.src_id, s.dest_id
  FROM user_interaction.search_route_details s
  CROSS JOIN date_params d
  WHERE s.__time >= d.start_ts AND s.__time < d.end_ts
    AND s.country = 'IND'
    AND s.channel = 'MOBILE_APP'
    AND s.os = 'Android'
    AND s.tp_channel = 'INVALID'
    AND (s.src_id = 70429 OR s.dest_id = 70429)
),
srp_tagged AS (
  SELECT
    'Varanasi' AS city_name,
    'Source' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id,
    s.route_id
  FROM srp_base s
  LEFT JOIN top100_source t ON t.src_id = s.src_id AND t.dest_id = s.dest_id
  WHERE s.src_id = 70429
  UNION ALL
  SELECT
    'Varanasi' AS city_name,
    'Destination' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id,
    s.route_id
  FROM srp_base s
  LEFT JOIN top100_destination t ON t.src_id = s.src_id AND t.dest_id = s.dest_id
  WHERE s.dest_id = 70429
),
sl_deduped AS (
  SELECT DISTINCT sl.mri_session_id, sl.route_id
  FROM user_interaction.seat_layout_details sl
  CROSS JOIN date_params d
  WHERE sl.__time >= d.start_ts AND sl.__time < d.end_ts
    AND sl.country = 'IND' AND sl.os = 'Android'
),
pax_deduped AS (
  SELECT DISTINCT p.mri_session_id, p.route_id
  FROM user_interaction.cust_info_details p
  CROSS JOIN date_params d
  WHERE p.__time >= d.start_ts AND p.__time < d.end_ts
    AND p.country = 'IND' AND p.os = 'Android'
),
tco_deduped AS (
  SELECT DISTINCT t.mri_session_id, t.route_id
  FROM user_interaction.create_order_details t
  CROSS JOIN date_params d
  WHERE t.__time >= d.start_ts AND t.__time < d.end_ts
    AND t.country = 'IND' AND t.os = 'Android'
),
payment_deduped AS (
  SELECT DISTINCT o.mri_session_id, o.route_id
  FROM user_interaction.order_info_details o
  CROSS JOIN date_params d
  WHERE o.__time >= d.start_ts AND o.__time < d.end_ts
    AND o.country = 'IND' AND o.os = 'Android'
),
confirm_deduped AS (
  SELECT c.mri_session_id, c.route_id, COUNT(DISTINCT c.tin) AS tin_count
  FROM user_interaction.confirm_order_details c
  CROSS JOIN date_params d
  WHERE c.__time >= d.start_ts AND c.__time < d.end_ts
    AND c.country = 'IND' AND c.os = 'Android'
    AND c.status = 200
    AND c.tin IS NOT NULL AND c.tin NOT IN ('', 'null')
  GROUP BY c.mri_session_id, c.route_id
)
SELECT
  srp.city_name,
  srp.city_role,
  srp.sd_bucket,
  COUNT(DISTINCT srp.mri_session_id) AS srp_sessions,
  COUNT(DISTINCT sl.mri_session_id) AS sl_sessions,
  COUNT(DISTINCT pax.mri_session_id) AS pax_sessions,
  COUNT(DISTINCT tco.mri_session_id) AS tco_sessions,
  COUNT(DISTINCT pay.mri_session_id) AS payment_sessions,
  COUNT(DISTINCT conf.mri_session_id) AS confirm_sessions,
  COALESCE(SUM(conf.tin_count), 0) AS tin_count,
  ROUND(100.0 * COUNT(DISTINCT sl.mri_session_id) / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS sl_pct,
  ROUND(100.0 * COUNT(DISTINCT pax.mri_session_id) / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS pax_pct,
  ROUND(100.0 * COUNT(DISTINCT tco.mri_session_id) / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS tco_pct,
  ROUND(100.0 * COUNT(DISTINCT pay.mri_session_id) / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS payment_pct,
  ROUND(100.0 * COUNT(DISTINCT conf.mri_session_id) / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0), 2) AS cr_pct
FROM srp_tagged srp
LEFT JOIN sl_deduped sl ON srp.mri_session_id = sl.mri_session_id AND srp.route_id = sl.route_id
LEFT JOIN pax_deduped pax ON srp.mri_session_id = pax.mri_session_id AND srp.route_id = pax.route_id
LEFT JOIN tco_deduped tco ON srp.mri_session_id = tco.mri_session_id AND srp.route_id = tco.route_id
LEFT JOIN payment_deduped pay ON srp.mri_session_id = pay.mri_session_id AND srp.route_id = pay.route_id
LEFT JOIN confirm_deduped conf ON srp.mri_session_id = conf.mri_session_id AND srp.route_id = conf.route_id
GROUP BY srp.city_name, srp.city_role, srp.sd_bucket
ORDER BY srp.city_role, srp.sd_bucket
LIMIT 20
