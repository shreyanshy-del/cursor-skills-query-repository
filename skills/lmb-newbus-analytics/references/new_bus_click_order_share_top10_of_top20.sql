-- =====================================================================================
-- New Bus (persuasion_id = 68): Click Share & Order Share of Top-10 tuples within Top-20
-- =====================================================================================
-- Scope       : India, 17-21 Sep 2026 (IST)  ->  __time >= 2026-09-16 18:30 UTC
--                                                __time <  2026-09-21 18:30 UTC
-- Platform    : Android app only (channel = MOBILE_APP, os = Android)
-- Cohort      : UNFILTERED SRP sessions only (search_details.is_filter_applied = FALSE, sort < 1)
-- Tuple rank  : search_route_details.offset + position + 1  (MIN per session x route x doj)
-- Test        : CONTAINS(persuasion_id, '68')          -> New Bus tagged tuple
-- Rest        : NOT CONTAINS(persuasion_id, '68')
-- Overall     : all tuples, irrespective of persuasion
-- Click       : distinct user_interaction.seat_layout_details.mri_uuid
--               (SL open = click on the SRP tuple), joined on session + route + doj
-- Order       : distinct transaction.bus_ticket_events.tin, event_type = 101 (confirmed),
--               event_class = 2, country_code = 'IND', Android sales_channel
-- Dest categ. : inline city_tier_map CTE -> Tier 1 / Tier 2 / Pilgrim / Leisure explicit,
--               residual dest_id = Tier 3. Used INSTEAD of the governed city-tagging table,
--               which is not in the Athena Glue catalog (it sits in a CustomDatabase) and so
--               raises TABLE_NOT_FOUND: awsdatacatalog.ind.city_tagging.
-- DBD         : date_diff(day, IST search date, doj) bucketed 0, 1, 2, 3, 4, 5+
--
-- SHARE DEFINITIONS (both emitted so either reading works):
--   *_share_within  = cohort top-10 count / SAME cohort top-20 count   (like-for-like)
--   test_share_vs_all_top20 = Test top-10 count / ALL top-20 count     (literal ask)
--
-- NOTES / KNOWN RISKS
--   1. Orders are joined on session + route + IST-converted date_of_journey. If the DOJ join
--      looks lossy, drop the doj predicate from the txn join (session + route only) or swap
--      transaction.bus_ticket_events for user_interaction.confirm_order_details (status = 200).
--   2. Every cut below is scoped to the Top-200 SD universe (Q0) for consistency.
--      Remove the "INNER JOIN top_sd" block to get an all-India cut instead.
--   3. seat_layout_details is filtered on country + channel only; os is inherited via the
--      session join to an Android-only SRP base.
--   4. NOT VALIDATED via dataplatformValidateSqlQuery / not executed.
-- =====================================================================================


-- =====================================================================================
-- Q0. Helper: the Top 200 source-destination pairs (ranked by unfiltered Android SRP sessions)
-- =====================================================================================
SELECT
    s.src_id,
    s.dest_id,
    COUNT(DISTINCT s.mri_session_id) AS srp_sessions
FROM user_interaction.search_route_details s
INNER JOIN user_interaction.search_details d
    ON  s.__time         = d.__time
    AND s.mri_session_id = d.mri_session_id
WHERE s.__time >= TIMESTAMP '2026-09-16 18:30:00'
  AND s.__time <  TIMESTAMP '2026-09-21 18:30:00'
  AND s.country = 'IND'
  AND s.channel = 'MOBILE_APP'
  AND s.os      = 'Android'
  AND d.is_filter_applied = FALSE
  AND d.sort < 1
  AND s.mri_session_id IS NOT NULL
  AND s.route_id       IS NOT NULL
GROUP BY 1, 2
ORDER BY srp_sessions DESC
LIMIT 200;


-- =====================================================================================
-- Q1. OVERALL (single row) - Test vs Rest vs Overall
-- =====================================================================================
WITH srp AS (
    SELECT
        s.mri_session_id,
        s.route_id,
        s.src_id,
        s.dest_id,
        UPPER(s.user_type)      AS user_type,
        CAST(s.doj AS DATE)     AS doj,
        CASE
            WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) >= 5 THEN '5+'
            ELSE CAST(DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) AS VARCHAR)
        END                     AS dbd,
        MIN(s.offset + s.position + 1)                                    AS tuple_position,
        MAX(CASE WHEN CONTAINS(s.persuasion_id, '68') THEN 1 ELSE 0 END)  AS is_new_bus
    FROM user_interaction.search_route_details s
    INNER JOIN user_interaction.search_details d
        ON  s.__time         = d.__time
        AND s.mri_session_id = d.mri_session_id
    WHERE s.__time >= TIMESTAMP '2026-09-16 18:30:00'
      AND s.__time <  TIMESTAMP '2026-09-21 18:30:00'
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os      = 'Android'
      AND d.is_filter_applied = FALSE
      AND d.sort < 1
      AND s.mri_session_id IS NOT NULL
      AND s.route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6, 7
),
top_sd AS (
    SELECT src_id, dest_id
    FROM srp
    GROUP BY 1, 2
    ORDER BY COUNT(DISTINCT mri_session_id) DESC
    LIMIT 200
),
sl AS (
    SELECT mri_session_id, route_id, CAST(doj AS DATE) AS doj, mri_uuid
    FROM user_interaction.seat_layout_details
    WHERE __time >= TIMESTAMP '2026-09-16 18:30:00'
      AND __time <  TIMESTAMP '2026-09-21 18:30:00'
      AND country = 'IND'
      AND channel = 'MOBILE_APP'
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
      AND mri_uuid       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
txn AS (
    SELECT
        mri_session_id,
        route_id,
        DATE(DATE_ADD('MINUTE', 330, date_of_journey)) AS doj,
        tin
    FROM transaction.bus_ticket_events
    WHERE time_of_event >= TIMESTAMP '2026-09-16 18:30:00'
      AND time_of_event <  TIMESTAMP '2026-09-21 18:30:00'
      AND country_code = 'IND'
      AND event_type   = 101
      AND event_class  = 2
      AND sales_channel = 'RB:MOBILEWEB#droidapp'
      AND tin IS NOT NULL
      AND tin NOT IN ('', 'null')
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
base AS (
    SELECT
        r.user_type,
        r.src_id,
        r.dest_id,
        r.dbd,
        r.tuple_position,
        r.is_new_bus,
        sl.mri_uuid AS click_id,
        t.tin
    FROM srp r
    INNER JOIN top_sd sd
        ON  r.src_id  = sd.src_id
        AND r.dest_id = sd.dest_id
    LEFT JOIN sl
        ON  r.mri_session_id = sl.mri_session_id
        AND r.route_id       = sl.route_id
        AND r.doj            = sl.doj
    LEFT JOIN txn t
        ON  r.mri_session_id = t.mri_session_id
        AND r.route_id       = t.route_id
        AND r.doj            = t.doj
    WHERE r.tuple_position <= 20
      AND r.dbd IN ('0', '1', '2', '3', '4', '5+')
),
agg AS (
    SELECT
        'Overall' AS cut_type,
        'All'     AS segment,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN click_id END) AS test_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN click_id END) AS test_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN click_id END) AS rest_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN click_id END) AS rest_top20_clicks,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN click_id END) AS all_top10_clicks,
        COUNT(DISTINCT click_id)                                                            AS all_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN tin END)      AS test_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN tin END)      AS test_top20_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN tin END)      AS rest_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN tin END)      AS rest_top20_orders,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN tin END)      AS all_top10_orders,
        COUNT(DISTINCT tin)                                                                 AS all_top20_orders
    FROM base
)
SELECT
    cut_type,
    segment,
    test_top10_clicks, test_top20_clicks,
    ROUND(100.0 * test_top10_clicks / NULLIF(test_top20_clicks, 0), 2) AS test_click_share_within,
    rest_top10_clicks, rest_top20_clicks,
    ROUND(100.0 * rest_top10_clicks / NULLIF(rest_top20_clicks, 0), 2) AS rest_click_share_within,
    all_top10_clicks, all_top20_clicks,
    ROUND(100.0 * all_top10_clicks  / NULLIF(all_top20_clicks, 0), 2)  AS overall_click_share_within,
    ROUND(100.0 * test_top10_clicks / NULLIF(all_top20_clicks, 0), 2)  AS test_click_share_vs_all_top20,
    test_top10_orders, test_top20_orders,
    ROUND(100.0 * test_top10_orders / NULLIF(test_top20_orders, 0), 2) AS test_order_share_within,
    rest_top10_orders, rest_top20_orders,
    ROUND(100.0 * rest_top10_orders / NULLIF(rest_top20_orders, 0), 2) AS rest_order_share_within,
    all_top10_orders, all_top20_orders,
    ROUND(100.0 * all_top10_orders  / NULLIF(all_top20_orders, 0), 2)  AS overall_order_share_within,
    ROUND(100.0 * test_top10_orders / NULLIF(all_top20_orders, 0), 2)  AS test_order_share_vs_all_top20
FROM agg;


-- =====================================================================================
-- Q2. TOP 200 SD CUT (single combined row across all 200 pairs)
-- =====================================================================================
WITH srp AS (
    SELECT
        s.mri_session_id,
        s.route_id,
        s.src_id,
        s.dest_id,
        UPPER(s.user_type)      AS user_type,
        CAST(s.doj AS DATE)     AS doj,
        CASE
            WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) >= 5 THEN '5+'
            ELSE CAST(DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) AS VARCHAR)
        END                     AS dbd,
        MIN(s.offset + s.position + 1)                                    AS tuple_position,
        MAX(CASE WHEN CONTAINS(s.persuasion_id, '68') THEN 1 ELSE 0 END)  AS is_new_bus
    FROM user_interaction.search_route_details s
    INNER JOIN user_interaction.search_details d
        ON  s.__time         = d.__time
        AND s.mri_session_id = d.mri_session_id
    WHERE s.__time >= TIMESTAMP '2026-09-16 18:30:00'
      AND s.__time <  TIMESTAMP '2026-09-21 18:30:00'
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os      = 'Android'
      AND d.is_filter_applied = FALSE
      AND d.sort < 1
      AND s.mri_session_id IS NOT NULL
      AND s.route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6, 7
),
top_sd AS (
    SELECT src_id, dest_id
    FROM srp
    GROUP BY 1, 2
    ORDER BY COUNT(DISTINCT mri_session_id) DESC
    LIMIT 200
),
sl AS (
    SELECT mri_session_id, route_id, CAST(doj AS DATE) AS doj, mri_uuid
    FROM user_interaction.seat_layout_details
    WHERE __time >= TIMESTAMP '2026-09-16 18:30:00'
      AND __time <  TIMESTAMP '2026-09-21 18:30:00'
      AND country = 'IND'
      AND channel = 'MOBILE_APP'
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
      AND mri_uuid       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
txn AS (
    SELECT
        mri_session_id,
        route_id,
        DATE(DATE_ADD('MINUTE', 330, date_of_journey)) AS doj,
        tin
    FROM transaction.bus_ticket_events
    WHERE time_of_event >= TIMESTAMP '2026-09-16 18:30:00'
      AND time_of_event <  TIMESTAMP '2026-09-21 18:30:00'
      AND country_code = 'IND'
      AND event_type   = 101
      AND event_class  = 2
      AND sales_channel = 'RB:MOBILEWEB#droidapp'
      AND tin IS NOT NULL
      AND tin NOT IN ('', 'null')
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
base AS (
    SELECT
        r.tuple_position,
        r.is_new_bus,
        sl.mri_uuid AS click_id,
        t.tin
    FROM srp r
    INNER JOIN top_sd sd
        ON  r.src_id  = sd.src_id
        AND r.dest_id = sd.dest_id
    LEFT JOIN sl
        ON  r.mri_session_id = sl.mri_session_id
        AND r.route_id       = sl.route_id
        AND r.doj            = sl.doj
    LEFT JOIN txn t
        ON  r.mri_session_id = t.mri_session_id
        AND r.route_id       = t.route_id
        AND r.doj            = t.doj
    WHERE r.tuple_position <= 20
      AND r.dbd IN ('0', '1', '2', '3', '4', '5+')
),
agg AS (
    SELECT
        'Top 200 SD' AS cut_type,
        'Top 200 SD combined' AS segment,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN click_id END) AS test_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN click_id END) AS test_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN click_id END) AS rest_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN click_id END) AS rest_top20_clicks,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN click_id END) AS all_top10_clicks,
        COUNT(DISTINCT click_id)                                                            AS all_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN tin END)      AS test_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN tin END)      AS test_top20_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN tin END)      AS rest_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN tin END)      AS rest_top20_orders,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN tin END)      AS all_top10_orders,
        COUNT(DISTINCT tin)                                                                 AS all_top20_orders
    FROM base
)
SELECT
    cut_type,
    segment,
    test_top10_clicks, test_top20_clicks,
    ROUND(100.0 * test_top10_clicks / NULLIF(test_top20_clicks, 0), 2) AS test_click_share_within,
    rest_top10_clicks, rest_top20_clicks,
    ROUND(100.0 * rest_top10_clicks / NULLIF(rest_top20_clicks, 0), 2) AS rest_click_share_within,
    all_top10_clicks, all_top20_clicks,
    ROUND(100.0 * all_top10_clicks  / NULLIF(all_top20_clicks, 0), 2)  AS overall_click_share_within,
    ROUND(100.0 * test_top10_clicks / NULLIF(all_top20_clicks, 0), 2)  AS test_click_share_vs_all_top20,
    test_top10_orders, test_top20_orders,
    ROUND(100.0 * test_top10_orders / NULLIF(test_top20_orders, 0), 2) AS test_order_share_within,
    rest_top10_orders, rest_top20_orders,
    ROUND(100.0 * rest_top10_orders / NULLIF(rest_top20_orders, 0), 2) AS rest_order_share_within,
    all_top10_orders, all_top20_orders,
    ROUND(100.0 * all_top10_orders  / NULLIF(all_top20_orders, 0), 2)  AS overall_order_share_within,
    ROUND(100.0 * test_top10_orders / NULLIF(all_top20_orders, 0), 2)  AS test_order_share_vs_all_top20
FROM agg;


-- =====================================================================================
-- Q3. USER TYPE CUT (GUEST / NEW / RETURNING)
-- =====================================================================================
WITH srp AS (
    SELECT
        s.mri_session_id,
        s.route_id,
        s.src_id,
        s.dest_id,
        UPPER(s.user_type)      AS user_type,
        CAST(s.doj AS DATE)     AS doj,
        CASE
            WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) >= 5 THEN '5+'
            ELSE CAST(DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) AS VARCHAR)
        END                     AS dbd,
        MIN(s.offset + s.position + 1)                                    AS tuple_position,
        MAX(CASE WHEN CONTAINS(s.persuasion_id, '68') THEN 1 ELSE 0 END)  AS is_new_bus
    FROM user_interaction.search_route_details s
    INNER JOIN user_interaction.search_details d
        ON  s.__time         = d.__time
        AND s.mri_session_id = d.mri_session_id
    WHERE s.__time >= TIMESTAMP '2026-09-16 18:30:00'
      AND s.__time <  TIMESTAMP '2026-09-21 18:30:00'
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os      = 'Android'
      AND d.is_filter_applied = FALSE
      AND d.sort < 1
      AND s.mri_session_id IS NOT NULL
      AND s.route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6, 7
),
top_sd AS (
    SELECT src_id, dest_id
    FROM srp
    GROUP BY 1, 2
    ORDER BY COUNT(DISTINCT mri_session_id) DESC
    LIMIT 200
),
sl AS (
    SELECT mri_session_id, route_id, CAST(doj AS DATE) AS doj, mri_uuid
    FROM user_interaction.seat_layout_details
    WHERE __time >= TIMESTAMP '2026-09-16 18:30:00'
      AND __time <  TIMESTAMP '2026-09-21 18:30:00'
      AND country = 'IND'
      AND channel = 'MOBILE_APP'
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
      AND mri_uuid       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
txn AS (
    SELECT
        mri_session_id,
        route_id,
        DATE(DATE_ADD('MINUTE', 330, date_of_journey)) AS doj,
        tin
    FROM transaction.bus_ticket_events
    WHERE time_of_event >= TIMESTAMP '2026-09-16 18:30:00'
      AND time_of_event <  TIMESTAMP '2026-09-21 18:30:00'
      AND country_code = 'IND'
      AND event_type   = 101
      AND event_class  = 2
      AND sales_channel = 'RB:MOBILEWEB#droidapp'
      AND tin IS NOT NULL
      AND tin NOT IN ('', 'null')
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
base AS (
    SELECT
        r.user_type,
        r.tuple_position,
        r.is_new_bus,
        sl.mri_uuid AS click_id,
        t.tin
    FROM srp r
    INNER JOIN top_sd sd
        ON  r.src_id  = sd.src_id
        AND r.dest_id = sd.dest_id
    LEFT JOIN sl
        ON  r.mri_session_id = sl.mri_session_id
        AND r.route_id       = sl.route_id
        AND r.doj            = sl.doj
    LEFT JOIN txn t
        ON  r.mri_session_id = t.mri_session_id
        AND r.route_id       = t.route_id
        AND r.doj            = t.doj
    WHERE r.tuple_position <= 20
      AND r.dbd IN ('0', '1', '2', '3', '4', '5+')
),
agg AS (
    SELECT
        'User Type' AS cut_type,
        COALESCE(user_type, 'Unknown') AS segment,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN click_id END) AS test_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN click_id END) AS test_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN click_id END) AS rest_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN click_id END) AS rest_top20_clicks,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN click_id END) AS all_top10_clicks,
        COUNT(DISTINCT click_id)                                                            AS all_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN tin END)      AS test_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN tin END)      AS test_top20_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN tin END)      AS rest_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN tin END)      AS rest_top20_orders,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN tin END)      AS all_top10_orders,
        COUNT(DISTINCT tin)                                                                 AS all_top20_orders
    FROM base
    GROUP BY 1, 2
)
SELECT
    cut_type,
    segment,
    test_top10_clicks, test_top20_clicks,
    ROUND(100.0 * test_top10_clicks / NULLIF(test_top20_clicks, 0), 2) AS test_click_share_within,
    rest_top10_clicks, rest_top20_clicks,
    ROUND(100.0 * rest_top10_clicks / NULLIF(rest_top20_clicks, 0), 2) AS rest_click_share_within,
    all_top10_clicks, all_top20_clicks,
    ROUND(100.0 * all_top10_clicks  / NULLIF(all_top20_clicks, 0), 2)  AS overall_click_share_within,
    ROUND(100.0 * test_top10_clicks / NULLIF(all_top20_clicks, 0), 2)  AS test_click_share_vs_all_top20,
    test_top10_orders, test_top20_orders,
    ROUND(100.0 * test_top10_orders / NULLIF(test_top20_orders, 0), 2) AS test_order_share_within,
    rest_top10_orders, rest_top20_orders,
    ROUND(100.0 * rest_top10_orders / NULLIF(rest_top20_orders, 0), 2) AS rest_order_share_within,
    all_top10_orders, all_top20_orders,
    ROUND(100.0 * all_top10_orders  / NULLIF(all_top20_orders, 0), 2)  AS overall_order_share_within,
    ROUND(100.0 * test_top10_orders / NULLIF(all_top20_orders, 0), 2)  AS test_order_share_vs_all_top20
FROM agg
ORDER BY segment;


-- =====================================================================================
-- Q4. DESTINATION CATEGORY CUT (Tier 1 / Tier 2 / Tier 3 / Pilgrim / Leisure)
-- =====================================================================================
WITH city_tier_map AS (
    -- Tier 1 / Tier 2 / Pilgrim / Leisure are explicit; every other dest_id falls through to Tier 3.
    -- Pilgrim / Leisure take precedence over tier, matching the governed city-tagging semantics.
    SELECT dest_id, tier FROM (VALUES
        (122, 'Tier 1'),
        (123, 'Tier 1'),
        (124, 'Tier 1'),
        (126, 'Tier 1'),
        (130, 'Tier 1'),
        (141, 'Tier 1'),
        (313, 'Tier 1'),
        (462, 'Tier 1'),
        (551, 'Tier 1'),
        (733, 'Tier 1'),
        (807, 'Tier 1'),
        (933, 'Tier 1'),
        (1073, 'Tier 1'),
        (1304, 'Tier 1'),
        (1429, 'Tier 1'),
        (70015, 'Tier 1'),
        (70633, 'Tier 1'),
        (71145, 'Tier 1'),
        (74820, 'Tier 1'),
        (76397, 'Tier 1'),
        (82100, 'Tier 1'),
        (94113, 'Tier 1'),
        (95174, 'Tier 1'),
        (201126, 'Tier 1'),
        (201665, 'Tier 1'),
        (215450, 'Tier 1'),
        (125, 'Tier 2'),
        (131, 'Tier 2'),
        (135, 'Tier 2'),
        (137, 'Tier 2'),
        (216, 'Tier 2'),
        (233, 'Tier 2'),
        (235, 'Tier 2'),
        (236, 'Tier 2'),
        (248, 'Tier 2'),
        (284, 'Tier 2'),
        (309, 'Tier 2'),
        (444, 'Tier 2'),
        (458, 'Tier 2'),
        (470, 'Tier 2'),
        (472, 'Tier 2'),
        (473, 'Tier 2'),
        (575, 'Tier 2'),
        (602, 'Tier 2'),
        (624, 'Tier 2'),
        (690, 'Tier 2'),
        (696, 'Tier 2'),
        (698, 'Tier 2'),
        (736, 'Tier 2'),
        (737, 'Tier 2'),
        (777, 'Tier 2'),
        (833, 'Tier 2'),
        (979, 'Tier 2'),
        (995, 'Tier 2'),
        (1003, 'Tier 2'),
        (1169, 'Tier 2'),
        (1290, 'Tier 2'),
        (1377, 'Tier 2'),
        (1439, 'Tier 2'),
        (1443, 'Tier 2'),
        (69802, 'Tier 2'),
        (70014, 'Tier 2'),
        (70024, 'Tier 2'),
        (71425, 'Tier 2'),
        (71757, 'Tier 2'),
        (71929, 'Tier 2'),
        (74661, 'Tier 2'),
        (74676, 'Tier 2'),
        (74699, 'Tier 2'),
        (74701, 'Tier 2'),
        (76079, 'Tier 2'),
        (76431, 'Tier 2'),
        (76451, 'Tier 2'),
        (78027, 'Tier 2'),
        (95083, 'Tier 2'),
        (95222, 'Tier 2'),
        (197696, 'Tier 2'),
        (133, 'Pilgrim'),
        (134, 'Pilgrim'),
        (142, 'Pilgrim'),
        (154, 'Pilgrim'),
        (177, 'Pilgrim'),
        (189, 'Pilgrim'),
        (196, 'Pilgrim'),
        (217, 'Pilgrim'),
        (231, 'Pilgrim'),
        (247, 'Pilgrim'),
        (275, 'Pilgrim'),
        (293, 'Pilgrim'),
        (361, 'Pilgrim'),
        (403, 'Pilgrim'),
        (427, 'Pilgrim'),
        (466, 'Pilgrim'),
        (471, 'Pilgrim'),
        (489, 'Pilgrim'),
        (496, 'Pilgrim'),
        (501, 'Pilgrim'),
        (517, 'Pilgrim'),
        (520, 'Pilgrim'),
        (534, 'Pilgrim'),
        (576, 'Pilgrim'),
        (636, 'Pilgrim'),
        (663, 'Pilgrim'),
        (669, 'Pilgrim'),
        (735, 'Pilgrim'),
        (747, 'Pilgrim'),
        (759, 'Pilgrim'),
        (802, 'Pilgrim'),
        (808, 'Pilgrim'),
        (842, 'Pilgrim'),
        (879, 'Pilgrim'),
        (960, 'Pilgrim'),
        (975, 'Pilgrim'),
        (987, 'Pilgrim'),
        (1001, 'Pilgrim'),
        (1007, 'Pilgrim'),
        (1061, 'Pilgrim'),
        (1128, 'Pilgrim'),
        (1136, 'Pilgrim'),
        (1141, 'Pilgrim'),
        (1148, 'Pilgrim'),
        (1219, 'Pilgrim'),
        (1242, 'Pilgrim'),
        (1343, 'Pilgrim'),
        (1351, 'Pilgrim'),
        (1459, 'Pilgrim'),
        (1496, 'Pilgrim'),
        (1528, 'Pilgrim'),
        (1529, 'Pilgrim'),
        (1585, 'Pilgrim'),
        (65805, 'Pilgrim'),
        (65815, 'Pilgrim'),
        (66007, 'Pilgrim'),
        (68705, 'Pilgrim'),
        (68747, 'Pilgrim'),
        (69475, 'Pilgrim'),
        (69526, 'Pilgrim'),
        (70030, 'Pilgrim'),
        (70346, 'Pilgrim'),
        (70429, 'Pilgrim'),
        (70628, 'Pilgrim'),
        (70983, 'Pilgrim'),
        (71642, 'Pilgrim'),
        (71756, 'Pilgrim'),
        (73533, 'Pilgrim'),
        (74124, 'Pilgrim'),
        (74130, 'Pilgrim'),
        (74690, 'Pilgrim'),
        (74708, 'Pilgrim'),
        (75103, 'Pilgrim'),
        (76187, 'Pilgrim'),
        (76480, 'Pilgrim'),
        (77093, 'Pilgrim'),
        (77167, 'Pilgrim'),
        (77530, 'Pilgrim'),
        (77687, 'Pilgrim'),
        (77705, 'Pilgrim'),
        (78796, 'Pilgrim'),
        (80438, 'Pilgrim'),
        (81826, 'Pilgrim'),
        (82558, 'Pilgrim'),
        (83409, 'Pilgrim'),
        (84310, 'Pilgrim'),
        (84832, 'Pilgrim'),
        (84848, 'Pilgrim'),
        (93189, 'Pilgrim'),
        (93580, 'Pilgrim'),
        (93968, 'Pilgrim'),
        (94509, 'Pilgrim'),
        (94515, 'Pilgrim'),
        (94782, 'Pilgrim'),
        (94877, 'Pilgrim'),
        (194482, 'Pilgrim'),
        (196096, 'Pilgrim'),
        (196752, 'Pilgrim'),
        (197504, 'Pilgrim'),
        (198750, 'Pilgrim'),
        (198868, 'Pilgrim'),
        (200347, 'Pilgrim'),
        (202212, 'Pilgrim'),
        (204358, 'Pilgrim'),
        (205655, 'Pilgrim'),
        (215191, 'Pilgrim'),
        (216346, 'Pilgrim'),
        (216354, 'Pilgrim'),
        (216551, 'Pilgrim'),
        (217335, 'Pilgrim'),
        (217362, 'Pilgrim'),
        (265316, 'Pilgrim'),
        (298723, 'Pilgrim'),
        (300439, 'Pilgrim'),
        (305974, 'Pilgrim'),
        (166, 'Leisure'),
        (187, 'Leisure'),
        (206, 'Leisure'),
        (210, 'Leisure'),
        (212, 'Leisure'),
        (227, 'Leisure'),
        (254, 'Leisure'),
        (286, 'Leisure'),
        (445, 'Leisure'),
        (446, 'Leisure'),
        (558, 'Leisure'),
        (606, 'Leisure'),
        (722, 'Leisure'),
        (734, 'Leisure'),
        (750, 'Leisure'),
        (756, 'Leisure'),
        (757, 'Leisure'),
        (771, 'Leisure'),
        (773, 'Leisure'),
        (791, 'Leisure'),
        (827, 'Leisure'),
        (938, 'Leisure'),
        (983, 'Leisure'),
        (1013, 'Leisure'),
        (1021, 'Leisure'),
        (1045, 'Leisure'),
        (1049, 'Leisure'),
        (1120, 'Leisure'),
        (1171, 'Leisure'),
        (1185, 'Leisure'),
        (1244, 'Leisure'),
        (1285, 'Leisure'),
        (1419, 'Leisure'),
        (1422, 'Leisure'),
        (1440, 'Leisure'),
        (1514, 'Leisure'),
        (1603, 'Leisure'),
        (65768, 'Leisure'),
        (65769, 'Leisure'),
        (65954, 'Leisure'),
        (68738, 'Leisure'),
        (69774, 'Leisure'),
        (71261, 'Leisure'),
        (71696, 'Leisure'),
        (71958, 'Leisure'),
        (72506, 'Leisure'),
        (73527, 'Leisure'),
        (74694, 'Leisure'),
        (74706, 'Leisure'),
        (74709, 'Leisure'),
        (75078, 'Leisure'),
        (76140, 'Leisure'),
        (77726, 'Leisure'),
        (79819, 'Leisure'),
        (81723, 'Leisure'),
        (81930, 'Leisure'),
        (82467, 'Leisure'),
        (82554, 'Leisure'),
        (84913, 'Leisure'),
        (86958, 'Leisure'),
        (88286, 'Leisure'),
        (90895, 'Leisure'),
        (92453, 'Leisure'),
        (92578, 'Leisure'),
        (93115, 'Leisure'),
        (93333, 'Leisure'),
        (94200, 'Leisure'),
        (95184, 'Leisure'),
        (95218, 'Leisure'),
        (195703, 'Leisure'),
        (197681, 'Leisure'),
        (197688, 'Leisure'),
        (198236, 'Leisure'),
        (199106, 'Leisure'),
        (201003, 'Leisure'),
        (201669, 'Leisure'),
        (202764, 'Leisure'),
        (204216, 'Leisure'),
        (204362, 'Leisure'),
        (204429, 'Leisure'),
        (215221, 'Leisure'),
        (215824, 'Leisure'),
        (216190, 'Leisure'),
        (220192, 'Leisure'),
        (260317, 'Leisure'),
        (289877, 'Leisure'),
        (298546, 'Leisure')
    ) AS t(dest_id, tier)
),
srp AS (
    SELECT
        s.mri_session_id,
        s.route_id,
        s.src_id,
        s.dest_id,
        CAST(s.doj AS DATE)     AS doj,
        CASE
            WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) >= 5 THEN '5+'
            ELSE CAST(DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) AS VARCHAR)
        END                     AS dbd,
        MIN(s.offset + s.position + 1)                                    AS tuple_position,
        MAX(CASE WHEN CONTAINS(s.persuasion_id, '68') THEN 1 ELSE 0 END)  AS is_new_bus
    FROM user_interaction.search_route_details s
    INNER JOIN user_interaction.search_details d
        ON  s.__time         = d.__time
        AND s.mri_session_id = d.mri_session_id
    WHERE s.__time >= TIMESTAMP '2026-09-16 18:30:00'
      AND s.__time <  TIMESTAMP '2026-09-21 18:30:00'
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os      = 'Android'
      AND d.is_filter_applied = FALSE
      AND d.sort < 1
      AND s.mri_session_id IS NOT NULL
      AND s.route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6
),
top_sd AS (
    SELECT src_id, dest_id
    FROM srp
    GROUP BY 1, 2
    ORDER BY COUNT(DISTINCT mri_session_id) DESC
    LIMIT 200
),
sl AS (
    SELECT mri_session_id, route_id, CAST(doj AS DATE) AS doj, mri_uuid
    FROM user_interaction.seat_layout_details
    WHERE __time >= TIMESTAMP '2026-09-16 18:30:00'
      AND __time <  TIMESTAMP '2026-09-21 18:30:00'
      AND country = 'IND'
      AND channel = 'MOBILE_APP'
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
      AND mri_uuid       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
txn AS (
    SELECT
        mri_session_id,
        route_id,
        DATE(DATE_ADD('MINUTE', 330, date_of_journey)) AS doj,
        tin
    FROM transaction.bus_ticket_events
    WHERE time_of_event >= TIMESTAMP '2026-09-16 18:30:00'
      AND time_of_event <  TIMESTAMP '2026-09-21 18:30:00'
      AND country_code = 'IND'
      AND event_type   = 101
      AND event_class  = 2
      AND sales_channel = 'RB:MOBILEWEB#droidapp'
      AND tin IS NOT NULL
      AND tin NOT IN ('', 'null')
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
base AS (
    SELECT
        COALESCE(ctm.tier, 'Tier 3') AS destination_category,
        r.tuple_position,
        r.is_new_bus,
        sl.mri_uuid AS click_id,
        t.tin
    FROM srp r
    INNER JOIN top_sd sd
        ON  r.src_id  = sd.src_id
        AND r.dest_id = sd.dest_id
    LEFT JOIN city_tier_map ctm
        ON ctm.dest_id = r.dest_id
    LEFT JOIN sl
        ON  r.mri_session_id = sl.mri_session_id
        AND r.route_id       = sl.route_id
        AND r.doj            = sl.doj
    LEFT JOIN txn t
        ON  r.mri_session_id = t.mri_session_id
        AND r.route_id       = t.route_id
        AND r.doj            = t.doj
    WHERE r.tuple_position <= 20
      AND r.dbd IN ('0', '1', '2', '3', '4', '5+')
),
agg AS (
    SELECT
        'Destination Category' AS cut_type,
        destination_category   AS segment,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN click_id END) AS test_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN click_id END) AS test_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN click_id END) AS rest_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN click_id END) AS rest_top20_clicks,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN click_id END) AS all_top10_clicks,
        COUNT(DISTINCT click_id)                                                            AS all_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN tin END)      AS test_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN tin END)      AS test_top20_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN tin END)      AS rest_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN tin END)      AS rest_top20_orders,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN tin END)      AS all_top10_orders,
        COUNT(DISTINCT tin)                                                                 AS all_top20_orders
    FROM base
    GROUP BY 1, 2
)
SELECT
    cut_type,
    segment,
    test_top10_clicks, test_top20_clicks,
    ROUND(100.0 * test_top10_clicks / NULLIF(test_top20_clicks, 0), 2) AS test_click_share_within,
    rest_top10_clicks, rest_top20_clicks,
    ROUND(100.0 * rest_top10_clicks / NULLIF(rest_top20_clicks, 0), 2) AS rest_click_share_within,
    all_top10_clicks, all_top20_clicks,
    ROUND(100.0 * all_top10_clicks  / NULLIF(all_top20_clicks, 0), 2)  AS overall_click_share_within,
    ROUND(100.0 * test_top10_clicks / NULLIF(all_top20_clicks, 0), 2)  AS test_click_share_vs_all_top20,
    test_top10_orders, test_top20_orders,
    ROUND(100.0 * test_top10_orders / NULLIF(test_top20_orders, 0), 2) AS test_order_share_within,
    rest_top10_orders, rest_top20_orders,
    ROUND(100.0 * rest_top10_orders / NULLIF(rest_top20_orders, 0), 2) AS rest_order_share_within,
    all_top10_orders, all_top20_orders,
    ROUND(100.0 * all_top10_orders  / NULLIF(all_top20_orders, 0), 2)  AS overall_order_share_within,
    ROUND(100.0 * test_top10_orders / NULLIF(all_top20_orders, 0), 2)  AS test_order_share_vs_all_top20
FROM agg
ORDER BY segment;


-- =====================================================================================
-- Q5. DBD CUT (0, 1, 2, 3, 4, 5+)
-- =====================================================================================
WITH srp AS (
    SELECT
        s.mri_session_id,
        s.route_id,
        s.src_id,
        s.dest_id,
        CAST(s.doj AS DATE)     AS doj,
        CASE
            WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) >= 5 THEN '5+'
            ELSE CAST(DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, s.__time)), CAST(s.doj AS DATE)) AS VARCHAR)
        END                     AS dbd,
        MIN(s.offset + s.position + 1)                                    AS tuple_position,
        MAX(CASE WHEN CONTAINS(s.persuasion_id, '68') THEN 1 ELSE 0 END)  AS is_new_bus
    FROM user_interaction.search_route_details s
    INNER JOIN user_interaction.search_details d
        ON  s.__time         = d.__time
        AND s.mri_session_id = d.mri_session_id
    WHERE s.__time >= TIMESTAMP '2026-09-16 18:30:00'
      AND s.__time <  TIMESTAMP '2026-09-21 18:30:00'
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os      = 'Android'
      AND d.is_filter_applied = FALSE
      AND d.sort < 1
      AND s.mri_session_id IS NOT NULL
      AND s.route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6
),
top_sd AS (
    SELECT src_id, dest_id
    FROM srp
    GROUP BY 1, 2
    ORDER BY COUNT(DISTINCT mri_session_id) DESC
    LIMIT 200
),
sl AS (
    SELECT mri_session_id, route_id, CAST(doj AS DATE) AS doj, mri_uuid
    FROM user_interaction.seat_layout_details
    WHERE __time >= TIMESTAMP '2026-09-16 18:30:00'
      AND __time <  TIMESTAMP '2026-09-21 18:30:00'
      AND country = 'IND'
      AND channel = 'MOBILE_APP'
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
      AND mri_uuid       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
txn AS (
    SELECT
        mri_session_id,
        route_id,
        DATE(DATE_ADD('MINUTE', 330, date_of_journey)) AS doj,
        tin
    FROM transaction.bus_ticket_events
    WHERE time_of_event >= TIMESTAMP '2026-09-16 18:30:00'
      AND time_of_event <  TIMESTAMP '2026-09-21 18:30:00'
      AND country_code = 'IND'
      AND event_type   = 101
      AND event_class  = 2
      AND sales_channel = 'RB:MOBILEWEB#droidapp'
      AND tin IS NOT NULL
      AND tin NOT IN ('', 'null')
      AND mri_session_id IS NOT NULL
      AND route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),
base AS (
    SELECT
        r.dbd,
        r.tuple_position,
        r.is_new_bus,
        sl.mri_uuid AS click_id,
        t.tin
    FROM srp r
    INNER JOIN top_sd sd
        ON  r.src_id  = sd.src_id
        AND r.dest_id = sd.dest_id
    LEFT JOIN sl
        ON  r.mri_session_id = sl.mri_session_id
        AND r.route_id       = sl.route_id
        AND r.doj            = sl.doj
    LEFT JOIN txn t
        ON  r.mri_session_id = t.mri_session_id
        AND r.route_id       = t.route_id
        AND r.doj            = t.doj
    WHERE r.tuple_position <= 20
      AND r.dbd IN ('0', '1', '2', '3', '4', '5+')
),
agg AS (
    SELECT
        'DBD' AS cut_type,
        dbd   AS segment,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN click_id END) AS test_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN click_id END) AS test_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN click_id END) AS rest_top10_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN click_id END) AS rest_top20_clicks,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN click_id END) AS all_top10_clicks,
        COUNT(DISTINCT click_id)                                                            AS all_top20_clicks,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1 AND tuple_position <= 10 THEN tin END)      AS test_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 1                          THEN tin END)      AS test_top20_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0 AND tuple_position <= 10 THEN tin END)      AS rest_top10_orders,
        COUNT(DISTINCT CASE WHEN is_new_bus = 0                          THEN tin END)      AS rest_top20_orders,
        COUNT(DISTINCT CASE WHEN                    tuple_position <= 10 THEN tin END)      AS all_top10_orders,
        COUNT(DISTINCT tin)                                                                 AS all_top20_orders
    FROM base
    GROUP BY 1, 2
)
SELECT
    cut_type,
    segment,
    test_top10_clicks, test_top20_clicks,
    ROUND(100.0 * test_top10_clicks / NULLIF(test_top20_clicks, 0), 2) AS test_click_share_within,
    rest_top10_clicks, rest_top20_clicks,
    ROUND(100.0 * rest_top10_clicks / NULLIF(rest_top20_clicks, 0), 2) AS rest_click_share_within,
    all_top10_clicks, all_top20_clicks,
    ROUND(100.0 * all_top10_clicks  / NULLIF(all_top20_clicks, 0), 2)  AS overall_click_share_within,
    ROUND(100.0 * test_top10_clicks / NULLIF(all_top20_clicks, 0), 2)  AS test_click_share_vs_all_top20,
    test_top10_orders, test_top20_orders,
    ROUND(100.0 * test_top10_orders / NULLIF(test_top20_orders, 0), 2) AS test_order_share_within,
    rest_top10_orders, rest_top20_orders,
    ROUND(100.0 * rest_top10_orders / NULLIF(rest_top20_orders, 0), 2) AS rest_order_share_within,
    all_top10_orders, all_top20_orders,
    ROUND(100.0 * all_top10_orders  / NULLIF(all_top20_orders, 0), 2)  AS overall_order_share_within,
    ROUND(100.0 * test_top10_orders / NULLIF(all_top20_orders, 0), 2)  AS test_order_share_vs_all_top20
FROM agg
ORDER BY CASE segment WHEN '0' THEN 0 WHEN '1' THEN 1 WHEN '2' THEN 2 WHEN '3' THEN 3 WHEN '4' THEN 4 ELSE 5 END;
