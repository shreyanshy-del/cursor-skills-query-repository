-- =============================================================================
-- LIGHT Return Trip (14d) — Women_SRP vs Female_SVOC
-- Android · IND · BUS
-- Default window: 3 IST days (edit t0/t1) to cut Athena scan
-- Return = reverse SD search / confirm within 14d of DOI
--
-- Scan reducers vs prior version:
--   1) Women path: INNER JOIN Women SRP sessions only (no Regular, no LEFT JOIN ux)
--   2) Female path: BTE ⋈ SVOC only (no ui_ux)
--   3) Return search/txn start FROM bookers (not full search_details / BTE then join)
--   4) Shorter default booking window (3d); widen t1 if needed
-- =============================================================================

WITH params AS (
  SELECT
    -- 3-day booking window (IST 7–9 Sep 2026). Widen t1 for more days.
    TIMESTAMP '2026-09-06 18:30:00' AS t0,
    TIMESTAMP '2026-09-09 18:30:00' AS t1,
    TIMESTAMP '2026-09-23 18:30:00' AS t_ret   -- t1 + 14d
),

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

-- Small: Women SRP sessions only
women_sess AS (
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

-- Women bookers: first confirm on a Women SRP session
women_first AS (
  SELECT *
  FROM (
    SELECT
      bte.rb_user_id,
      bte.time_of_event AS doi_ts,
      bte.source_location_id AS src_id,
      bte.destination_location_id AS dest_id,
      ROW_NUMBER() OVER (
        PARTITION BY bte.rb_user_id
        ORDER BY bte.time_of_event
      ) AS rn
    FROM transaction.bus_ticket_events bte
    INNER JOIN women_sess w ON bte.mri_session_id = w.mri_session_id
    CROSS JOIN params p
    WHERE bte.time_of_event >= p.t0 AND bte.time_of_event < p.t1
      AND bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.event_class = 2
      AND bte.sales_channel LIKE '%droidapp%'
      AND bte.rb_user_id > 0
      AND bte.source_location_id IS NOT NULL
      AND bte.destination_location_id IS NOT NULL
  ) x
  WHERE rn = 1
),

-- Female SVOC bookers: first confirm in window (no ui_ux scan)
female_first AS (
  SELECT *
  FROM (
    SELECT
      bte.rb_user_id,
      bte.time_of_event AS doi_ts,
      bte.source_location_id AS src_id,
      bte.destination_location_id AS dest_id,
      ROW_NUMBER() OVER (
        PARTITION BY bte.rb_user_id
        ORDER BY bte.time_of_event
      ) AS rn
    FROM transaction.bus_ticket_events bte
    INNER JOIN svoc_female f ON bte.rb_user_id = f.rb_user_id
    CROSS JOIN params p
    WHERE bte.time_of_event >= p.t0 AND bte.time_of_event < p.t1
      AND bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.event_class = 2
      AND bte.sales_channel LIKE '%droidapp%'
      AND bte.rb_user_id > 0
      AND bte.source_location_id IS NOT NULL
      AND bte.destination_location_id IS NOT NULL
  ) x
  WHERE rn = 1
),

bookers AS (
  SELECT rb_user_id, doi_ts, src_id, dest_id, 'Women_SRP' AS segment
  FROM women_first
  UNION ALL
  SELECT rb_user_id, doi_ts, src_id, dest_id, 'Female_SVOC'
  FROM female_first
),

-- Return flags: drive FROM bookers + EXISTS (no full-table build of ret_*)
flagged AS (
  SELECT
    b.segment,
    b.rb_user_id,
    CASE WHEN EXISTS (
      SELECT 1
      FROM user_interaction.search_details s
      CROSS JOIN params p
      WHERE s.rb_user_id = b.rb_user_id
        AND s.__time > b.doi_ts
        AND s.__time <= b.doi_ts + INTERVAL '14' DAY
        AND s.__time >= p.t0 AND s.__time < p.t_ret
        AND s.country = 'IND'
        AND s.os = 'Android'
        AND s.src_id = b.dest_id
        AND s.dest_id = b.src_id
    ) THEN 1 ELSE 0 END AS has_return_search,
    CASE WHEN EXISTS (
      SELECT 1
      FROM transaction.bus_ticket_events t
      CROSS JOIN params p
      WHERE t.rb_user_id = b.rb_user_id
        AND t.time_of_event > b.doi_ts
        AND t.time_of_event <= b.doi_ts + INTERVAL '14' DAY
        AND t.time_of_event >= p.t0 AND t.time_of_event < p.t_ret
        AND t.country_code = 'IND'
        AND t.event_type = 101
        AND t.event_class = 2
        AND t.source_location_id = b.dest_id
        AND t.destination_location_id = b.src_id
    ) THEN 1 ELSE 0 END AS has_return_txn
  FROM bookers b
)

SELECT
  segment,
  COUNT(*) AS bookers,
  SUM(has_return_search) AS return_search_users_14d,
  SUM(has_return_txn) AS return_txn_users_14d,
  SUM(CASE WHEN has_return_search = 1 OR has_return_txn = 1 THEN 1 ELSE 0 END) AS either_return_users_14d,
  SUM(has_return_search) * 100.0 / NULLIF(COUNT(*), 0) AS return_search_rate_pct,
  SUM(has_return_txn) * 100.0 / NULLIF(COUNT(*), 0) AS return_txn_rate_pct
FROM flagged
GROUP BY 1
ORDER BY 1;
