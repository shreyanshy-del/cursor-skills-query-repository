---
name: women-funnel-analytics
description: >-
  redBus India women-funnel analytics on Android BUS: Women SRP vs Regular SRP,
  Female/Male SVOC, QoQ search and transaction funnels, micro-funnel SL→BP→DP→CI,
  single-women DOJ and BP/DP time, top-100 SD order share, and 14-day return trip.
  Use when the user asks about women funnel, Women SRP, Female SVOC, single women,
  women vs regular, women CR, or women return trip.
---

# Women funnel analytics

India Android BUS. Run the SQL in [`references/`](references/) on Data Platform / Iceberg. Change only the `params` / `t0` / `t1` timestamps. IST day start = previous calendar day `18:30` UTC.

Confirmed tickets: `transaction.bus_ticket_events`, `country_code = 'IND'`, `event_type = 101`. Add `event_class = 2` only when the file already has it.

## Segments (do not collapse)

| Segment | Definition |
|---|---|
| Women_SRP | `ui_ux_events`: `event_group = 'srp_click_event'`, `event_name = 'SRP loaded'`, `event_value = 'Women'`, `event_src = 'Android'`, `header_country = 'IND'`, `header_bu = 'BUS'`, `selected_country = 'India'` |
| Regular_SRP | Same, `event_value = 'Regular'` |
| Female_SVOC | Any SRP session whose `search_details.rb_user_id` matches `svoc.svoc_booker` with `LOWER(gender) IN ('female','f')` |
| Male_SVOC | Same join, `LOWER(gender) IN ('male','m')` |

Women_SRP and Female_SVOC overlap. Report them as separate segments. `user_type` comes from `search_details.user_type` (GUEST / NEW / RETURNING).

## Funnel steps

Session grain is `mri_session_id` unless the file says users or TINs.

- SRP = cohort above, or `search_route_details` / `search_details` when the file says so
- SL = `user_interaction.seat_layout_details`
- CI = `user_interaction.cust_info_details`
- BP = `screen_name = 'boarding point screen'` OR `event_group = 'bp_dp_screen_load'` and screen mentions board
- DP = `screen_name = 'dropping point screen'` OR the same group and screen mentions drop
- Confirm = issued TIN on `bus_ticket_events`

Micro-funnel denominator is SRP / segment sessions, not a forced SL→BP→DP→CI path.

Return trip base is onward bookers. Return = reverse source-destination search or confirm within 14 days of DOI. Use the LIGHT file.

Top-100 SD list is hardcoded in `top100_sd_q2_2026_hardcoded.sql`. Join that list; do not re-rank unless the user asks.

## Which file

| Ask | File |
|---|---|
| One-quarter search funnel, Women_SRP vs Female_SVOC | [women_funnel_search_q2_2026.sql](references/women_funnel_search_q2_2026.sql) |
| One-quarter transaction funnel | [women_funnel_transaction_q2_2026.sql](references/women_funnel_transaction_q2_2026.sql) |
| 8-quarter search | [women_funnel_search_qoq_8q.sql](references/women_funnel_search_qoq_8q.sql) |
| 8-quarter transactions | [women_funnel_transaction_qoq_8q.sql](references/women_funnel_transaction_qoq_8q.sql) |
| Combined 8-quarter pack | [women_funnel_qoq_8quarters.sql](references/women_funnel_qoq_8quarters.sql) |
| Women vs Regular, DBD and city | [women_vs_regular_android_queries.sql](references/women_vs_regular_android_queries.sql) |
| SVOC gender revision of that cut | [women_regular_svoc_revised_queries.sql](references/women_regular_svoc_revised_queries.sql) |
| Women SRP vs Female SVOC side by side | [women_srp_vs_female_svoc_queries.sql](references/women_srp_vs_female_svoc_queries.sql) |
| SL → BP → DP → CI, four segments | [micro_funnel_sl_bp_dp_ci_4segments.sql](references/micro_funnel_sl_bp_dp_ci_4segments.sql) |
| Overall women/female CR | [women_female_cr_overall_q2_2026.sql](references/women_female_cr_overall_q2_2026.sql) |
| Order share on top-100 SD | [women_female_order_share_top100_sd_q2_2026.sql](references/women_female_order_share_top100_sd_q2_2026.sql) and [women_female_order_share_top100_sd_qoq.sql](references/women_female_order_share_top100_sd_qoq.sql) |
| 14-day return, scan-light | [return_trip_women_female_LIGHT.sql](references/return_trip_women_female_LIGHT.sql) |
| 14-day return rate, Female SVOC | [return_rate_14d_women_female_svoc.sql](references/return_rate_14d_women_female_svoc.sql) |
| Single-women DOJ buckets / after 7pm | [single_women_doj_buckets_top100_sd.sql](references/single_women_doj_buckets_top100_sd.sql), [single_women_doj_7pm_top100_sd.sql](references/single_women_doj_7pm_top100_sd.sql) |
| Single-women BP/DP time | [single_women_bp_dp_time_preference.sql](references/single_women_bp_dp_time_preference.sql) |
| Women SRP in six cities | [srp_women_6cities.sql](references/srp_women_6cities.sql) |
| Top-100 SD id list | [top100_sd_q2_2026_hardcoded.sql](references/top100_sd_q2_2026_hardcoded.sql) |
