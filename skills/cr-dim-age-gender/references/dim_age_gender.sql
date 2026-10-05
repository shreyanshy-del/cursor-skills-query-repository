-- CR dim: Age / Gender from svoc.svoc_booker
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
    min_by(sd.rb_user_id, sd.__time) AS rb_user_id
  FROM user_interaction.search_details sd
  INNER JOIN srp s ON sd.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE sd.__time >= p.t_start AND sd.__time < p.t_end
    AND sd.country = 'IND'
  GROUP BY 1
)
SELECT
  f.mri_session_id,
  f.rb_user_id,
  CASE
    WHEN LOWER(COALESCE(b.gender, '')) IN ('female', 'f') THEN 'Female'
    WHEN LOWER(COALESCE(b.gender, '')) IN ('male', 'm') THEN 'Male'
    ELSE 'Unknown'
  END AS gender
  -- Age: expose available SVOC age/YOB columns from your catalog, e.g. b.age / b.yob
FROM first_sd f
LEFT JOIN svoc.svoc_booker b
  ON TRY_CAST(b.rb_userid AS BIGINT) = f.rb_user_id
 AND f.rb_user_id > 0;
