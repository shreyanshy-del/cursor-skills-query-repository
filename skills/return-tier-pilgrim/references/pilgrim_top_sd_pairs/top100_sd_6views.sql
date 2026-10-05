-- Top 100 searched SD pairs — 6 views
-- Cities: Varanasi, Ayodhya, Prayagraj(Uttar Pradesh)
-- Each as Source and as Destination (Top 100 each)
-- Source: user_interaction.search_details
-- Metric: COUNT(DISTINCT mri_session_id)
-- Country: IND | Window: 2026-08-02 to 2026-09-01 (30 days)

WITH route_searches AS (
  SELECT
    sd.src_id,
    sd.dest_id,
    src_loc.location_name AS src_city,
    dst_loc.location_name AS dst_city,
    COUNT(DISTINCT sd.mri_session_id) AS search_count
  FROM user_interaction.search_details AS sd
  INNER JOIN lis.config_locations AS src_loc
    ON sd.src_id = src_loc.id
    AND src_loc.location_type = 'CITY'
    AND src_loc.is_expired = 0
  INNER JOIN lis.config_locations AS dst_loc
    ON sd.dest_id = dst_loc.id
    AND dst_loc.location_type = 'CITY'
    AND dst_loc.is_expired = 0
  WHERE
    sd.__time >= CAST('2026-08-02 00:00:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-09-01 00:00:00' AS TIMESTAMP)
    AND sd.country = 'IND'
  GROUP BY
    sd.src_id,
    sd.dest_id,
    src_loc.location_name,
    dst_loc.location_name
),
categorized AS (
  SELECT
    'Source' AS city_role,
    src_city AS anchor_city_name,
    src_id,
    dest_id,
    src_city,
    dst_city,
    search_count
  FROM route_searches
  WHERE
    LOWER(src_city) IN ('varanasi', 'ayodhya')
    OR (LOWER(src_city) LIKE '%prayagraj%' AND LOWER(src_city) LIKE '%uttar%' AND LOWER(src_city) LIKE '%pradesh%')
  UNION ALL
  SELECT
    'Destination' AS city_role,
    dst_city AS anchor_city_name,
    src_id,
    dest_id,
    src_city,
    dst_city,
    search_count
  FROM route_searches
  WHERE
    LOWER(dst_city) IN ('varanasi', 'ayodhya')
    OR (LOWER(dst_city) LIKE '%prayagraj%' AND LOWER(dst_city) LIKE '%uttar%' AND LOWER(dst_city) LIKE '%pradesh%')
),
ranked AS (
  SELECT
    city_role,
    anchor_city_name,
    src_id,
    dest_id,
    src_city,
    dst_city,
    search_count,
    ROW_NUMBER() OVER (
      PARTITION BY city_role, anchor_city_name
      ORDER BY search_count DESC
    ) AS rank
  FROM categorized
)
SELECT
  city_role,
  anchor_city_name,
  src_id,
  dest_id,
  src_city,
  dst_city,
  search_count,
  rank
FROM ranked
WHERE rank <= 100
ORDER BY
  anchor_city_name,
  city_role,
  rank
LIMIT 700
