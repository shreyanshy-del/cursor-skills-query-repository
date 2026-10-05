---
name: cr-dim-bus-type
description: >-
  CR Analytics dimension: AC/Sleeper/Seater/Hybrid from search_route_details is_ac, is_sleeper, is_seater. Use with cr-analyser.
---

# CR Dim — AC / Sleeper / Seater

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.search_route_details`:

- `is_ac` → AC / non-AC
- `is_sleeper` + `is_seater` → Sleeper / Seater / Hybrid / NA

Grain is session × route (or MAX/ANY_VALUE rolled to session if asked).


## SQL

- [`references/dim_bus_type.sql`](references/dim_bus_type.sql)
