WITH date_params AS (
  SELECT CAST('2026-08-02 00:00:00' AS TIMESTAMP) AS start_ts,
         CAST('2026-09-01 00:00:00' AS TIMESTAMP) AS end_ts
),
top100_source AS (
  SELECT CAST(src AS BIGINT) AS src_id, CAST(dst AS BIGINT) AS dest_id
  FROM (VALUES
    (84832,733),
    (84832,1439),
    (84832,624),
    (84832,70429),
    (84832,807),
    (84832,73534),
    (84832,1429),
    (84832,1377),
    (84832,76480),
    (84832,1290),
    (84832,78027),
    (84832,462),
    (84832,313),
    (84832,70014),
    (84832,747),
    (84832,90355),
    (84832,216383),
    (84832,124),
    (84832,74153),
    (84832,979),
    (84832,70024),
    (84832,1001),
    (84832,197105),
    (84832,90113),
    (84832,443),
    (84832,76431),
    (84832,130),
    (84832,833),
    (84832,122),
    (84832,78023),
    (84832,74820),
    (84832,70015),
    (84832,74699),
    (84832,551),
    (84832,197682),
    (84832,76481),
    (84832,736),
    (84832,77718),
    (84832,95032),
    (84832,91608),
    (84832,476),
    (84832,217335),
    (84832,777),
    (84832,90189),
    (84832,94990),
    (84832,76451),
    (84832,1437),
    (84832,1369),
    (84832,95234),
    (84832,73533),
    (84832,205922),
    (84832,1443),
    (84832,473),
    (84832,88443),
    (84832,123),
    (84832,94782),
    (84832,79617),
    (84832,1169),
    (84832,94981),
    (84832,95514),
    (84832,808),
    (84832,94838),
    (84832,95483),
    (84832,77167),
    (84832,74676),
    (84832,93947),
    (84832,802),
    (84832,95026),
    (84832,219652),
    (84832,77705),
    (84832,94840),
    (84832,309),
    (84832,69774),
    (84832,95015),
    (84832,76479),
    (84832,771),
    (84832,1514),
    (84832,829),
    (84832,95013),
    (84832,74136),
    (84832,73532),
    (84832,73529),
    (84832,71958),
    (84832,84828),
    (84832,90329),
    (84832,73723),
    (84832,79613),
    (84832,444),
    (84832,95029),
    (84832,470),
    (84832,65850),
    (84832,1499),
    (84832,74672),
    (84832,254069),
    (84832,94978),
    (84832,80303),
    (84832,1003),
    (84832,205744),
    (84832,76576),
    (84832,74680)
  ) AS t(src, dst)
),
top100_destination AS (
  SELECT CAST(src AS BIGINT) AS src_id, CAST(dst AS BIGINT) AS dest_id
  FROM (VALUES
    (733,84832),
    (1439,84832),
    (624,84832),
    (70429,84832),
    (807,84832),
    (1429,84832),
    (1377,84832),
    (1290,84832),
    (73534,84832),
    (70014,84832),
    (313,84832),
    (747,84832),
    (76480,84832),
    (78027,84832),
    (216383,84832),
    (124,84832),
    (979,84832),
    (462,84832),
    (197105,84832),
    (74153,84832),
    (443,84832),
    (90355,84832),
    (70015,84832),
    (70024,84832),
    (1001,84832),
    (76431,84832),
    (833,84832),
    (130,84832),
    (74820,84832),
    (122,84832),
    (78023,84832),
    (90113,84832),
    (74699,84832),
    (91608,84832),
    (1369,84832),
    (736,84832),
    (76481,84832),
    (551,84832),
    (77718,84832),
    (76451,84832),
    (476,84832),
    (777,84832),
    (95032,84832),
    (1437,84832),
    (90189,84832),
    (79617,84832),
    (197682,84832),
    (95514,84832),
    (1169,84832),
    (88443,84832),
    (1443,84832),
    (217335,84832),
    (309,84832),
    (79613,84832),
    (95234,84832),
    (73723,84832),
    (74676,84832),
    (473,84832),
    (94990,84832),
    (93947,84832),
    (808,84832),
    (94838,84832),
    (84828,84832),
    (802,84832),
    (73532,84832),
    (123,84832),
    (73533,84832),
    (219652,84832),
    (76479,84832),
    (94840,84832),
    (69774,84832),
    (73529,84832),
    (205922,84832),
    (1365,84832),
    (77167,84832),
    (74136,84832),
    (95483,84832),
    (90329,84832),
    (1514,84832),
    (95026,84832),
    (94632,84832),
    (94981,84832),
    (94782,84832),
    (470,84832),
    (74672,84832),
    (71958,84832),
    (95015,84832),
    (829,84832),
    (1438,84832),
    (76576,84832),
    (1372,84832),
    (221347,84832),
    (69802,84832),
    (94978,84832),
    (1499,84832),
    (77705,84832),
    (256864,84832),
    (216812,84832),
    (1003,84832),
    (444,84832)
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
    AND (s.src_id = 84832 OR s.dest_id = 84832)
),
srp_tagged AS (
  SELECT
    'Prayagraj' AS city_name,
    'Source' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id,
    s.route_id
  FROM srp_base s
  LEFT JOIN top100_source t ON t.src_id = s.src_id AND t.dest_id = s.dest_id
  WHERE s.src_id = 84832
  UNION ALL
  SELECT
    'Prayagraj' AS city_name,
    'Destination' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id,
    s.route_id
  FROM srp_base s
  LEFT JOIN top100_destination t ON t.src_id = s.src_id AND t.dest_id = s.dest_id
  WHERE s.dest_id = 84832
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
