-- Mobweb daily LOGINS -> same-day Mobweb sessions, funnel throughput, transactions
-- Window: IST 2026-03-31 to 2026-09-29 (UTC 2026-03-30 18:30 to 2026-09-29 18:30). Country IND.
-- Login = capi.uid_login_action row with a Mobweb channel (IST day of login_datetime).
-- login_datetime assumed stored in UTC (+330 min to IST). Drop the interval if it is already IST.

WITH login_raw AS (
  SELECT
    CAST(l.user_id AS VARCHAR) AS user_id,
    l.mri_session_id,
    CAST(l.login_datetime + INTERVAL '330' MINUTE AS DATE) AS dt
  FROM capi.uid_login_action l
  WHERE l.login_datetime >= TIMESTAMP '2026-03-30 18:30:00'
    AND l.login_datetime <  TIMESTAMP '2026-09-29 18:30:00'
    AND UPPER(l.channel) IN ('MOBILE_WEB', 'MOBWEB', 'MWEB', 'MOB_WEB')
),
login_daily AS (
  SELECT
    dt,
    COUNT(*)                       AS login_events,
    COUNT(DISTINCT user_id)        AS logged_in_users,
    COUNT(DISTINCT mri_session_id) AS login_sessions
  FROM login_raw
  GROUP BY 1
),
cohort AS (
  SELECT DISTINCT user_id, dt FROM login_raw
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
funnel_daily AS (
  SELECT
    c.dt,
    COUNT(DISTINCT s.user_id)                  AS logged_in_users_with_srp,
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
  l.dt,
  l.logged_in_users,
  tu.total_users,
  ROUND(100.0 * l.logged_in_users / NULLIF(tu.total_users, 0), 2) AS logged_in_share_of_total_users_pct,
  l.login_events,
  l.login_sessions,
  f.logged_in_users_with_srp,
  f.srp_sessions,
  f.sl_sessions,
  f.custinfo_sessions,
  f.tentative_sessions,
  f.payment_sessions,
  f.confirm_sessions,
  f.transactions,
  f.transacting_users,
  ROUND(100.0 * f.sl_sessions        / NULLIF(f.srp_sessions, 0), 2)       AS srp_to_sl_pct,
  ROUND(100.0 * f.custinfo_sessions  / NULLIF(f.sl_sessions, 0), 2)        AS sl_to_custinfo_pct,
  ROUND(100.0 * f.tentative_sessions / NULLIF(f.custinfo_sessions, 0), 2)  AS custinfo_to_tentative_pct,
  ROUND(100.0 * f.payment_sessions   / NULLIF(f.tentative_sessions, 0), 2) AS tentative_to_payment_pct,
  ROUND(100.0 * f.confirm_sessions   / NULLIF(f.payment_sessions, 0), 2)   AS payment_to_confirm_pct,
  ROUND(100.0 * f.transactions       / NULLIF(f.srp_sessions, 0), 2)       AS cr_pct,
  ROUND(100.0 * f.transacting_users  / NULLIF(l.logged_in_users, 0), 2)    AS login_to_txn_pct
FROM login_daily l
LEFT JOIN funnel_daily f ON f.dt = l.dt
LEFT JOIN total_users tu ON tu.dt = l.dt
ORDER BY l.dt;
