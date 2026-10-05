-- CR dim: Short / Long from lis.short_route_sds
WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
),
short_routes AS (
  SELECT DISTINCT src_id, dest_id
  FROM lis.short_route_sds
  WHERE cohort = '2026'
),
srp AS (
  SELECT DISTINCT sd.mri_session_id
  FROM user_interaction.search_details sd
  CROSS JOIN params p
  WHERE sd.__time >= p.t_start AND sd.__time < p.t_end
    AND sd.country = 'IND' AND sd.mri_session_id IS NOT NULL
),
first_sd AS (
  SELECT
    sd.mri_session_id,
    min_by(sd.src_id, sd.__time) AS src_id,
    min_by(sd.dest_id, sd.__time) AS dest_id
  FROM user_interaction.search_details sd
  INNER JOIN srp s ON sd.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE sd.__time >= p.t_start AND sd.__time < p.t_end
    AND sd.country = 'IND'
  GROUP BY 1
)
SELECT
  f.mri_session_id,
  CASE WHEN sr.src_id IS NOT NULL THEN 'Short' ELSE 'Long' END AS sd_type
FROM first_sd f
LEFT JOIN short_routes sr
  ON f.src_id = sr.src_id AND f.dest_id = sr.dest_id;
