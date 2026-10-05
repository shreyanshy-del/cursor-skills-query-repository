---
name: cr-dim-bo-type
description: >-
  CR Analytics dimension: BO Type RTC / PRIVATE / PRIMO. RTC via lis.bo_mappings.is_rtc; PRIMO bus_ticket_events.hft=2; else PRIVATE. Use with cr-analyser.
---

# CR Dim — BO Type

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

1. Map `search_route_details.op_id` → `lis.bo_mappings.vendor_id` where `is_rtc = 'RTC'` → **RTC**
2. Else if session has BTE confirm with `hft = 2` → **PRIMO**
3. Else → **PRIVATE**

Precedence when both RTC and PRIMO: report both flags; default label **PRIMO** if `hft=2` on confirm, else RTC if mapped, else PRIVATE.


## SQL

- [`references/dim_bo_type.sql`](references/dim_bo_type.sql)
