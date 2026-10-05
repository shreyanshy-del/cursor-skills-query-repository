-- CR dim: Operator from search_route_details.op_id
WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
)
SELECT DISTINCT
  srd.mri_session_id,
  srd.op_id AS operator_id,
  srd.route_id,
  srd.src_id,
  srd.dest_id
FROM user_interaction.search_route_details srd
CROSS JOIN params p
WHERE srd.__time >= p.t_start AND srd.__time < p.t_end
  AND srd.country = 'IND'
  AND srd.mri_session_id IS NOT NULL
  AND srd.op_id IS NOT NULL;
