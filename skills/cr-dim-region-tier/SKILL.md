---
name: cr-dim-region-tier
description: >-
  CR Analytics dimension: Region/State via lis.config_locations.parent_location on search src/dest. Use with cr-analyser.
---

# CR Dim — Region / Tier

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

From first `search_details` (or session src/dest):

- `src_id` / `dest_id` → `lis.config_locations` (`geo = 'IND'`)
- **Region / State** = `parent_location` (state id); optionally join again for state name

Use dest or src state as the dashboard cut (default **destination state** unless asked otherwise).


## SQL

- [`references/dim_region_tier.sql`](references/dim_region_tier.sql)
