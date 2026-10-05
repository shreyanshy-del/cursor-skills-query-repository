-- CR dim: AC / Sleeper / Seater from search_route_details
WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
)
SELECT DISTINCT
  srd.mri_session_id,
  srd.route_id,
  srd.op_id AS operator_id,
  CASE WHEN srd.is_ac = TRUE THEN 'AC' ELSE 'non-AC' END AS ac_cut,
  CASE
    WHEN COALESCE(srd.is_sleeper, FALSE) AND COALESCE(srd.is_seater, FALSE) THEN 'Hybrid'
    WHEN COALESCE(srd.is_sleeper, FALSE) AND NOT COALESCE(srd.is_seater, FALSE) THEN 'Sleeper'
    WHEN COALESCE(srd.is_seater, FALSE) AND NOT COALESCE(srd.is_sleeper, FALSE) THEN 'Seater'
    ELSE 'NA'
  END AS seat_type
FROM user_interaction.search_route_details srd
CROSS JOIN params p
WHERE srd.__time >= p.t_start AND srd.__time < p.t_end
  AND srd.country = 'IND'
  AND srd.mri_session_id IS NOT NULL;
