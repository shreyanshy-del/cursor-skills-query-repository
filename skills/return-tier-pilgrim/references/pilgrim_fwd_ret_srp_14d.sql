-- Pilgrim Forward SRP → Return SRP within 14d
-- Forward dates: STATIC | Return dates: DYNAMIC (per forward session)
-- IND | MOBILE_APP Android/iOS | Variant on FORWARD only

WITH date_params AS (
  SELECT
    TIMESTAMP '2026-08-03 18:30:00' AS fwd_start_utc,  -- 4 Aug 00:00 IST
    TIMESTAMP '2026-08-23 18:30:00' AS fwd_end_utc,    -- 24 Aug 00:00 IST (exclusive)
    14                              AS return_window_days
),

pilgrim_cities AS (
  SELECT DISTINCT CAST(city_id AS BIGINT) AS city_id
  FROM lis.city_tagging
  WHERE category = 'Pilgrim'
),

forward AS (
  SELECT DISTINCT
    sd.rb_user_id,
    sd.mri_session_id AS fwd_session_id,
    sd.src_id         AS fwd_src_id,
    sd.__time         AS fwd_time,
    DATE_ADD('day', p.return_window_days, sd.__time) AS ret_window_end,
    sd.os             AS channel,
    CASE
      WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V2') THEN 'V2'
      WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V1') THEN 'V1'
      WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V0') THEN 'V0'
    END AS variant
  FROM user_interaction.search_details sd
  CROSS JOIN date_params p
  INNER JOIN pilgrim_cities pc ON pc.city_id = sd.dest_id
  WHERE sd.country = 'IND'
    AND sd.channel = 'MOBILE_APP'
    AND sd.os IN ('Android', 'iOS')
    AND sd.rb_user_id IS NOT NULL
    AND sd.__time >= p.fwd_start_utc
    AND sd.__time <  p.fwd_end_utc
    AND (
      CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V0')
      OR CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V1')
      OR CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V2')
    )
),

fwd_key AS (
  SELECT
    f.rb_user_id,
    f.channel,
    f.variant,
    f.fwd_src_id,
    MIN(f.fwd_time) AS first_fwd_time,
    DATE_ADD('day', p.return_window_days, MIN(f.fwd_time)) AS ret_window_end
  FROM forward f
  CROSS JOIN date_params p
  GROUP BY 1, 2, 3, 4, p.return_window_days
),

return_srp AS (
  SELECT DISTINCT
    f.variant,
    f.channel,
    f.rb_user_id,
    r.mri_session_id AS ret_session_id
  FROM fwd_key f
  INNER JOIN user_interaction.search_details r
    ON r.rb_user_id = f.rb_user_id
   AND r.dest_id    = f.fwd_src_id
   AND r.os         = f.channel
   AND r.country    = 'IND'
   AND r.channel    = 'MOBILE_APP'
   AND r.__time     > f.first_fwd_time
   AND r.__time     < f.ret_window_end
)

SELECT
  f.variant,
  f.channel,
  COUNT(DISTINCT f.rb_user_id)      AS fwd_users,
  COUNT(DISTINCT f.fwd_session_id)  AS fwd_srp_sessions,
  COUNT(DISTINCT r.rb_user_id)      AS ret_srp_users,
  COUNT(DISTINCT r.ret_session_id)  AS ret_srp_sessions,
  ROUND(100.0 * COUNT(DISTINCT r.rb_user_id)
        / NULLIF(COUNT(DISTINCT f.rb_user_id), 0), 2) AS ret_srp_user_pct,
  ROUND(100.0 * COUNT(DISTINCT r.ret_session_id)
        / NULLIF(COUNT(DISTINCT f.fwd_session_id), 0), 2) AS ret_srp_session_pct
FROM forward f
LEFT JOIN return_srp r
  ON r.rb_user_id = f.rb_user_id
 AND r.variant    = f.variant
 AND r.channel    = f.channel
GROUP BY 1, 2
ORDER BY 1, 2
