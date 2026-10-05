-- Smoke: Forward pilgrim SRP by variant only (4–23 Aug IST)
SELECT
  CASE
    WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V2') THEN 'V2'
    WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V1') THEN 'V1'
    WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V0') THEN 'V0'
  END AS variant,
  sd.os AS channel,
  COUNT(DISTINCT sd.rb_user_id) AS fwd_users,
  COUNT(DISTINCT sd.mri_session_id) AS fwd_srp
FROM user_interaction.search_details sd
JOIN lis.city_tagging ct
  ON CAST(ct.city_id AS BIGINT) = sd.dest_id
 AND ct.category = 'Pilgrim'
WHERE sd.country = 'IND'
  AND sd.channel = 'MOBILE_APP'
  AND sd.os IN ('Android', 'iOS')
  AND sd.__time >= TIMESTAMP '2026-08-03 18:30:00'
  AND sd.__time < TIMESTAMP '2026-08-23 18:30:00'
  AND sd.rb_user_id IS NOT NULL
  AND (
    CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V0')
    OR CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V1')
    OR CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V2')
  )
GROUP BY 1, 2
ORDER BY 1, 2
