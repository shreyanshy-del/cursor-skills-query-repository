-- =============================================================================
-- PILGRIM RETURN — users + sessions
-- Forward dates: STATIC (date_params) | Return dates: DYNAMIC (per forward TIN)
-- IND | MOBILE_APP Android/iOS | Variant on RETURN SRP
-- =============================================================================

WITH date_params AS (
  SELECT
    TIMESTAMP '2026-08-23 00:00:00' AS fwd_start,       -- static forward start (23 Aug IST)
    TIMESTAMP '2026-08-27 00:00:00' AS fwd_end,         -- static forward end   (26 Aug IST exclusive → 27 Aug 00:00)
    14                              AS return_window_days -- dynamic return window per forward TIN
),

pilgrim_cities AS (
  SELECT DISTINCT CAST(city_id AS BIGINT) AS city_id
  FROM lis.city_tagging
  WHERE category = 'Pilgrim'
),

-- Forward: STATIC window only (change dates here)
forward_confirm AS (
  SELECT DISTINCT
    bte.rb_user_id,
    bte.tin                   AS fwd_tin,
    bte.source_location_id    AS fwd_src_id,
    bte.date_of_issue         AS fwd_issue_time,
    DATE_ADD('day', p.return_window_days, bte.date_of_issue) AS ret_window_end
  FROM transaction.bus_ticket_events bte
  CROSS JOIN date_params p
  INNER JOIN pilgrim_cities pc
    ON pc.city_id = bte.destination_location_id
  WHERE bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.rb_user_id IS NOT NULL
    AND bte.date_of_issue >= p.fwd_start
    AND bte.date_of_issue <  p.fwd_end
),

-- Return SRP: DYNAMIC window per forward TIN (no static return dates)
return_srp AS (
  SELECT DISTINCT
    fc.rb_user_id,
    fc.fwd_tin,
    fc.fwd_issue_time,
    fc.ret_window_end,
    sd.mri_session_id         AS ret_session_id,
    sd.__time                 AS ret_session_time,
    sd.src_id                 AS ret_src_id,
    sd.dest_id                AS ret_dest_id,
    sd.os                     AS channel,
    CASE
      WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V2') THEN 'V2'
      WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V1') THEN 'V1'
      WHEN CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V0') THEN 'V0'
    END AS variant
  FROM forward_confirm fc
  INNER JOIN user_interaction.search_details sd
    ON sd.rb_user_id = fc.rb_user_id
   AND sd.dest_id    = CAST(fc.fwd_src_id AS BIGINT)
   AND sd.country    = 'IND'
   AND sd.channel    = 'MOBILE_APP'
   AND sd.os IN ('Android', 'iOS')
   AND sd.__time     > fc.fwd_issue_time      -- dynamic: after this forward issue
   AND sd.__time     < fc.ret_window_end      -- dynamic: within 14d of this forward issue
   AND (
     CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V0')
     OR CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V1')
     OR CONTAINS(sd.channel_exp_info, 'PILGRIM_RETURN_OFFER:V2')
   )
),

-- Return funnel: session joins; time bounds dynamic per forward TIN window
return_funnel AS (
  SELECT
    rs.variant,
    rs.channel,
    rs.rb_user_id,
    rs.fwd_tin,
    rs.ret_session_id,
    sl.mri_session_id   AS sl_session_id,
    mpax.mri_session_id AS mpax_session_id,
    tco.mri_session_id  AS tco_session_id,
    conf.mri_session_id AS confirm_session_id,
    conf.tin            AS ret_tin
  FROM return_srp rs
  LEFT JOIN user_interaction.seat_layout_details sl
    ON sl.mri_session_id = rs.ret_session_id
   AND sl.country = 'IND'
   AND sl.__time >= rs.fwd_issue_time
   AND sl.__time <  rs.ret_window_end
  LEFT JOIN user_interaction.cust_info_details mpax
    ON mpax.mri_session_id = rs.ret_session_id
   AND mpax.__time >= rs.fwd_issue_time
   AND mpax.__time <  rs.ret_window_end
  LEFT JOIN user_interaction.create_order_details tco
    ON tco.mri_session_id = rs.ret_session_id
   AND tco.__time >= rs.fwd_issue_time
   AND tco.__time <  rs.ret_window_end
  LEFT JOIN user_interaction.confirm_order_details conf
    ON conf.mri_session_id = rs.ret_session_id
   AND conf.src_id         = rs.ret_src_id
   AND conf.dest_id        = rs.ret_dest_id
   AND conf.country        = 'IND'
   AND conf.channel        = 'MOBILE_APP'
   AND conf.error_code     = 'CONFIRMED'
   AND conf.status_str     = 'SUCCESS'
   AND conf.tin IS NOT NULL
   AND conf.tin NOT IN ('', 'null')
   AND conf.__time >= rs.fwd_issue_time
   AND conf.__time <  rs.ret_window_end
),

fwd_totals AS (
  SELECT
    COUNT(DISTINCT rb_user_id) AS fwd_confirm_users,
    COUNT(DISTINCT fwd_tin)    AS fwd_confirm_tins
  FROM forward_confirm
)

SELECT
  rf.variant,
  rf.channel,
  ft.fwd_confirm_users,
  ft.fwd_confirm_tins,
  COUNT(DISTINCT rf.rb_user_id)           AS ret_srp_users,
  COUNT(DISTINCT rf.ret_session_id)       AS ret_srp_sessions,
  COUNT(DISTINCT rf.sl_session_id)        AS sl_sessions,
  COUNT(DISTINCT rf.mpax_session_id)      AS mpax_sessions,
  COUNT(DISTINCT rf.tco_session_id)       AS tco_sessions,
  COUNT(DISTINCT rf.confirm_session_id)   AS confirm_sessions,
  COUNT(DISTINCT rf.ret_tin)              AS ret_confirm_tins,
  ROUND(100.0 * COUNT(DISTINCT rf.rb_user_id)
        / NULLIF(ft.fwd_confirm_users, 0), 2) AS ret_srp_user_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN rf.ret_tin IS NOT NULL THEN rf.rb_user_id END)
        / NULLIF(ft.fwd_confirm_users, 0), 2) AS overall_ret_tin_user_pct,
  ROUND(100.0 * COUNT(DISTINCT rf.ret_tin)
        / NULLIF(COUNT(DISTINCT rf.ret_session_id), 0), 2) AS ret_srp_to_tin_session_cr,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN rf.ret_tin IS NOT NULL THEN rf.rb_user_id END)
        / NULLIF(COUNT(DISTINCT rf.rb_user_id), 0), 2) AS ret_srp_to_tin_user_cr
FROM return_funnel rf
CROSS JOIN fwd_totals ft
GROUP BY 1, 2, ft.fwd_confirm_users, ft.fwd_confirm_tins
ORDER BY 1, 2
