-- CR dim: Usertype from search_details (first row per session)
-- Join to cr-analyser SRP cohort on mri_session_id
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
    min_by(sd.user_type, sd.__time) AS user_type_raw
  FROM user_interaction.search_details sd
  INNER JOIN srp s ON sd.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE sd.__time >= p.t_start AND sd.__time < p.t_end
    AND sd.country = 'IND'
  GROUP BY 1
)
SELECT
  mri_session_id,
  CASE
    WHEN UPPER(TRIM(COALESCE(user_type_raw, ''))) = 'GUEST' THEN 'GUEST'
    WHEN UPPER(TRIM(COALESCE(user_type_raw, ''))) = 'NEW' THEN 'NEW'
    WHEN UPPER(TRIM(COALESCE(user_type_raw, ''))) IN ('RETURNING', 'EXISTING', 'OLD') THEN 'RETURNING'
    ELSE 'OTHER'
  END AS usertype
FROM first_sd;
