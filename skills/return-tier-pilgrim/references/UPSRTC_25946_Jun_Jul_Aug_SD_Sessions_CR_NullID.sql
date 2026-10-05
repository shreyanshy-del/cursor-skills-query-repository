-- UPSRTC (25946) | IND | Jun–Aug 2026 (IST)
-- Sessions, Null-ID sessions, Transactions, Seats, CR by year_month × SD
--
-- NOTE on Booking_OTA offline:
--   Booking_OTA is a Unity India (Bitla/1_bla) field, NOT on Iceberg bus_ticket_events.
--   Operator = offline; Redbus/Abhibus/PayTM/Other = OTA.
--   UPSRTC is RTC and typically not present in Bitla — Booking_OTA offline across SDs
--   is peer-market Bitla offline, not UPSRTC B2C. See MDX section at bottom of this file.

WITH searches_cte AS (
  SELECT
    DATE_FORMAT(CAST(AT_TIMEZONE(sd.__time, 'Asia/Kolkata') AS TIMESTAMP), '%Y-%m') AS year_month,
    sd.src_id,
    sd.dest_id,
    COUNT(DISTINCT sd.mri_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN sd.rb_user_id IS NULL THEN sd.mri_session_id END) AS null_id_sessions
  FROM user_interaction.search_details AS sd
  WHERE
    sd.country = 'IND'
    AND sd.__time >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND sd.__time < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND sd.operator_id = 25946
  GROUP BY
    DATE_FORMAT(CAST(AT_TIMEZONE(sd.__time, 'Asia/Kolkata') AS TIMESTAMP), '%Y-%m'),
    sd.src_id,
    sd.dest_id
), transactions_cte AS (
  SELECT
    DATE_FORMAT(CAST(AT_TIMEZONE(bte.time_of_event, 'Asia/Kolkata') AS TIMESTAMP), '%Y-%m') AS year_month,
    bte.source_location_id,
    bte.destination_location_id,
    COUNT(DISTINCT bte.tin) AS transactions,
    SUM(bte.seat_count) AS seats
  FROM transaction.bus_ticket_events AS bte
  WHERE
    bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.time_of_event >= CAST('2026-05-31 18:30:00' AS TIMESTAMP)
    AND bte.time_of_event < CAST('2026-08-31 18:30:00' AS TIMESTAMP)
    AND bte.operator_id = 25946
  GROUP BY
    DATE_FORMAT(CAST(AT_TIMEZONE(bte.time_of_event, 'Asia/Kolkata') AS TIMESTAMP), '%Y-%m'),
    bte.source_location_id,
    bte.destination_location_id
)
SELECT
  COALESCE(s.year_month, t.year_month) AS year_month,
  COALESCE(s.src_id, t.source_location_id) AS src_id,
  COALESCE(s.dest_id, t.destination_location_id) AS dest_id,
  src_loc.location_name AS source_city_name,
  dst_loc.location_name AS destination_city_name,
  COALESCE(s.sessions, 0) AS sessions,
  COALESCE(s.null_id_sessions, 0) AS null_id_sessions,
  CASE
    WHEN COALESCE(s.sessions, 0) > 0
    THEN (CAST(COALESCE(s.null_id_sessions, 0) AS DOUBLE) / s.sessions) * 100.0
    ELSE 0.0
  END AS null_id_share_pct,
  COALESCE(t.transactions, 0) AS transactions,
  COALESCE(t.seats, 0) AS seats,
  CASE
    WHEN COALESCE(s.sessions, 0) > 0
    THEN (CAST(COALESCE(t.transactions, 0) AS DOUBLE) / s.sessions) * 100.0
    ELSE 0.0
  END AS conversion_rate_percentage
FROM searches_cte AS s
FULL OUTER JOIN transactions_cte AS t
  ON s.year_month = t.year_month
  AND s.src_id = t.source_location_id
  AND s.dest_id = t.destination_location_id
LEFT JOIN lis.config_locations AS src_loc
  ON COALESCE(s.src_id, t.source_location_id) = src_loc.id
  AND src_loc.location_type = 'CITY'
  AND src_loc.is_expired = 0
LEFT JOIN lis.config_locations AS dst_loc
  ON COALESCE(s.dest_id, t.destination_location_id) = dst_loc.id
  AND dst_loc.location_type = 'CITY'
  AND dst_loc.is_expired = 0
ORDER BY
  year_month ASC,
  sessions DESC
LIMIT 1500;


-- =============================================================================
-- Unity India MDX — Booking_OTA offline (Operator) seats by month × route
-- Booking_OTA members: Operator (offline) | Redbus | Abhibus | PayTM | Other | Cleartrip/TY
-- Run in Unity / SSAS India cube. Filter Route members as needed for UPSRTC corridors.
-- =============================================================================
/*
SELECT
  {[Measures].[bla seats], [Measures].[RB bla share], [Measures].[GDS Offline Share]} ON 0,
  NON EMPTY
  CrossJoin(
    {
      [1_bla].[Booking_OTA].[Booking_OTA].[Operator],
      [1_bla].[Booking_OTA].[Booking_OTA].[Redbus],
      [1_bla].[Booking_OTA].[Booking_OTA].[Abhibus],
      [1_bla].[Booking_OTA].[Booking_OTA].[PayTM],
      [1_bla].[Booking_OTA].[Booking_OTA].[Other]
    },
    {
      [2_Date].[Month].[Month].&[2026-06-01T00:00:00],
      [2_Date].[Month].[Month].&[2026-07-01T00:00:00],
      [2_Date].[Month].[Month].&[2026-08-01T00:00:00]
    }
  ) ON 1
FROM [Model];

-- Optional: break by route (SD) for offline Operator only
-- SELECT {[Measures].[bla seats]} ON 0,
-- NON EMPTY
-- CrossJoin(
--   [2_Routes].[Route].[Route].MEMBERS,
--   {
--     [2_Date].[Month].[Month].&[2026-06-01T00:00:00],
--     [2_Date].[Month].[Month].&[2026-07-01T00:00:00],
--     [2_Date].[Month].[Month].&[2026-08-01T00:00:00]
--   }
-- ) ON 1
-- FROM [Model]
-- WHERE ([1_bla].[Booking_OTA].[Booking_OTA].[Operator]);
*/
