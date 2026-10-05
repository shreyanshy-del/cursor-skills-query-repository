---
name: cr-dim-operator
description: >-
  CR Analytics dimension: operator_id / op_id from search_route_details. Use with cr-analyser.
---

# CR Dim — Operator ID

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.search_route_details.op_id` (alias operator).

Session grain: distinct ops seen, or filter to a supplied `op_id` list.


## SQL

- [`references/dim_operator.sql`](references/dim_operator.sql)
