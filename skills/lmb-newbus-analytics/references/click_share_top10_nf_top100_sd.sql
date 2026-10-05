-- =============================================================================
-- Click Share — Non-filtered sessions · Top 10 routes by SL / Total SL
-- Hardcoded Top 100 SDs (Q2 2026) · Platform | Women_SRP | Female_SVOC
-- Android · IND · BUS
--
-- CHANGE ONLY params t0 / t1 (UTC).
--
-- Definitions:
--   Non-filtered = search_details.is_filter_applied = false (session has ≥1 such search)
--   SL click     = seat_layout_details (session × route_id) on that SD
--   Top 10       = top 10 route_ids by SL sessions WITHIN each (segment, SD)
--   Click share  = SUM(SL sessions on top-10 routes) / SUM(SL sessions on all routes)
--                  (session-route grain; standard concentration)
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

svoc_female AS (
  SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
  FROM svoc.svoc_booker
  WHERE rb_userid IS NOT NULL
    AND LOWER(COALESCE(gender, '')) IN ('female', 'f')
),

-- Non-filtered searches on Top 100 SDs
nf_search AS (
  SELECT
    s.mri_session_id,
    s.src_id,
    s.dest_id,
    MAX(s.rb_user_id) AS rb_user_id
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
  GROUP BY 1, 2, 3
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

-- SL session × route on Top 100 SDs (non-filtered sessions only)
sl_clicks AS (
  SELECT DISTINCT
    sl.mri_session_id,
    sl.route_id,
    nf.src_id,
    nf.dest_id,
    nf.rb_user_id
  FROM user_interaction.seat_layout_details sl
  CROSS JOIN params p
  INNER JOIN nf_search nf
    ON sl.mri_session_id = nf.mri_session_id
   AND sl.src_id = nf.src_id
   AND sl.dest_id = nf.dest_id
  WHERE sl.__time >= p.t0 AND sl.__time < p.t1
    AND sl.country = 'IND'
    AND sl.os = 'Android'
    AND sl.route_id IS NOT NULL
),

-- Expand to 3 segments (overlapping OK)
seg_sl AS (
  SELECT
    'Platform' AS segment,
    c.mri_session_id,
    c.route_id,
    c.src_id,
    c.dest_id
  FROM sl_clicks c

  UNION ALL

  SELECT
    'Women_SRP' AS segment,
    c.mri_session_id,
    c.route_id,
    c.src_id,
    c.dest_id
  FROM sl_clicks c
  INNER JOIN women_srp_sess w ON c.mri_session_id = w.mri_session_id

  UNION ALL

  SELECT
    'Female_SVOC' AS segment,
    c.mri_session_id,
    c.route_id,
    c.src_id,
    c.dest_id
  FROM sl_clicks c
  INNER JOIN svoc_female f ON c.rb_user_id = f.rb_user_id AND c.rb_user_id > 0
),

-- SL sessions per (segment, SD, route)
route_sl AS (
  SELECT
    segment,
    src_id,
    dest_id,
    route_id,
    COUNT(DISTINCT mri_session_id) AS route_sl_sessions
  FROM seg_sl
  GROUP BY 1, 2, 3, 4
),

ranked AS (
  SELECT
    r.*,
    ROW_NUMBER() OVER (
      PARTITION BY segment, src_id, dest_id
      ORDER BY route_sl_sessions DESC, route_id
    ) AS route_rank
  FROM route_sl r
),

sd_agg AS (
  SELECT
    segment,
    src_id,
    dest_id,
    SUM(route_sl_sessions) AS total_sl_sessions,
    SUM(CASE WHEN route_rank <= 10 THEN route_sl_sessions ELSE 0 END) AS top10_route_sl_sessions,
    COUNT(DISTINCT route_id) AS distinct_routes,
    COUNT(DISTINCT CASE WHEN route_rank <= 10 THEN route_id END) AS top10_routes
  FROM ranked
  GROUP BY 1, 2, 3
)

SELECT
  t.sd_rank,
  CONCAT(CAST(a.src_id AS VARCHAR), '-', CAST(a.dest_id AS VARCHAR)) AS sd_key,
  a.src_id,
  a.dest_id,
  t.source_location,
  t.destination_location,
  a.segment,
  a.distinct_routes,
  a.top10_routes,
  a.total_sl_sessions,
  a.top10_route_sl_sessions,
  a.top10_route_sl_sessions * 100.0 / NULLIF(a.total_sl_sessions, 0) AS top10_click_share_pct
FROM sd_agg a
INNER JOIN top100_sd t ON a.src_id = t.src_id AND a.dest_id = t.dest_id
ORDER BY
  t.sd_rank,
  CASE a.segment
    WHEN 'Platform' THEN 1
    WHEN 'Female_SVOC' THEN 2
    WHEN 'Women_SRP' THEN 3
    ELSE 4
  END;
