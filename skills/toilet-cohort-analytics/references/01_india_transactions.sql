SELECT
  multiIf(
    DateOfIssue >= toDateTime('2026-07-31 18:30:00') AND DateOfIssue < toDateTime('2026-08-10 18:30:00'), 'P1_Aug1_10',
    DateOfIssue >= toDateTime('2026-08-10 18:30:00') AND DateOfIssue < toDateTime('2026-08-20 18:30:00'), 'P2_Aug11_20',
    'other'
  ) AS period,
  countDistinct(TIN) AS overall_txns,
  sum(NoofSeats) AS overall_seats,
  countDistinctIf(TIN, lower(Gender)='female') AS female_txns,
  sumIf(NoofSeats, lower(Gender)='female') AS female_seats
FROM oms_db.bus_ticket_issued
WHERE Year = 2026
  AND BusinessUnit = 'REDBUS_IN'
  AND DateOfIssue >= toDateTime('2026-07-31 18:30:00')
  AND DateOfIssue < toDateTime('2026-08-20 18:30:00')

GROUP BY period
ORDER BY period
