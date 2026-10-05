SELECT
  COUNT(DISTINCT tin) AS metro_tins,
  COUNT(DISTINCT rb_user_id) AS metro_users
FROM transaction.addon_item
WHERE country_code = 'IND'
  AND item_type = 13
  AND s_c_t = 'Ticket'
  AND c_t = 'METRO_TICKETING'
  AND event_type = 101
  AND status = 'CONFIRMED'
  AND tin IS NOT NULL
  AND rb_user_id IS NOT NULL
  AND rb_user_id <> 0
  AND time_of_event >= CAST('2026-08-10 18:30:00' AS TIMESTAMP)
  AND time_of_event < CAST('2026-08-17 18:30:00' AS TIMESTAMP)
LIMIT 5
