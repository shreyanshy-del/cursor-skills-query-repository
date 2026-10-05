-- CR dim: LMB / Non-LMB from search_details (DBD 0 only)
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
),
dbd0 AS (
  SELECT
    mri_session_id,
    search_ts,
    hour(date_add('minute', 330, search_ts)) AS ist_hour
  FROM first_sd
  WHERE doj IS NOT NULL
    AND date_diff('day', CAST(date_add('minute', 330, search_ts) AS DATE), doj) <= 0
)
SELECT
  mri_session_id,
  CASE WHEN ist_hour BETWEEN 17 AND 23 THEN 'LMB' ELSE 'Non-LMB' END AS lmb_cut
FROM dbd0;
