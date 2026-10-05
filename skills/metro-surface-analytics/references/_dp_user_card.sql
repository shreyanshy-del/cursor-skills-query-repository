WITH metro_city_map AS (
  SELECT * FROM (
    VALUES
      ('MaharashtraMetroRailCoLtd', 'Pune'),
      ('Mumbai Metro One Pvt Ltd', 'Mumbai'),
      ('Bangalore Metro Rail Corporation Limited', 'Bangalore'),
      ('Mumbai Metro Rail Corporation Limited', 'Mumbai'),
      ('Kochi Metro Rail Limited', 'Ernakulam'),
      ('Maha Mumbai Metro Operation Corporation Limited', 'Mumbai'),
      ('Chennai Metro Rail Limited', 'Chennai'),
      ('Delhi Metro Rail Corporation', 'Delhi')
  ) AS t(service_provider_name, city)
),
metro_buyers AS (
  SELECT DISTINCT a.rb_user_id, m.city
  FROM transaction.addon_item a
  INNER JOIN metro_city_map m ON a.service_provider_name = m.service_provider_name
  WHERE a.country_code = 'IND'
    AND a.item_type = 13
    AND a.s_c_t = 'Ticket'
    AND a.c_t = 'METRO_TICKETING'
    AND a.event_type = 101
    AND a.status = 'CONFIRMED'
    AND a.tin IS NOT NULL
    AND a.rb_user_id IS NOT NULL
    AND a.rb_user_id <> 0
    AND a.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND a.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
),
metro_any AS (
  SELECT DISTINCT rb_user_id FROM metro_buyers
),
ev AS (
  SELECT
    uue.event_name,
    uue.mri_client_id,
    CASE
      WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'bengaluru|bangalore|ಬೆಂಗಳೂರು|பெங்களூரு') THEN 'Bangalore'
      WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'chennai|சென்னை') THEN 'Chennai'
      WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'delhi|दिल्ली') THEN 'Delhi'
      WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'ernakulam|kochi') THEN 'Ernakulam'
      WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'mumbai|मुंबई') THEN 'Mumbai'
      WHEN REGEXP_LIKE(LOWER(COALESCE(uue.event_value, '')), 'pune|पुणे') THEN 'Pune'
    END AS metro_city
  FROM user_interaction.ui_ux_events AS uue
  WHERE
    uue.__time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND uue.__time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
    AND uue.header_country = 'IND'
    AND uue.header_bu = 'BUS'
    AND uue.selected_country = 'India'
    AND uue.event_group = 'bus_buddy_click_event'
    AND uue.event_src = 'Android'
    AND uue.event_name = 'BusMetro_MetroCardLoaded'
    AND uue.mri_client_id IS NOT NULL
    AND uue.mri_client_id NOT IN ('', '0')
),
id_map AS (
  SELECT b.mri_client_id, MAX(b.rb_user_id) AS rb_user_id
  FROM transaction.bus_ticket_events AS b
  INNER JOIN (SELECT DISTINCT mri_client_id FROM ev) i
    ON b.mri_client_id = i.mri_client_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.rb_user_id IS NOT NULL
    AND b.rb_user_id <> 0
    AND b.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND b.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  GROUP BY 1
),
u_event AS (
  SELECT DISTINCT e.event_name, e.mri_client_id, m.rb_user_id
  FROM ev e
  LEFT JOIN id_map m ON e.mri_client_id = m.mri_client_id
),
u_city AS (
  SELECT DISTINCT e.event_name, e.metro_city, e.mri_client_id, m.rb_user_id
  FROM ev e
  LEFT JOIN id_map m ON e.mri_client_id = m.mri_client_id
  WHERE e.metro_city IS NOT NULL
)
SELECT city, event_name, users, mapped_users, metro_users, same_city_users
FROM (
  SELECT
    'Overall' AS city,
    u.event_name,
    COUNT(*) AS users,
    SUM(CASE WHEN u.rb_user_id IS NOT NULL THEN 1 ELSE 0 END) AS mapped_users,
    SUM(CASE WHEN a.rb_user_id IS NOT NULL THEN 1 ELSE 0 END) AS metro_users,
    CAST(0 AS BIGINT) AS same_city_users
  FROM u_event u
  LEFT JOIN metro_any a ON u.rb_user_id = a.rb_user_id
  GROUP BY 2
  UNION ALL
  SELECT
    u.metro_city AS city,
    u.event_name,
    COUNT(*) AS users,
    SUM(CASE WHEN u.rb_user_id IS NOT NULL THEN 1 ELSE 0 END) AS mapped_users,
    SUM(CASE WHEN a.rb_user_id IS NOT NULL THEN 1 ELSE 0 END) AS metro_users,
    SUM(CASE WHEN sc.rb_user_id IS NOT NULL THEN 1 ELSE 0 END) AS same_city_users
  FROM u_city u
  LEFT JOIN metro_any a ON u.rb_user_id = a.rb_user_id
  LEFT JOIN metro_buyers sc ON u.rb_user_id = sc.rb_user_id AND u.metro_city = sc.city
  GROUP BY 1, 2
)
LIMIT 20
