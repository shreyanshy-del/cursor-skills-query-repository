-- =============================================================================
-- Single Women Pax vs All Single Pax · Top 100 SDs (Q2 2026 hardcoded)
-- Journey-start (date_of_journey IST) share by 6-hour buckets
-- Android · IND · BUS · confirm event_type=101 event_class=2
--
-- CHANGE ONLY params t0 / t1 (UTC).
--
-- Buckets (IST hour from date_of_journey):
--   06AM-12PM  = HOUR 6–11
--   12PM-06PM  = HOUR 12–17
--   06PM-12AM  = HOUR 18–23
--   12AM-06AM  = HOUR 0–5
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

base AS (
  SELECT
    b.tin,
    b.rb_user_id,
    b.source_location_id AS src_id,
    b.destination_location_id AS dest_id,
    t.sd_rank,
    t.source_location,
    t.destination_location,
    HOUR(CAST(AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata') AS TIMESTAMP)) AS doj_hour_ist,
    CASE
      WHEN HOUR(CAST(AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata') AS TIMESTAMP)) BETWEEN 6 AND 11
        THEN '06AM-12PM'
      WHEN HOUR(CAST(AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata') AS TIMESTAMP)) BETWEEN 12 AND 17
        THEN '12PM-06PM'
      WHEN HOUR(CAST(AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata') AS TIMESTAMP)) BETWEEN 18 AND 23
        THEN '06PM-12AM'
      WHEN HOUR(CAST(AT_TIMEZONE(b.date_of_journey, 'Asia/Kolkata') AS TIMESTAMP)) BETWEEN 0 AND 5
        THEN '12AM-06AM'
    END AS doj_bucket,
    CASE
      WHEN b.seat_count = 1
       AND b.travellers_gender IS NOT NULL
       AND CARDINALITY(b.travellers_gender) = 1
       AND UPPER(TRIM(CAST(element_at(b.travellers_gender, 1) AS VARCHAR))) = 'FEMALE'
      THEN 'Single_Women_Pax'
      WHEN b.seat_count = 1
       AND b.travellers_gender IS NOT NULL
       AND CARDINALITY(b.travellers_gender) = 1
       AND UPPER(TRIM(CAST(element_at(b.travellers_gender, 1) AS VARCHAR))) = 'MALE'
      THEN 'Single_Male_Pax'
      WHEN b.seat_count = 1
      THEN 'Single_Pax_OtherGender'
      ELSE NULL
    END AS pax_segment
  FROM transaction.bus_ticket_events b
  CROSS JOIN params p
  INNER JOIN top100_sd t
    ON b.source_location_id = t.src_id
   AND b.destination_location_id = t.dest_id
  WHERE b.time_of_event >= p.t0 AND b.time_of_event < p.t1
    AND b.country_code = 'IND'
    AND b.event_type = 101
    AND b.event_class = 2
    AND b.sales_channel LIKE '%droidapp%'
    AND b.seat_count = 1
    AND b.date_of_journey IS NOT NULL
),

flagged AS (
  SELECT * FROM base WHERE pax_segment IS NOT NULL AND doj_bucket IS NOT NULL
),

seg AS (
  SELECT
    'All_Single_Pax' AS segment,
    sd_rank, src_id, dest_id, source_location, destination_location,
    tin, rb_user_id, doj_bucket
  FROM flagged

  UNION ALL

  SELECT
    'Single_Women_Pax' AS segment,
    sd_rank, src_id, dest_id, source_location, destination_location,
    tin, rb_user_id, doj_bucket
  FROM flagged
  WHERE pax_segment = 'Single_Women_Pax'

  UNION ALL

  SELECT
    'Single_Male_Pax' AS segment,
    sd_rank, src_id, dest_id, source_location, destination_location,
    tin, rb_user_id, doj_bucket
  FROM flagged
  WHERE pax_segment = 'Single_Male_Pax'
),

sd_seg_tot AS (
  SELECT
    segment,
    sd_rank,
    src_id,
    dest_id,
    source_location,
    destination_location,
    COUNT(DISTINCT tin) AS single_pax_txns
  FROM seg
  GROUP BY 1, 2, 3, 4, 5, 6
),

sd_seg_bucket AS (
  SELECT
    segment,
    sd_rank,
    src_id,
    dest_id,
    source_location,
    destination_location,
    doj_bucket,
    COUNT(DISTINCT tin) AS bucket_txns
  FROM seg
  GROUP BY 1, 2, 3, 4, 5, 6, 7
)

SELECT
  b.sd_rank,
  CONCAT(CAST(b.src_id AS VARCHAR), '-', CAST(b.dest_id AS VARCHAR)) AS sd_key,
  b.src_id,
  b.dest_id,
  b.source_location,
  b.destination_location,
  b.segment,
  t.single_pax_txns,
  b.doj_bucket,
  b.bucket_txns,
  b.bucket_txns * 100.0 / NULLIF(t.single_pax_txns, 0) AS txn_share_pct
FROM sd_seg_bucket b
INNER JOIN sd_seg_tot t
  ON b.segment = t.segment
 AND b.sd_rank = t.sd_rank
 AND b.src_id = t.src_id
 AND b.dest_id = t.dest_id
ORDER BY
  b.sd_rank,
  CASE b.segment
    WHEN 'All_Single_Pax' THEN 1
    WHEN 'Single_Women_Pax' THEN 2
    WHEN 'Single_Male_Pax' THEN 3
    ELSE 4
  END,
  CASE b.doj_bucket
    WHEN '06AM-12PM' THEN 1
    WHEN '12PM-06PM' THEN 2
    WHEN '06PM-12AM' THEN 3
    WHEN '12AM-06AM' THEN 4
    ELSE 5
  END;
