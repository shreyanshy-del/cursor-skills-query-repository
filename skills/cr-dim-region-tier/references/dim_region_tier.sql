-- CR dim: Region/State from lis.config_locations.parent_location
WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
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
  f.src_id,
  f.dest_id,
  src.parent_location AS src_state_id,
  dst.parent_location AS dest_state_id,
  src.region AS src_region,
  dst.region AS dest_region
FROM first_sd f
LEFT JOIN lis.config_locations src
  ON f.src_id = src.id AND src.geo = 'IND'
LEFT JOIN lis.config_locations dst
  ON f.dest_id = dst.id AND dst.geo = 'IND';
