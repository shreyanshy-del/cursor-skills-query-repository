
SELECT
  CASE
    WHEN t.sales_channel = 'RB:MOBILEWEB#droidapp' THEN 'Android'
    WHEN t.sales_channel = 'RB:MOBILEWEB#iosapp' THEN 'iOS'
    WHEN t.sales_channel = 'WEBDIRECT' THEN 'Desktop'
    WHEN t.sales_channel = 'MOBILEWEB' THEN 'MobWeb'
    ELSE COALESCE(t.sales_channel, 'Unknown')
  END AS platform,
  COUNT(DISTINCT t.tin) AS txn_count,
  SUM(t.seat_count) AS seats,
  100.0 * COUNT(DISTINCT t.tin) / SUM(COUNT(DISTINCT t.tin)) OVER () AS txn_share_pct
FROM transaction.bus_ticket_events t
WHERE
  t.date_of_issue >= CAST('2026-08-09 18:30:00' AS TIMESTAMP)
  AND t.date_of_issue < CAST('2026-08-16 18:30:00' AS TIMESTAMP)
  AND t.country_code = 'IND'
  AND t.event_type = 101
  AND t.event_class = 2
GROUP BY 1
ORDER BY txn_count DESC
