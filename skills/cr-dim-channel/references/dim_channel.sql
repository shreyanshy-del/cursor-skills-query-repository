-- CR dim: Channel from search_details
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
    min_by(sd.os, sd.__time) AS os,
    min_by(sd.channel, sd.__time) AS channel
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
    WHEN UPPER(TRIM(COALESCE(channel, ''))) = 'MOBILE_WEB' THEN 'Mobweb'
    WHEN UPPER(TRIM(COALESCE(channel, ''))) = 'WEB_DIRECT' THEN 'Web'
    WHEN UPPER(TRIM(COALESCE(channel, ''))) = 'MOBILE_APP'
     AND UPPER(TRIM(COALESCE(os, ''))) = 'ANDROID' THEN 'Android'
    WHEN UPPER(TRIM(COALESCE(channel, ''))) = 'MOBILE_APP'
     AND UPPER(TRIM(COALESCE(os, ''))) IN ('IOS', 'IPHONE', 'IPAD') THEN 'iOS'
    ELSE 'Other'
  END AS channel_cut
FROM first_sd;
