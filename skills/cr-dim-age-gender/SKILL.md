---
name: cr-dim-age-gender
description: >-
  CR Analytics dimension: Age and Gender from svoc.svoc_booker joined via search_details.rb_user_id. Use with cr-analyser.
---

# CR Dim — Age / Gender (SVOC)

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`svoc.svoc_booker` joined on `rb_userid` = first `search_details.rb_user_id`.

- **Gender:** normalize female/f, male/m
- **Age:** from SVOC age/YOB fields available on `svoc_booker` (use the column present in your catalog; do not invent)

Guest / rb_user_id 0 → Unknown.


## SQL

- [`references/dim_age_gender.sql`](references/dim_age_gender.sql)
