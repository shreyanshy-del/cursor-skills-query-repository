-- CR dim: Custom SD from search_route_details
-- Replace custom_sd VALUES with the user-supplied list
WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
),
custom_sd AS (
  SELECT src_id, dest_id FROM (VALUES
    (122, 123),
    (123, 122)
  ) AS t(src_id, dest_id)
),
hits AS (
  SELECT DISTINCT
    srd.mri_session_id,
    srd.src_id,
    srd.dest_id,
    srd.route_id
  FROM user_interaction.search_route_details srd
  INNER JOIN custom_sd c
    ON srd.src_id = c.src_id AND srd.dest_id = c.dest_id
  CROSS JOIN params p
  WHERE srd.__time >= p.t_start AND srd.__time < p.t_end
    AND srd.country = 'IND'
    AND srd.mri_session_id IS NOT NULL
)
SELECT
  mri_session_id,
  src_id,
  dest_id,
  route_id,
  CAST(src_id AS VARCHAR) || '_' || CAST(dest_id AS VARCHAR) AS sd_id,
  TRUE AS in_custom_sd
FROM hits;
