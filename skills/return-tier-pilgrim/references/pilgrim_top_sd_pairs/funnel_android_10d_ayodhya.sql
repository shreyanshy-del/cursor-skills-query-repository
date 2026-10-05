WITH date_params AS (
  SELECT CAST('2026-08-22 00:00:00' AS TIMESTAMP) AS start_ts,
         CAST('2026-09-01 00:00:00' AS TIMESTAMP) AS end_ts
),
top100_source AS (
  SELECT CAST(src AS BIGINT) AS src_id, CAST(dst AS BIGINT) AS dest_id
  FROM (VALUES
    (76480,733),(76480,70429),(76480,807),(76480,1439),(76480,624),(76480,747),(76480,1290),(76480,78027),(76480,84832),(76480,833),
    (76480,1429),(76480,216383),(76480,1377),(76480,122),(76480,313),(76480,1001),(76480,70015),(76480,74820),(76480,1369),(76480,1443),
    (76480,777),(76480,70014),(76480,94782),(76480,197504),(76480,802),(76480,1514),(76480,462),(76480,736),(76480,124),(76480,90355),
    (76480,1437),(76480,77705),(76480,309),(76480,551),(76480,74699),(76480,74153),(76480,76431),(76480,76451),(76480,76481),(76480,71958),
    (76480,94840),(76480,979),(76480,808),(76480,73723),(76480,79617),(76480,1603),(76480,217335),(76480,73534),(76480,70024),(76480,130),
    (76480,94838),(76480,473),(76480,771),(76480,95032),(76480,69774),(76480,298723),(76480,77677),(76480,842),(76480,65850),(76480,90113),
    (76480,91608),(76480,77726),(76480,197105),(76480,95015),(76480,90189),(76480,79613),(76480,79729),(76480,1405),(76480,90329),(76480,1435),
    (76480,94990),(76480,94781),(76480,80303),(76480,470),(76480,1513),(76480,94839),(76480,94632),(76480,221347),(76480,93947),(76480,737),
    (76480,200888),(76480,1169),(76480,1438),(76480,74154),(76480,77682),(76480,73533),(76480,197682),(76480,1365),(76480,93233),(76480,78023),
    (76480,1372),(76480,472),(76480,74690),(76480,95026),(76480,74120),(76480,77521),(76480,74694),(76480,1538),(76480,444),(76480,80297)
  ) AS t(src, dst)
),
top100_destination AS (
  SELECT CAST(src AS BIGINT) AS src_id, CAST(dst AS BIGINT) AS dest_id
  FROM (VALUES
    (733,76480),(70429,76480),(1439,76480),(807,76480),(78027,76480),(624,76480),(747,76480),(1290,76480),(84832,76480),(1377,76480),
    (833,76480),(1429,76480),(70015,76480),(216383,76480),(313,76480),(70014,76480),(1443,76480),(122,76480),(1369,76480),(777,76480),
    (309,76480),(1001,76480),(802,76480),(736,76480),(124,76480),(94782,76480),(71958,76480),(73723,76480),(74820,76480),(74699,76480),
    (73534,76480),(90355,76480),(462,76480),(551,76480),(70024,76480),(94840,76480),(74153,76480),(1437,76480),(197504,76480),(76431,76480),
    (130,76480),(979,76480),(76451,76480),(95015,76480),(77705,76480),(91608,76480),(79617,76480),(1514,76480),(197105,76480),(76481,76480),
    (95032,76480),(77677,76480),(90113,76480),(69774,76480),(94838,76480),(79613,76480),(808,76480),(74676,76480),(90189,76480),(842,76480),
    (79729,76480),(1405,76480),(298723,76480),(473,76480),(1513,76480),(1365,76480),(93233,76480),(217335,76480),(1438,76480),(77682,76480),
    (94990,76480),(65850,76480),(1435,76480),(221347,76480),(1372,76480),(94978,76480),(200888,76480),(197682,76480),(80303,76480),(82100,76480),
    (94839,76480),(93947,76480),(74154,76480),(95480,76480),(95026,76480),(1169,76480),(90329,76480),(95234,76480),(204409,76480),(78023,76480),
    (470,76480),(205922,76480),(74690,76480),(94781,76480),(443,76480),(77167,76480),(94837,76480),(91770,76480),(94845,76480),(1538,76480)
  ) AS t(src, dst)
),
srp_deduped AS (
  SELECT DISTINCT s.mri_session_id, s.route_id, s.src_id, s.dest_id
  FROM user_interaction.search_route_details s
  CROSS JOIN date_params d
  WHERE s.__time >= d.start_ts AND s.__time < d.end_ts
    AND s.country = 'IND'
    AND s.os = 'Android'
    AND s.channel = 'MOBILE_APP'
    AND (s.src_id = 76480 OR s.dest_id = 76480)
),
srp_tagged AS (
  SELECT 'Ayodhya' AS city_name, 'Source' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id, s.route_id
  FROM srp_deduped s
  LEFT JOIN top100_source t ON t.src_id = s.src_id AND t.dest_id = s.dest_id
  WHERE s.src_id = 76480
  UNION ALL
  SELECT 'Ayodhya' AS city_name, 'Destination' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id, s.route_id
  FROM srp_deduped s
  LEFT JOIN top100_destination t ON t.src_id = s.src_id AND t.dest_id = s.dest_id
  WHERE s.dest_id = 76480
),
sl_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.seat_layout_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts
    AND country = 'IND' AND os = 'Android'
),
pax_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.cust_info_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts
    AND country = 'IND' AND os = 'Android'
),
tco_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.create_order_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts
    AND country = 'IND' AND os = 'Android'
),
payment_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.order_info_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts
    AND country = 'IND' AND os = 'Android'
),
confirm_deduped AS (
  SELECT mri_session_id, route_id, COUNT(DISTINCT tin) AS tin_count
  FROM user_interaction.confirm_order_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts
    AND country = 'IND' AND os = 'Android'
    AND status = 200 AND tin IS NOT NULL AND tin NOT IN ('', 'null')
  GROUP BY mri_session_id, route_id
)
SELECT
  srp.city_name, srp.city_role, srp.sd_bucket,
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
