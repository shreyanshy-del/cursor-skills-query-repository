---
name: cr-dim-channel
description: >-
  CR Analytics dimension: Channel (Android/iOS/Web/Mobweb) from search_details.os and channel. Use with cr-analyser.
---

# CR Dim — Channel

CR Analytics **dimension skill**. Use with `cr-analyser` (session grain `mri_session_id`, CR = TIN/SRP).
Attach this cut onto the SRP cohort, then recompute step rates **within the cut**. Product identity must still hold inside each cut value.

## Source

`user_interaction.search_details`: first row `os` + `channel`.

| Label | Rule |
|---|---|
| Android | `channel = MOBILE_APP` and os Android |
| iOS | `channel = MOBILE_APP` and os iOS/iPhone/iPad |
| Mobweb | `channel = MOBILE_WEB` |
| Web | `channel = WEB_DIRECT` |


## SQL

- [`references/dim_channel.sql`](references/dim_channel.sql)
