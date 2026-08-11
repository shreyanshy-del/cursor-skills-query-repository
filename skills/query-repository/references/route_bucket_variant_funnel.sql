/* Funnel throughputs: Top Routes vs Other Top Routes x studentDeal variants
   Window: 2026-06-17 to 2026-06-30 (UTC) — Student Deal experiment period
   Cohort: IND Android, age <= 23 (SVOC), OD in target list, studentDeal present
   Grain: route_bucket x exp_variant
*/
WITH target_routes AS (
    SELECT *
    FROM (
        VALUES
            ('Bengaluru', 'Chennai', 122, 123, 'Other Top Routes'),
            ('Chennai', 'Bengaluru', 123, 122, 'Other Top Routes'),
            ('Hyderabad', 'Bengaluru', 124, 122, 'Other Top Routes'),
            ('Bengaluru', 'Hyderabad', 122, 124, 'Other Top Routes'),
            ('Chennai', 'Coimbatore', 123, 141, 'Other Top Routes'),
            ('Coimbatore', 'Chennai', 141, 123, 'Other Top Routes'),
            ('Chennai', 'Madurai', 123, 126, 'Other Top Routes'),
            ('Madurai', 'Chennai', 126, 123, 'Other Top Routes'),
            ('Coimbatore', 'Bengaluru', 141, 122, 'Other Top Routes'),
            ('Bengaluru', 'Coimbatore', 122, 141, 'Other Top Routes'),
            ('Hyderabad', 'Vijayawada', 124, 134, 'Other Top Routes'),
            ('Vijayawada', 'Hyderabad', 134, 124, 'Other Top Routes'),
            ('Chennai', 'Tiruchirapalli', 123, 71929, 'Other Top Routes'),
            ('Chennai', 'Salem', 123, 602, 'Other Top Routes'),
            ('Delhi', 'Lucknow', 733, 1439, 'Other Top Routes'),
            ('Pune', 'Nagpur', 130, 624, 'Other Top Routes'),
            ('Indore', 'Bhopal', 313, 979, 'Other Top Routes'),
            ('Delhi', 'Dehradun', 733, 777, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Delhi', 807, 733, 'Other Top Routes'),
            ('Pune', 'Mumbai', 130, 462, 'Other Top Routes'),
            ('Chennai', 'Tirunelveli', 123, 696, 'Other Top Routes'),
            ('Delhi', 'Gorakhpur (uttar pradesh)', 733, 78027, 'Other Top Routes'),
            ('Delhi', 'Jaipur (Rajasthan)', 733, 807, 'Other Top Routes'),
            ('Mumbai', 'Pune', 462, 130, 'Other Top Routes'),
            ('Hyderabad', 'Visakhapatnam', 124, 248, 'Other Top Routes'),
            ('Pune', 'Aurangabad (Maharashtra)', 130, 309, 'Other Top Routes'),
            ('Chennai', 'Nagercoil', 123, 690, 'Other Top Routes'),
            ('Bengaluru', 'Madurai', 122, 126, 'Other Top Routes'),
            ('Madurai', 'Bengaluru', 126, 122, 'Other Top Routes'),
            ('Bengaluru', 'Mangaluru', 122, 95222, 'Other Top Routes'),
            ('Kolkata', 'Durgapur (West Bengal)', 74820, 69802, 'Other Top Routes'),
            ('Hyderabad', 'Chennai', 124, 123, 'Other Top Routes'),
            ('Chennai', 'Hosur', 123, 458, 'Other Top Routes'),
            ('Pune', 'Hyderabad', 130, 124, 'Other Top Routes'),
            ('Hyderabad', 'Pune', 124, 130, 'Other Top Routes'),
            ('Chennai', 'Hyderabad', 123, 124, 'Other Top Routes'),
            ('Chennai', 'Thoothukudi', 123, 698, 'Other Top Routes'),
            ('Pune', 'Latur', 130, 575, 'Other Top Routes'),
            ('Mumbai', 'Kolhapur(Maharashtra)', 462, 76079, 'Other Top Routes'),
            ('Hyderabad', 'Nellore', 124, 131, 'Other Top Routes'),
            ('Bengaluru', 'Nellore', 122, 131, 'Other Top Routes'),
            ('Bengaluru', 'Ernakulam', 122, 216, 'Other Top Routes'),
            ('Vijayawada', 'Bengaluru', 134, 122, 'Other Top Routes'),
            ('Chennai', 'Pondicherry', 123, 233, 'Other Top Routes'),
            ('Bengaluru', 'Vijayawada', 122, 134, 'Other Top Routes'),
            ('Chennai', 'Erode', 123, 236, 'Other Top Routes'),
            ('Delhi', 'Chandigarh', 733, 833, 'Other Top Routes'),
            ('Hyderabad', 'Mumbai', 124, 462, 'Other Top Routes'),
            ('Bengaluru', 'Pondicherry', 122, 233, 'Other Top Routes'),
            ('Pune', 'Indore', 130, 313, 'Other Top Routes'),
            ('Indore', 'Pune', 313, 130, 'Other Top Routes'),
            ('Hyderabad', 'Ongole', 124, 135, 'Other Top Routes'),
            ('Bengaluru', 'Tiruchirapalli', 122, 71929, 'Other Top Routes'),
            ('Mumbai', 'Hyderabad', 462, 124, 'Other Top Routes'),
            ('Chennai', 'Tirupur', 123, 235, 'Other Top Routes'),
            ('Madurai', 'Coimbatore', 126, 141, 'Other Top Routes'),
            ('Hyderabad', 'Guntur (Andhra Pradesh)', 124, 137, 'Other Top Routes'),
            ('Coimbatore', 'Madurai', 141, 126, 'Other Top Routes'),
            ('Pune', 'Bengaluru', 130, 122, 'Other Top Routes'),
            ('Bengaluru', 'Pune', 122, 130, 'Other Top Routes'),
            ('Bengaluru', 'Salem', 122, 602, 'Other Top Routes'),
            ('Pune', 'Kolhapur(Maharashtra)', 130, 76079, 'Other Top Routes'),
            ('Hyderabad', 'Kadapa', 124, 284, 'Other Top Routes'),
            ('Bengaluru', 'Kozhikode', 122, 74661, 'Other Top Routes'),
            ('Indore', 'Mumbai', 313, 462, 'Other Top Routes'),
            ('Hyderabad', 'Rajahmundry', 124, 71757, 'Other Top Routes'),
            ('Bengaluru', 'Belagavi', 122, 95083, 'Other Top Routes'),
            ('Mumbai', 'Aurangabad (Maharashtra)', 462, 309, 'Other Top Routes'),
            ('Delhi', 'Kanpur (Uttar Pradesh)', 733, 1377, 'Other Top Routes'),
            ('Vijayawada', 'Visakhapatnam', 134, 248, 'Other Top Routes'),
            ('Mumbai', 'Indore', 462, 313, 'Other Top Routes'),
            ('Bengaluru', 'Thrissur', 122, 995, 'Other Top Routes'),
            ('Kolkata', 'Bhubaneswar', 74820, 74676, 'Other Top Routes'),
            ('Gurugram (Gurgaon)', 'Jaipur (Rajasthan)', 70015, 807, 'Other Top Routes'),
            ('Ahmedabad', 'Rajkot (Gujarat)', 551, 472, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Gurugram (Gurgaon)', 807, 70015, 'Other Top Routes'),
            ('Bengaluru', 'Mumbai', 122, 462, 'Other Top Routes'),
            ('Mumbai', 'Bengaluru', 462, 122, 'Other Top Routes'),
            ('Bengaluru', 'Erode', 122, 236, 'Other Top Routes'),
            ('Hyderabad', 'Nagpur', 124, 624, 'Other Top Routes'),
            ('Bengaluru', 'Thiruvananthapuram', 122, 71425, 'Other Top Routes'),
            ('Pune', 'Belagavi', 130, 95083, 'Other Top Routes'),
            ('Coimbatore', 'Tirunelveli', 141, 696, 'Other Top Routes'),
            ('Coimbatore', 'Tiruchirapalli', 141, 71929, 'Other Top Routes'),
            ('Bengaluru', 'Guntur (Andhra Pradesh)', 122, 137, 'Other Top Routes'),
            ('Hyderabad', 'Bhubaneswar', 124, 74676, 'Other Top Routes'),
            ('Mumbai', 'Nagpur', 462, 624, 'Other Top Routes'),
            ('Bengaluru', 'Kadapa', 122, 284, 'Other Top Routes'),
            ('Ahmedabad', 'Indore', 551, 313, 'Other Top Routes'),
            ('Delhi', 'Indore', 733, 313, 'Other Top Routes'),
            ('Indore', 'Delhi', 313, 733, 'Other Top Routes'),
            ('Indore', 'Ahmedabad', 313, 551, 'Other Top Routes'),
            ('Pune', 'Surat', 130, 473, 'Other Top Routes'),
            ('Bengaluru', 'Tirupur', 122, 235, 'Other Top Routes'),
            ('Pune', 'Nashik', 130, 444, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Udaipur', 807, 470, 'Other Top Routes'),
            ('Ahmedabad', 'Surat', 551, 473, 'Other Top Routes'),
            ('Chennai', 'Ernakulam', 123, 216, 'Other Top Routes'),
            ('Coimbatore', 'Nagercoil', 141, 690, 'Other Top Routes'),
            ('Pune', 'Ahmedabad', 130, 551, 'Other Top Routes'),
            ('Bengaluru', 'Nagercoil', 122, 690, 'Other Top Routes'),
            ('Ahmedabad', 'Pune', 551, 130, 'Other Top Routes'),
            ('Vijayawada', 'Chennai', 134, 123, 'Other Top Routes'),
            ('Bengaluru', 'Tirunelveli', 122, 696, 'Other Top Routes'),
            ('Coimbatore', 'Hosur', 141, 458, 'Other Top Routes'),
            ('Coimbatore', 'Thoothukudi', 141, 698, 'Other Top Routes'),
            ('Coimbatore', 'Pondicherry', 141, 233, 'Other Top Routes'),
            ('Bengaluru', 'Kurnool', 122, 125, 'Other Top Routes'),
            ('Hyderabad', 'Kurnool', 124, 125, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Lucknow', 807, 1439, 'Other Top Routes'),
            ('Ahmedabad', 'Udaipur', 551, 470, 'Other Top Routes'),
            ('Bengaluru', 'Ongole', 122, 135, 'Other Top Routes'),
            ('Delhi', 'Jalandhar', 733, 737, 'Other Top Routes'),
            ('Delhi', 'Ludhiana', 733, 736, 'Other Top Routes'),
            ('Chennai', 'Vijayawada', 123, 134, 'Other Top Routes'),
            ('Bengaluru', 'Visakhapatnam', 122, 248, 'Other Top Routes'),
            ('Ahmedabad', 'Mumbai', 551, 462, 'Other Top Routes'),
            ('Bengaluru', 'Bhubaneswar', 122, 74676, 'Other Top Routes'),
            ('Delhi', 'Ahmedabad', 733, 551, 'Other Top Routes'),
            ('Ahmedabad', 'Vadodara', 551, 1003, 'Other Top Routes'),
            ('Mumbai', 'Ahmedabad', 462, 551, 'Other Top Routes'),
            ('Gurugram (Gurgaon)', 'Lucknow', 70015, 1439, 'Other Top Routes'),
            ('Chennai', 'Thiruvananthapuram', 123, 71425, 'Other Top Routes'),
            ('Indore', 'Jabalpur', 313, 70024, 'Other Top Routes'),
            ('Indore', 'Nagpur', 313, 624, 'Other Top Routes'),
            ('Ahmedabad', 'Delhi', 551, 733, 'Other Top Routes'),
            ('Coimbatore', 'Ernakulam', 141, 216, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Ahmedabad', 807, 551, 'Other Top Routes'),
            ('Delhi', 'Agra', 733, 1290, 'Other Top Routes'),
            ('Ahmedabad', 'Jaipur (Rajasthan)', 551, 807, 'Other Top Routes'),
            ('Mumbai', 'Belagavi', 462, 95083, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Indore', 807, 313, 'Other Top Routes'),
            ('Delhi', 'Patna (Bihar)', 733, 74699, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Jodhpur', 807, 1169, 'Other Top Routes'),
            ('Amritsar', 'Chandigarh', 759, 833, 'Other Top Routes'),
            ('Amritsar', 'Delhi', 759, 733, 'Other Top Routes'),
            ('Ayodhya', 'Delhi', 76480, 733, 'Other Top Routes'),
            ('Bengaluru', 'Goa', 122, 210, 'Other Top Routes'),
            ('Bengaluru', 'Kannur (Kerala)', 122, 558, 'Other Top Routes'),
            ('Bengaluru', 'Ooty', 122, 254, 'Other Top Routes'),
            ('Bengaluru', 'Palakkad', 122, 1013, 'Other Top Routes'),
            ('Bengaluru', 'Thanjavur', 122, 66007, 'Other Top Routes'),
            ('Bengaluru', 'Tirupati', 122, 71756, 'Other Top Routes'),
            ('Bengaluru', 'Tiruvannamalai', 122, 293, 'Other Top Routes'),
            ('Bengaluru', 'Udupi', 122, 154, 'Other Top Routes'),
            ('Bengaluru', 'Vellore', 122, 960, 'Other Top Routes'),
            ('Bengaluru', '86882', 122, 86882, 'Other Top Routes'),
            ('Bhadrachalam', 'Hyderabad', 517, 124, 'Other Top Routes'),
            ('Bikaner', 'Jaipur (Rajasthan)', 827, 807, 'Other Top Routes'),
            ('Chandigarh', 'Amritsar', 833, 759, 'Other Top Routes'),
            ('Chandigarh', 'Jammu (j and k)', 833, 734, 'Other Top Routes'),
            ('Chennai', 'Chidambaram', 123, 231, 'Other Top Routes'),
            ('Chennai', 'Kumbakonam', 123, 427, 'Other Top Routes'),
            ('Chennai', 'Marthandam', 123, 489, 'Other Top Routes'),
            ('Chennai', 'Mayiladuthurai', 123, 466, 'Other Top Routes'),
            ('Chennai', 'Palani', 123, 501, 'Other Top Routes'),
            ('Chennai', 'Thanjavur', 123, 66007, 'Other Top Routes'),
            ('Chennai', 'Tiruchendur', 123, 663, 'Other Top Routes'),
            ('Chennai', 'Tirupati', 123, 71756, 'Other Top Routes'),
            ('Chennai', 'Tiruvannamalai', 123, 293, 'Other Top Routes'),
            ('Chidambaram', 'Chennai', 231, 123, 'Other Top Routes'),
            ('Coimbatore', 'Tiruchendur', 141, 663, 'Other Top Routes'),
            ('Delhi', 'Amritsar', 733, 759, 'Other Top Routes'),
            ('Delhi', 'Ayodhya', 733, 76480, 'Other Top Routes'),
            ('Delhi', 'Haldwani', 733, 1514, 'Other Top Routes'),
            ('Delhi', 'Haridwar', 733, 802, 'Other Top Routes'),
            ('Delhi', 'Jammu (j and k)', 733, 734, 'Other Top Routes'),
            ('Delhi', 'Kasol', 733, 197688, 'Other Top Routes'),
            ('Delhi', 'KHATTUSHYAMJI DHAM Bus Teminal', 733, 197504, 'Other Top Routes'),
            ('Delhi', 'Manali', 733, 757, 'Other Top Routes'),
            ('Delhi', 'Nainital', 733, 771, 'Other Top Routes'),
            ('Delhi', '309423', 733, 309423, 'Other Top Routes'),
            ('Delhi', 'Rishikesh', 733, 842, 'Top Routes'),
            ('Delhi', 'Shimla', 733, 1285, 'Other Top Routes'),
            ('Delhi', 'Ujjain', 733, 1001, 'Other Top Routes'),
            ('Delhi', 'Varanasi', 733, 70429, 'Other Top Routes'),
            ('Dharamshala (Himachal Pradesh)', 'Delhi', 65768, 733, 'Other Top Routes'),
            ('Digha', 'Kolkata', 74706, 74820, 'Other Top Routes'),
            ('Goa', 'Bengaluru', 210, 122, 'Other Top Routes'),
            ('Goa', 'Mumbai', 210, 462, 'Other Top Routes'),
            ('Goa', 'Pune', 210, 130, 'Other Top Routes'),
            ('Gwalior', 'Indore', 71958, 313, 'Other Top Routes'),
            ('Haldwani', 'Delhi', 1514, 733, 'Other Top Routes'),
            ('Haridwar', 'Delhi', 802, 733, 'Other Top Routes'),
            ('Hyderabad', 'Bhadrachalam', 124, 517, 'Other Top Routes'),
            ('Hyderabad', 'Tirupati', 124, 71756, 'Top Routes'),
            ('Indore', 'Gwalior', 313, 71958, 'Other Top Routes'),
            ('Indore', 'Ujjain', 313, 1001, 'Other Top Routes'),
            ('Jaipur (Rajasthan)', 'Bikaner', 807, 827, 'Other Top Routes'),
            ('Jammu (j and k)', 'Chandigarh', 734, 833, 'Other Top Routes'),
            ('Jammu (j and k)', 'Delhi', 734, 733, 'Other Top Routes'),
            ('Kannur (Kerala)', 'Bengaluru', 558, 122, 'Other Top Routes'),
            ('Kasol', 'Delhi', 197688, 733, 'Other Top Routes'),
            ('Katra (jammu and kashmir)', 'Delhi', 735, 733, 'Other Top Routes'),
            ('KHATTUSHYAMJI DHAM Bus Teminal', 'Delhi', 197504, 733, 'Other Top Routes'),
            ('Kolkata', 'Digha', 74820, 74706, 'Other Top Routes'),
            ('Kolkata', 'Siliguri', 74820, 74694, 'Top Routes'),
            ('Kumbakonam', 'Chennai', 427, 123, 'Other Top Routes'),
            ('Manali', 'Delhi', 757, 733, 'Other Top Routes'),
            ('Mandarmani', 'Kolkata', 82467, 74820, 'Other Top Routes'),
            ('Marthandam', 'Chennai', 489, 123, 'Other Top Routes'),
            ('Mayiladuthurai', 'Chennai', 466, 123, 'Other Top Routes'),
            ('Mumbai', 'Goa', 462, 210, 'Other Top Routes'),
            ('Nagpur', 'Nanded', 624, 361, 'Other Top Routes'),
            ('Nanded', 'Nagpur', 361, 624, 'Other Top Routes'),
            ('Nanded', 'Pune', 361, 130, 'Other Top Routes'),
            ('Palakkad', 'Bengaluru', 1013, 122, 'Other Top Routes'),
            ('Palani', 'Chennai', 501, 123, 'Other Top Routes'),
            ('309423', 'Delhi', 309423, 733, 'Other Top Routes'),
            ('Pune', 'Goa', 130, 210, 'Other Top Routes'),
            ('Pune', 'Nanded', 130, 361, 'Other Top Routes'),
            ('Pune', 'Ratnagiri (Maharashtra)', 130, 750, 'Other Top Routes'),
            ('Rishikesh', 'Delhi', 842, 733, 'Top Routes'),
            ('Shimla', 'Delhi', 1285, 733, 'Other Top Routes'),
            ('Siliguri', 'Kolkata', 74694, 74820, 'Top Routes'),
            ('Thanjavur', 'Bengaluru', 66007, 122, 'Other Top Routes'),
            ('Thanjavur', 'Chennai', 66007, 123, 'Top Routes'),
            ('Tiruchendur', 'Chennai', 663, 123, 'Other Top Routes'),
            ('Tirupati', 'Bengaluru', 71756, 122, 'Other Top Routes'),
            ('Tirupati', 'Chennai', 71756, 123, 'Other Top Routes'),
            ('Tirupati', 'Hyderabad', 71756, 124, 'Top Routes'),
            ('Tirupati', 'Vijayawada', 71756, 134, 'Other Top Routes'),
            ('Tiruvannamalai', 'Bengaluru', 293, 122, 'Other Top Routes'),
            ('Udupi', 'Bengaluru', 154, 122, 'Other Top Routes'),
            ('Ujjain', 'Bhopal', 1001, 979, 'Other Top Routes'),
            ('Ujjain', 'Delhi', 1001, 733, 'Other Top Routes'),
            ('Varanasi', 'Delhi', 70429, 733, 'Other Top Routes'),
            ('Vellore', 'Bengaluru', 960, 122, 'Other Top Routes'),
            ('86882', 'Bengaluru', 86882, 122, 'Other Top Routes'),
            ('Vijayawada', 'Tirupati', 134, 71756, 'Other Top Routes')
    ) AS t(source_name, destination_name, source_location_id, destination_location_id, route_bucket)
),
svoc_users AS (
    SELECT DISTINCT TRY_CAST(rb_userid AS BIGINT) AS rb_user_id
    FROM svoc.svoc_booker
    WHERE rb_userid IS NOT NULL
      AND TRY_CAST(age AS INTEGER) <= 23
),
params AS (
    SELECT
        TIMESTAMP '2026-06-17 00:00:00' AS window_start,
        TIMESTAMP '2026-06-30 00:00:00' AS window_end
),
srp_deduped AS (
    SELECT DISTINCT
        s.mri_session_id,
        s.route_id,
        tr.route_bucket,
        CASE
            WHEN CONTAINS(s.channel_exp_info, 'studentDeal:V0') THEN 'V0'
            WHEN CONTAINS(s.channel_exp_info, 'studentDeal:V1') THEN 'V1'
            WHEN CONTAINS(s.channel_exp_info, 'studentDeal:V2') THEN 'V2'
            WHEN CONTAINS(s.channel_exp_info, 'studentDeal:V3') THEN 'V3'
            WHEN CONTAINS(s.channel_exp_info, 'studentDeal:V4') THEN 'V4'
            ELSE 'others'
        END AS exp_variant
    FROM user_interaction.search_route_details s
    CROSS JOIN params p
    INNER JOIN target_routes tr
        ON s.src_id = tr.source_location_id
       AND s.dest_id = tr.destination_location_id
    INNER JOIN svoc_users u
        ON s.rb_user_id = u.rb_user_id
    WHERE s.__time >= p.window_start
      AND s.__time < p.window_end
      AND s.country = 'IND'
      AND s.os = 'Android'
      AND s.rb_user_id > 0
      AND s.channel_exp_info IS NOT NULL
      AND ANY_MATCH(s.channel_exp_info, x -> x LIKE '%studentDeal%')
),
sl_deduped AS (
    SELECT sl.mri_session_id, sl.route_id
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN params p
    WHERE sl.__time >= p.window_start
      AND sl.__time < p.window_end
      AND sl.country = 'IND'
    GROUP BY 1, 2
),
mpax_deduped AS (
    SELECT c.mri_session_id, c.route_id
    FROM user_interaction.cust_info_details c
    CROSS JOIN params p
    WHERE c.__time >= p.window_start
      AND c.__time < p.window_end
      AND c.country = 'IND'
    GROUP BY 1, 2
),
orderinfo_deduped AS (
    SELECT oi.mri_session_id, oi.route_id
    FROM user_interaction.order_info_details oi
    CROSS JOIN params p
    WHERE oi.__time >= p.window_start
      AND oi.__time < p.window_end
      AND oi.country = 'IND'
    GROUP BY 1, 2
),
confirm_deduped AS (
    SELECT
        conf.mri_session_id,
        conf.route_id,
        COUNT(DISTINCT conf.tin) AS tin_count
    FROM user_interaction.confirm_order_details conf
    CROSS JOIN params p
    WHERE conf.__time >= p.window_start
      AND conf.__time < p.window_end
      AND conf.country = 'IND'
      AND conf.status = 200
      AND conf.tin IS NOT NULL
      AND conf.tin NOT IN ('', 'null')
    GROUP BY 1, 2
)
SELECT
    srp.route_bucket,
    srp.exp_variant,
    COUNT(DISTINCT srp.mri_session_id) AS srpload,
    COUNT(DISTINCT sl.mri_session_id) AS slland,
    COUNT(DISTINCT pax.mri_session_id) AS custinfo,
    COUNT(DISTINCT oi.mri_session_id) AS payland,
    COUNT(DISTINCT conf.mri_session_id) AS confirm,
    COALESCE(SUM(conf.tin_count), 0) AS tin,
    CAST(COUNT(DISTINCT conf.mri_session_id) AS DOUBLE)
        / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0) AS cr_session,
    CAST(COALESCE(SUM(conf.tin_count), 0) AS DOUBLE)
        / NULLIF(COUNT(DISTINCT srp.mri_session_id), 0) AS cr_tin
FROM srp_deduped srp
LEFT JOIN sl_deduped sl
    ON srp.mri_session_id = sl.mri_session_id
   AND srp.route_id = sl.route_id
LEFT JOIN mpax_deduped pax
    ON srp.mri_session_id = pax.mri_session_id
   AND srp.route_id = pax.route_id
LEFT JOIN orderinfo_deduped oi
    ON srp.mri_session_id = oi.mri_session_id
   AND srp.route_id = oi.route_id
LEFT JOIN confirm_deduped conf
    ON srp.mri_session_id = conf.mri_session_id
   AND srp.route_id = conf.route_id
GROUP BY
    srp.route_bucket,
    srp.exp_variant
ORDER BY
    srp.route_bucket,
    srp.exp_variant;
