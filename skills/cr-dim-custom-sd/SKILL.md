---
name: cr-dim-custom-sd
description: >-
  CR Analytics dimension: Custom SD / routes from search_route_details src_id×dest_id (and route_id). Use with cr-analyser; pass SD list as input.
---

# CR Dim — Custom SD

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.search_route_details`: `src_id`, `dest_id`, `route_id`, `mri_session_id`.

**Input required:** custom SD list `(src_id, dest_id)` (or route_ids). Filter or flag sessions that hit that list.


## SQL

- [`references/dim_custom_sd.sql`](references/dim_custom_sd.sql)
