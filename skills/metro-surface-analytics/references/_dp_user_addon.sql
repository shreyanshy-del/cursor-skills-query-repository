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
ev AS (
  SELECT
    u.event_name,
    CASE
      WHEN u.event_src LIKE '%iOS%' THEN 'iOS'
      WHEN u.event_src LIKE '%Android%' THEN 'Android'
      ELSE 'Other'
    END AS platform,
    CAST(u.mri_client_id AS VARCHAR) AS mri_client_id,
    CASE
      WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'bengaluru|bangalore|ಬೆಂಗಳೂರು|பெங்களூரு') THEN 'Bangalore'
      WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'chennai|சென்னை') THEN 'Chennai'
      WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'delhi|दिल्ली') THEN 'Delhi'
      WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'ernakulam|kochi') THEN 'Ernakulam'
      WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'mumbai|मुंबई') THEN 'Mumbai'
      WHEN REGEXP_LIKE(LOWER(COALESCE(u.event_value, '')), 'pune|पुणे') THEN 'Pune'
    END AS city
  FROM user_interaction.ui_ux_events u
  WHERE u.__time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND u.__time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
    AND u.header_country = 'IND'
    AND u.header_bu = 'BUS'
    AND u.selected_country = 'India'
    AND u.event_group = 'bus_buddy_click_event'
    AND u.event_name IN (
      'BusMetro_MetroMetaShown',
      'BusMetro_MetroCardLoaded',
      'BusMetro_MetroStickyLoaded',
      'BusMetro_MetroHomeLanded'
    )
    AND u.mri_client_id IS NOT NULL
    AND CAST(u.mri_client_id AS VARCHAR) NOT IN ('', '0')
),
id_map AS (
  SELECT
    CAST(b.mri_client_id AS VARCHAR) AS mri_client_id,
    MAX(b.rb_user_id) AS rb_user_id
  FROM transaction.bus_ticket_events b
  INNER JOIN (SELECT DISTINCT mri_client_id FROM ev) i
    ON CAST(b.mri_client_id AS VARCHAR) = i.mri_client_id
  WHERE b.country_code = 'IND'
    AND b.event_type = 101
    AND b.rb_user_id IS NOT NULL
    AND b.rb_user_id <> 0
    AND b.time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
    AND b.time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  GROUP BY 1
),
metro_txns AS (
  SELECT DISTINCT
    a.rb_user_id,
    CAST(a.tin AS VARCHAR) AS tin,
    m.city AS metro_city
  FROM transaction.addon_item a
  INNER JOIN metro_city_map m
    ON a.service_provider_name = m.service_provider_name
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
users AS (
  SELECT DISTINCT
    e.event_name,
    e.platform,
    e.city,
    e.mri_client_id,
    im.rb_user_id
  FROM ev e
  LEFT JOIN id_map im
    ON e.mri_client_id = im.mri_client_id
),
rows AS (
  SELECT event_name, 'All' AS platform, 'Overall' AS city, mri_client_id, rb_user_id
  FROM users
  UNION
  SELECT event_name, platform, 'Overall' AS city, mri_client_id, rb_user_id
  FROM users
  UNION
  SELECT event_name, 'All' AS platform, city, mri_client_id, rb_user_id
  FROM users
  WHERE city IS NOT NULL
  UNION
  SELECT event_name, platform, city, mri_client_id, rb_user_id
  FROM users
  WHERE city IS NOT NULL
)
SELECT
  r.event_name,
  r.platform,
  r.city,
  COUNT(DISTINCT r.mri_client_id) AS users,
  COUNT(DISTINCT CASE WHEN r.rb_user_id IS NOT NULL THEN r.mri_client_id END) AS mapped_users,
  COUNT(DISTINCT CASE WHEN t.rb_user_id IS NOT NULL THEN r.mri_client_id END) AS metro_users,
  COUNT(DISTINCT t.tin) AS metro_tins,
  COUNT(DISTINCT CASE WHEN r.city <> 'Overall' AND t.metro_city = r.city THEN r.mri_client_id END) AS same_city_users
FROM rows r
LEFT JOIN metro_txns t
  ON r.rb_user_id = t.rb_user_id
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
LIMIT 200
