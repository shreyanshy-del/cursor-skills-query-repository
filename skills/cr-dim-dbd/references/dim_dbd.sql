-- CR dim: DBD from search_details
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
    min_by(sd.__time, sd.__time) AS search_ts,
    min_by(TRY_CAST(sd.doj AS DATE), sd.__time) AS doj
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
    WHEN date_diff('day', CAST(date_add('minute', 330, search_ts) AS DATE), doj) <= 0 THEN '0'
    WHEN date_diff('day', CAST(date_add('minute', 330, search_ts) AS DATE), doj) = 1 THEN '1'
    WHEN date_diff('day', CAST(date_add('minute', 330, search_ts) AS DATE), doj) = 2 THEN '2'
    WHEN date_diff('day', CAST(date_add('minute', 330, search_ts) AS DATE), doj) = 3 THEN '3'
    WHEN date_diff('day', CAST(date_add('minute', 330, search_ts) AS DATE), doj) = 4 THEN '4'
    ELSE '5+'
  END AS dbd
FROM first_sd
WHERE doj IS NOT NULL;
