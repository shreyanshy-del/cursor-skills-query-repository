---
name: cr-dim-ga-plugin
description: >-
  CR Analytics dimension: GA/plugin events from ui_ux_events. Requires user-supplied event_group, event_name, event_value. Use with cr-analyser.
---

# CR Dim — GA Plugin

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.ui_ux_events`

## Input (required)

User must supply one or more of:

- `event_group`
- `event_name`
- `event_value`

Also keep IND BUS filters: `header_country='IND'`, `header_bu='BUS'`, `selected_country='India'` unless asked otherwise.


## SQL

- [`references/dim_ga_plugin.sql`](references/dim_ga_plugin.sql)
