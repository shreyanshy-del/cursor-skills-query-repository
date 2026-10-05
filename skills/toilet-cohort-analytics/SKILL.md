---
name: toilet-cohort-analytics
description: >-
  redBus India toilet-cohort transaction comparison: pre vs post window for
  toilet-on-seat-layout, toilet-as-amenity, and the union of those services,
  against overall India. Uses OMS ClickHouse bus_ticket_issued with operator
  plus service id. Use when the user asks about toilet cohort, toilet on SL,
  toilet amenity, toilet pre vs post, or operator-service route lists.
---

# Toilet cohort (pre vs post)

These files are **OMS ClickHouse**, not Iceberg. Run them with OMS `executeQueryInOmsCh`. Keep `Year` in the WHERE clause. Do not rewrite them onto `transaction.bus_ticket_events` unless the user asks for that source.

Match a service only as **`(OperatorId = vendor AND ServiceID IN (...))`**. Never filter `ServiceID` alone.

## Windows (IST, stored as OMS UTC)

| Period | DateOfIssue |
|---|---|
| P1 pre, 1–10 Aug 2026 | `>= 2026-07-31 18:30:00` and `< 2026-08-10 18:30:00` |
| P2 post, 11–20 Aug 2026 | `>= 2026-08-10 18:30:00` and `< 2026-08-20 18:30:00` |

Scope: `Year = 2026`, `BusinessUnit = 'REDBUS_IN'`. Metrics: distinct TIN, seats, and the same counts where `lower(Gender) = 'female'`.

| Ask | File |
|---|---|
| India overall, no vendor filter | [01_india_transactions.sql](references/01_india_transactions.sql) |
| Toilet shown on seat layout | [02_toilet_on_sl.sql](references/02_toilet_on_sl.sql) |
| Toilet as amenity | [03_toilet_as_amenity.sql](references/03_toilet_as_amenity.sql) |
| Either cohort (SL ∪ amenity) | [04_toilet_union_either.sql](references/04_toilet_union_either.sql) |

## Operator and service lookup (Iceberg)

When the user needs the operator–service–city list behind a cohort, use Data Platform, not OMS:

- [operator_service_routes.sql](references/operator_service_routes.sql) — `bus_ticket_events` `event_type = 101`, joined to `lis.config_locations`
- [op_svc_by_operator.sql](references/op_svc_by_operator.sql) — same grain, one operator cut

Change only the `time_of_event` window.
