WITH date_params AS (
  SELECT
    CAST('2026-08-02 00:00:00' AS TIMESTAMP) AS start_ts,
    CAST('2026-09-01 00:00:00' AS TIMESTAMP) AS end_ts
),
anchor_cities AS (
  SELECT city_id, city_name
  FROM (
    VALUES
      (CAST(70429 AS BIGINT), 'Varanasi'),
      (CAST(76480 AS BIGINT), 'Ayodhya'),
      (CAST(84832 AS BIGINT), 'Prayagraj')
  ) AS t(city_id, city_name)
),
-- Top 100 SDs by distinct search sessions (same definition as prior analysis)
sd_search_counts AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS search_count
  FROM user_interaction.search_details sd
  CROSS JOIN date_params d
  WHERE sd.__time >= d.start_ts
    AND sd.__time < d.end_ts
    AND sd.country = 'IND'
    AND (
      sd.src_id IN (70429, 76480, 84832)
      OR sd.dest_id IN (70429, 76480, 84832)
    )
  GROUP BY sd.src_id, sd.dest_id
),
top100_source AS (
  SELECT city_id, city_name, src_id, dest_id
  FROM (
    SELECT
      a.city_id,
      a.city_name,
      s.src_id,
      s.dest_id,
      ROW_NUMBER() OVER (PARTITION BY a.city_id ORDER BY s.search_count DESC) AS rn
    FROM sd_search_counts s
    INNER JOIN anchor_cities a ON s.src_id = a.city_id
  ) x
  WHERE rn <= 100
),
top100_destination AS (
  SELECT city_id, city_name, src_id, dest_id
  FROM (
    SELECT
      a.city_id,
      a.city_name,
      s.src_id,
      s.dest_id,
      ROW_NUMBER() OVER (PARTITION BY a.city_id ORDER BY s.search_count DESC) AS rn
    FROM sd_search_counts s
    INNER JOIN anchor_cities a ON s.dest_id = a.city_id
  ) x
  WHERE rn <= 100
),
-- SRP base for all 3 cities as source or destination
srp_base AS (
  SELECT DISTINCT
    s.mri_session_id,
    s.route_id,
    s.src_id,
    s.dest_id
  FROM user_interaction.search_route_details s
  CROSS JOIN date_params d
  WHERE s.__time >= d.start_ts
    AND s.__time < d.end_ts
    AND s.country = 'IND'
    AND s.channel IN ('MOBILE_APP', 'MOBILE_WEB', 'WEB_DIRECT')
    AND (
      s.src_id IN (70429, 76480, 84832)
      OR s.dest_id IN (70429, 76480, 84832)
    )
),
-- Expand to 6 views (city x role) with Top100/Rest bucket
srp_tagged AS (
  SELECT
    a.city_name,
    'Source' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id,
    s.route_id
  FROM srp_base s
  INNER JOIN anchor_cities a ON s.src_id = a.city_id
  LEFT JOIN top100_source t
    ON t.city_id = a.city_id
   AND t.src_id = s.src_id
   AND t.dest_id = s.dest_id
  UNION ALL
  SELECT
    a.city_name,
    'Destination' AS city_role,
    CASE WHEN t.src_id IS NOT NULL THEN 'Top100' ELSE 'Rest' END AS sd_bucket,
    s.mri_session_id,
    s.route_id
  FROM srp_base s
  INNER JOIN anchor_cities a ON s.dest_id = a.city_id
  LEFT JOIN top100_destination t
    ON t.city_id = a.city_id
   AND t.src_id = s.src_id
   AND t.dest_id = s.dest_id
),
sl_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.seat_layout_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts AND country = 'IND'
),
pax_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.cust_info_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts AND country = 'IND'
),
tco_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.create_order_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts AND country = 'IND'
),
payment_deduped AS (
  SELECT DISTINCT mri_session_id, route_id
  FROM user_interaction.order_info_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts AND __time < d.end_ts AND country = 'IND'
),
confirm_deduped AS (
  SELECT
    mri_session_id,
    route_id,
    COUNT(DISTINCT tin) AS tin_count
  FROM user_interaction.confirm_order_details
  CROSS JOIN date_params d
  WHERE __time >= d.start_ts
    AND __time < d.end_ts
    AND country = 'IND'
    AND status = 200
    AND tin IS NOT NULL
    AND tin NOT IN ('', 'null')
  GROUP BY mri_session_id, route_id
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
LEFT JOIN sl_deduped sl
  ON srp.mri_session_id = sl.mri_session_id AND srp.route_id = sl.route_id
LEFT JOIN pax_deduped pax
  ON srp.mri_session_id = pax.mri_session_id AND srp.route_id = pax.route_id
LEFT JOIN tco_deduped tco
  ON srp.mri_session_id = tco.mri_session_id AND srp.route_id = tco.route_id
LEFT JOIN payment_deduped pay
  ON srp.mri_session_id = pay.mri_session_id AND srp.route_id = pay.route_id
LEFT JOIN confirm_deduped conf
  ON srp.mri_session_id = conf.mri_session_id AND srp.route_id = conf.route_id
GROUP BY srp.city_name, srp.city_role, srp.sd_bucket
ORDER BY srp.city_name, srp.city_role, srp.sd_bucket
LIMIT 50
