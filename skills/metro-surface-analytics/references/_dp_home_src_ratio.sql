SELECT
  CASE
    WHEN REGEXP_LIKE(LOWER(COALESCE(event_value, '')), 'bengaluru|bangalore|ಬೆಂಗಳೂರು|பெங்களூரு') THEN 'Bangalore'
    WHEN REGEXP_LIKE(LOWER(COALESCE(event_value, '')), 'chennai|சென்னை') THEN 'Chennai'
    WHEN REGEXP_LIKE(LOWER(COALESCE(event_value, '')), 'delhi|दिल्ली') THEN 'Delhi'
    WHEN REGEXP_LIKE(LOWER(COALESCE(event_value, '')), 'ernakulam|kochi') THEN 'Ernakulam'
    WHEN REGEXP_LIKE(LOWER(COALESCE(event_value, '')), 'mumbai|मुंबई') THEN 'Mumbai'
    WHEN REGEXP_LIKE(LOWER(COALESCE(event_value, '')), 'pune|पुणे') THEN 'Pune'
    ELSE 'Unmapped'
  END AS city,
  CASE
    WHEN LOWER(COALESCE(event_value, '')) LIKE 'banner%' THEN 'banner'
    WHEN LOWER(COALESCE(event_value, '')) LIKE 'sticky%' THEN 'sticky'
    ELSE 'other'
  END AS home_src,
  COUNT(DISTINCT mri_session_id) AS sessions
FROM user_interaction.ui_ux_events
WHERE __time >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
  AND __time < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
  AND header_country = 'IND'
  AND header_bu = 'BUS'
  AND selected_country = 'India'
  AND event_group = 'bus_buddy_click_event'
  AND event_name = 'BusMetro_MetroHomeLanded'
  AND mri_session_id IS NOT NULL
  AND CAST(mri_session_id AS VARCHAR) NOT IN ('', '0')
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 40
