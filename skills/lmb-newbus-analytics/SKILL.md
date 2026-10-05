---
name: lmb-newbus-analytics
description: >-
  redBus India Android analytics for DBD-0 last-minute bus (LMB) versus the rest
  of departure day, and for New Bus (persuasion id 68) click and order share on
  unfiltered SRP ranks within top SD pairs. Use when the user asks about LMB,
  DBD 0, last-minute bus, dropper recovery, New Bus, persuasion 68, tuple rank,
  or top-10/top-20 click or order share.
---

# LMB and New Bus SRP share

Android IND. Run [`references/`](references/) on Data Platform / Iceberg. Change only the UTC window. IST day start = previous day `18:30` UTC.

Confirmed order: `transaction.bus_ticket_events`, `country_code = 'IND'`, `event_type = 101`, `event_class = 2`, Android `sales_channel`.

## LMB vs rest of DBD 0

Scope is **DBD 0 only** (DOJ date = IST search date). Segment from the **first** `search_details` row in the session:

- **LMB** = IST hour 17–23
- **DBD0_WITHOUT_LMB** = any other hour that same DBD-0 day

Do not compare LMB with DBD 1+.

| Ask | File |
|---|---|
| Weekday dropper recovery, 2 weeks, session | [lmb_vs_dbd0_dropper_recovery_weekday_2w.sql](references/lmb_vs_dbd0_dropper_recovery_weekday_2w.sql) |
| Same cut at user grain | [lmb_vs_dbd0_dropper_recovery_weekday_2w_user.sql](references/lmb_vs_dbd0_dropper_recovery_weekday_2w_user.sql) |
| Payment-page visit frequency, weekday, user | [lmb_vs_dbd0_pp_visit_freq_weekday_user.sql](references/lmb_vs_dbd0_pp_visit_freq_weekday_user.sql) |
| RB user / client, 1-minute gap | [lmb_vs_dbd0_pp_rbuser_client_1min_gap.sql](references/lmb_vs_dbd0_pp_rbuser_client_1min_gap.sql) |

## New Bus and unfiltered rank share

- **New Bus** = `CONTAINS(persuasion_id, '68')`. Rest = not contains. Overall = all tuples.
- **Cohort** = unfiltered SRP: `search_details.is_filter_applied = FALSE` and sort < 1, `channel = MOBILE_APP`, `os = Android`.
- **Tuple rank** = `search_route_details.offset + position + 1`, minimum per session × route × DOJ.
- **Click** = distinct `seat_layout_details.mri_uuid` joined on session + route + DOJ.
- **Order** = distinct confirmed TIN, same join keys.
- **Shares:** `*_share_within` = cohort top-10 ÷ same cohort top-20. `test_share_vs_all_top20` = New Bus top-10 ÷ all top-20.
- Top-200 SD universe is query Q0 inside the New Bus file. Remove the `INNER JOIN top_sd` block only when the user wants all-India.

| Ask | File |
|---|---|
| New Bus click and order share, top-10 of top-20 | [new_bus_click_order_share_top10_of_top20.sql](references/new_bus_click_order_share_top10_of_top20.sql) |
| New Bus SL load rate and ASP | [new_bus_sl_load_rate_asp_top10_top20.sql](references/new_bus_sl_load_rate_asp_top10_top20.sql) |
| Click share, SRP-ranked top 10/20, no filter, top 100 SD | [click_share_srp_ranked_top10_20_nf_top100_sd.sql](references/click_share_srp_ranked_top10_20_nf_top100_sd.sql) |
| Order share, same universe | [order_share_srp_ranked_top10_20_nf_top100_sd.sql](references/order_share_srp_ranked_top10_20_nf_top100_sd.sql) |
| Click and order together | [click_order_share_srp_ranked_top10_20_nf_top100_sd.sql](references/click_order_share_srp_ranked_top10_20_nf_top100_sd.sql) |
| Click share top 10, no filter, top 100 SD | [click_share_top10_nf_top100_sd.sql](references/click_share_top10_nf_top100_sd.sql) |
| Top 10/20 route SL and txn share | [top10_top20_route_sl_txn_share_nf_top100_sd.sql](references/top10_top20_route_sl_txn_share_nf_top100_sd.sql) |
