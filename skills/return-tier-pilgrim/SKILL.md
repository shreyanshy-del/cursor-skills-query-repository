---
name: return-tier-pilgrim
description: >-
  redBus India return-trip, Mehar city-tier, and pilgrim-destination analytics
  for Android: forward funnel, 14-day reverse-route return, RB offer attach,
  high vs low pilgrim CR, intra vs inter-state, pilgrim circuits, and UPSRTC.
  Use when the user asks about return trip, city tier, Tier 1/2/3, pilgrim,
  leisure, Mehar listing, DBD return, or UPSRTC.
---

# Return trip, city tier, and pilgrim

Android IND. Run [`references/`](references/) on Data Platform / Iceberg. Change only date bounds. IST day start = previous day `18:30` UTC.

Confirmed ticket: `transaction.bus_ticket_events`, `country_code = 'IND'`, `event_type = 101`.

## Definitions

- **DBD** = DOJ − DOI. Buckets used in these files: 0, 1, 2, 3, 4, 5+.
- **user_type** = `search_details.user_type`.
- **Forward CR** = confirm sessions or TINs ÷ SRP sessions.
- **Return base** = users who **booked** A→B (onward transactors), not onward searchers.
- **Return search / book** = same user, reverse route B→A, within 14 days of the onward DOI (or DOJ when the file says DOJ).
- **Tiers** = Mehar listing in [`_city_tier_map_cte.sql`](references/_city_tier_map_cte.sql): explicit Tier 1, Tier 2, Pilgrim, Leisure. Residual `dest_id` is Tier 3. Do not rebuild this list. Swap-in id lists are `_dest_ids_*_cte.sql`.
- **Intra / inter** = source state vs destination state via `lis.config_locations.parent_location`, not pilgrim-to-pilgrim.
- **High vs low pilgrim** = destination labels `B_High` / `A_Low` inside the circuit SQL. Do not re-label cities.

Reference window for the FULL files: 24 Aug–6 Sep 2026 IST.

Three Downloads copies of Q1 (`OVERALL`, `BY_TIER`, `BY_TIER_USER`) were the same file. Same for Q3 DOI, Q3 DOJ, and Q4 OVERALL vs BY_TIER. This skill keeps one copy of each, under the `BY_TIER` name. Q2 OVERALL differs from Q2 BY_TIER; both are stored.

## Which file

| Ask | File |
|---|---|
| Forward funnel, tier × DBD × user_type | [Q1_FULL_funnel_throughput_14d_dbd_usertype_BY_TIER.sql](references/Q1_FULL_funnel_throughput_14d_dbd_usertype_BY_TIER.sql) |
| Short Q1 without the inlined city map | [Q1_funnel_throughput_14d_dbd_usertype.sql](references/Q1_funnel_throughput_14d_dbd_usertype.sql) |
| Return rate, base = onward bookers | [Q2_FULL_return_trip_onward_transactor_base_dbd_usertype_BY_TIER.sql](references/Q2_FULL_return_trip_onward_transactor_base_dbd_usertype_BY_TIER.sql), [OVERALL](references/Q2_FULL_return_trip_onward_transactor_base_dbd_usertype_OVERALL.sql) |
| Days since onward DOI | [Q3_FULL_days_since_onward_doi_return_session_txn_BY_TIER.sql](references/Q3_FULL_days_since_onward_doi_return_session_txn_BY_TIER.sql) |
| Days since onward DOJ | [Q3_FULL_days_since_onward_doj_return_session_txn_BY_TIER.sql](references/Q3_FULL_days_since_onward_doj_return_session_txn_BY_TIER.sql) |
| Return search D−14 to D+13 from DOJ | [Q3_FULL_return_search_days_since_doj_m14_to_p13_BY_TIER.sql](references/Q3_FULL_return_search_days_since_doj_m14_to_p13_BY_TIER.sql) |
| Platform / Pilgrim / Leisure return sections | [Q3_FULL_return_book_sections_doi_doj_post_Platform_Pilgrim_Leisure.sql](references/Q3_FULL_return_book_sections_doi_doj_post_Platform_Pilgrim_Leisure.sql), [search window](references/Q3_FULL_return_search_days_since_doj_m14_to_p13_Platform_Pilgrim_Leisure.sql) |
| DOI→DOJ (14d) vs post-DOJ (12d), 28d cohort | [Q3_FULL_return_sections_doi_to_doj_14d_post_doj_12d_28d_BY_TIER.sql](references/Q3_FULL_return_sections_doi_to_doj_14d_post_doj_12d_28d_BY_TIER.sql) |
| Return-trip funnel SRP→confirm | [Q4_FULL_return_trip_funnel_throughput_dbd_usertype_BY_TIER.sql](references/Q4_FULL_return_trip_funnel_throughput_dbd_usertype_BY_TIER.sql) |
| RB offer attach | [Q5_FULL_offer_attach_txn_dbd_usertype_BY_TIER.sql](references/Q5_FULL_offer_attach_txn_dbd_usertype_BY_TIER.sql) |
| Offer attach, seats > 3 | [Q6_FULL_offer_attach_txn_seats_gt3_dbd_usertype_BY_TIER.sql](references/Q6_FULL_offer_attach_txn_seats_gt3_dbd_usertype_BY_TIER.sql) |
| High vs low pilgrim × intra/inter state | [Q7_High_vs_Low_Pilgrim_Dest_CR_Intra_Inter_STATE.sql](references/Q7_High_vs_Low_Pilgrim_Dest_CR_Intra_Inter_STATE.sql), city grain [Q7b](references/Q7b_High_vs_Low_Pilgrim_Dest_CR_Intra_Inter_STATE_DEST.sql) |

### Offer attach (Q5 / Q6)

- **total_tins** = confirmed Android IND transactions
- **rb_offer_attach_success** = `payment_system` in (`RBOFFER`, `RB_SL_OFFER`) or offer-split amount > 0
- **rb_offer_attach_failed** = session `offer_response = FAILURE` and no RB offer on the ticket
- **rb_offer_attach** = success OR failed
- Q6 = Q5 with `COALESCE(seat_count,0) > 3`

### Pilgrim circuit and UPSRTC

| Ask | File |
|---|---|
| Pilgrim destination CR (8 cuts) | [pilgrim_dest_cr_8_queries.sql](references/pilgrim_dest_cr_8_queries.sql) |
| Pilgrim band CR | [pilgrim_band_cr_8_queries.sql](references/pilgrim_band_cr_8_queries.sql) |
| High vs low circuit behaviour | [pilgrim_circuit_behaviour_high_vs_low.sql](references/pilgrim_circuit_behaviour_high_vs_low.sql), [by dest](references/pilgrim_circuit_behaviour_by_dest.sql) |
| Circuit group A/B CR, top 10 SD | [pilgrim_circuit_group_ab_cr.sql](references/pilgrim_circuit_group_ab_cr.sql), [pilgrim_circuit_top10_sd.sql](references/pilgrim_circuit_top10_sd.sql), [pilgrim_top10_sd_cr.sql](references/pilgrim_top10_sd_cr.sql) |
| Circuit growth, inventory, DBD, user type | [OVERALL](references/pilgrim_circuit_growth_OVERALL_DBD_usertype_inventory_queries.sql), [by SD](references/pilgrim_circuit_growth_SD_DBD_usertype_inventory_queries.sql) |
| Varanasi / Ayodhya / Prayagraj funnels | [pilgrim_top_sd_pairs/](references/pilgrim_top_sd_pairs/) |
| UPSRTC operator 25946 | `UPSRTC_25946_*.sql`, [Jun–Aug high/low](references/UPSRTC_Pilgrim_HighLow_Guest_HeavyRBID_JunAug2026.sql) |
| UP pilgrim guest sessions | [IND_UP_UPPilgrim_Guest_Fraud_Android_Sessions_14d.sql](references/IND_UP_UPPilgrim_Guest_Fraud_Android_Sessions_14d.sql) |
| Forward SRP → return SRP in 14 days (Android/iOS, pilgrim `lis.city_tagging`) | [pilgrim_fwd_ret_srp_14d.sql](references/pilgrim_fwd_ret_srp_14d.sql), [\_pilgrim_fwd_ret_srp.sql](references/_pilgrim_fwd_ret_srp.sql) |
| Forward only | [\_pilgrim_fwd_only.sql](references/_pilgrim_fwd_only.sql) |
| Return users and sessions, variant on the return SRP | [pilgrim_return_reconciled_users_sessions.sql](references/pilgrim_return_reconciled_users_sessions.sql) |
| 23–26 Aug forward window | [\_pilgrim_23_26.sql](references/_pilgrim_23_26.sql), light scan [\_pilgrim_23_26_light.sql](references/_pilgrim_23_26_light.sql) |

On these forward/return files, forward dates are the static `date_params` window. The return window is 14 days from each forward session or TIN, not a second fixed calendar range. Pilgrim cities come from `lis.city_tagging` where `category = 'Pilgrim'`.

Short date-edit templates without the inlined map: `Q1_funnel_throughput_14d_dbd_usertype.sql`, `Q2_return_trip_rate_onward_transactor_base_dbd_usertype.sql`, `Q3_days_since_onward_doi_return_session_txn.sql`. Paste `dest_ids` from the matching `_dest_ids_*_cte.sql`.
