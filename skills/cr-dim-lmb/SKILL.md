---
name: cr-dim-lmb
description: >-
  CR Analytics dimension: LMB vs Non-LMB from search_details on DBD 0 only (IST hour 17-23 = LMB). Use with cr-analyser.
---

# CR Dim — LMB / Non-LMB

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.search_details` first row. **DBD 0 only** (same calendar IST day as doj).

- **LMB** = IST hour of search in 17–23
- **Non-LMB** = any other hour that same DBD-0 day

Do not label DBD 1+ as LMB.


## SQL

- [`references/dim_lmb.sql`](references/dim_lmb.sql)
