---
name: cr-dim-dbd
description: >-
  CR Analytics dimension: DBD (0,1,2,3,4,5+) from search_details DOI vs doj. Use with cr-analyser.
---

# CR Dim — DBD

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.search_details`: first row per session.

`DBD = date_diff(day, IST(search __time), doj)`.

## Buckets

`0`, `1`, `2`, `3`, `4`, `5+` (same as women / return-tier packs).


## SQL

- [`references/dim_dbd.sql`](references/dim_dbd.sql)
