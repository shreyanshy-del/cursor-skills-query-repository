-- =============================================================================
-- City-level route coverage: boarding points within 3 km and 5 km of POI
-- Distance: Haversine (open-source, straight-line / crow-flies)
-- SQL dialect: Presto / Trino (adjust table name as needed)
-- =============================================================================
-- Replace `your_schema.poi_dp_mapping` with your actual table/view name
-- after loading "POI and DP Mapping.xlsx"
-- =============================================================================

WITH poi_dp_base AS (
  SELECT
    dest_id,
    destination,
    dropping_point_id,
    dropping_point,
    CAST(poi_lat AS DOUBLE)   AS poi_lat,
    CAST(poi_long AS DOUBLE)  AS poi_long,
    TRY_CAST(dp_latitude AS DOUBLE)  AS dp_lat,
    TRY_CAST(dp_longitude AS DOUBLE) AS dp_lon
  FROM your_schema.poi_dp_mapping
  WHERE poi_lat IS NOT NULL
    AND poi_long IS NOT NULL
    AND TRY_CAST(dp_latitude AS DOUBLE) IS NOT NULL
    AND TRY_CAST(dp_longitude AS DOUBLE) IS NOT NULL
    AND UPPER(CAST(dp_latitude AS VARCHAR)) NOT IN ('\N', 'NULL', 'NAN')
),

poi_dp_with_distance AS (
  SELECT
    dest_id,
    destination,
    dropping_point_id,
    dropping_point,
    poi_lat,
    poi_long,
    dp_lat,
    dp_lon,
    -- Haversine distance in kilometers (WGS84 sphere, radius 6371 km)
    6371.0 * 2 * ASIN(
      SQRT(
        POWER(SIN(RADIANS(dp_lat - poi_lat) / 2), 2)
        + COS(RADIANS(poi_lat)) * COS(RADIANS(dp_lat))
          * POWER(SIN(RADIANS(dp_lon - poi_long) / 2), 2)
      )
    ) AS distance_km
  FROM poi_dp_base
),

city_coverage AS (
  SELECT
    dest_id,
    destination,
    MAX(poi_lat)  AS poi_lat,
    MAX(poi_long) AS poi_long,

    -- Total boarding points (routes) with valid coordinates per city
    COUNT(DISTINCT dropping_point_id) AS total_routes_with_coords,

    -- Boarding points within distance thresholds
    COUNT(DISTINCT CASE WHEN distance_km < 3  THEN dropping_point_id END) AS routes_within_3_km,
    COUNT(DISTINCT CASE WHEN distance_km < 5  THEN dropping_point_id END) AS routes_within_5_km,
    COUNT(DISTINCT CASE WHEN distance_km >= 3 AND distance_km < 5 THEN dropping_point_id END) AS routes_between_3_and_5_km,
    COUNT(DISTINCT CASE WHEN distance_km >= 5 THEN dropping_point_id END) AS routes_beyond_5_km,

    -- Coverage % = (routes in range / total routes with coords) * 100
    ROUND(
      100.0 * COUNT(DISTINCT CASE WHEN distance_km < 3 THEN dropping_point_id END)
      / NULLIF(COUNT(DISTINCT dropping_point_id), 0),
      2
    ) AS coverage_pct_within_3_km,

    ROUND(
      100.0 * COUNT(DISTINCT CASE WHEN distance_km < 5 THEN dropping_point_id END)
      / NULLIF(COUNT(DISTINCT dropping_point_id), 0),
      2
    ) AS coverage_pct_within_5_km,

    -- Distance stats for context
    ROUND(MIN(distance_km), 3) AS min_distance_km,
    ROUND(MAX(distance_km), 3) AS max_distance_km,
    ROUND(AVG(distance_km), 3) AS avg_distance_km

  FROM poi_dp_with_distance
  GROUP BY dest_id, destination
)

SELECT
  dest_id,
  destination,
  poi_lat,
  poi_long,
  total_routes_with_coords,
  routes_within_3_km,
  routes_within_5_km,
  routes_between_3_and_5_km,
  routes_beyond_5_km,
  coverage_pct_within_3_km,
  coverage_pct_within_5_km,
  min_distance_km,
  max_distance_km,
  avg_distance_km
FROM city_coverage
ORDER BY coverage_pct_within_3_km DESC, destination;


-- =============================================================================
-- OPTIONAL: Overall summary across all cities
-- =============================================================================
/*
SELECT
  COUNT(*) AS total_cities,
  SUM(total_routes_with_coords) AS total_routes_all_cities,
  SUM(routes_within_3_km) AS total_routes_within_3_km,
  SUM(routes_within_5_km) AS total_routes_within_5_km,
  ROUND(100.0 * SUM(routes_within_3_km) / NULLIF(SUM(total_routes_with_coords), 0), 2) AS overall_coverage_pct_3_km,
  ROUND(100.0 * SUM(routes_within_5_km) / NULLIF(SUM(total_routes_with_coords), 0), 2) AS overall_coverage_pct_5_km
FROM city_coverage;
*/
