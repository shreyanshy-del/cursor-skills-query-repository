-- Live CR Analyser grain for dashboard CSV (India)
-- Output matches feb_data_check2.csv schema at day × user_type × platform × language
-- Change only t_start / t_end (UTC walls for IST days: prior day 18:30 → day 18:30)

WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
),
srp AS (
  SELECT
    CAST(date_add('minute', 330, sd.__time) AS DATE) AS dt,
    LOWER(COALESCE(sd.user_type, 'unknown')) AS user_type,
    LOWER(COALESCE(sd.os, 'unknown')) AS platform,
    LOWER(COALESCE(sd.language, 'en')) AS language,
    sd.mri_session_id
  FROM user_interaction.search_details sd
  CROSS JOIN params p
  WHERE sd.__time >= p.t_start AND sd.__time < p.t_end
    AND sd.country = 'IND'
    AND sd.mri_session_id IS NOT NULL
),
srp_dedup AS (
  SELECT dt, user_type, platform, language, mri_session_id
  FROM (
    SELECT
      *,
      row_number() OVER (PARTITION BY mri_session_id ORDER BY dt) AS rn
    FROM srp
  ) x
  WHERE rn = 1
),
sl AS (
  SELECT DISTINCT sl.mri_session_id
  FROM user_interaction.seat_layout_details sl
  INNER JOIN srp_dedup s ON sl.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE sl.__time >= p.t_start AND sl.__time < p.t_end AND sl.country = 'IND'
),
ci AS (
  SELECT DISTINCT ci.mri_session_id
  FROM user_interaction.cust_info_details ci
  INNER JOIN srp_dedup s ON ci.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE ci.__time >= p.t_start AND ci.__time < p.t_end
),
tco AS (
  SELECT DISTINCT co.mri_session_id
  FROM user_interaction.create_order_details co
  INNER JOIN srp_dedup s ON co.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE co.__time >= p.t_start AND co.__time < p.t_end
),
pay AS (
  SELECT DISTINCT oi.mri_session_id
  FROM user_interaction.order_info_details oi
  INNER JOIN srp_dedup s ON oi.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE oi.__time >= p.t_start AND oi.__time < p.t_end
),
pay_now AS (
  SELECT DISTINCT mp.mri_session_id
  FROM user_interaction.make_payment_details mp
  INNER JOIN srp_dedup s ON mp.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE mp.__time >= p.t_start AND mp.__time < p.t_end
),
bte AS (
  SELECT
    bte.mri_session_id,
    bte.tin,
    TRY_CAST(bte.no_of_seats AS DOUBLE) AS seats,
    TRY_CAST(bte.total_fare AS DOUBLE) AS gmv
  FROM transaction.bus_ticket_events bte
  INNER JOIN srp_dedup s ON bte.mri_session_id = s.mri_session_id
  CROSS JOIN params p
  WHERE bte.time_of_event >= p.t_start AND bte.time_of_event < p.t_end
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.tin IS NOT NULL
    AND bte.tin NOT IN ('', 'null')
),
joined AS (
  SELECT
    s.dt,
    s.user_type,
    CASE
      WHEN s.platform IN ('android') THEN 'android'
      WHEN s.platform IN ('ios', 'iphone', 'ipad') THEN 'ios'
      WHEN s.platform LIKE '%web%' THEN 'mobile_web'
      ELSE s.platform
    END AS platform,
    s.language,
    s.mri_session_id,
    CASE WHEN sl.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS hit_sl,
    CASE WHEN ci.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS hit_ci,
    CASE WHEN tco.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS hit_tco,
    CASE WHEN pay.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS hit_pay,
    CASE WHEN pn.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS hit_pay_now
  FROM srp_dedup s
  LEFT JOIN sl ON s.mri_session_id = sl.mri_session_id
  LEFT JOIN ci ON s.mri_session_id = ci.mri_session_id
  LEFT JOIN tco ON s.mri_session_id = tco.mri_session_id
  LEFT JOIN pay ON s.mri_session_id = pay.mri_session_id
  LEFT JOIN pay_now pn ON s.mri_session_id = pn.mri_session_id
),
txn AS (
  SELECT
    j.dt, j.user_type, j.platform, j.language,
    COUNT(DISTINCT b.tin) AS total_txns,
    SUM(COALESCE(b.seats, 1)) AS total_seats,
    SUM(COALESCE(b.gmv, 0)) AS gmv
  FROM joined j
  INNER JOIN bte b ON j.mri_session_id = b.mri_session_id
  GROUP BY 1,2,3,4
)
SELECT
  CAST(j.dt AS VARCHAR) AS dt,
  j.user_type,
  j.language,
  j.platform,
  COUNT(*) AS search_sessions,
  CAST(0 AS BIGINT) AS oops,
  SUM(j.hit_sl) AS seatlayout_sessions,
  CAST(0 AS BIGINT) AS seatlayout_clicks,
  CAST(0.0 AS DOUBLE) AS avg_clicks_per_session,
  CAST(0 AS BIGINT) AS seatlayout_failures,
  SUM(j.hit_ci) AS custinfo_sessions,
  SUM(j.hit_tco) AS create_order_sessions,
  CAST(0 AS BIGINT) AS tentative_error_sessions,
  CAST(0 AS BIGINT) AS total_tentative_errors,
  SUM(j.hit_pay) AS orderinfo_sessions,
  SUM(j.hit_pay_now) AS total_payment_attempts,
  COALESCE(MAX(t.total_txns), 0) AS total_txns,
  COALESCE(MAX(t.total_seats), 0) AS total_seats,
  CAST(0 AS BIGINT) AS discount_txns,
  CAST(0 AS BIGINT) AS reddeal_txns,
  COALESCE(MAX(t.gmv), 0) AS GMV,
  CAST(0.0 AS DOUBLE) AS payment_success_rate
FROM joined j
LEFT JOIN txn t
  ON j.dt = t.dt AND j.user_type = t.user_type
 AND j.platform = t.platform AND j.language = t.language
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4;
