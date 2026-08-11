-- =============================================================================
-- City-level (DESTINATION) route coverage vs POI proximity
-- "How many route_ids (out of Top 1000 SD routes serving a destination city)
--  have a dropping point within 1 km / within 3 km of that city's POI"
--
-- Dialect : Athena / Iceberg (Presto / Trino)
-- Grain   : one row per destination city
--
-- INPUTS (populate the two CTEs below):
--   sd_pairs(source_id, destination_id)        -> the "Top 1000 SD" scope
--   dp_buckets(dropping_point_id, bucket)      -> per-DP distance-from-POI bucket
--        bucket = 'Less than 1'   -> dropping point <= 1 km from POI
--        bucket = 'Between 1-3'   -> dropping point 1-3 km from POI
--   NOTE: dropping_point_id is globally unique, so dp_buckets is joined on
--         dropping_point_id only (this avoids destination NAME vs ID mismatches
--         such as "Allahabad" vs "Prayagraj" or "Mehandipur" vs
--         "Mehandipur balaji mandir").
--
-- Use build_coverage_query.py to auto-fill the two VALUES blocks from your
-- pasted data, OR paste the rows manually where indicated.
-- =============================================================================

WITH sd_pairs (source_id, destination_id) AS (
  VALUES
    -- (source_id, destination_id) -- Top 1000 SD pairs
    (124, 134),
    (122, 71756)
    -- ... <fill remaining SD pairs here> ...
),

dp_buckets (dropping_point_id, bucket) AS (
  VALUES
    -- (dropping_point_id, bucket)
    (27142203, 'Less than 1'),
    (25422059, 'Between 1-3')
    -- ... <fill remaining dropping-point buckets here> ...
)

SELECT
  dr.destination_id,
  cl.location_name AS destination_city,
  COUNT(DISTINCT r.route_id)                                                        AS total_routes,
  COUNT(DISTINCT CASE WHEN db.bucket = 'Less than 1' THEN r.route_id END)           AS routes_within_1km,
  COUNT(DISTINCT CASE WHEN db.bucket IN ('Less than 1', 'Between 1-3')
                      THEN r.route_id END)                                          AS routes_within_3km,
  ROUND(
    COUNT(DISTINCT CASE WHEN db.bucket = 'Less than 1' THEN r.route_id END) * 100.0
    / NULLIF(COUNT(DISTINCT r.route_id), 0), 2)                                     AS coverage_pct_1km,
  ROUND(
    COUNT(DISTINCT CASE WHEN db.bucket IN ('Less than 1', 'Between 1-3')
                        THEN r.route_id END) * 100.0
    / NULLIF(COUNT(DISTINCT r.route_id), 0), 2)                                     AS coverage_pct_3km
FROM lis.routes AS r
INNER JOIN "awsdatacatalog$iceberg-aws"."catalog:403299956707:s3tablescatalog/supply$schema:dimensions"."dim_route" AS dr
  ON r.route_id = dr.route_id
INNER JOIN inventory.inventory_dropping_points AS idp
  ON r.route_id = idp.route_id
INNER JOIN sd_pairs AS sp
  ON dr.source_id = sp.source_id
 AND dr.destination_id = sp.destination_id
LEFT JOIN lis.config_locations AS cl
  ON dr.destination_id = cl.id
 AND cl.location_type = 'CITY'
 AND cl.is_expired = 0
LEFT JOIN dp_buckets AS db
  ON idp.dropping_point_id = db.dropping_point_id
WHERE
  idp.doj >= CAST('2026-06-11' AS DATE)   -- weekly partition window; adjust as needed
  AND idp.doj < CAST('2026-06-18' AS DATE)
  AND r.status = 'Enabled'                -- live routes only
GROUP BY
  dr.destination_id,
  cl.location_name
ORDER BY
  total_routes DESC
LIMIT 1500;
