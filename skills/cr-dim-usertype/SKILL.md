---
name: cr-dim-usertype
description: >-
  CR Analytics dimension: Usertype (GUEST/NEW/RETURNING) from user_interaction.search_details.user_type. Use with cr-analyser.
---

# CR Dim — Usertype

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.search_details.user_type` on the **first** search row per `mri_session_id`.

## Values

| Raw | Normalized |
|---|---|
| GUEST | GUEST |
| NEW | NEW |
| RETURNING, EXISTING, OLD | RETURNING |
| else | OTHER (exclude unless asked) |


## SQL

- [`references/dim_usertype.sql`](references/dim_usertype.sql)
