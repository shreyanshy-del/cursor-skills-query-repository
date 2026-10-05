-- =============================================================================
-- QoQ — Last 8 Quarters · TRANSACTION
-- Segments: Platform | Female_SVOC | Women_SRP
-- Android · IND · BUS · confirm event_type=101 event_class=2
-- Quarters: current IST quarter + prior 7 (Q4'24…Q3'26 as of 2026-09-15)
--
-- Platform    = all Android IND confirmed txns (baseline)
-- Women_SRP   = confirm on session with SRP loaded event_value='Women'
-- Female_SVOC = confirm for SVOC female users
-- NOTE: Women SRP may be zero in early quarters (instrumentation launch).
-- =============================================================================

WITH params AS (
  SELECT
    CAST(
      AT_TIMEZONE(
        CAST(
          date_add(
            'quarter', -7,
            date_trunc('quarter', CAST(AT_TIMEZONE(CURRENT_TIMESTAMP, 'Asia/Kolkata') AS TIMESTAMP))
          ) AS TIMESTAMP
        ),
        'UTC'
      ) AS TIMESTAMP
    ) AS t0,
    CURRENT_TIMESTAMP AS t1
),

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

women_srp_sess AS (
  SELECT DISTINCT ux.mri_session_id
  FROM user_interaction.ui_ux_events ux
  CROSS JOIN params p
  WHERE ux.__time >= p.t0 AND ux.__time < p.t1
    AND ux.event_src = 'Android'
    AND ux.header_country = 'IND'
    AND ux.header_bu = 'BUS'
    AND ux.selected_country = 'India'
    AND ux.event_group = 'srp_click_event'
    AND ux.event_name = 'SRP loaded'
    AND ux.event_value = 'Women'
),

platform_base AS (
  SELECT
    b.tin,
    b.rb_user_id,
    b.seat_count,
    b.ticket_fare,
    b.mri_session_id,
    CAST(date_trunc('quarter', CAST(AT_TIMEZONE(b.time_of_event, 'Asia/Kolkata') AS TIMESTAMP)) AS DATE) AS qtr_start
  FROM transaction.bus_ticket_events b
  CROSS JOIN params p
  WHERE b.time_of_event >= p.t0 AND b.time_of_event < p.t1
    AND b.country_code = 'IND'
    AND b.event_type = 101
    AND b.event_class = 2
    AND b.sales_channel LIKE '%droidapp%'
),

all_txns AS (
  SELECT tin, rb_user_id, seat_count, ticket_fare, qtr_start, 'Platform' AS segment
  FROM platform_base

  UNION ALL

  SELECT b.tin, b.rb_user_id, b.seat_count, b.ticket_fare, b.qtr_start, 'Women_SRP' AS segment
  FROM platform_base b
  INNER JOIN women_srp_sess w ON b.mri_session_id = w.mri_session_id

  UNION ALL

  SELECT b.tin, b.rb_user_id, b.seat_count, b.ticket_fare, b.qtr_start, 'Female_SVOC' AS segment
  FROM platform_base b
  INNER JOIN svoc_female f ON b.rb_user_id = f.rb_user_id AND b.rb_user_id > 0
),

qtr_agg AS (
  SELECT
    segment,
    qtr_start,
    CONCAT(
      CAST(year(qtr_start) AS VARCHAR),
      '-Q',
      CAST(quarter(qtr_start) AS VARCHAR)
    ) AS quarter_label,
    COUNT(DISTINCT tin) AS txns,
    SUM(COALESCE(seat_count, 0)) AS seats,
    SUM(COALESCE(ticket_fare, 0)) AS gmv,
    COUNT(DISTINCT rb_user_id) AS unique_users,
    SUM(COALESCE(ticket_fare, 0)) * 1.0 / NULLIF(SUM(COALESCE(seat_count, 0)), 0) AS asp
  FROM all_txns
  GROUP BY 1, 2, 3
),

with_platform AS (
  SELECT
    s.*,
    p.txns AS platform_txns,
    p.seats AS platform_seats,
    p.gmv AS platform_gmv,
    s.txns * 100.0 / NULLIF(p.txns, 0) AS txn_share_of_platform_pct,
    s.seats * 100.0 / NULLIF(p.seats, 0) AS seat_share_of_platform_pct,
    s.gmv * 100.0 / NULLIF(p.gmv, 0) AS gmv_share_of_platform_pct
  FROM qtr_agg s
  INNER JOIN qtr_agg p
    ON s.qtr_start = p.qtr_start
   AND p.segment = 'Platform'
)

SELECT
  'TRANSACTION' AS funnel_type,
  segment,
  quarter_label,
  qtr_start,
  txns,
  seats,
  gmv,
  unique_users,
  asp,
  txn_share_of_platform_pct,
  seat_share_of_platform_pct,
  gmv_share_of_platform_pct,
  LAG(txns) OVER (PARTITION BY segment ORDER BY qtr_start) AS prev_txns,
  (txns - LAG(txns) OVER (PARTITION BY segment ORDER BY qtr_start)) * 100.0
    / NULLIF(LAG(txns) OVER (PARTITION BY segment ORDER BY qtr_start), 0) AS txns_qoq_pct,
  LAG(seats) OVER (PARTITION BY segment ORDER BY qtr_start) AS prev_seats,
  (seats - LAG(seats) OVER (PARTITION BY segment ORDER BY qtr_start)) * 100.0
    / NULLIF(LAG(seats) OVER (PARTITION BY segment ORDER BY qtr_start), 0) AS seats_qoq_pct,
  LAG(gmv) OVER (PARTITION BY segment ORDER BY qtr_start) AS prev_gmv,
  (gmv - LAG(gmv) OVER (PARTITION BY segment ORDER BY qtr_start)) * 100.0
    / NULLIF(LAG(gmv) OVER (PARTITION BY segment ORDER BY qtr_start), 0) AS gmv_qoq_pct,
  LAG(unique_users) OVER (PARTITION BY segment ORDER BY qtr_start) AS prev_users,
  (unique_users - LAG(unique_users) OVER (PARTITION BY segment ORDER BY qtr_start)) * 100.0
    / NULLIF(LAG(unique_users) OVER (PARTITION BY segment ORDER BY qtr_start), 0) AS users_qoq_pct
FROM with_platform
ORDER BY
  qtr_start,
  CASE segment
    WHEN 'Platform' THEN 1
    WHEN 'Female_SVOC' THEN 2
    WHEN 'Women_SRP' THEN 3
    ELSE 4
  END;
