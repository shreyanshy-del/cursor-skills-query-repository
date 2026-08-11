/* Student_Deal_section loaded/clicked — past 15 days IST, India BUS, Android, by variant */
WITH target_sd_raw AS (
    SELECT *
    FROM (
        VALUES
            ('Bengaluru', 'Chennai', 122, 123),
            ('Chennai', 'Bengaluru', 123, 122),
            ('Hyderabad', 'Bengaluru', 124, 122),
            ('Bengaluru', 'Hyderabad', 122, 124),
            ('Chennai', 'Coimbatore', 123, 141),
            ('Coimbatore', 'Chennai', 141, 123),
            ('Chennai', 'Madurai', 123, 126),
            ('Madurai', 'Chennai', 126, 123),
            ('Coimbatore', 'Bengaluru', 141, 122),
            ('Bengaluru', 'Coimbatore', 122, 141),
            ('Hyderabad', 'Vijayawada', 124, 134),
            ('Vijayawada', 'Hyderabad', 134, 124),
            ('Chennai', 'Tiruchirapalli', 123, 71929),
            ('Chennai', 'Salem', 123, 602),
            ('Delhi', 'Lucknow', 733, 1439),
            ('Pune', 'Nagpur', 130, 624),
            ('Indore', 'Bhopal', 313, 979),
            ('Delhi', 'Dehradun', 733, 777),
            ('Jaipur (Rajasthan)', 'Delhi', 807, 733),
            ('Pune', 'Mumbai', 130, 462),
            ('Chennai', 'Tirunelveli', 123, 696),
            ('Delhi', 'Gorakhpur (uttar pradesh)', 733, 78027),
            ('Delhi', 'Jaipur (Rajasthan)', 733, 807),
            ('Mumbai', 'Pune', 462, 130),
            ('Hyderabad', 'Visakhapatnam', 124, 248),
            ('Pune', 'Aurangabad (Maharashtra)', 130, 309),
            ('Chennai', 'Nagercoil', 123, 690),
            ('Bengaluru', 'Madurai', 122, 126),
            ('Madurai', 'Bengaluru', 126, 122),
            ('Bengaluru', 'Mangaluru', 122, 95222),
            ('Kolkata', 'Durgapur (West Bengal)', 74820, 69802),
            ('Hyderabad', 'Chennai', 124, 123),
            ('Chennai', 'Hosur', 123, 458),
            ('Pune', 'Hyderabad', 130, 124),
            ('Hyderabad', 'Pune', 124, 130),
            ('Chennai', 'Hyderabad', 123, 124),
            ('Chennai', 'Thoothukudi', 123, 698),
            ('Pune', 'Latur', 130, 575),
            ('Mumbai', 'Kolhapur(Maharashtra)', 462, 76079),
            ('Hyderabad', 'Nellore', 124, 131),
            ('Bengaluru', 'Nellore', 122, 131),
            ('Bengaluru', 'Ernakulam', 122, 216),
            ('Vijayawada', 'Bengaluru', 134, 122),
            ('Chennai', 'Pondicherry', 123, 233),
            ('Bengaluru', 'Vijayawada', 122, 134),
            ('Chennai', 'Erode', 123, 236),
            ('Delhi', 'Chandigarh', 733, 833),
            ('Hyderabad', 'Mumbai', 124, 462),
            ('Bengaluru', 'Pondicherry', 122, 233),
            ('Pune', 'Indore', 130, 313),
            ('Indore', 'Pune', 313, 130),
            ('Hyderabad', 'Ongole', 124, 135),
            ('Bengaluru', 'Tiruchirapalli', 122, 71929),
            ('Mumbai', 'Hyderabad', 462, 124),
            ('Chennai', 'Tirupur', 123, 235),
            ('Madurai', 'Coimbatore', 126, 141),
            ('Hyderabad', 'Guntur (Andhra Pradesh)', 124, 137),
            ('Coimbatore', 'Madurai', 141, 126),
            ('Pune', 'Bengaluru', 130, 122),
            ('Bengaluru', 'Pune', 122, 130),
            ('Bengaluru', 'Salem', 122, 602),
            ('Pune', 'Kolhapur(Maharashtra)', 130, 76079),
            ('Hyderabad', 'Kadapa', 124, 284),
            ('Bengaluru', 'Kozhikode', 122, 74661),
            ('Indore', 'Mumbai', 313, 462),
            ('Hyderabad', 'Rajahmundry', 124, 71757),
            ('Bengaluru', 'Belagavi', 122, 95083),
            ('Mumbai', 'Aurangabad (Maharashtra)', 462, 309),
            ('Delhi', 'Kanpur (Uttar Pradesh)', 733, 1377),
            ('Vijayawada', 'Visakhapatnam', 134, 248),
            ('Mumbai', 'Indore', 462, 313),
            ('Bengaluru', 'Thrissur', 122, 995),
            ('Kolkata', 'Bhubaneswar', 74820, 74676),
            ('Gurugram (Gurgaon)', 'Jaipur (Rajasthan)', 70015, 807),
            ('Ahmedabad', 'Rajkot (Gujarat)', 551, 472),
            ('Jaipur (Rajasthan)', 'Gurugram (Gurgaon)', 807, 70015),
            ('Bengaluru', 'Mumbai', 122, 462),
            ('Mumbai', 'Bengaluru', 462, 122),
            ('Bengaluru', 'Erode', 122, 236),
            ('Hyderabad', 'Nagpur', 124, 624),
            ('Bengaluru', 'Thiruvananthapuram', 122, 71425),
            ('Pune', 'Belagavi', 130, 95083),
            ('Coimbatore', 'Tirunelveli', 141, 696),
            ('Coimbatore', 'Tiruchirapalli', 141, 71929),
            ('Bengaluru', 'Guntur (Andhra Pradesh)', 122, 137),
            ('Hyderabad', 'Bhubaneswar', 124, 74676),
            ('Mumbai', 'Nagpur', 462, 624),
            ('Bengaluru', 'Kadapa', 122, 284),
            ('Ahmedabad', 'Indore', 551, 313),
            ('Delhi', 'Indore', 733, 313),
            ('Indore', 'Delhi', 313, 733),
            ('Indore', 'Ahmedabad', 313, 551),
            ('Pune', 'Surat', 130, 473),
            ('Bengaluru', 'Tirupur', 122, 235),
            ('Pune', 'Nashik', 130, 444),
            ('Jaipur (Rajasthan)', 'Udaipur', 807, 470),
            ('Ahmedabad', 'Surat', 551, 473),
            ('Chennai', 'Ernakulam', 123, 216),
            ('Coimbatore', 'Nagercoil', 141, 690),
            ('Pune', 'Ahmedabad', 130, 551),
            ('Bengaluru', 'Nagercoil', 122, 690),
            ('Ahmedabad', 'Pune', 551, 130),
            ('Vijayawada', 'Chennai', 134, 123),
            ('Bengaluru', 'Tirunelveli', 122, 696),
            ('Coimbatore', 'Hosur', 141, 458),
            ('Coimbatore', 'Thoothukudi', 141, 698),
            ('Coimbatore', 'Pondicherry', 141, 233),
            ('Bengaluru', 'Kurnool', 122, 125),
            ('Hyderabad', 'Kurnool', 124, 125),
            ('Jaipur (Rajasthan)', 'Lucknow', 807, 1439),
            ('Ahmedabad', 'Udaipur', 551, 470),
            ('Bengaluru', 'Ongole', 122, 135),
            ('Delhi', 'Jalandhar', 733, 737),
            ('Delhi', 'Ludhiana', 733, 736),
            ('Chennai', 'Vijayawada', 123, 134),
            ('Bengaluru', 'Visakhapatnam', 122, 248),
            ('Ahmedabad', 'Mumbai', 551, 462),
            ('Bengaluru', 'Bhubaneswar', 122, 74676),
            ('Delhi', 'Ahmedabad', 733, 551),
            ('Ahmedabad', 'Vadodara', 551, 1003),
            ('Mumbai', 'Ahmedabad', 462, 551),
            ('Gurugram (Gurgaon)', 'Lucknow', 70015, 1439),
            ('Chennai', 'Thiruvananthapuram', 123, 71425),
            ('Indore', 'Jabalpur', 313, 70024),
            ('Indore', 'Nagpur', 313, 624),
            ('Ahmedabad', 'Delhi', 551, 733),
            ('Coimbatore', 'Ernakulam', 141, 216),
            ('Jaipur (Rajasthan)', 'Ahmedabad', 807, 551),
            ('Delhi', 'Agra', 733, 1290),
            ('Ahmedabad', 'Jaipur (Rajasthan)', 551, 807),
            ('Mumbai', 'Belagavi', 462, 95083),
            ('Jaipur (Rajasthan)', 'Indore', 807, 313),
            ('Delhi', 'Patna (Bihar)', 733, 74699),
            ('Jaipur (Rajasthan)', 'Jodhpur', 807, 1169),
            ('Amritsar', 'Chandigarh', 759, 833),
            ('Amritsar', 'Delhi', 759, 733),
            ('Ayodhya', 'Delhi', 76480, 733),
            ('Bengaluru', 'Goa', 122, 210),
            ('Bengaluru', 'Kannur (Kerala)', 122, 558),
            ('Bengaluru', 'Ooty', 122, 254),
            ('Bengaluru', 'Palakkad', 122, 1013),
            ('Bengaluru', 'Thanjavur', 122, 66007),
            ('Bengaluru', 'Tirupati', 122, 71756),
            ('Bengaluru', 'Tiruvannamalai', 122, 293),
            ('Bengaluru', 'Udupi', 122, 154),
            ('Bengaluru', 'Vellore', 122, 960),
            ('Bengaluru', '86882', 122, 86882),
            ('Bhadrachalam', 'Hyderabad', 517, 124),
            ('Bikaner', 'Jaipur (Rajasthan)', 827, 807),
            ('Chandigarh', 'Amritsar', 833, 759),
            ('Chandigarh', 'Jammu (j and k)', 833, 734),
            ('Chennai', 'Chidambaram', 123, 231),
            ('Chennai', 'Kumbakonam', 123, 427),
            ('Chennai', 'Marthandam', 123, 489),
            ('Chennai', 'Mayiladuthurai', 123, 466),
            ('Chennai', 'Palani', 123, 501),
            ('Chennai', 'Thanjavur', 123, 66007),
            ('Chennai', 'Tiruchendur', 123, 663),
            ('Chennai', 'Tirupati', 123, 71756),
            ('Chennai', 'Tiruvannamalai', 123, 293),
            ('Chidambaram', 'Chennai', 231, 123),
            ('Coimbatore', 'Tiruchendur', 141, 663),
            ('Delhi', 'Amritsar', 733, 759),
            ('Delhi', 'Ayodhya', 733, 76480),
            ('Delhi', 'Haldwani', 733, 1514),
            ('Delhi', 'Haridwar', 733, 802),
            ('Delhi', 'Jammu (j and k)', 733, 734),
            ('Delhi', 'Kasol', 733, 197688),
            ('Delhi', 'KHATTUSHYAMJI DHAM Bus Teminal', 733, 197504),
            ('Delhi', 'Manali', 733, 757),
            ('Delhi', 'Nainital', 733, 771),
            ('Delhi', '309423', 733, 309423),
            ('Delhi', 'Rishikesh', 733, 842),
            ('Delhi', 'Shimla', 733, 1285),
            ('Delhi', 'Ujjain', 733, 1001),
            ('Delhi', 'Varanasi', 733, 70429),
            ('Dharamshala (Himachal Pradesh)', 'Delhi', 65768, 733),
            ('Digha', 'Kolkata', 74706, 74820),
            ('Goa', 'Bengaluru', 210, 122),
            ('Goa', 'Mumbai', 210, 462),
            ('Goa', 'Pune', 210, 130),
            ('Gwalior', 'Indore', 71958, 313),
            ('Haldwani', 'Delhi', 1514, 733),
            ('Haridwar', 'Delhi', 802, 733),
            ('Hyderabad', 'Bhadrachalam', 124, 517),
            ('Hyderabad', 'Tirupati', 124, 71756),
            ('Indore', 'Gwalior', 313, 71958),
            ('Indore', 'Ujjain', 313, 1001),
            ('Jaipur (Rajasthan)', 'Bikaner', 807, 827),
            ('Jammu (j and k)', 'Chandigarh', 734, 833),
            ('Jammu (j and k)', 'Delhi', 734, 733),
            ('Kannur (Kerala)', 'Bengaluru', 558, 122),
            ('Kasol', 'Delhi', 197688, 733),
            ('Katra (jammu and kashmir)', 'Delhi', 735, 733),
            ('KHATTUSHYAMJI DHAM Bus Teminal', 'Delhi', 197504, 733),
            ('Kolkata', 'Digha', 74820, 74706),
            ('Kolkata', 'Siliguri', 74820, 74694),
            ('Kumbakonam', 'Chennai', 427, 123),
            ('Manali', 'Delhi', 757, 733),
            ('Mandarmani', 'Kolkata', 82467, 74820),
            ('Marthandam', 'Chennai', 489, 123),
            ('Mayiladuthurai', 'Chennai', 466, 123),
            ('Mumbai', 'Goa', 462, 210),
            ('Nagpur', 'Nanded', 624, 361),
            ('Nanded', 'Nagpur', 361, 624),
            ('Nanded', 'Pune', 361, 130),
            ('Palakkad', 'Bengaluru', 1013, 122),
            ('Palani', 'Chennai', 501, 123),
            ('309423', 'Delhi', 309423, 733),
            ('Pune', 'Goa', 130, 210),
            ('Pune', 'Nanded', 130, 361),
            ('Pune', 'Ratnagiri (Maharashtra)', 130, 750),
            ('Rishikesh', 'Delhi', 842, 733),
            ('Shimla', 'Delhi', 1285, 733),
            ('Siliguri', 'Kolkata', 74694, 74820),
            ('Thanjavur', 'Bengaluru', 66007, 122),
            ('Thanjavur', 'Chennai', 66007, 123),
            ('Tiruchendur', 'Chennai', 663, 123),
            ('Tirupati', 'Bengaluru', 71756, 122),
            ('Tirupati', 'Chennai', 71756, 123),
            ('Tirupati', 'Hyderabad', 71756, 124),
            ('Tirupati', 'Vijayawada', 71756, 134),
            ('Tiruvannamalai', 'Bengaluru', 293, 122),
            ('Udupi', 'Bengaluru', 154, 122),
            ('Ujjain', 'Bhopal', 1001, 979),
            ('Ujjain', 'Delhi', 1001, 733),
            ('Varanasi', 'Delhi', 70429, 733),
            ('Vellore', 'Bengaluru', 960, 122),
            ('86882', 'Bengaluru', 86882, 122),
            ('Vijayawada', 'Tirupati', 134, 71756)
    ) AS v(source_name, destination_name, source_location_id, destination_location_id)
),
target_sd AS (
    SELECT
        source_name,
        destination_name,
        source_location_id,
        destination_location_id,
        -- city key without state suffix, e.g. "Jaipur (Rajasthan)" -> "jaipur"
        LOWER(TRIM(regexp_replace(source_name, ' *\\([^)]*\\)', ''))) AS source_key,
        LOWER(TRIM(regexp_replace(destination_name, ' *\\([^)]*\\)', ''))) AS dest_key
    FROM target_sd_raw
),
base AS (
    SELECT
        CAST(u.__time + INTERVAL '330' MINUTE AS DATE) AS event_date_ist,
        CAST(u.app_version AS VARCHAR) AS app_version,
        TRY_CAST(split_part(CAST(u.app_version AS VARCHAR), '.', 1) AS INTEGER) AS app_version_major,
        TRY_CAST(split_part(CAST(u.app_version AS VARCHAR), '.', 2) AS INTEGER) AS app_version_minor,
        TRY_CAST(
            COALESCE(NULLIF(split_part(CAST(u.app_version AS VARCHAR), '.', 3), ''), '0') AS INTEGER
        ) AS app_version_patch,
        LOWER(TRIM(CAST(u.event_value AS VARCHAR))) AS event_value_norm,
        CASE
            WHEN UPPER(TRIM(CAST(u.variantname AS VARCHAR))) IN ('V0', 'V1', 'V2', 'V3', 'V4')
                THEN UPPER(TRIM(CAST(u.variantname AS VARCHAR)))
            WHEN CAST(u.channel_exp_info AS VARCHAR) LIKE '%studentDeal:V0%' THEN 'V0'
            WHEN CAST(u.channel_exp_info AS VARCHAR) LIKE '%studentDeal:V1%' THEN 'V1'
            WHEN CAST(u.channel_exp_info AS VARCHAR) LIKE '%studentDeal:V2%' THEN 'V2'
            WHEN CAST(u.channel_exp_info AS VARCHAR) LIKE '%studentDeal:V3%' THEN 'V3'
            WHEN CAST(u.channel_exp_info AS VARCHAR) LIKE '%studentDeal:V4%' THEN 'V4'
            WHEN u.variantname IS NULL OR TRIM(CAST(u.variantname AS VARCHAR)) IN ('', 'NA', 'null', 'NULL')
                THEN 'others'
            ELSE TRIM(CAST(u.variantname AS VARCHAR))
        END AS exp_variant,
        u.mri_session_id,
        u.mri_client_id,
        u.source_destination
    FROM user_interaction.ui_ux_events u
    INNER JOIN target_sd t
        ON strpos(CAST(u.source_destination AS VARCHAR), '_') > 0
       AND (
            LOWER(TRIM(split_part(CAST(u.source_destination AS VARCHAR), '_', 1)))
                LIKE '%' || t.source_key || '%'
            OR (
                t.source_key IN ('bengaluru', 'bangalore')
                AND LOWER(TRIM(split_part(CAST(u.source_destination AS VARCHAR), '_', 1)))
                    LIKE '%bangalore%'
            )
            OR (
                t.source_key IN ('gurugram', 'gurgaon')
                AND LOWER(TRIM(split_part(CAST(u.source_destination AS VARCHAR), '_', 1)))
                    LIKE '%gurgaon%'
            )
       )
       AND (
            LOWER(TRIM(substr(
                CAST(u.source_destination AS VARCHAR),
                strpos(CAST(u.source_destination AS VARCHAR), '_') + 1
            )))
                LIKE '%' || t.dest_key || '%'
            OR (
                t.dest_key IN ('bengaluru', 'bangalore')
                AND LOWER(TRIM(substr(
                    CAST(u.source_destination AS VARCHAR),
                    strpos(CAST(u.source_destination AS VARCHAR), '_') + 1
                )))
                    LIKE '%bangalore%'
            )
            OR (
                t.dest_key IN ('gurugram', 'gurgaon')
                AND LOWER(TRIM(substr(
                    CAST(u.source_destination AS VARCHAR),
                    strpos(CAST(u.source_destination AS VARCHAR), '_') + 1
                )))
                    LIKE '%gurgaon%'
            )
       )
    WHERE u.__time >= CAST(CURRENT_DATE - INTERVAL '15' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE
      AND u.__time < CAST(CURRENT_DATE + INTERVAL '1' DAY AS TIMESTAMP) - INTERVAL '330' MINUTE
      AND u.event_name = 'Student_Deal_section'
      AND LOWER(TRIM(CAST(u.event_value AS VARCHAR))) IN ('loaded', 'clicked')
      AND u.selected_country = 'India'
      AND u.event_src = 'Android'
      AND TRY_CAST(split_part(CAST(u.app_version AS VARCHAR), '.', 1) AS INTEGER) >= 82
      AND (
            UPPER(TRIM(CAST(u.header_bu AS VARCHAR))) = 'BUS'
         OR UPPER(TRIM(CAST(u.lob AS VARCHAR))) = 'BUS'
      )
)
SELECT
    event_date_ist,
    exp_variant,
    app_version,
    COUNT(*) AS total_events,
    COUNT(CASE WHEN event_value_norm = 'loaded' THEN 1 END) AS loaded_events,
    COUNT(CASE WHEN event_value_norm = 'clicked' THEN 1 END) AS clicked_events,
    COUNT(DISTINCT CASE WHEN event_value_norm = 'loaded' THEN mri_session_id END) AS loaded_sessions,
    COUNT(DISTINCT CASE WHEN event_value_norm = 'clicked' THEN mri_session_id END) AS clicked_sessions,
    COUNT(DISTINCT CASE WHEN event_value_norm = 'loaded' THEN mri_client_id END) AS loaded_users,
    COUNT(DISTINCT CASE WHEN event_value_norm = 'clicked' THEN mri_client_id END) AS clicked_users,
    CAST(
        COUNT(DISTINCT CASE WHEN event_value_norm = 'clicked' THEN mri_session_id END) AS DOUBLE
    ) / NULLIF(
        COUNT(DISTINCT CASE WHEN event_value_norm = 'loaded' THEN mri_session_id END),
        0
    ) AS click_through_rate
FROM base
GROUP BY
    event_date_ist,
    exp_variant,
    app_version
ORDER BY
    event_date_ist,
    exp_variant,
    app_version;
