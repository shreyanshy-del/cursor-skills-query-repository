---
name: syed-athena-queries
description: >-
  Athena Saved Queries bank (160 Syed Product_B2C_Intl queries): Bus Images,
  Toilet/Safety, RTC funnels, Student/Primo, Cohort Deals, Connecting Services,
  Free Seats, Pilgrim/RTR, Discover Bharat Sale, behaviour loops, PriceVariantAB,
  NPS/UGC, payments. Use when user asks for a Syed Athena saved query, QUERY Syed N,
  or to re-run analysis SQL from this bank. Prefer references/*.sql verbatim;
  adjust only date params. Workgroup: Product_B2C_Intl.
---

# Syed Athena Queries

Athena **Product_B2C_Intl** saved-query bank exported from Syed's Athena library (160 queries).

**Source:** Amazon Athena Saved Queries (Asia Pacific Mumbai). SQL is Presto/Athena dialect over Iceberg-style catalogs (`user_interaction.*`, `transaction.*`, `lis.*`, `ugc.*`, etc.).

## How to use

1. Match the ask to a row in the **Index** (title / `#` / topic / Athena UUID).
2. Open the matching file under [`references/`](references/).
3. Change only date / params CTEs the user requests; keep other filters.
4. For confirmed bus tickets prefer `transaction.bus_ticket_events` with `event_type = 101` (and `event_class = 2` when the file already uses it). Default country **IND**.
5. Prefer **dataplatformCreateQuery** / **dataplatformExecuteIcebergQuery** for Iceberg runs; do not rewrite dialect unless asked.
6. Some exports may be drafts or partially commented — run as-is first; fix only if execution fails.

## Topics

- **Other** (27)
- **Cohort Deals** (14)
- **Pilgrim** (14)
- **Student / GenZ** (14)
- **Discover Bharat Sale** (11)
- **Funnel** (11)
- **RTC** (11)
- **Bus Images** (9)
- **Toilet / Safety** (7)
- **UGC / NPS** (6)
- **Price Variant AB** (5)
- **User Behaviour Loop** (5)
- **Click / Order Share** (4)
- **Connecting Services** (3)
- **Express Tag AB** (3)
- **Free Seats** (3)
- **LMB / Filters** (3)
- **Offers / RedDeal** (2)
- **RTR / Return** (2)
- **Train on Bus SRP** (2)
- **User Profiling** (2)
- **Airport / Location** (1)
- **Payments** (1)

**Totals:** 160 queries

## Index

| # | Title | Topic | File | Athena ID |
|---|-------|-------|------|-----------|
| 1 | Bus Images Overall Funnel - Syed | Bus Images | [Q001_bus_images_overall_funnel_4f514bb6.sql](references/Q001_bus_images_overall_funnel_4f514bb6.sql) | `4f514bb6-7be8-4113-8147-6c654e61b5cf` |
| 2 | Noida International Airport txns - Syed | Airport / Location | [Q002_noida_international_airport_txns_f36dc945.sql](references/Q002_noida_international_airport_txns_f36dc945.sql) | `f36dc945-bfe7-4689-a442-148315c3c491` |
| 3 | Top 500 Routes Student x Primo - Syed | Student / GenZ | [Q003_top_500_routes_student_x_primo_4aba18ae.sql](references/Q003_top_500_routes_student_x_primo_4aba18ae.sql) | `4aba18ae-493c-4620-8147-07ac0cd21571` |
| 4 | RTC Inventory - Syed | RTC | [Q004_rtc_inventory_2e615980.sql](references/Q004_rtc_inventory_2e615980.sql) | `2e615980-cc2a-49f5-b378-e3acc327bd85` |
| 5 | userhash from rbuserid - Syed | Other | [Q005_userhash_from_rbuserid_f9481674.sql](references/Q005_userhash_from_rbuserid_f9481674.sql) | `f9481674-f650-432c-80a8-35c6600118fa` |
| 6 | Toilet Dashboard - SL Coverage - Syed | Toilet / Safety | [Q006_toilet_dashboard_sl_coverage_c5004569.sql](references/Q006_toilet_dashboard_sl_coverage_c5004569.sql) | `c5004569-031b-4c7f-af17-8c63b75b7cb2` |
| 7 | Bus Images Dashboard Coverage Android and iOS- Syed | Bus Images | [Q007_bus_images_dashboard_coverage_android_and_ios_5a22988b.sql](references/Q007_bus_images_dashboard_coverage_android_and_ios_5a22988b.sql) | `5a22988b-5565-442a-9083-626e37fc1407` |
| 8 | Toilet Dashboard - Route_id Share - Syed | Toilet / Safety | [Q008_toilet_dashboard_route_id_share_f400e942.sql](references/Q008_toilet_dashboard_route_id_share_f400e942.sql) | `f400e942-2864-4e5a-b0d2-eec6ea248000` |
| 9 | RTC Funnel Throughput - Syed | RTC | [Q009_rtc_funnel_throughput_6f2ccd17.sql](references/Q009_rtc_funnel_throughput_6f2ccd17.sql) | `6f2ccd17-758e-4d5f-b77c-7f3bfad910f2` |
| 10 | Toilet Dashboard - Txn Coverage - Syed | Toilet / Safety | [Q010_toilet_dashboard_txn_coverage_b940995f.sql](references/Q010_toilet_dashboard_txn_coverage_b940995f.sql) | `b940995f-4c86-49f8-9909-dd733584de85` |
| 11 | RTC AC Sort SD Level Txns - Syed | RTC | [Q011_rtc_ac_sort_sd_level_txns_72f74ae5.sql](references/Q011_rtc_ac_sort_sd_level_txns_72f74ae5.sql) | `72f74ae5-a92f-4ad0-929f-b96834804fc3` |
| 12 | Primo Student Data - Syed | Student / GenZ | [Q012_primo_student_data_41d5b13b.sql](references/Q012_primo_student_data_41d5b13b.sql) | `41d5b13b-8d34-4012-b2fb-0a7bce0b180a` |
| 13 | Connecting Services Transactions - Syed | Connecting Services | [Q013_connecting_services_transactions_b7d38b17.sql](references/Q013_connecting_services_transactions_b7d38b17.sql) | `b7d38b17-d69d-47ee-9a4f-a7f4c8e2337f` |
| 14 | UGC Rating vs Return Behavior - Syed | UGC / NPS | [Q014_ugc_rating_vs_return_behavior_0e6902e5.sql](references/Q014_ugc_rating_vs_return_behavior_0e6902e5.sql) | `0e6902e5-563d-4de5-966c-f782754d564b` |
| 15 | RTC ASP - Syed | RTC | [Q015_rtc_asp_b4d5bfc8.sql](references/Q015_rtc_asp_b4d5bfc8.sql) | `b4d5bfc8-6f94-438e-9e79-e3906c17446d` |
| 16 | UGC Rating vs Return Behavior - Syed | UGC / NPS | [Q016_ugc_rating_vs_return_behavior_f4d21457.sql](references/Q016_ugc_rating_vs_return_behavior_f4d21457.sql) | `f4d21457-8256-4770-a182-0529f37f563b` |
| 17 | User Profiling RUM - Syed | User Profiling | [Q017_user_profiling_rum_90a320f8.sql](references/Q017_user_profiling_rum_90a320f8.sql) | `90a320f8-7662-447d-a8ab-8a1850c0d12e` |
| 18 | UGC Rating vs Return Behavior - Syed | UGC / NPS | [Q018_ugc_rating_vs_return_behavior_a8f1780e.sql](references/Q018_ugc_rating_vs_return_behavior_a8f1780e.sql) | `a8f1780e-6519-4fb4-bce7-c37a0276fb91` |
| 19 | New Bus Tag - Syed | Other | [Q019_new_bus_tag_d4b665d5.sql](references/Q019_new_bus_tag_d4b665d5.sql) | `d4b665d5-01cb-4741-8055-4e783935ab64` |
| 20 | Toilet tag Coverage History Data - Syed | Toilet / Safety | [Q020_toilet_tag_coverage_history_data_53668b14.sql](references/Q020_toilet_tag_coverage_history_data_53668b14.sql) | `53668b14-bf20-4919-976b-23f080142255` |
| 21 | GDS wise Toilet Coverage - Syed | Toilet / Safety | [Q021_gds_wise_toilet_coverage_2b662df5.sql](references/Q021_gds_wise_toilet_coverage_2b662df5.sql) | `2b662df5-2c32-4683-97ba-cc3f200c7a29` |
| 22 | User Profiling Perz - Syed | User Profiling | [Q022_user_profiling_perz_09003dbe.sql](references/Q022_user_profiling_perz_09003dbe.sql) | `09003dbe-e3f5-432c-aef1-1882dda853a6` |
| 23 | Payment Method / UPI Txn Share - Syed | Payments | [Q023_payment_method_upi_txn_share_a0ceccb4.sql](references/Q023_payment_method_upi_txn_share_a0ceccb4.sql) | `a0ceccb4-f53c-41f4-8cac-683d4b991f27` |
| 24 | Toilet tag Coverage History Data Overall - Syed | Toilet / Safety | [Q024_toilet_tag_coverage_history_data_overall_13301aa7.sql](references/Q024_toilet_tag_coverage_history_data_overall_13301aa7.sql) | `13301aa7-636e-488c-bfc4-6b3ea3d65a7b` |
| 25 | Student same routeid multiple txns - Syed | Student / GenZ | [Q025_student_same_routeid_multiple_txns_beebd356.sql](references/Q025_student_same_routeid_multiple_txns_beebd356.sql) | `beebd356-ff5c-475a-8a8f-bfab48fd40b0` |
| 26 | RTC AC Sort Click and Order Share - Syed | RTC | [Q026_rtc_ac_sort_click_and_order_share_a7e5a231.sql](references/Q026_rtc_ac_sort_click_and_order_share_a7e5a231.sql) | `a7e5a231-ae2a-46a0-8580-17a55bbbc752` |
| 27 | Offer Attach for BO Offers - Syed | Offers / RedDeal | [Q027_offer_attach_for_bo_offers_1180f37b.sql](references/Q027_offer_attach_for_bo_offers_1180f37b.sql) | `1180f37b-746e-442b-9d38-c5ec4f3f0a55` |
| 28 | Bus Images Funnel - Syed | Bus Images | [Q028_bus_images_funnel_93170133.sql](references/Q028_bus_images_funnel_93170133.sql) | `93170133-2146-4348-84d3-7289136c4cb2` |
| 29 | Offer status wise NPS - Syed | UGC / NPS | [Q029_offer_status_wise_nps_78180329.sql](references/Q029_offer_status_wise_nps_78180329.sql) | `78180329-bc0c-4945-a7e6-b63f2899cf81` |
| 30 | avg_distinct_buses_clicked_before_txn - Syed | Other | [Q030_avg_distinct_buses_clicked_before_txn_cd1a4158.sql](references/Q030_avg_distinct_buses_clicked_before_txn_cd1a4158.sql) | `cd1a4158-0d68-4c72-8a0f-1213ab9bb7ed` |
| 31 | Users who saw connecting Services - Syed | Connecting Services | [Q031_users_who_saw_connecting_services_8743b4fa.sql](references/Q031_users_who_saw_connecting_services_8743b4fa.sql) | `8743b4fa-c1ea-4cd4-85ba-84f92cdd73b8` |
| 32 | Free Seat Data - Syed | Free Seats | [Q032_free_seat_data_8ba86db7.sql](references/Q032_free_seat_data_8ba86db7.sql) | `8ba86db7-dd78-40c1-80ad-ac71973596d5` |
| 33 | Students Funnel who saw student Card - Syed | Student / GenZ | [Q033_students_funnel_who_saw_student_card_0ab584cb.sql](references/Q033_students_funnel_who_saw_student_card_0ab584cb.sql) | `0ab584cb-051d-49bf-b236-15e5b2087a2c` |
| 34 | Bus Images Dashboard Engagement - Syed | Bus Images | [Q034_bus_images_dashboard_engagement_1b9ab1fe.sql](references/Q034_bus_images_dashboard_engagement_1b9ab1fe.sql) | `1b9ab1fe-9078-47ad-9a9c-a72be13e88f1` |
| 35 | Free Seats RTC_Pvt Funnel - Syed | RTC | [Q035_free_seats_rtc_pvt_funnel_952f0460.sql](references/Q035_free_seats_rtc_pvt_funnel_952f0460.sql) | `952f0460-c869-4558-9670-4607725dba6a` |
| 36 | Free Seat Pvt seats - Syed | Free Seats | [Q036_free_seat_pvt_seats_7b3d4b67.sql](references/Q036_free_seat_pvt_seats_7b3d4b67.sql) | `7b3d4b67-69d9-4ced-9d40-27bc39b2f156` |
| 37 | Toilet and Safety Dashboard - Syed | Toilet / Safety | [Q037_toilet_and_safety_dashboard_289c4f7e.sql](references/Q037_toilet_and_safety_dashboard_289c4f7e.sql) | `289c4f7e-de5d-4084-a55a-e8fc341df8e1` |
| 38 | Bus Images Dashboard NPS - Syed | Bus Images | [Q038_bus_images_dashboard_nps_1012d1d9.sql](references/Q038_bus_images_dashboard_nps_1012d1d9.sql) | `1012d1d9-261d-44fd-8359-cdaf172ed9f5` |
| 39 | Bus Images Dashboard Pre Funnel - Syed | Bus Images | [Q039_bus_images_dashboard_pre_funnel_7f0a52af.sql](references/Q039_bus_images_dashboard_pre_funnel_7f0a52af.sql) | `7f0a52af-e21c-4002-b4c2-010fd6191eab` |
| 40 | Free Seat Data at Seat level - Syed | Free Seats | [Q040_free_seat_data_at_seat_level_e81ec85a.sql](references/Q040_free_seat_data_at_seat_level_e81ec85a.sql) | `e81ec85a-1e20-4503-8445-3a86e7a97fd9` |
| 41 | Bus Images Unique routeids - Syed | Bus Images | [Q041_bus_images_unique_routeids_5f96461b.sql](references/Q041_bus_images_unique_routeids_5f96461b.sql) | `5f96461b-dc38-4ea1-b409-c5a4fb2f8c04` |
| 42 | Students Funnel of <24 yo users with split of who saw student Card - Syed | Student / GenZ | [Q042_students_funnel_of_24_yo_users_with_split_of_who_saw_student_card_059e5457.sql](references/Q042_students_funnel_of_24_yo_users_with_split_of_who_saw_student_card_059e5457.sql) | `059e5457-5a5a-44c0-89ec-e22b60e6ccc6` |
| 43 | Bus Images Dashboard Current Coverage - Syed | Bus Images | [Q043_bus_images_dashboard_current_coverage_66233995.sql](references/Q043_bus_images_dashboard_current_coverage_66233995.sql) | `66233995-6271-4327-acc4-f0e03541867e` |
| 44 | Bus Images Dashboard Engagement - Syed | Bus Images | [Q044_bus_images_dashboard_engagement_71fc39d2.sql](references/Q044_bus_images_dashboard_engagement_71fc39d2.sql) | `71fc39d2-7a34-469a-938d-c4a6c51d9126` |
| 45 | Connecting Services Searched and Transacted Users - Syed | Connecting Services | [Q045_connecting_services_searched_and_transacted_users_3a3fbaa8.sql](references/Q045_connecting_services_searched_and_transacted_users_3a3fbaa8.sql) | `3a3fbaa8-6d97-4406-82ea-b3e5e55dd464` |
| 46 | Cohorted deal final metrics CTR CR - Syed | Cohort Deals | [Q046_cohorted_deal_final_metrics_ctr_cr_13514a19.sql](references/Q046_cohorted_deal_final_metrics_ctr_cr_13514a19.sql) | `13514a19-0366-44c9-a037-f1b6e1b4a5d7` |
| 47 | Student redeemed transactions Raw - Syed | Student / GenZ | [Q047_student_redeemed_transactions_raw_0c525869.sql](references/Q047_student_redeemed_transactions_raw_0c525869.sql) | `0c525869-3e2e-4a17-8dee-b41d58328a72` |
| 48 | Train CTR - Syed | Train on Bus SRP | [Q048_train_ctr_dd878989.sql](references/Q048_train_ctr_dd878989.sql) | `dd878989-1fe8-400a-85db-10a8a6814430` |
| 49 | API events Check - Syed | Other | [Q049_api_events_check_129f5ccb.sql](references/Q049_api_events_check_129f5ccb.sql) | `129f5ccb-1152-44e8-abe8-185f694d7d2b` |
| 50 | Student Funnel revised - Syed | Student / GenZ | [Q050_student_funnel_revised_4fde201c.sql](references/Q050_student_funnel_revised_4fde201c.sql) | `4fde201c-1d13-42bf-a9d2-4ea16d7be830` |
| 51 | Cohorted deal final metrics Click and order share - Syed | Cohort Deals | [Q051_cohorted_deal_final_metrics_click_and_order_share_f061b304.sql](references/Q051_cohorted_deal_final_metrics_click_and_order_share_f061b304.sql) | `f061b304-3059-49d8-9eca-a6722944f684` |
| 52 | Group Deal Transactions - Syed | Other | [Q052_group_deal_transactions_8771063b.sql](references/Q052_group_deal_transactions_8771063b.sql) | `8771063b-9dcf-475f-a838-07aad7e27a14` |
| 53 | Cohort Deals Final Metrics - Syed | Cohort Deals | [Q053_cohort_deals_final_metrics_12886c66.sql](references/Q053_cohort_deals_final_metrics_12886c66.sql) | `12886c66-1516-48ff-b4e3-e0c9cb23b7f3` |
| 54 | Cohort_deals route ids clicked - Syed | Cohort Deals | [Q054_cohort_deals_route_ids_clicked_756df98c.sql](references/Q054_cohort_deals_route_ids_clicked_756df98c.sql) | `756df98c-5375-4cd8-b6d1-a77c02e64d1c` |
| 55 | Students who saw student Card - Syed | Student / GenZ | [Q055_students_who_saw_student_card_24876601.sql](references/Q055_students_who_saw_student_card_24876601.sql) | `24876601-4742-428c-82f3-df969253b4d2` |
| 56 | Cohort Deals Organic order share of boosted listings - Syed | Cohort Deals | [Q056_cohort_deals_organic_order_share_of_boosted_listings_268b4cb2.sql](references/Q056_cohort_deals_organic_order_share_of_boosted_listings_268b4cb2.sql) | `268b4cb2-705d-4a33-81e7-2f798e246e7c` |
| 57 | Click Share Debayan - Syed | Click / Order Share | [Q057_click_share_debayan_08768b9b.sql](references/Q057_click_share_debayan_08768b9b.sql) | `08768b9b-c415-4d51-99b1-55badf08a798` |
| 58 | Cohorted Deal Order and Click Share Final - Syed | Cohort Deals | [Q058_cohorted_deal_order_and_click_share_final_d68afc5e.sql](references/Q058_cohorted_deal_order_and_click_share_final_d68afc5e.sql) | `d68afc5e-7239-46ef-9c20-b361a94d9e02` |
| 59 | Cohort Deals Organic click share of boosted listings - Syed | Cohort Deals | [Q059_cohort_deals_organic_click_share_of_boosted_listings_022c8af1.sql](references/Q059_cohort_deals_organic_click_share_of_boosted_listings_022c8af1.sql) | `022c8af1-dbb6-4d20-b33d-069738d9004d` |
| 60 | Order Share Debayan - Syed | Click / Order Share | [Q060_order_share_debayan_ea7162ea.sql](references/Q060_order_share_debayan_ea7162ea.sql) | `ea7162ea-c65c-4892-b258-21cf621494f0` |
| 61 | Student Viewed Throughput - Syed | Student / GenZ | [Q061_student_viewed_throughput_ff1f91de.sql](references/Q061_student_viewed_throughput_ff1f91de.sql) | `ff1f91de-c1b3-433a-be40-0d65ddfa079f` |
| 62 | User Behaviour Loop Funnel UI - Syed | User Behaviour Loop | [Q062_user_behaviour_loop_funnel_ui_d0c5efcf.sql](references/Q062_user_behaviour_loop_funnel_ui_d0c5efcf.sql) | `d0c5efcf-90f6-4820-996a-6e48ca8da29b` |
| 63 | Train Section seen on SRP - Syed | Train on Bus SRP | [Q063_train_section_seen_on_srp_4eaf1e03.sql](references/Q063_train_section_seen_on_srp_4eaf1e03.sql) | `4eaf1e03-2cf6-4a4b-a7ca-4a61c4790cc1` |
| 64 | Cohorted Deals Numerator_denominator - Syed | Cohort Deals | [Q064_cohorted_deals_numerator_denominator_bd890d88.sql](references/Q064_cohorted_deals_numerator_denominator_bd890d88.sql) | `bd890d88-cb8c-4cde-a90d-4c9228225d3a` |
| 65 | User Behaviour Loop Deeper Funnel API - Syed | User Behaviour Loop | [Q065_user_behaviour_loop_deeper_funnel_api_6cd7fc43.sql](references/Q065_user_behaviour_loop_deeper_funnel_api_6cd7fc43.sql) | `6cd7fc43-3186-4769-9217-68754fc21ba9` |
| 66 | Student - Users under 24 YO - Syed | Student / GenZ | [Q066_student_users_under_24_yo_0b1e1974.sql](references/Q066_student_users_under_24_yo_0b1e1974.sql) | `0b1e1974-5922-41a5-916f-78a3f8dccda3` |
| 67 | Students who clicked on Share - Syed | Student / GenZ | [Q067_students_who_clicked_on_share_e31f72b3.sql](references/Q067_students_who_clicked_on_share_e31f72b3.sql) | `e31f72b3-a8a9-41f9-bd97-2ccc92f19c1c` |
| 68 | Cohort deals routeid wise CS OS - Syed | Cohort Deals | [Q068_cohort_deals_routeid_wise_cs_os_9dcb7add.sql](references/Q068_cohort_deals_routeid_wise_cs_os_9dcb7add.sql) | `9dcb7add-b3ac-4485-bf6a-55c5a5d21625` |
| 69 | User Behaviour Loop Funnel API - Syed | User Behaviour Loop | [Q069_user_behaviour_loop_funnel_api_8aa89fd2.sql](references/Q069_user_behaviour_loop_funnel_api_8aa89fd2.sql) | `8aa89fd2-6379-4f08-8bbf-3cf91d5380a1` |
| 70 | SL Visit Frequency wise conversion - Syed | Other | [Q070_sl_visit_frequency_wise_conversion_b12c9048.sql](references/Q070_sl_visit_frequency_wise_conversion_b12c9048.sql) | `b12c9048-5496-4f83-8864-8025cf076a12` |
| 71 | User Funnel Behaviour Same Route Back Seat - Syed | User Behaviour Loop | [Q071_user_funnel_behaviour_same_route_back_seat_0d63ce65.sql](references/Q071_user_funnel_behaviour_same_route_back_seat_0d63ce65.sql) | `0d63ce65-837f-48d3-abd5-4c31e2bbe268` |
| 72 | User Behaviour Loop Deeper Funnel UI - Syed | User Behaviour Loop | [Q072_user_behaviour_loop_deeper_funnel_ui_ab8090ee.sql](references/Q072_user_behaviour_loop_deeper_funnel_ui_ab8090ee.sql) | `ab8090ee-f9dd-4dec-b2a8-0dc53d86f89a` |
| 73 | COHORT_DEALS Click and Order Share - Syed | Cohort Deals | [Q073_cohort_deals_click_and_order_share_e41872e0.sql](references/Q073_cohort_deals_click_and_order_share_e41872e0.sql) | `e41872e0-e3b3-4199-bd09-92e79952797f` |
| 74 | Mutiple txn sessions - Syed | Other | [Q074_mutiple_txn_sessions_5835a864.sql](references/Q074_mutiple_txn_sessions_5835a864.sql) | `5835a864-8a92-4c33-851e-93c6a5e28193` |
| 75 | Pilgrim BP DP Search events - Syed | Pilgrim | [Q075_pilgrim_bp_dp_search_events_743cce61.sql](references/Q075_pilgrim_bp_dp_search_events_743cce61.sql) | `743cce61-8b65-4f7e-a04e-efe7700a2a9c` |
| 76 | Events test / Check - Syed | Other | [Q076_events_test_check_d87eef7b.sql](references/Q076_events_test_check_d87eef7b.sql) | `d87eef7b-cacb-4d86-bb7b-de421df00e1b` |
| 77 | Students AB Events Funnel - Syed | Student / GenZ | [Q077_students_ab_events_funnel_eaaf06fc.sql](references/Q077_students_ab_events_funnel_eaaf06fc.sql) | `eaaf06fc-d6ef-4911-8080-ee3c7b908f48` |
| 78 | iOS COHORT DEALS SRP AB Funnel - Syed | Cohort Deals | [Q078_ios_cohort_deals_srp_ab_funnel_c854b6e5.sql](references/Q078_ios_cohort_deals_srp_ab_funnel_c854b6e5.sql) | `c854b6e5-0bce-46ed-80e6-7770857dac8e` |
| 79 | COHORTED Deals Debugging - Syed | Cohort Deals | [Q079_cohorted_deals_debugging_0467a581.sql](references/Q079_cohorted_deals_debugging_0467a581.sql) | `0467a581-ed67-4429-bda1-ee475c329823` |
| 80 | Price Variant AB - Closed loop funnel - Cursor - Syed | Price Variant AB | [Q080_price_variant_ab_closed_loop_funnel_cursor_5d27bb9f.sql](references/Q080_price_variant_ab_closed_loop_funnel_cursor_5d27bb9f.sql) | `5d27bb9f-ed36-4ef6-bee6-d04e510ddeff` |
| 81 | priceVariantAB Funnel - Syed | Price Variant AB | [Q081_pricevariantab_funnel_5c9dea6a.sql](references/Q081_pricevariantab_funnel_5c9dea6a.sql) | `5c9dea6a-62ee-42e2-92c9-2b7c5dac32cc` |
| 82 | PayLoad Instances - Syed | Other | [Q082_payload_instances_aee3c872.sql](references/Q082_payload_instances_aee3c872.sql) | `aee3c872-d79e-4c13-9385-6bc834cc3671` |
| 83 | COHORTED DEALS SL Land Open Conversion - Syed | Cohort Deals | [Q083_cohorted_deals_sl_land_open_conversion_ede591f2.sql](references/Q083_cohorted_deals_sl_land_open_conversion_ede591f2.sql) | `ede591f2-2442-4831-8b7f-2fb2c0e08187` |
| 84 | India Bus Platform Funnel - Syed | Funnel | [Q084_india_bus_platform_funnel_43a35ec9.sql](references/Q084_india_bus_platform_funnel_43a35ec9.sql) | `43a35ec9-1f44-4154-935a-27d74eddf3ee` |
| 85 | AB Exp Funnel - Syed priceVariantAB | Price Variant AB | [Q085_ab_exp_funnel_53d6387c.sql](references/Q085_ab_exp_funnel_53d6387c.sql) | `53d6387c-dc29-49e1-88c7-285d982b0715` |
| 86 | Loop Funnel Seat Unblock main - Syed | Funnel | [Q086_loop_funnel_seat_unblock_main_9e432697.sql](references/Q086_loop_funnel_seat_unblock_main_9e432697.sql) | `9e432697-22d0-4107-ad86-996d1f2e5dbd` |
| 87 | Click Share Order Share - Syed | Click / Order Share | [Q087_click_share_order_share_13dd84ef.sql](references/Q087_click_share_order_share_13dd84ef.sql) | `13dd84ef-95a8-4916-a729-4a624ce3c6de` |
| 88 | Event Flow Check - Syed | Other | [Q088_event_flow_check_64c09b78.sql](references/Q088_event_flow_check_64c09b78.sql) | `64c09b78-efcb-4eed-a4d9-1d90f27b3229` |
| 89 | LMB_FILTER_BP AB Mumbai Funnel - Syed | LMB / Filters | [Q089_lmb_filter_bp_ab_mumbai_funnel_f1ceb6e5.sql](references/Q089_lmb_filter_bp_ab_mumbai_funnel_f1ceb6e5.sql) | `f1ceb6e5-10cd-4ede-8a62-d81e6c10d890` |
| 90 | LMB_FILTER_BP AB Mumbai Events- Syed | LMB / Filters | [Q090_lmb_filter_bp_ab_mumbai_events_37ee398e.sql](references/Q090_lmb_filter_bp_ab_mumbai_events_37ee398e.sql) | `37ee398e-d9c6-4359-97fe-db9cb3e0f087` |
| 91 | Price Variant AB - Closed loop funnel - Gemini - Syed | Price Variant AB | [Q091_price_variant_ab_closed_loop_funnel_gemini_2fb8daf8.sql](references/Q091_price_variant_ab_closed_loop_funnel_gemini_2fb8daf8.sql) | `2fb8daf8-890a-4c18-b210-3c8d1478ee09` |
| 92 | LMB_FILTER_BP AB Mumbai Event Funnel - Syed | LMB / Filters | [Q092_lmb_filter_bp_ab_mumbai_event_funnel_8f66084f.sql](references/Q092_lmb_filter_bp_ab_mumbai_event_funnel_8f66084f.sql) | `8f66084f-fe5b-41a8-b420-47aeefa40f38` |
| 93 | Seat Block feature loop Funnel without SRP - Syed check | Funnel | [Q093_seat_block_feature_loop_funnel_without_srp_1e6fbeb3.sql](references/Q093_seat_block_feature_loop_funnel_without_srp_1e6fbeb3.sql) | `1e6fbeb3-d483-4e16-809e-3e70e88f5fc7` |
| 94 | Student Group Transactions - Syed | Student / GenZ | [Q094_student_group_transactions_4bcca521.sql](references/Q094_student_group_transactions_4bcca521.sql) | `4bcca521-1089-49ee-b718-e786540cda88` |
| 95 | iOS COHORT DEALS SRP AB redDeal attach % - Syed | Cohort Deals | [Q095_ios_cohort_deals_srp_ab_reddeal_attach_d30f9bc4.sql](references/Q095_ios_cohort_deals_srp_ab_reddeal_attach_d30f9bc4.sql) | `d30f9bc4-158e-46a9-84d8-85b266633a59` |
| 96 | Data Check & Test - Syed | Other | [Q096_data_check_test_988780d0.sql](references/Q096_data_check_test_988780d0.sql) | `988780d0-5803-483f-ad18-1de8c667b07e` |
| 97 | priceVariantAB Median SL Visits - Syed | Price Variant AB | [Q097_pricevariantab_median_sl_visits_41a37282.sql](references/Q097_pricevariantab_median_sl_visits_41a37282.sql) | `41a37282-e1ad-4d34-b537-bb2f5e8e7bc1` |
| 98 | MH vs India Funnel Overall - Syed | Funnel | [Q098_mh_vs_india_funnel_overall_8483ead6.sql](references/Q098_mh_vs_india_funnel_overall_8483ead6.sql) | `8483ead6-0355-4b30-9f4a-9b6d7dd90cc9` |
| 99 | RTC Hourly CR - Syed | RTC | [Q099_rtc_hourly_cr_8e4fd6f7.sql](references/Q099_rtc_hourly_cr_8e4fd6f7.sql) | `8e4fd6f7-a619-467d-9935-4901a8ab622e` |
| 100 | Pilgrim travellers on redBus - Syed | Pilgrim | [Q100_pilgrim_travellers_on_redbus_dbc1b59d.sql](references/Q100_pilgrim_travellers_on_redbus_dbc1b59d.sql) | `dbc1b59d-3d0b-4917-bcfe-49026a18adb5` |
| 101 | Pilgrim searched and dropped off - Syed | Pilgrim | [Q101_pilgrim_searched_and_dropped_off_ee753209.sql](references/Q101_pilgrim_searched_and_dropped_off_ee753209.sql) | `ee753209-2b6a-461a-97ff-046eb6cb5a28` |
| 102 | Check - Syed | Other | [Q102_check_df554fb6.sql](references/Q102_check_df554fb6.sql) | `df554fb6-421e-42c8-a9b0-0d5bc21f3274` |
| 103 | Priya Leisure pilgrim gap analysis - Syed | Pilgrim | [Q103_priya_leisure_pilgrim_gap_analysis_c83dc690.sql](references/Q103_priya_leisure_pilgrim_gap_analysis_c83dc690.sql) | `c83dc690-57a3-4958-b381-88561986f17e` |
| 104 | NPS Variant wise Correct - Syed | UGC / NPS | [Q104_nps_variant_wise_correct_e655de17.sql](references/Q104_nps_variant_wise_correct_e655de17.sql) | `e655de17-caee-44c7-bf83-8ecef4a37122` |
| 105 | Overlapping BP DP events - Syed | Other | [Q105_overlapping_bp_dp_events_8563f349.sql](references/Q105_overlapping_bp_dp_events_8563f349.sql) | `8563f349-a7db-4838-9177-017daa42c340` |
| 106 | Seat Block feature loop Funnel without SRP - Syed | Funnel | [Q106_seat_block_feature_loop_funnel_without_srp_9c7240a5.sql](references/Q106_seat_block_feature_loop_funnel_without_srp_9c7240a5.sql) | `9c7240a5-98fc-4e49-9397-5914c9bdd3e2` |
| 107 | Students AB Events check - Syed | Student / GenZ | [Q107_students_ab_events_check_c2f142bc.sql](references/Q107_students_ab_events_check_c2f142bc.sql) | `c2f142bc-a00a-4234-a259-ab35b0f43804` |
| 108 | Pilgrim User Analysis Seat per Txn- Syed | Pilgrim | [Q108_pilgrim_user_analysis_seat_per_txn_eae52c64.sql](references/Q108_pilgrim_user_analysis_seat_per_txn_eae52c64.sql) | `eae52c64-e7dd-4367-83c8-0d08992053e1` |
| 109 | Overlapping BP DP Throughput - Syed | Other | [Q109_overlapping_bp_dp_throughput_446ebdc5.sql](references/Q109_overlapping_bp_dp_throughput_446ebdc5.sql) | `446ebdc5-4e42-42e1-9e6f-2069c14591df` |
| 110 | Atul Pilgrim non pilgrim - Syed | Pilgrim | [Q110_atul_pilgrim_non_pilgrim_ba29f600.sql](references/Q110_atul_pilgrim_non_pilgrim_ba29f600.sql) | `ba29f600-c861-41c9-a8a0-3ae3a97c678f` |
| 111 | Pilgrim BP DP Search Funnel - Syed | Pilgrim | [Q111_pilgrim_bp_dp_search_funnel_952c6b65.sql](references/Q111_pilgrim_bp_dp_search_funnel_952c6b65.sql) | `952c6b65-d75d-4531-ac9b-2ab9aac76bc5` |
| 112 | users search for return trip Optimized rolling window - Pilgrim - Syed | Pilgrim | [Q112_users_search_for_return_trip_optimized_rolling_window_pilgrim_e589b93d.sql](references/Q112_users_search_for_return_trip_optimized_rolling_window_pilgrim_e589b93d.sql) | `e589b93d-a689-4844-be7b-2e91d4587895` |
| 113 | Seat Block feature loop Funnel - Syed | Funnel | [Q113_seat_block_feature_loop_funnel_26263de6.sql](references/Q113_seat_block_feature_loop_funnel_26263de6.sql) | `26263de6-0e41-4498-8fd3-831daefdc4eb` |
| 114 | RTR trx share and Return Search Optimized - Syed | RTR / Return | [Q114_rtr_trx_share_and_return_search_optimized_5cbeb12c.sql](references/Q114_rtr_trx_share_and_return_search_optimized_5cbeb12c.sql) | `5cbeb12c-4d7c-4ae4-af03-94729f013cd9` |
| 115 | Reddeal opt in phase 2 - Syed | Offers / RedDeal | [Q115_reddeal_opt_in_phase_2_6fa05540.sql](references/Q115_reddeal_opt_in_phase_2_6fa05540.sql) | `6fa05540-497d-4757-a6d9-3c30c2ab7429` |
| 116 | Pilgrim BP DP Impact - Syed | Pilgrim | [Q116_pilgrim_bp_dp_impact_799e0bcf.sql](references/Q116_pilgrim_bp_dp_impact_799e0bcf.sql) | `799e0bcf-952f-4426-ad71-07f326eb7771` |
| 117 | Tier 3 Route wise Inv_Traffic_Transactions - Syed | Other | [Q117_tier_3_route_wise_inv_traffic_transactions_ac9eaf34.sql](references/Q117_tier_3_route_wise_inv_traffic_transactions_ac9eaf34.sql) | `ac9eaf34-2ccd-4a81-845b-97bb5527bb7c` |
| 118 | Monthly Searches and Txn RoutePass Active routes - Syed | Other | [Q118_monthly_searches_and_txn_routepass_active_routes_d1d22505.sql](references/Q118_monthly_searches_and_txn_routepass_active_routes_d1d22505.sql) | `d1d22505-965a-4946-a6cf-ba0eaa49afe2` |
| 119 | New User % DBS - Syed | Discover Bharat Sale | [Q119_new_user_dbs_308418f4.sql](references/Q119_new_user_dbs_308418f4.sql) | `308418f4-7e1c-452a-9b62-861f7d9f2823` |
| 120 | 1 or 2 character name Tins - Syed | Other | [Q120_1_or_2_character_name_tins_3e4d0f67.sql](references/Q120_1_or_2_character_name_tins_3e4d0f67.sql) | `3e4d0f67-ae0d-4ee0-a611-2f8e3772ca0c` |
| 121 | RTC Impact by DBS - Syed | RTC | [Q121_rtc_impact_by_dbs_e730fd42.sql](references/Q121_rtc_impact_by_dbs_e730fd42.sql) | `e730fd42-8a64-47b1-bfef-51efc259beb4` |
| 122 | RTC AB Funnel Query - Syed | RTC | [Q122_rtc_ab_funnel_query_9b233c31.sql](references/Q122_rtc_ab_funnel_query_9b233c31.sql) | `9b233c31-2475-471f-9b08-6099ddb1c671` |
| 123 | NPS Correct - Syed | UGC / NPS | [Q123_nps_correct_20823245.sql](references/Q123_nps_correct_20823245.sql) | `20823245-df26-4718-a24f-0f57b4269593` |
| 124 | Back click holistic - Syed | Other | [Q124_back_click_holistic_f4402321.sql](references/Q124_back_click_holistic_f4402321.sql) | `f4402321-02f0-40f5-a09d-f6d5d287b4f1` |
| 125 | Back button click and converted DBS - Syed | Discover Bharat Sale | [Q125_back_button_click_and_converted_dbs_61a056e1.sql](references/Q125_back_button_click_and_converted_dbs_61a056e1.sql) | `61a056e1-697a-429f-b92e-5c6f1a49859f` |
| 126 | Discover Bharat Sales Funnel with DBD cut - Syed | Discover Bharat Sale | [Q126_discover_bharat_sales_funnel_with_dbd_cut_d6b2ec5c.sql](references/Q126_discover_bharat_sales_funnel_with_dbd_cut_d6b2ec5c.sql) | `d6b2ec5c-da51-49b5-a2d5-ae4710317b2a` |
| 127 | DBS Impressions - Syed | Discover Bharat Sale | [Q127_dbs_impressions_6148bcd4.sql](references/Q127_dbs_impressions_6148bcd4.sql) | `6148bcd4-f4eb-4d27-8e90-82708b6a74fc` |
| 128 | Transaction Distribution wrt Ratings - Syed | Other | [Q128_transaction_distribution_wrt_ratings_e6041020.sql](references/Q128_transaction_distribution_wrt_ratings_e6041020.sql) | `e6041020-ea7d-498b-9347-77bb9ec975d8` |
| 129 | Route wise Funnel with DBD - Syed | Funnel | [Q129_route_wise_funnel_with_dbd_a905a86a.sql](references/Q129_route_wise_funnel_with_dbd_a905a86a.sql) | `a905a86a-4959-4a2e-baaf-ea219bd63ff3` |
| 130 | RTC Funnel Rollup - Syed | RTC | [Q130_rtc_funnel_rollup_02a809fd.sql](references/Q130_rtc_funnel_rollup_02a809fd.sql) | `02a809fd-5de2-4d5b-b938-365033c97373` |
| 131 | SameDay vs Same hour bookings - Syed | Other | [Q131_sameday_vs_same_hour_bookings_fe9fdc1f.sql](references/Q131_sameday_vs_same_hour_bookings_fe9fdc1f.sql) | `fe9fdc1f-58f9-43b0-9a21-e03d4ad3afea` |
| 132 | Departure sort % - Syed | Other | [Q132_departure_sort_0c217606.sql](references/Q132_departure_sort_0c217606.sql) | `0c217606-349d-4452-808d-7eed205a34a7` |
| 133 | Target Discover Bharat Sales Funnel - Syed | Discover Bharat Sale | [Q133_target_discover_bharat_sales_funnel_2e3c298e.sql](references/Q133_target_discover_bharat_sales_funnel_2e3c298e.sql) | `2e3c298e-179f-4791-911a-65533bc83048` |
| 134 | 0 tuple click share - Syed | Click / Order Share | [Q134_0_tuple_click_share_8c333ad5.sql](references/Q134_0_tuple_click_share_8c333ad5.sql) | `8c333ad5-5647-4cd5-9973-3e16dec3088a` |
| 135 | rescheduleable Usage - Syed | Other | [Q135_rescheduleable_usage_ef746f34.sql](references/Q135_rescheduleable_usage_ef746f34.sql) | `ef746f34-ac6e-4407-a028-eeb5d5abf0d2` |
| 136 | 0 Tuple Funnel DBS - Syed | Discover Bharat Sale | [Q136_0_tuple_funnel_dbs_5544bde0.sql](references/Q136_0_tuple_funnel_dbs_5544bde0.sql) | `5544bde0-d7e4-4074-abab-fabee058369e` |
| 137 | RTR trx share and Return Search - Syed Discarded | RTR / Return | [Q137_rtr_trx_share_and_return_search_39739d4b.sql](references/Q137_rtr_trx_share_and_return_search_39739d4b.sql) | `39739d4b-938e-457d-b977-54528b457050` |
| 138 | Discover Bharat Sale SRP tuple count - Syed | Discover Bharat Sale | [Q138_discover_bharat_sale_srp_tuple_count_9f643b26.sql](references/Q138_discover_bharat_sale_srp_tuple_count_9f643b26.sql) | `9f643b26-2624-4269-acad-3c2db2a19e9f` |
| 139 | Discover Bharath Sale - Syed contextual_filters | Discover Bharat Sale | [Q139_discover_bharath_sale_9c960373.sql](references/Q139_discover_bharath_sale_9c960373.sql) | `9c960373-01a0-4506-88a9-91cd017f5077` |
| 140 | Sessions Before Txn- Syed - With device details | Other | [Q140_sessions_before_txn_a6396fd0.sql](references/Q140_sessions_before_txn_a6396fd0.sql) | `a6396fd0-7365-45dc-b7ca-ef49b0868cea` |
| 141 | Funnel Throughput Optimized - Syed | Funnel | [Q141_funnel_throughput_optimized_ca126712.sql](references/Q141_funnel_throughput_optimized_ca126712.sql) | `ca126712-9cd4-4fb4-8c73-ae42ac8c8d69` |
| 142 | Discover Bharat Sales Funnel with DBD and Tuple cut - Syed | Discover Bharat Sale | [Q142_discover_bharat_sales_funnel_with_dbd_and_tuple_cut_8e90da77.sql](references/Q142_discover_bharat_sales_funnel_with_dbd_and_tuple_cut_8e90da77.sql) | `8e90da77-0069-4b0d-a47e-19c423b10d20` |
| 143 | Pilgrim CR - Syed | Pilgrim | [Q143_pilgrim_cr_5e6ad4f9.sql](references/Q143_pilgrim_cr_5e6ad4f9.sql) | `5e6ad4f9-c700-4dad-b477-fd0054175ace` |
| 144 | language Switch back - Syed | Other | [Q144_language_switch_back_23d68ac4.sql](references/Q144_language_switch_back_23d68ac4.sql) | `23d68ac4-2aa7-41da-a6bb-2d5ff1949e39` |
| 145 | Super Optimized Funnel - Syed | Funnel | [Q145_super_optimized_funnel_2572ec69.sql](references/Q145_super_optimized_funnel_2572ec69.sql) | `2572ec69-5493-483c-a2ba-722be893fb5d` |
| 146 | Contextual Filter - Syed | Other | [Q146_contextual_filter_0cf6e66c.sql](references/Q146_contextual_filter_0cf6e66c.sql) | `0cf6e66c-8030-4156-95b2-2fde25d52dc2` |
| 147 | Discover Bharat Sales Funnel - Syed | Discover Bharat Sale | [Q147_discover_bharat_sales_funnel_d5efafb1.sql](references/Q147_discover_bharat_sales_funnel_d5efafb1.sql) | `d5efafb1-d579-4d63-8d95-8ea768579d1e` |
| 148 | users search for return trip RTR AB - non Pilgrim - Syed | Pilgrim | [Q148_users_search_for_return_trip_rtr_ab_non_pilgrim_7aa3cc6a.sql](references/Q148_users_search_for_return_trip_rtr_ab_non_pilgrim_7aa3cc6a.sql) | `7aa3cc6a-8282-4d59-ba04-b02f1e662e62` |
| 149 | Discover Bharat Sale - Syed | Discover Bharat Sale | [Q149_discover_bharat_sale_5ec56d31.sql](references/Q149_discover_bharat_sale_5ec56d31.sql) | `5ec56d31-2d26-4eb2-97a2-59f863791446` |
| 150 | Device model wise Funnel - Syed | Funnel | [Q150_device_model_wise_funnel_d0df5a3d.sql](references/Q150_device_model_wise_funnel_d0df5a3d.sql) | `d0df5a3d-ae9a-4317-b0d0-9768518e03aa` |
| 151 | Express AB Validation MP_CG - Syed | Express Tag AB | [Q151_express_ab_validation_mp_cg_604f9d50.sql](references/Q151_express_ab_validation_mp_cg_604f9d50.sql) | `604f9d50-76b3-425f-a8bf-5e4c27613b92` |
| 152 | Express AB Validation MH - Syed | Express Tag AB | [Q152_express_ab_validation_mh_4ebeac39.sql](references/Q152_express_ab_validation_mh_4ebeac39.sql) | `4ebeac39-fa90-4521-a2e3-1478c8b341bd` |
| 153 | Age wise Funnel with Tier - Syed | Funnel | [Q153_age_wise_funnel_with_tier_f10808bf.sql](references/Q153_age_wise_funnel_with_tier_f10808bf.sql) | `f10808bf-3b1f-4589-ad5f-2b488031d37d` |
| 154 | users search for return trip Optimized - non Pilgrim - Syed | Pilgrim | [Q154_users_search_for_return_trip_optimized_non_pilgrim_887c75ef.sql](references/Q154_users_search_for_return_trip_optimized_non_pilgrim_887c75ef.sql) | `887c75ef-3b6e-447b-b5da-b71c60a139a2` |
| 155 | Tester - Syed | Other | [Q155_tester_bb6f2609.sql](references/Q155_tester_bb6f2609.sql) | `bb6f2609-1e42-48d4-bf45-8e25a77d3b61` |
| 156 | users search for return trip Optimized - Pilgrim - Syed | Pilgrim | [Q156_users_search_for_return_trip_optimized_pilgrim_84df38d6.sql](references/Q156_users_search_for_return_trip_optimized_pilgrim_84df38d6.sql) | `84df38d6-7c91-4e5f-ba81-a24323d7c56b` |
| 157 | users search for return trip RTR AB - Pilgrim - Syed | Pilgrim | [Q157_users_search_for_return_trip_rtr_ab_pilgrim_b654c899.sql](references/Q157_users_search_for_return_trip_rtr_ab_pilgrim_b654c899.sql) | `b654c899-05dd-4d62-acd8-010212dbd836` |
| 158 | non 0 RTC - Syed | RTC | [Q158_non_0_rtc_a669bafb.sql](references/Q158_non_0_rtc_a669bafb.sql) | `a669bafb-46d5-41ef-bad2-9e04297c3891` |
| 159 | EXPRESS_TAG_SRP_AB - Syed | Express Tag AB | [Q159_express_tag_srp_ab_34886ae6.sql](references/Q159_express_tag_srp_ab_34886ae6.sql) | `34886ae6-3f3b-4ead-9e47-8d6c0af99e44` |
| 160 | Perz sort AB - Syed | Other | [Q160_perz_sort_ab_c72fe3f7.sql](references/Q160_perz_sort_ab_c72fe3f7.sql) | `c72fe3f7-adf0-4de6-bcec-7a0d3aee7cb9` |

## Notes

- Duplicate Athena titles kept as separate files (distinct UUIDs).
- File header includes Athena UUID for round-trip to Saved Queries UI.
- Companion bank: `query-repository` (personal QUERY 1–70 style analyses). Prefer this skill for Syed Athena named saves.

