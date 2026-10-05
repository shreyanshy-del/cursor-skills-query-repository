---
name: cr-dim-sd-type
description: >-
  CR Analytics dimension: Short vs Long SD via lis.short_route_sds (else Long). Use with cr-analyser.
---

# CR Dim — SD Type (Short / Long)

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`lis.short_route_sds` where `cohort = '2026'`.

Session/route in that list → **Short**, else **Long**.


## SQL

- [`references/dim_sd_type.sql`](references/dim_sd_type.sql)
