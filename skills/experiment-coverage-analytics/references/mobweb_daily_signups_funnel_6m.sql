-- Mobweb daily SIGNUPS -> same-day Mobweb sessions, funnel throughput, transactions
-- Window: IST 2026-03-31 to 2026-09-29 (UTC 2026-03-30 18:30 to 2026-09-29 18:30). Country IND.
-- Signup = capi.user_data.created_on (IST day). user_data has no channel column, so a signup is
-- Mobweb when the same user_id has a Mobweb row in capi.uid_login_action on the same IST day.
-- created_on / login_datetime assumed stored in UTC (+330 min to IST). Drop the interval if they are already IST.

WITH mobweb_login AS (
  SELECT DISTINCT
    CAST(l.user_id AS VARCHAR) AS user_id,
    CAST(l.login_datetime + INTERVAL '330' MINUTE AS DATE) AS dt
  FROM capi.uid_login_action l
  WHERE l.login_datetime >= TIMESTAMP '2026-03-30 18:30:00'
    AND l.login_datetime <  TIMESTAMP '2026-09-29 18:30:00'
    AND UPPER(l.channel) IN ('MOBILE_WEB', 'MOBWEB', 'MWEB', 'MOB_WEB')
),
signups AS (
  SELECT DISTINCT
    CAST(u.user_id AS VARCHAR) AS user_id,
    CAST(u.created_on + INTERVAL '330' MINUTE AS DATE) AS dt
  FROM capi.user_data u
  WHERE u.created_on >= TIMESTAMP '2026-03-30 18:30:00'
    AND u.created_on <  TIMESTAMP '2026-09-29 18:30:00'
),
cohort AS (
  SELECT s.user_id, s.dt
  FROM signups s
  JOIN mobweb_login m ON m.user_id = s.user_id AND m.dt = s.dt
),
srp AS (
  SELECT DISTINCT
    CAST(at_timezone(__time, 'Asia/Kolkata') AS DATE) AS dt,
    CAST(rb_user_id AS VARCHAR) AS user_id,
    mri_session_id,
    route_id
  FROM user_interaction.search_route_details
  WHERE __time >= TIMESTAMP '2026-03-30 18:30:00'
    AND __time <  TIMESTAMP '2026-09-29 18:30:00'
    AND country = 'IND'
    AND channel = 'MOBILE_WEB'
    AND rb_user_id IS NOT NULL
),
sl AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.seat_layout_details
  WHERE __time >= TIMESTAMP '2026-03-30 18:30:00'
    AND __time <  TIMESTAMP '2026-09-29 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
custinfo AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.cust_info_details
  WHERE __time >= TIMESTAMP '2026-03-30 18:30:00'
    AND __time <  TIMESTAMP '2026-09-29 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
tentative AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.create_order_details
  WHERE __time >= TIMESTAMP '2026-03-30 18:30:00'
    AND __time <  TIMESTAMP '2026-09-29 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
payment AS (
  SELECT mri_session_id, route_id
  FROM user_interaction.order_info_details
  WHERE __time >= TIMESTAMP '2026-03-30 18:30:00'
    AND __time <  TIMESTAMP '2026-09-29 18:30:00'
    AND country = 'IND'
  GROUP BY 1, 2
),
confirm AS (
  SELECT DISTINCT mri_session_id, route_id, CAST(tin AS VARCHAR) AS tin
  FROM user_interaction.confirm_order_details
  WHERE __time >= TIMESTAMP '2026-03-30 18:30:00'
    AND __time <  TIMESTAMP '2026-09-29 18:30:00'
    AND country = 'IND'
    AND status = 200
    AND tin IS NOT NULL
    AND tin NOT IN ('', 'null')
),
txn AS (
  SELECT DISTINCT CAST(tin AS VARCHAR) AS tin
  FROM transaction.bus_ticket_events
  WHERE country_code = 'IND'
    AND event_type = 101
    AND event_class = 2
    AND date_of_issue >= TIMESTAMP '2026-03-30 18:30:00'
    AND date_of_issue <  TIMESTAMP '2026-09-30 18:30:00'
),
total_users AS (
  SELECT
    CAST(at_timezone(__time, 'Asia/Kolkata') AS DATE) AS dt,
    COUNT(DISTINCT mri_client_id) AS total_users
  FROM user_interaction.search_route_details
  WHERE __time >= TIMESTAMP '2026-03-30 18:30:00'
    AND __time <  TIMESTAMP '2026-09-29 18:30:00'
    AND country = 'IND'
    AND channel = 'MOBILE_WEB'
    AND mri_client_id IS NOT NULL
    AND mri_client_id NOT IN ('', 'null')
  GROUP BY 1
),
daily AS (
  SELECT
    c.dt,
    COUNT(DISTINCT c.user_id)                  AS signups,
    COUNT(DISTINCT s.user_id)                  AS signups_with_srp,
    COUNT(DISTINCT s.mri_session_id)           AS srp_sessions,
    COUNT(DISTINCT sl.mri_session_id)          AS sl_sessions,
    COUNT(DISTINCT ci.mri_session_id)          AS custinfo_sessions,
    COUNT(DISTINCT tc.mri_session_id)          AS tentative_sessions,
    COUNT(DISTINCT pm.mri_session_id)          AS payment_sessions,
    COUNT(DISTINCT cf.mri_session_id)          AS confirm_sessions,
    COUNT(DISTINCT t.tin)                      AS transactions,
    COUNT(DISTINCT CASE WHEN t.tin IS NOT NULL THEN s.user_id END) AS transacting_users
  FROM cohort c
  LEFT JOIN srp s        ON s.user_id = c.user_id AND s.dt = c.dt
  LEFT JOIN sl           ON sl.mri_session_id = s.mri_session_id AND sl.route_id = s.route_id
  LEFT JOIN custinfo ci  ON ci.mri_session_id = s.mri_session_id AND ci.route_id = s.route_id
  LEFT JOIN tentative tc ON tc.mri_session_id = s.mri_session_id AND tc.route_id = s.route_id
  LEFT JOIN payment pm   ON pm.mri_session_id = s.mri_session_id AND pm.route_id = s.route_id
  LEFT JOIN confirm cf   ON cf.mri_session_id = s.mri_session_id AND cf.route_id = s.route_id
  LEFT JOIN txn t        ON t.tin = cf.tin
  GROUP BY 1
)
SELECT
  d.dt,
  d.signups,
  tu.total_users,
  ROUND(100.0 * d.signups / NULLIF(tu.total_users, 0), 2) AS signup_share_of_total_users_pct,
  d.signups_with_srp,
  srp_sessions,
  sl_sessions,
  custinfo_sessions,
  tentative_sessions,
  payment_sessions,
  confirm_sessions,
  transactions,
  transacting_users,
  ROUND(100.0 * sl_sessions        / NULLIF(srp_sessions, 0), 2)       AS srp_to_sl_pct,
  ROUND(100.0 * custinfo_sessions  / NULLIF(sl_sessions, 0), 2)        AS sl_to_custinfo_pct,
  ROUND(100.0 * tentative_sessions / NULLIF(custinfo_sessions, 0), 2)  AS custinfo_to_tentative_pct,
  ROUND(100.0 * payment_sessions   / NULLIF(tentative_sessions, 0), 2) AS tentative_to_payment_pct,
  ROUND(100.0 * confirm_sessions   / NULLIF(payment_sessions, 0), 2)   AS payment_to_confirm_pct,
  ROUND(100.0 * transactions       / NULLIF(srp_sessions, 0), 2)       AS cr_pct,
  ROUND(100.0 * d.transacting_users  / NULLIF(d.signups, 0), 2)       AS signup_to_txn_pct
FROM daily d
LEFT JOIN total_users tu ON tu.dt = d.dt
ORDER BY d.dt;
