---
name: filter-usage-analytics
description: >-
  redBus SRP filter-usage analytics on ui_ux_events for Android/iOS: overall any-filter
  vs SRP load, Sort & Filter coverage, Contextual (Clicked/SRP), LMB & Inline
  (Clicked/Viewed), AI, screenshot_taken, chip tops (event_value / filter_applied),
  eligible app-version filtering, and Cursor canvas sheets with Platform/User-type cuts.
  Use when the user asks about filter usage, sort_and_filter, contextual chips, LMB,
  inline filters, SRP filter coverage, screenshot taken, or Filter Usage canvas.
---

# Filter Usage Analytics

Domain skill for **SRP filter instrumentation** on Data Platform / Iceberg
(`user_interaction.ui_ux_events`). Prefer **dataplatformCreateQuery** then
**dataplatformExecuteIcebergQuery** (verbatim). Default country **IND** /
`selected_country = 'India'`, `header_bu = 'BUS'`.

Deliver results as a **Cursor canvas** (Sheet + Platform + User type dropdowns)
unless the user wants a short chat answer only.

## Quick routing

| User intent | Do this |
|-------------|---------|
| Overall any filter / SRP | [overall-any-filter.sql](references/overall-any-filter.sql) |
| Sort & Filter / SRP | [sort-vs-srp.sql](references/sort-vs-srp.sql) |
| Contextual Clicked / SRP + chips | [contextual.sql](references/contextual.sql) |
| LMB or Inline Clicked/Viewed | [lmb-inline.sql](references/lmb-inline.sql) |
| Screenshot volume | [screenshot.sql](references/screenshot.sql) |
| Canvas layout / sheet list | [canvas-structure.md](references/canvas-structure.md) |
| Version eligibility | **Eligible versions** below |

## Canonical filters (never invent)

```
table: user_interaction.ui_ux_events
header_country = 'IND'
header_bu = 'BUS'
selected_country = 'India'
event_src IN ('Android', 'iOS')   -- or one platform if asked
```

### Event groups / names

| Surface | event_group | event_name | Notes |
|---------|-------------|------------|-------|
| Sort & Filter | `srp_filter_event` | `sort_and_filter` | `event_value` = dimension(s); `filter_applied` = values |
| Contextual | `srp_filter_event` | `contextual` | **Clicked only** (no Viewed in data) |
| LMB | `srp_filter_event` | `LMB` | Viewed / Clicked in `event_value` |
| Inline | `srp_filter_event` | `inline` / `Inline` | Viewed / Clicked; RTC bus-type chips |
| AI | `srp_filter_event` | `AI` | Often empty in window |
| SRP denom | `srpLoad` | `SRP load` | Distinct `mri_session_id` |
| Screenshot | `screenshot_taken` | `screenshot taken` | Page/usertype often **null** |

Normalize usertype to `GUEST` / `NEW` / `RETURNING` (else `OTHER`; exclude OTHER from canvas cuts unless asked).

## Coverage definitions (fixed)

| Metric | Formula |
|--------|---------|
| **Overall filter** | Distinct sessions with **any** of Sort / Contextual Clicked / LMB Clicked / Inline Clicked ÷ SRP load |
| **Sort** | Distinct `sort_and_filter` sessions ÷ SRP load |
| **Contextual** | Distinct Contextual **Clicked** ÷ SRP load (**not** Clicked/Viewed) |
| **LMB / Inline** | Distinct Clicked ÷ Distinct Viewed |
| Session grain | Prefer **Σ of daily distinct** for multi-day coverage (matches canvas) |

Overall is a **union of sessions**, not a sum of filter types (overlap is real).

## Eligible versions (critical)

`app_version >= '82.2'` (string) **inflates SRP** with versions that have **0% sort** (e.g. Android `82.2.51`).

Use **explicit IN lists** of versions that emit sort events + meaningful SRP:

```
Android: '82.3.0', '82.3.1', '82.3.5', '82.3.6', '82.4.0-IB1'
iOS:     '8.6.7.10', '8.7.0.1', '8.6.9.2', '8.6.8.1'
```

Re-discover eligibility if the user changes the window: versions with sort sessions > 0 and non-trivial SRP. Document excluded inflators in the canvas callout.

## Workflow

```
Filter usage ask:
- [ ] 1. Confirm window (default last 7 complete days), platforms, country IND
- [ ] 2. Apply eligible version lists (never raw >= 82.2 alone)
- [ ] 3. Pull Overall any-filter + Sort vs SRP (usertype × platform × day)
- [ ] 4. Pull Contextual / LMB / Inline (+ filter_applied tops)
- [ ] 5. Screenshot volume; note null page/usertype
- [ ] 6. Build/update canvas: Overall first sheet; Sheet/Platform/Usertype selects
- [ ] 7. Lead with coverage %; state eligible-version caveat
```

For large scans, run **per-day** queries if the 7d combined query times out.

## Canvas output

Path pattern: `~/.cursor/projects/<workspace>/canvases/filter-usage-android.canvas.tsx`

Required sheets (order):

1. Overall filter (any / SRP)
2. Usage overview (Sort vs SRP + other-filter snapshot)
3. Sort & Filter (usage → top `event_value` → top `filter_applied`)
4. Contextual (Clicked/SRP + chips: AC, SLEEPER, Primo, Deals, …)
5. LMB (Viewed/Clicked by usertype)
6. Inline (coverage + RTC chips: SUPER LUXURY, VOLVO, JANRATH, …)
7. AI (empty-state callout if no rows)
8. Screenshot

Dropdowns: **Sheet**, **Platform** (ALL / Android / iOS), **User type** (ALL / RETURNING / NEW / GUEST).

Embed query results inline — no `fetch()`. Import only from `cursor/canvas`.

## Output style

- Lead with the coverage the user asked for (Overall / Sort / Contextual / LMB / Inline).
- State: India BUS, eligible versions, window, Σ daily distinct.
- Do not invent event names, page fields, or Viewed for Contextual.
- Prefer canvas over markdown tables for multi-sheet results.

## Additional resources

- [overall-any-filter.sql](references/overall-any-filter.sql)
- [sort-vs-srp.sql](references/sort-vs-srp.sql)
- [contextual.sql](references/contextual.sql)
- [lmb-inline.sql](references/lmb-inline.sql)
- [screenshot.sql](references/screenshot.sql)
- [canvas-structure.md](references/canvas-structure.md)
