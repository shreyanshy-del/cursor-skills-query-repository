-- =============================================================================
-- Q3: Return BOOKERS by DOI→DOJ / ON_DOJ / POST_DOJ
--        × Within 14d of DOI vs NOT within 14d of DOI
-- Cuts: Platform | Pilgrim | Leisure ONLY (same dest map as search twin)
--
-- Same onward cohort as:
--   Q3_FULL_return_search_days_since_doj_m14_to_p13_Platform_Pilgrim_Leisure.sql
--   DOI 11 Aug 2026 – 8 Sep 2026 IST | Android IND | event_type=101
--
-- Return = reverse-route confirmed booking (B→A) AFTER onward booking time
-- FIRST return booking day (IST):
--   DOI_TO_DOJ : onward_doi <= first_txn_day <  onward_doj
--   ON_DOJ     : first_txn_day = onward_doj
--   POST_DOJ   : first_txn_day > onward_doj
--   WITHIN_14D_DOI     : first_txn_day <= onward_doi + 13   (14 calendar days)
--   NOT_WITHIN_14D_DOI : first_txn_day >  onward_doi + 13
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

return_route_keys AS (
  SELECT DISTINCT
    rb_user_id,
    dest_id AS return_src_id,
    src_id  AS return_dest_id,
    onward_txn_time,
    onward_doi,
    onward_doj,
    destination_tier
  FROM onward_txn
),

return_txn_hits AS (
  SELECT
    rk.destination_tier,
    rk.rb_user_id,
    rk.onward_doi,
    rk.onward_doj,
    CAST(DATE_TRUNC('day', AT_TIMEZONE(t.time_of_event, 'Asia/Kolkata')) AS DATE) AS txn_day
  FROM transaction.bus_ticket_events t
  INNER JOIN return_route_keys rk
    ON t.rb_user_id = rk.rb_user_id
   AND t.source_location_id = rk.return_src_id
   AND t.destination_location_id = rk.return_dest_id
   AND t.time_of_event > rk.onward_txn_time
  WHERE t.country_code = 'IND'
    AND t.event_type = 101
    AND t.tin IS NOT NULL
    AND t.sales_channel IN ('RB:MOBILEWEB#droidapp', 'DROIDAPP')
    AND t.time_of_event > TIMESTAMP '2026-08-10 18:30:00'
    AND t.time_of_event <  TIMESTAMP '2026-11-30 18:30:00'
),

first_return_txn AS (
  SELECT
    destination_tier,
    rb_user_id,
    onward_doi,
    onward_doj,
    MIN(txn_day) AS first_txn_day
  FROM return_txn_hits
  WHERE txn_day >= onward_doi
  GROUP BY 1, 2, 3, 4
),

first_return_txn_flags AS (
  SELECT
    destination_tier,
    rb_user_id,
    first_txn_day,
    CASE
      WHEN first_txn_day < onward_doj THEN 'DOI_TO_DOJ'
      WHEN first_txn_day = onward_doj THEN 'ON_DOJ'
      ELSE 'POST_DOJ'
    END AS book_section,
    CASE
      WHEN first_txn_day <= DATE_ADD('day', 13, onward_doi) THEN 1
      ELSE 0
    END AS within_14d_of_doi
  FROM first_return_txn
),

-- Platform: take flags from the tier-row with earliest first_txn_day
platform_flags AS (
  SELECT
    'Platform' AS destination_tier,
    rb_user_id,
    book_section,
    within_14d_of_doi
  FROM (
    SELECT
      rb_user_id,
      book_section,
      within_14d_of_doi,
      ROW_NUMBER() OVER (
        PARTITION BY rb_user_id
        ORDER BY first_txn_day, destination_tier
      ) AS rn
    FROM first_return_txn_flags
  ) x
  WHERE rn = 1
),

all_flags AS (
  SELECT destination_tier, rb_user_id, book_section, within_14d_of_doi
  FROM first_return_txn_flags
  UNION ALL
  SELECT destination_tier, rb_user_id, book_section, within_14d_of_doi
  FROM platform_flags
),

base_users AS (
  SELECT
    CASE WHEN GROUPING(destination_tier) = 1 THEN 'Platform' ELSE destination_tier END AS destination_tier,
    COUNT(DISTINCT rb_user_id) AS onward_bookers
  FROM onward_txn
  GROUP BY GROUPING SETS ((destination_tier), ())
),

section_totals AS (
  SELECT
    destination_tier,
    -- DOI → DOJ
    COUNT(CASE WHEN book_section = 'DOI_TO_DOJ' AND within_14d_of_doi = 1 THEN 1 END)
      AS doi_to_doj_within_14d_doi,
    COUNT(CASE WHEN book_section = 'DOI_TO_DOJ' AND within_14d_of_doi = 0 THEN 1 END)
      AS doi_to_doj_not_within_14d_doi,
    COUNT(CASE WHEN book_section = 'DOI_TO_DOJ' THEN 1 END)
      AS doi_to_doj_return_bookers,
    -- ON DOJ
    COUNT(CASE WHEN book_section = 'ON_DOJ' AND within_14d_of_doi = 1 THEN 1 END)
      AS on_doj_within_14d_doi,
    COUNT(CASE WHEN book_section = 'ON_DOJ' AND within_14d_of_doi = 0 THEN 1 END)
      AS on_doj_not_within_14d_doi,
    COUNT(CASE WHEN book_section = 'ON_DOJ' THEN 1 END)
      AS on_doj_return_bookers,
    -- POST DOJ
    COUNT(CASE WHEN book_section = 'POST_DOJ' AND within_14d_of_doi = 1 THEN 1 END)
      AS post_doj_within_14d_doi,
    COUNT(CASE WHEN book_section = 'POST_DOJ' AND within_14d_of_doi = 0 THEN 1 END)
      AS post_doj_not_within_14d_doi,
    COUNT(CASE WHEN book_section = 'POST_DOJ' THEN 1 END)
      AS post_doj_return_bookers,
    -- Any return
    COUNT(CASE WHEN within_14d_of_doi = 1 THEN 1 END) AS any_within_14d_doi,
    COUNT(CASE WHEN within_14d_of_doi = 0 THEN 1 END) AS any_not_within_14d_doi,
    COUNT(*) AS any_return_bookers
  FROM all_flags
  GROUP BY 1
)

SELECT
  b.destination_tier,
  b.onward_bookers,
  -- DOI → DOJ
  COALESCE(st.doi_to_doj_return_bookers, 0) AS doi_to_doj_return_bookers,
  COALESCE(st.doi_to_doj_within_14d_doi, 0) AS doi_to_doj_within_14d_doi,
  COALESCE(st.doi_to_doj_not_within_14d_doi, 0) AS doi_to_doj_not_within_14d_doi,
  -- ON DOJ
  COALESCE(st.on_doj_return_bookers, 0) AS on_doj_return_bookers,
  COALESCE(st.on_doj_within_14d_doi, 0) AS on_doj_within_14d_doi,
  COALESCE(st.on_doj_not_within_14d_doi, 0) AS on_doj_not_within_14d_doi,
  -- POST DOJ
  COALESCE(st.post_doj_return_bookers, 0) AS post_doj_return_bookers,
  COALESCE(st.post_doj_within_14d_doi, 0) AS post_doj_within_14d_doi,
  COALESCE(st.post_doj_not_within_14d_doi, 0) AS post_doj_not_within_14d_doi,
  -- Any
  COALESCE(st.any_return_bookers, 0) AS any_return_bookers,
  COALESCE(st.any_within_14d_doi, 0) AS any_within_14d_doi,
  COALESCE(st.any_not_within_14d_doi, 0) AS any_not_within_14d_doi,
  ROUND(100.0 * COALESCE(st.any_return_bookers, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS any_return_booking_rate_pct,
  ROUND(100.0 * COALESCE(st.any_within_14d_doi, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS within_14d_doi_rate_pct,
  ROUND(100.0 * COALESCE(st.any_not_within_14d_doi, 0) / NULLIF(b.onward_bookers, 0), 2)
    AS not_within_14d_doi_rate_pct
FROM base_users b
LEFT JOIN section_totals st
  ON b.destination_tier = st.destination_tier
ORDER BY
  CASE b.destination_tier
    WHEN 'Platform' THEN 0 WHEN 'Pilgrim' THEN 1 WHEN 'Leisure' THEN 2 ELSE 9
  END;
