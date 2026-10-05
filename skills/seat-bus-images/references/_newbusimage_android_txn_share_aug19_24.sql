WITH daily_image_routes AS (
  SELECT
    CAST(AT_TIMEZONE(uue.__time, 'Asia/Kolkata') AS DATE) AS event_date,
    TRY_CAST(uue.route_id_train_no AS BIGINT) AS route_id
  FROM user_interaction.ui_ux_events AS uue
  WHERE
    uue.__time >= CAST('2026-08-18 18:30:00' AS TIMESTAMP)
    AND uue.__time < CAST('2026-08-24 18:30:00' AS TIMESTAMP)
    AND uue.event_src = 'Android'
    AND uue.header_country = 'IND'
    AND uue.event_name = 'NewBusImageLoaded'
    AND uue.header_bu = 'BUS'
    AND NOT TRY_CAST(uue.route_id_train_no AS BIGINT) IS NULL
  GROUP BY
    1,
    2
), daily_txns AS (
  SELECT
    CAST(AT_TIMEZONE(bte.time_of_event, 'Asia/Kolkata') AS DATE) AS event_date,
    bte.route_id,
    bte.tin
  FROM transaction.bus_ticket_events AS bte
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-08-18 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-24 18:30:00' AS TIMESTAMP)
    AND bte.date_of_issue >= CAST('2026-08-18 18:30:00' AS TIMESTAMP)
    AND bte.date_of_issue < CAST('2026-08-24 18:30:00' AS TIMESTAMP)
    AND bte.event_class = 2
    AND bte.sales_channel = 'RB:MOBILEWEB#droidapp'
), txns_with_image_flag AS (
  SELECT
    t.event_date,
    t.tin,
    t.route_id,
    CASE WHEN NOT r.route_id IS NULL THEN 1 ELSE 0 END AS has_image_loaded
  FROM daily_txns AS t
  LEFT JOIN daily_image_routes AS r
    ON t.event_date = r.event_date AND t.route_id = r.route_id
), image_routes_summary AS (
  SELECT
    event_date,
    COUNT(DISTINCT route_id) AS distinct_image_routes
  FROM daily_image_routes
  GROUP BY
    event_date
), txns_summary AS (
  SELECT
    event_date,
    COUNT(DISTINCT tin) AS overall_android_txns,
    COUNT(DISTINCT CASE WHEN has_image_loaded = 1 THEN tin END) AS image_route_android_txns
  FROM txns_with_image_flag
  GROUP BY
    event_date
)
SELECT
  COALESCE(i.event_date, t.event_date) AS event_date,
  COALESCE(i.distinct_image_routes, 0) AS distinct_image_routes,
  COALESCE(t.overall_android_txns, 0) AS overall_android_txns,
  COALESCE(t.image_route_android_txns, 0) AS image_route_android_txns,
  CASE
    WHEN COALESCE(t.overall_android_txns, 0) > 0
    THEN 100.0 * COALESCE(t.image_route_android_txns, 0) / t.overall_android_txns
    ELSE 0.0
  END AS txn_share_pct
FROM image_routes_summary AS i
FULL OUTER JOIN txns_summary AS t
  ON i.event_date = t.event_date
ORDER BY
  event_date ASC
LIMIT 1500