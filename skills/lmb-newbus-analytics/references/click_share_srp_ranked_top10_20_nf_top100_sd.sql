-- =============================================================================
-- Click share on Top 10 / Top 20 route_ids ranked by SRP position
-- Non-filtered · Top 100 SDs · Platform | Women_SRP | Female_SVOC
-- Usertype cut (NEW / RETURNING) on Women_SRP & Female_SVOC only
-- Android · IND · BUS
--
-- CHANGE ONLY params t0 / t1 (UTC).
--
-- Ranking: AVG(offset+position+1) from search_route_details (NOT SL/txn volume)
-- Click share: SL on SRP-ranked top N / all SL on SD
-- Usertype: from search_details (NEW / RETURNING|EXISTING|OLD → RETURNING)
-- =============================================================================

WITH params AS (
  SELECT
    -- >>> CHANGE ANALYSIS DATE RANGE ONLY <<<
    TIMESTAMP '2026-03-31 18:30:00' AS t0,
    TIMESTAMP '2026-06-30 18:30:00' AS t1
),

top100_sd AS (
  SELECT * FROM (
    VALUES
      (1, 122, 123, 'Bangalore', 'Chennai'),
      (2, 123, 122, 'Chennai', 'Bangalore'),
      (3, 141, 123, 'Coimbatore', 'Chennai'),
      (4, 123, 141, 'Chennai', 'Coimbatore'),
      (5, 124, 122, 'Hyderabad', 'Bangalore'),
      (6, 122, 124, 'Bangalore', 'Hyderabad'),
      (7, 123, 126, 'Chennai', 'Madurai'),
      (8, 126, 123, 'Madurai', 'Chennai'),
      (9, 124, 134, 'Hyderabad', 'Vijayawada'),
      (10, 141, 122, 'Coimbatore', 'Bangalore'),
      (11, 122, 141, 'Bangalore', 'Coimbatore'),
      (12, 134, 124, 'Vijayawada', 'Hyderabad'),
      (13, 123, 71929, 'Chennai', 'Tiruchirapalli'),
      (14, 602, 123, 'Salem', 'Chennai'),
      (15, 123, 602, 'Chennai', 'Salem'),
      (16, 71929, 123, 'Tiruchirapalli', 'Chennai'),
      (17, 733, 1439, 'Delhi', 'Lucknow'),
      (18, 1439, 733, 'Lucknow', 'Delhi'),
      (19, 69802, 74820, 'Durgapur (West Bengal)', 'Kolkata'),
      (20, 122, 71756, 'Bangalore', 'Tirupati'),
      (21, 71756, 122, 'Tirupati', 'Bangalore'),
      (22, 130, 624, 'Pune', 'Nagpur'),
      (23, 313, 979, 'Indore', 'Bhopal'),
      (24, 624, 130, 'Nagpur', 'Pune'),
      (25, 733, 78027, 'Delhi', 'Gorakhpur (uttar pradesh)'),
      (26, 696, 123, 'Tirunelveli', 'Chennai'),
      (27, 123, 696, 'Chennai', 'Tirunelveli'),
      (28, 979, 313, 'Bhopal', 'Indore'),
      (29, 807, 733, 'Jaipur (Rajasthan)', 'Delhi'),
      (30, 78027, 733, 'Gorakhpur (uttar pradesh)', 'Delhi'),
      (31, 74820, 69802, 'Kolkata', 'Durgapur (West Bengal)'),
      (32, 777, 733, 'Dehradun', 'Delhi'),
      (33, 74694, 74820, 'Siliguri', 'Kolkata'),
      (34, 74820, 74694, 'Kolkata', 'Siliguri'),
      (35, 733, 777, 'Delhi', 'Dehradun'),
      (36, 124, 248, 'Hyderabad', 'Visakhapatnam'),
      (37, 123, 690, 'Chennai', 'Nagercoil'),
      (38, 130, 309, 'Pune', 'Aurangabad (Maharashtra)'),
      (39, 690, 123, 'Nagercoil', 'Chennai'),
      (40, 248, 124, 'Visakhapatnam', 'Hyderabad'),
      (41, 733, 807, 'Delhi', 'Jaipur (Rajasthan)'),
      (42, 130, 462, 'Pune', 'Mumbai'),
      (43, 309, 130, 'Aurangabad (Maharashtra)', 'Pune'),
      (44, 126, 122, 'Madurai', 'Bangalore'),
      (45, 122, 126, 'Bangalore', 'Madurai'),
      (46, 74820, 74706, 'Kolkata', 'Digha'),
      (47, 123, 458, 'Chennai', 'Hosur'),
      (48, 458, 123, 'Hosur', 'Chennai'),
      (49, 124, 71756, 'Hyderabad', 'Tirupati'),
      (50, 462, 130, 'Mumbai', 'Pune'),
      (51, 698, 123, 'Thoothukudi', 'Chennai'),
      (52, 131, 122, 'Nellore', 'Bangalore'),
      (53, 124, 123, 'Hyderabad', 'Chennai'),
      (54, 123, 698, 'Chennai', 'Thoothukudi'),
      (55, 130, 575, 'Pune', 'Latur'),
      (56, 71756, 124, 'Tirupati', 'Hyderabad'),
      (57, 122, 95222, 'Bangalore', 'Mangaluru'),
      (58, 95222, 122, 'Mangaluru', 'Bangalore'),
      (59, 842, 733, 'Rishikesh', 'Delhi'),
      (60, 130, 124, 'Pune', 'Hyderabad'),
      (61, 124, 131, 'Hyderabad', 'Nellore'),
      (62, 122, 131, 'Bangalore', 'Nellore'),
      (63, 74706, 74820, 'Digha', 'Kolkata'),
      (64, 124, 130, 'Hyderabad', 'Pune'),
      (65, 131, 124, 'Nellore', 'Hyderabad'),
      (66, 123, 124, 'Chennai', 'Hyderabad'),
      (67, 236, 123, 'Erode', 'Chennai'),
      (68, 66007, 123, 'Thanjavur', 'Chennai'),
      (69, 462, 76079, 'Mumbai', 'Kolhapur(Maharashtra)'),
      (70, 733, 842, 'Delhi', 'Rishikesh'),
      (71, 76079, 462, 'Kolhapur(Maharashtra)', 'Mumbai'),
      (72, 575, 130, 'Latur', 'Pune'),
      (73, 123, 66007, 'Chennai', 'Thanjavur'),
      (74, 134, 122, 'Vijayawada', 'Bangalore'),
      (75, 123, 236, 'Chennai', 'Erode'),
      (76, 130, 641, 'Pune', 'Jalgaon'),
      (77, 124, 135, 'Hyderabad', 'Ongole'),
      (78, 122, 134, 'Bangalore', 'Vijayawada'),
      (79, 135, 124, 'Ongole', 'Hyderabad'),
      (80, 641, 130, 'Jalgaon', 'Pune'),
      (81, 733, 802, 'Delhi', 'Haridwar'),
      (82, 235, 123, 'Tirupur', 'Chennai'),
      (83, 733, 90355, 'Delhi', 'Azamgarh'),
      (84, 124, 462, 'Hyderabad', 'Mumbai'),
      (85, 216, 122, 'Ernakulam', 'Bangalore'),
      (86, 802, 733, 'Haridwar', 'Delhi'),
      (87, 233, 122, 'Pondicherry', 'Bangalore'),
      (88, 123, 235, 'Chennai', 'Tirupur'),
      (89, 229, 123, 'Dindigul', 'Chennai'),
      (90, 123, 233, 'Chennai', 'Pondicherry'),
      (91, 130, 1476, 'Pune', 'Amravati'),
      (92, 233, 123, 'Pondicherry', 'Chennai'),
      (93, 74678, 74820, 'Burdwan', 'Kolkata'),
      (94, 122, 71929, 'Bangalore', 'Tiruchirapalli'),
      (95, 313, 130, 'Indore', 'Pune'),
      (96, 130, 361, 'Pune', 'Nanded'),
      (97, 71929, 122, 'Tiruchirapalli', 'Bangalore'),
      (98, 126, 141, 'Madurai', 'Coimbatore'),
      (99, 137, 124, 'Guntur (Andhra Pradesh)', 'Hyderabad'),
      (100, 130, 313, 'Pune', 'Indore')

  ) AS t(sd_rank, src_id, dest_id, source_location, destination_location)
),

seg_grid AS (
  SELECT * FROM (
    VALUES
      ('Platform', 'ALL'),
      ('Women_SRP', 'ALL'),
      ('Women_SRP', 'NEW'),
      ('Women_SRP', 'RETURNING'),
      ('Female_SVOC', 'ALL'),
      ('Female_SVOC', 'NEW'),
      ('Female_SVOC', 'RETURNING')
  ) AS s(segment, user_type)
),

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

-- Unfiltered searches + usertype (first search row per session×SD)
nf_search AS (
  SELECT *
  FROM (
    SELECT
      s.mri_session_id,
      s.src_id,
      s.dest_id,
      s.rb_user_id,
      CASE
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('NEW') THEN 'NEW'
        WHEN UPPER(COALESCE(s.user_type, '')) IN ('RETURNING', 'EXISTING', 'OLD') THEN 'RETURNING'
        ELSE 'OTHER'
      END AS user_type,
      ROW_NUMBER() OVER (
        PARTITION BY s.mri_session_id, s.src_id, s.dest_id
        ORDER BY s.__time ASC
      ) AS rn
    FROM user_interaction.search_details s
    CROSS JOIN params p
    INNER JOIN top100_sd t
      ON s.src_id = t.src_id
     AND s.dest_id = t.dest_id
    WHERE s.__time >= p.t0 AND s.__time < p.t1
      AND s.country = 'IND'
      AND s.os = 'Android'
      AND s.is_filter_applied = false
      AND s.src_id IS NOT NULL
      AND s.dest_id IS NOT NULL
  ) x
  WHERE rn = 1
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

-- Segment × user_type tagged sessions
nf_seg AS (
  -- Platform overall
  SELECT 'Platform' AS segment, 'ALL' AS user_type,
         mri_session_id, src_id, dest_id, rb_user_id
  FROM nf_search

  UNION ALL

  -- Women_SRP ALL / NEW / RETURNING
  SELECT 'Women_SRP', 'ALL',
         n.mri_session_id, n.src_id, n.dest_id, n.rb_user_id
  FROM nf_search n
  INNER JOIN women_srp_sess w ON n.mri_session_id = w.mri_session_id

  UNION ALL
  SELECT 'Women_SRP', n.user_type,
         n.mri_session_id, n.src_id, n.dest_id, n.rb_user_id
  FROM nf_search n
  INNER JOIN women_srp_sess w ON n.mri_session_id = w.mri_session_id
  WHERE n.user_type IN ('NEW', 'RETURNING')

  UNION ALL

  -- Female_SVOC ALL / NEW / RETURNING
  SELECT 'Female_SVOC', 'ALL',
         n.mri_session_id, n.src_id, n.dest_id, n.rb_user_id
  FROM nf_search n
  INNER JOIN svoc_female f ON n.rb_user_id = f.rb_user_id AND n.rb_user_id > 0

  UNION ALL
  SELECT 'Female_SVOC', n.user_type,
         n.mri_session_id, n.src_id, n.dest_id, n.rb_user_id
  FROM nf_search n
  INNER JOIN svoc_female f ON n.rb_user_id = f.rb_user_id AND n.rb_user_id > 0
  WHERE n.user_type IN ('NEW', 'RETURNING')
),

srp_pos AS (
  SELECT
    ns.segment,
    ns.user_type,
    ns.src_id,
    ns.dest_id,
    ns.mri_session_id,
    srd.route_id,
    MIN(srd.offset + srd.position + 1) AS best_tuple_pos
  FROM user_interaction.search_route_details srd
  CROSS JOIN params p
  INNER JOIN nf_seg ns
    ON srd.mri_session_id = ns.mri_session_id
   AND srd.src_id = ns.src_id
   AND srd.dest_id = ns.dest_id
  WHERE srd.__time >= p.t0 AND srd.__time < p.t1
    AND srd.country = 'IND'
    AND srd.os = 'Android'
    AND srd.route_id IS NOT NULL
    AND srd.offset IS NOT NULL
    AND srd.position IS NOT NULL
  GROUP BY 1, 2, 3, 4, 5, 6
),

route_srp_rank AS (
  SELECT
    segment,
    user_type,
    src_id,
    dest_id,
    route_id,
    AVG(CAST(best_tuple_pos AS DOUBLE)) AS avg_srp_rank,
    ROW_NUMBER() OVER (
      PARTITION BY segment, user_type, src_id, dest_id
      ORDER BY AVG(CAST(best_tuple_pos AS DOUBLE)) ASC, route_id
    ) AS srp_route_rank
  FROM srp_pos
  GROUP BY 1, 2, 3, 4, 5
),

top_routes AS (
  SELECT segment, user_type, src_id, dest_id, route_id, avg_srp_rank, srp_route_rank
  FROM route_srp_rank
  WHERE srp_route_rank <= 20
),

sl_clicks AS (
  SELECT DISTINCT
    ns.segment,
    ns.user_type,
    ns.src_id,
    ns.dest_id,
    sl.mri_session_id,
    sl.route_id
  FROM user_interaction.seat_layout_details sl
  CROSS JOIN params p
  INNER JOIN nf_seg ns
    ON sl.mri_session_id = ns.mri_session_id
   AND sl.src_id = ns.src_id
   AND sl.dest_id = ns.dest_id
  WHERE sl.__time >= p.t0 AND sl.__time < p.t1
    AND sl.country = 'IND'
    AND sl.os = 'Android'
    AND sl.route_id IS NOT NULL
),

sl_by_route AS (
  SELECT
    segment, user_type, src_id, dest_id, route_id,
    COUNT(DISTINCT mri_session_id) AS route_sl_sessions
  FROM sl_clicks
  GROUP BY 1, 2, 3, 4, 5
),

sl_tot_pairs AS (
  SELECT
    segment, user_type, src_id, dest_id,
    SUM(route_sl_sessions) AS total_sl_session_routes
  FROM sl_by_route
  GROUP BY 1, 2, 3, 4
),

click_on_top AS (
  SELECT
    r.segment,
    r.user_type,
    r.src_id,
    r.dest_id,
    SUM(CASE WHEN r.srp_route_rank <= 10 THEN COALESCE(s.route_sl_sessions, 0) ELSE 0 END) AS top10_sl_sessions,
    SUM(CASE WHEN r.srp_route_rank <= 20 THEN COALESCE(s.route_sl_sessions, 0) ELSE 0 END) AS top20_sl_sessions
  FROM top_routes r
  LEFT JOIN sl_by_route s
    ON r.segment = s.segment
   AND r.user_type = s.user_type
   AND r.src_id = s.src_id
   AND r.dest_id = s.dest_id
   AND r.route_id = s.route_id
  GROUP BY 1, 2, 3, 4
),

grid AS (
  SELECT t.sd_rank, t.src_id, t.dest_id, t.source_location, t.destination_location,
         g.segment, g.user_type
  FROM top100_sd t
  CROSS JOIN seg_grid g
)

SELECT
  g.sd_rank,
  CONCAT(CAST(g.src_id AS VARCHAR), '-', CAST(g.dest_id AS VARCHAR)) AS sd_key,
  g.src_id,
  g.dest_id,
  g.source_location,
  g.destination_location,
  g.segment,
  g.user_type,
  COALESCE(tp.total_sl_session_routes, 0) AS total_sl_session_routes,
  COALESCE(c.top10_sl_sessions, 0) AS top10_srp_ranked_sl_sessions,
  COALESCE(c.top20_sl_sessions, 0) AS top20_srp_ranked_sl_sessions,
  c.top10_sl_sessions * 100.0 / NULLIF(tp.total_sl_session_routes, 0) AS top10_click_share_pct,
  c.top20_sl_sessions * 100.0 / NULLIF(tp.total_sl_session_routes, 0) AS top20_click_share_pct
FROM grid g
LEFT JOIN sl_tot_pairs tp
  ON g.segment = tp.segment AND g.user_type = tp.user_type
 AND g.src_id = tp.src_id AND g.dest_id = tp.dest_id
LEFT JOIN click_on_top c
  ON g.segment = c.segment AND g.user_type = c.user_type
 AND g.src_id = c.src_id AND g.dest_id = c.dest_id
ORDER BY
  g.sd_rank,
  CASE g.segment
    WHEN 'Platform' THEN 1
    WHEN 'Female_SVOC' THEN 2
    WHEN 'Women_SRP' THEN 3
    ELSE 4
  END,
  CASE g.user_type
    WHEN 'ALL' THEN 1
    WHEN 'NEW' THEN 2
    WHEN 'RETURNING' THEN 3
    ELSE 4
  END;
