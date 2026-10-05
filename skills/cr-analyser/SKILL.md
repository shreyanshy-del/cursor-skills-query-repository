---
name: cr-analyser
description: >-
  CR Analyser — redBus India BUS conversion and funnel throughput at
  mri_session_id grain: SRP from search_details, steps
  SL→CI→TCO→PAY→PAY_NOW→CONFIRM, CR = TIN/SRP from bus_ticket_events.
  Enforces ordered step rates and product identity
  CR = (SL/SRP)×(CI/SL)×(TCO/CI)×(PAY/TCO)×(PAY_NOW/PAY)×(CONFIRM/PAY_NOW).
  Use when the user asks for CR Analyser, India CR, funnel throughput,
  SRP to confirm, or TIN per SRP.
---

# CR Analyser

India BUS conversion dashboard skill. Session grain is **`mri_session_id` only**
(no route join, no channel / platform / usertype cut unless the user explicitly
asks for a separate cut and accepts that the product identity is checked
**within each cut**).

Run [`references/cr_analyser_1d.sql`](references/cr_analyser_1d.sql) on
Data Platform / Iceberg. Change **only** `t_start` / `t_end` (IST day =
previous calendar day `18:30` UTC → next day `18:30` UTC).

## Hard contracts (do not invent)

| Item | Rule |
|---|---|
| Country | `IND` |
| Search / SRP | Distinct `mri_session_id` from `user_interaction.search_details` |
| SL | `user_interaction.seat_layout_details` |
| CI | `user_interaction.cust_info_details` |
| TCO | `user_interaction.create_order_details` |
| PAY | `user_interaction.order_info_details` |
| PAY_NOW | `user_interaction.make_payment_details` |
| CONFIRM / TIN | `transaction.bus_ticket_events`, `event_type = 101`, `event_class = 2`, non-null `tin`, joined **only** on `mri_session_id` to the SRP cohort |
| Time on BTE | `time_of_event` in the same window as UI tables’ `__time` |

**CR = TIN / SRP sessions** (distinct `tin` ÷ distinct SRP `mri_session_id`).

Under this skill, the CONFIRM numerator in step 6 and in the product identity is
**distinct TIN** (not `confirm_order_details`). Also emit `confirm_sessions`
(distinct BTE `mri_session_id`) for QA; it is **not** the CR denominator or the
step-6 numerator.

## Ordered output (fixed)

Results **must** appear in this order. Do not reorder, drop, or insert steps.

| # | Step | Formula |
|---|---|---|
| 1 | SRP → SL | `SL / SRP` |
| 2 | SL → CI | `CI / SL` |
| 3 | CI → TCO | `TCO / CI` |
| 4 | TCO → PAY | `PAY / TCO` |
| 5 | PAY → PAY_NOW | `PAY_NOW / PAY` |
| 6 | PAY_NOW → CONFIRM | `CONFIRM / PAY_NOW` = `TIN / PAY_NOW` |
| 7 | CR | `TIN / SRP` |

## Product identity (must hold)

```
CR = (1) × (2) × (3) × (4) × (5) × (6)
TIN/SRP = (SL/SRP) × (CI/SL) × (TCO/CI) × (PAY/TCO) × (PAY_NOW/PAY) × (TIN/PAY_NOW)
```

After every run:

1. Compute `product_pct = r1 × r2 × r3 × r4 × r5 × r6` (rates as fractions, or
   percentages ÷ 100).
2. Compute `cr_pct = TIN / SRP`.
3. **Pass** if `ABS(product_pct - cr_pct) ≤ 1e-9` (or ≤ `0.0001` when comparing
   percentage points after rounding to 4 decimals).
4. **Error** if it fails: stop and say the funnel identity broke (usually a wrong
   join grain, a channel cut on only some steps, or TIN not from BTE). Do **not**
   publish the dashboard numbers until fixed.

Zero denominators: if any step denominator is 0, mark that step and CR as NULL and
**fail** the identity check (do not silently treat NULL as 1).

## Which file

| Ask | File |
|---|---|
| One-day (or any window) India CR + throughput | [cr_analyser_1d.sql](references/cr_analyser_1d.sql) |

## Workflow

```
CR Analyser / India CR / funnel throughput:
- [ ] 1. Set t_start / t_end only (default one IST day)
- [ ] 2. SRP = distinct mri_session_id on search_details, country IND
- [ ] 3. Join every later table on mri_session_id only (restrict to SRP cohort)
- [ ] 4. TIN from bus_ticket_events event_type=101 event_class=2
- [ ] 5. Emit counts + rates in order 1…7
- [ ] 6. Assert product(1..6) == CR (7); on failure report ERROR, do not invent fixes
```

## Output style

Lead with CR (`TIN/SRP`), then the six step rates in order, then raw counts
(`srpload`, `slload`, `ci`/`paxload`, `tcoload`, `paymentload`, `addPayClick`,
`confirm_sessions`, `tin`), then `product_pct` and `identity_ok`.

Prefer dataplatformCreateQuery / dataplatformExecuteIcebergQuery. Do not swap
confirm onto `confirm_order_details`. Do not add channel cuts by default.


## Dimension skills (first set)

Attach these cuts onto `cr-analyser` sessions (`mri_session_id`). Recompute steps inside each cut; product identity must hold.

| Skill | Cut | Source |
|---|---|---|
| `cr-dim-usertype` | Usertype | `search_details.user_type` |
| `cr-dim-dbd` | DBD | `search_details` DOI vs doj |
| `cr-dim-lmb` | LMB / Non-LMB | `search_details` DBD0 IST hour 17–23 |
| `cr-dim-channel` | Channel | `search_details.os` + `channel` |
| `cr-dim-region-tier` | Region / State | `lis.config_locations.parent_location` |
| `cr-dim-sd-type` | Short / Long | `lis.short_route_sds` else Long |
| `cr-dim-custom-sd` | Custom SD | `search_route_details` + input SD list |
| `cr-dim-ga-plugin` | GA Plugin | `ui_ux_events` (input group/name/value) |
| `cr-dim-operator` | Operator_ID | `search_route_details.op_id` |
| `cr-dim-bo-type` | BO Type | `lis.bo_mappings.is_rtc` / BTE `hft=2` / PRIVATE |
| `cr-dim-age-gender` | Age / Gender | `svoc.svoc_booker` |
| `cr-dim-bus-type` | AC / Sleeper / Seater | `search_route_details.is_ac/is_sleeper/is_seater` |
