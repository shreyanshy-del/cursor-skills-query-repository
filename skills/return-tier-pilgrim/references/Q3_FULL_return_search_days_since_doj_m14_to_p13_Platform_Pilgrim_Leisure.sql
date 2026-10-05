-- =============================================================================
-- Q3 DOJ RELATIVE: Return SEARCH by days vs onward DOJ (D-14 .. D+13)
-- Cuts: Platform | Pilgrim | Leisure ONLY (Tier 1/2/3 excluded)
--   Platform = Pilgrim + Leisure combined (rollup)
--
-- OPTIMIZED vs full city_tier dump:
--   1) city_tier_map = Pilgrim+Leisure only (~202 ids; Tier 1/2/3 dropped)
--   2) search scan pruned to reverse-route pairs from onward bookings (not all searches)
--   3) cumulative via window SUM of daily news (avoids day_spine × users COUNT DISTINCT)
--   4) single pass over first_return_search for Platform rollup + section totals
--
-- Forward / onward cohort:
--   DOI in 11 Aug 2026 – 8 Sep 2026 IST
--   UTC: 2026-08-10 18:30:00 → 2026-09-08 18:30:00
--   Android IND | event_type=101 | Mehar Pilgrim & Leisure dests
--
-- Return = reverse-route search (B→A) AFTER onward booking time
-- Day key = DATE_DIFF(day, onward_doj, search_day_IST)
-- =============================================================================

WITH city_tier_map AS (
  SELECT dest_id, tier FROM (VALUES
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

-- Confirmed onward bookings into Pilgrim / Leisure destinations
onward_txn AS (
  SELECT
    b.rb_user_id,
    b.tin AS onward_tin,
    b.source_location_id AS src_id,
    b.destination_location_id AS dest_id,
    ctm.tier AS destination_tier,
    b.time_of_event AS onward_txn_time,
    CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_issue, 'Asia/Kolkata')) AS DATE) AS onward_doi,
    CAST(DATE_TRUNC('day', AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata')) AS DATE) AS onward_doj
  FROM transaction.bus_ticket_events b
  INNER JOIN city_tier_map ctm
    ON b.destination_location_id = ctm.dest_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.tin IS NOT NULL
    AND b.rb_user_id > 0
    AND b.sales_channel IN ('RB:MOBILEWEB#droidapp', 'DROIDAPP')
    AND b.date_of_issue >= TIMESTAMP '2026-08-10 18:30:00'
    AND b.date_of_issue <  TIMESTAMP '2026-09-08 18:30:00'
    AND b.date_of_journey IS NOT NULL
),

-- Distinct reverse-route keys to prune search_details early
return_route_keys AS (
  SELECT DISTINCT
    rb_user_id,
    dest_id AS return_src_id,   -- onward dest → return origin
    src_id  AS return_dest_id,  -- onward src  → return destination
    onward_txn_time,
    onward_doj,
    destination_tier
  FROM onward_txn
),

-- Searches only on reverse routes, after booking, within DOJ±window
return_search_hits AS (
  SELECT
    rk.destination_tier,
    rk.rb_user_id,
    DATE_DIFF(
      'day',
      rk.onward_doj,
      CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE)
    ) AS days_since_doj
  FROM user_interaction.search_details s
  INNER JOIN return_route_keys rk
    ON s.rb_user_id = rk.rb_user_id
   AND s.src_id = rk.return_src_id
   AND s.dest_id = rk.return_dest_id
   AND s.__time > rk.onward_txn_time
  WHERE s.country = 'IND'
    AND s.os = 'Android'
    AND s.mri_session_id IS NOT NULL
    AND s.__time > TIMESTAMP '2026-07-20 18:30:00'   -- room for DOJ-14 before cohort start
    AND s.__time <  TIMESTAMP '2026-11-30 18:30:00'   -- room for late DOJ +13
    AND CAST(DATE_TRUNC('day', AT_TIMEZONE(s.__time, 'Asia/Kolkata')) AS DATE)
          BETWEEN DATE_ADD('day', -14, rk.onward_doj)
              AND DATE_ADD('day',  13, rk.onward_doj)
),

-- First return-search day in [-14, +13] per user × tier
first_return_search AS (
  SELECT
    destination_tier,
    rb_user_id,
    MIN(days_since_doj) AS first_search_day
  FROM return_search_hits
  WHERE days_since_doj BETWEEN -14 AND 13
  GROUP BY 1, 2
),

-- Tier rows + Platform rollup (earliest first-search day across tiers)
first_return_search_w_overall AS (
  SELECT destination_tier, rb_user_id, first_search_day
  FROM first_return_search
  UNION ALL
  SELECT
    'Platform' AS destination_tier,
    rb_user_id,
    MIN(first_search_day) AS first_search_day
  FROM first_return_search
  GROUP BY rb_user_id
),

day_spine AS (
  SELECT day_n FROM UNNEST(SEQUENCE(-14, 13)) AS t(day_n)
),

base_users AS (
  SELECT
    CASE WHEN GROUPING(destination_tier) = 1 THEN 'Platform' ELSE destination_tier END AS destination_tier,
    COUNT(DISTINCT rb_user_id) AS onward_bookers
  FROM onward_txn
  GROUP BY GROUPING SETS ((destination_tier), ())
),

-- Daily new searchers (zeros filled via final CROSS JOIN + COALESCE)
inc_search AS (
  SELECT
    destination_tier,
    first_search_day AS days_since_doj,
    COUNT(*) AS new_return_searchers_on_day
  FROM first_return_search_w_overall
  GROUP BY 1, 2
),

-- Cumulative = running sum of daily news (equiv. to COUNT DISTINCT first_day <= d)
cum_search AS (
  SELECT
    b.destination_tier,
    d.day_n AS days_since_doj,
    SUM(COALESCE(i.new_return_searchers_on_day, 0)) OVER (
      PARTITION BY b.destination_tier
      ORDER BY d.day_n
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_return_searchers
  FROM base_users b
  CROSS JOIN day_spine d
  LEFT JOIN inc_search i
    ON b.destination_tier = i.destination_tier
   AND d.day_n = i.days_since_doj
),

section_totals AS (
  SELECT
    destination_tier,
    COUNT(CASE WHEN first_search_day BETWEEN -14 AND -1 THEN 1 END) AS pre_doj_return_searchers,
    COUNT(CASE WHEN first_search_day = 0 THEN 1 END) AS on_doj_return_searchers,
    COUNT(CASE WHEN first_search_day BETWEEN 1 AND 13 THEN 1 END) AS post_doj_return_searchers,
    COUNT(*) AS any_return_searchers_d_minus14_to_plus13
  FROM first_return_search_w_overall
  GROUP BY 1
)

SELECT
  b.destination_tier,
  d.day_n AS days_since_doj,
  CASE
    WHEN d.day_n < 0 THEN 'PRE_DOJ'
    WHEN d.day_n = 0 THEN 'ON_DOJ'
    ELSE 'POST_DOJ'
  END AS doj_section,
  b.onward_bookers AS onward_bookers_base,
  COALESCE(i.new_return_searchers_on_day, 0) AS new_return_searchers_on_day,
  c.cumulative_return_searchers,
  ROUND(100.0 * COALESCE(i.new_return_searchers_on_day, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS new_return_search_rate_pct,
  ROUND(100.0 * c.cumulative_return_searchers / NULLIF(b.onward_bookers, 0), 2)
    AS cumulative_return_search_rate_pct,
  st.pre_doj_return_searchers,
  st.on_doj_return_searchers,
  st.post_doj_return_searchers,
  st.any_return_searchers_d_minus14_to_plus13,
  ROUND(100.0 * st.pre_doj_return_searchers / NULLIF(b.onward_bookers, 0), 2) AS pre_doj_search_rate_pct,
  ROUND(100.0 * st.on_doj_return_searchers / NULLIF(b.onward_bookers, 0), 2) AS on_doj_search_rate_pct,
  ROUND(100.0 * st.post_doj_return_searchers / NULLIF(b.onward_bookers, 0), 2) AS post_doj_search_rate_pct
FROM base_users b
CROSS JOIN day_spine d
LEFT JOIN inc_search i
  ON b.destination_tier = i.destination_tier AND d.day_n = i.days_since_doj
INNER JOIN cum_search c
  ON b.destination_tier = c.destination_tier AND d.day_n = c.days_since_doj
LEFT JOIN section_totals st
  ON b.destination_tier = st.destination_tier
ORDER BY
  CASE b.destination_tier
    WHEN 'Platform' THEN 0 WHEN 'Pilgrim' THEN 1 WHEN 'Leisure' THEN 2 ELSE 9
  END,
  d.day_n;
