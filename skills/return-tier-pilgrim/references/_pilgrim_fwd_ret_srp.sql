-- Forward pilgrim SRP + Return SRP within 14d (session-deduped)
-- 4–23 Aug 2026 IST | MOBILE_APP Android/iOS | IND | PILGRIM_RETURN_OFFER V0/V1/V2

WITH pilgrim_cities AS (
  SELECT DISTINCT CAST(city_id AS BIGINT) AS city_id
  FROM lis.city_tagging
  WHERE category = 'Pilgrim'
),
sd_raw AS (
  SELECT
    rb_user_id,
    mri_session_id,
    src_id,
    dest_id,
    __time,
    os AS channel,
    CASE
      WHEN CONTAINS(channel_exp_info, 'PILGRIM_RETURN_OFFER:V2') THEN 'V2'
      WHEN CONTAINS(channel_exp_info, 'PILGRIM_RETURN_OFFER:V1') THEN 'V1'
      WHEN CONTAINS(channel_exp_info, 'PILGRIM_RETURN_OFFER:V0') THEN 'V0'
    END AS variant
  FROM user_interaction.search_details
  WHERE country = 'IND'
    AND channel = 'MOBILE_APP'
    AND os IN ('Android', 'iOS')
    AND __time >= TIMESTAMP '2026-08-03 18:30:00'
    AND __time < TIMESTAMP '2026-09-06 18:30:00'
    AND rb_user_id IS NOT NULL
    AND (
      CONTAINS(channel_exp_info, 'PILGRIM_RETURN_OFFER:V0')
      OR CONTAINS(channel_exp_info, 'PILGRIM_RETURN_OFFER:V1')
      OR CONTAINS(channel_exp_info, 'PILGRIM_RETURN_OFFER:V2')
    )
),
sd_var AS (
  SELECT
    rb_user_id,
    mri_session_id,
    src_id,
    dest_id,
    __time,
    channel,
    variant
  FROM (
    SELECT
      sd_raw.*,
      ROW_NUMBER() OVER (
        PARTITION BY mri_session_id
        ORDER BY __time
      ) AS rn
    FROM sd_raw
  ) x
  WHERE rn = 1
),
fwd AS (
  SELECT
    s.rb_user_id,
    s.mri_session_id AS fwd_session_id,
    s.src_id AS fwd_src_id,
    s.__time AS fwd_time,
    s.channel,
    s.variant
  FROM sd_var s
  INNER JOIN pilgrim_cities pc ON pc.city_id = s.dest_id
  WHERE s.__time < TIMESTAMP '2026-08-23 18:30:00'
),
fwd_key AS (
  SELECT
    rb_user_id,
    channel,
    variant,
    fwd_src_id,
    MIN(fwd_time) AS first_fwd_time
  FROM fwd
  GROUP BY 1, 2, 3, 4
),
ret_hit AS (
  SELECT DISTINCT
    f.variant,
    f.channel,
    f.rb_user_id,
    r.mri_session_id AS ret_session_id
  FROM fwd_key f
  INNER JOIN sd_var r
    ON r.rb_user_id = f.rb_user_id
   AND r.dest_id = f.fwd_src_id
   AND r.channel = f.channel
   AND r.__time > f.first_fwd_time
   AND r.__time < DATE_ADD('day', 14, f.first_fwd_time)
)
SELECT
  f.variant,
  f.channel,
  COUNT(DISTINCT f.rb_user_id) AS fwd_users,
  COUNT(DISTINCT f.fwd_session_id) AS fwd_srp,
  COUNT(DISTINCT r.rb_user_id) AS ret_users_14d,
  COUNT(DISTINCT r.ret_session_id) AS ret_srp_14d,
  ROUND(
    100.0 * COUNT(DISTINCT r.rb_user_id) / NULLIF(COUNT(DISTINCT f.rb_user_id), 0),
    2
  ) AS ret_user_pct
FROM fwd f
LEFT JOIN ret_hit r
  ON r.rb_user_id = f.rb_user_id
 AND r.variant = f.variant
 AND r.channel = f.channel
GROUP BY 1, 2
ORDER BY 1, 2
