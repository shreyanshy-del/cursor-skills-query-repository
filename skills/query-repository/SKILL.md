---
name: query-repository
description: >-
  Personal redBus SQL query bank (70 queries): pilgrim/RTC/LOB/ASP/comfort/POI
  coverage, funnels, student deal, women funnel, repeat-visit. Use when the user
  asks for a stored SQL, Query Repository, QUERY N, or to re-run a known analysis
  SQL from the bank. Prefer references/*.sql verbatim; adjust only params dates.
---

# Query Repository

Personal SQL query bank. Each query has a short explanation (<50 words), the SQL in `references/`, and sample output where live-pulled.

**Totals:** 70 queries | Removed: 12 CR funnel dimension SQLs | Live DB pulls: 9 | Excel: `Query_Repository_Sample_Outputs_v2.xlsx`

Live pulls use smallest practical windows (often 1 day / 1 hour), `LIMIT 50`, country **IND**.

## How to use

1. Match the user ask to a row in the **Index** (title / filename / topic).
2. Open the matching file under [`references/`](references/).
3. Change only `params` / date CTEs the user requests; keep filters otherwise.
4. For bus confirmed tickets prefer `transaction.bus_ticket_events` with `event_type = 101` (and `event_class = 2` when the file already uses it). Default `country_code = 'IND'`.
5. Prefer **dataplatformCreateQuery** / **dataplatformExecuteIcebergQuery** for Iceberg/Trino runs; OMS ClickHouse only when the SQL file itself targets `oms_db.*`.
6. Show sample shape from [`references/samples/live-pulls.md`](references/samples/live-pulls.md) when available; otherwise note “not live-pulled — run with a short window”.

## Index

| # | Title | File | Live |
|---|-------|------|------|
| 1 | Pilgrim vs Non-Pilgrim Return / Onward | [QUERY18_pilgrim_return.sql](references/QUERY18_pilgrim_return.sql) | YES |
| 2 | Sample Raw Confirmed Tickets (1 Hour) | [SAMPLE_raw_confirmed_tickets_1h.sql](references/SAMPLE_raw_confirmed_tickets_1h.sql) | YES |
| 3 | Discover UGC Review / Rating Tables | [discover_ugc_review_tables.sql](references/discover_ugc_review_tables.sql) |  |
| 4 | Android Lob Funnel Header | [android_lob_funnel_header.sql](references/android_lob_funnel_header.sql) |  |
| 5 | RTC TIN Comparison via BTE | [tin_comparison_bte.sql](references/tin_comparison_bte.sql) | YES |
| 6 | Top 200 Routes by Confirmed Transactions | [top_200_routes_by_transactions.sql](references/top_200_routes_by_transactions.sql) | YES |
| 7 | SRP to Confirm CR by Android / iOS | [genz_month_srp_tin.sql](references/genz_month_srp_tin.sql) | YES |
| 8 | Rtc Shared Base | [rtc_shared_base.sql](references/rtc_shared_base.sql) |  |
| 9 | RTC Conversion Funnel — Confirms Only | [rtc_conversion_funnel_confirms_only.sql](references/rtc_conversion_funnel_confirms_only.sql) | YES |
| 10 | User SD ASP Percentile Deciles (Txn > 3) | [user_sd_asp_percentile_decile_10pct_all_user_txn_gt_3.sql](references/user_sd_asp_percentile_decile_10pct_all_user_txn_gt_3.sql) | YES |
| 11 | User SD ASP Percentile Deciles (Min 5 Txns) | [user_sd_asp_percentile_decile_10pct_all_user.sql](references/user_sd_asp_percentile_decile_10pct_all_user.sql) |  |
| 12 | Android Lob No Offer Attached | [android_lob_no_offer_attached.sql](references/android_lob_no_offer_attached.sql) |  |
| 13 | Route Coverage By City | [route_coverage_by_city.sql](references/route_coverage_by_city.sql) |  |
| 14 | HF GenZ User SD ASP Percentile Deciles | [user_sd_asp_percentile_decile_10pct_hf_15_27.sql](references/user_sd_asp_percentile_decile_10pct_hf_15_27.sql) |  |
| 15 | GenZ / Event-Src Month CR | [genz_mom_cr_by_event_src.sql](references/genz_mom_cr_by_event_src.sql) |  |
| 16 | Poi Dp City Coverage Query | [poi_dp_city_coverage_query.sql](references/poi_dp_city_coverage_query.sql) |  |
| 17 | Android Lob Funnel Optimized | [android_lob_funnel_optimized.sql](references/android_lob_funnel_optimized.sql) |  |
| 18 | Ritual Share Pair Agg Query | [ritual_share_pair_agg_query.sql](references/ritual_share_pair_agg_query.sql) |  |
| 19 | Asp Asset Class Operator Vfm Part B | [asp_asset_class_operator_vfm_part_b.sql](references/asp_asset_class_operator_vfm_part_b.sql) |  |
| 20 | Asp Asset Class Sd Coverage Part A | [asp_asset_class_sd_coverage_part_a.sql](references/asp_asset_class_sd_coverage_part_a.sql) |  |
| 21 | Tin Comparison Funnel | [tin_comparison_funnel.sql](references/tin_comparison_funnel.sql) |  |
| 22 | Rtc Search Funnel By Date | [rtc_search_funnel_by_date.sql](references/rtc_search_funnel_by_date.sql) |  |
| 23 | Rtc Conversion Funnel Period | [rtc_conversion_funnel_period.sql](references/rtc_conversion_funnel_period.sql) |  |
| 24 | Rtc Transactions Aligned | [rtc_transactions_aligned.sql](references/rtc_transactions_aligned.sql) |  |
| 25 | Pilgrim Tminus1H Destination Query | [pilgrim_tminus1h_destination_query.sql](references/pilgrim_tminus1h_destination_query.sql) |  |
| 26 | Rtc Conversion Funnel Aligned | [rtc_conversion_funnel_aligned.sql](references/rtc_conversion_funnel_aligned.sql) |  |
| 27 | Android Lob Funnel Footer | [android_lob_funnel_footer.sql](references/android_lob_funnel_footer.sql) |  |
| 28 | Top20 Sd Route Seat Ranking 4K | [top20_sd_route_seat_ranking_4k.sql](references/top20_sd_route_seat_ranking_4k.sql) |  |
| 29 | Funnel Queries | [funnel-queries.sql](references/funnel-queries.sql) |  |
| 30 | Asp Asset Class Sd Txn Share Pivot | [asp_asset_class_sd_txn_share_pivot.sql](references/asp_asset_class_sd_txn_share_pivot.sql) |  |
| 31 | Repeat Visit Funnel Optimized | [repeat_visit_funnel_optimized.sql](references/repeat_visit_funnel_optimized.sql) |  |
| 32 | Rtc Immediate Return Trip | [rtc_immediate_return_trip.sql](references/rtc_immediate_return_trip.sql) |  |
| 33 | Asp Asset Class Operator Count Top200 Sd | [asp_asset_class_operator_count_top200_sd.sql](references/asp_asset_class_operator_count_top200_sd.sql) |  |
| 34 | Cancellation Policy Sl Funnel With Post Cancel | [cancellation_policy_sl_funnel_with_post_cancel.sql](references/cancellation_policy_sl_funnel_with_post_cancel.sql) |  |
| 35 | Asp Asset Class Sd Coverage Unified | [asp_asset_class_sd_coverage_unified.sql](references/asp_asset_class_sd_coverage_unified.sql) |  |
| 36 | Orig Asp Sql | [_orig_asp_sql.sql](references/_orig_asp_sql.sql) |  |
| 37 | Sd Day Android Funnel Last10 | [sd_day_android_funnel_last10.sql](references/sd_day_android_funnel_last10.sql) |  |
| 38 | Sd Day Android Funnel Date Only | [sd_day_android_funnel_date_only.sql](references/sd_day_android_funnel_date_only.sql) |  |
| 39 | Repeat Visit Overlap Attr Optimized | [repeat_visit_overlap_attr_optimized.sql](references/repeat_visit_overlap_attr_optimized.sql) |  |
| 40 | Pilgrim Tminus1H Destination Query Supported | [pilgrim_tminus1h_destination_query_supported.sql](references/pilgrim_tminus1h_destination_query_supported.sql) |  |
| 41 | Route Pairs Values | [route_pairs_values.sql](references/route_pairs_values.sql) |  |
| 42 | Pilgrim Tminus1H Destination Query Union | [pilgrim_tminus1h_destination_query_union.sql](references/pilgrim_tminus1h_destination_query_union.sql) |  |
| 43 | Cancellation Policy Full Analysis | [cancellation_policy_full_analysis.sql](references/cancellation_policy_full_analysis.sql) |  |
| 44 | Ritual Share Query | [ritual_share_query.sql](references/ritual_share_query.sql) |  |
| 45 | Repeat Visit Attr Analysis Optimized | [repeat_visit_attr_analysis_optimized.sql](references/repeat_visit_attr_analysis_optimized.sql) |  |
| 46 | Pilgrim Tminus1H Destination Query Flat | [pilgrim_tminus1h_destination_query_flat.sql](references/pilgrim_tminus1h_destination_query_flat.sql) |  |
| 47 | City Tier Cte | [city_tier_cte.sql](references/city_tier_cte.sql) |  |
| 48 | Android Lob No Offer Funnel | [android_lob_no_offer_funnel.sql](references/android_lob_no_offer_funnel.sql) |  |
| 49 | Student Deal Section Sd Daily | [student_deal_section_sd_daily.sql](references/student_deal_section_sd_daily.sql) |  |
| 50 | Primo Sd Operator Day Metrics | [primo_sd_operator_day_metrics.sql](references/primo_sd_operator_day_metrics.sql) |  |
| 51 | Android Lob Funnel Simple | [android_lob_funnel_simple.sql](references/android_lob_funnel_simple.sql) |  |
| 52 | Rtc Srp To Txn Funnel | [rtc_srp_to_txn_funnel.sql](references/rtc_srp_to_txn_funnel.sql) |  |
| 53 | Route Bucket Variant Funnel | [route_bucket_variant_funnel.sql](references/route_bucket_variant_funnel.sql) |  |
| 54 | Updated Sd Operator Query | [updated_sd_operator_query.sql](references/updated_sd_operator_query.sql) |  |
| 55 | Women Funnel Query Corrected | [women_funnel_query_corrected.sql](references/women_funnel_query_corrected.sql) |  |
| 56 | Women Funnel Optimized | [women_funnel_optimized.sql](references/women_funnel_optimized.sql) |  |
| 57 | Student Deal Query Summary | [student_deal_query_summary.sql](references/student_deal_query_summary.sql) |  |
| 58 | Student Deal Query | [student_deal_query.sql](references/student_deal_query.sql) |  |
| 59 | Comfort Score Ctr Band Array Mapping | [comfort_score_ctr_band_array_mapping.sql](references/comfort_score_ctr_band_array_mapping.sql) |  |
| 60 | Comfort Score Ctr Band Array Mapping Chunked | [comfort_score_ctr_band_array_mapping_chunked.sql](references/comfort_score_ctr_band_array_mapping_chunked.sql) |  |
| 61 | Comfort Score Ab Query With Median | [comfort_score_ab_query_with_median.sql](references/comfort_score_ab_query_with_median.sql) |  |
| 62 | Route Coverage By City Filled | [route_coverage_by_city_FILLED.sql](references/route_coverage_by_city_FILLED.sql) |  |
| 63 | New Tagging City Route Coverage 1Km 3Km | [new_tagging_city_route_coverage_1km_3km.sql](references/new_tagging_city_route_coverage_1km_3km.sql) |  |
| 64 | New Tagging Sd Route Coverage 1Km 3Km | [new_tagging_sd_route_coverage_1km_3km.sql](references/new_tagging_sd_route_coverage_1km_3km.sql) |  |
| 65 | Top1000 City Route Coverage 1Km 3Km | [top1000_city_route_coverage_1km_3km.sql](references/top1000_city_route_coverage_1km_3km.sql) |  |
| 66 | Top1000 Sd City Route Coverage 1Km 3Km | [top1000_sd_city_route_coverage_1km_3km.sql](references/top1000_sd_city_route_coverage_1km_3km.sql) |  |
| 67 | Newbus Funnel Overall | [newbus_funnel_overall.sql](references/newbus_funnel_overall.sql) |  |
| 68 | Comfort Score Ctr By Band | [comfort_score_ctr_by_band.sql](references/comfort_score_ctr_by_band.sql) |  |
| 69 | Comfort Score Ctr Each Band Separate | [comfort_score_ctr_each_band_separate.sql](references/comfort_score_ctr_each_band_separate.sql) |  |
| 70 | Poi Dp Route Txn Coverage Query | [poi_dp_route_txn_coverage_query.sql](references/poi_dp_route_txn_coverage_query.sql) |  |

## Explanations (<50 words)

### QUERY 1: Pilgrim vs Non-Pilgrim Return / Onward
Splits India bookings by pilgrim destination and counts same-user return vs onward trips. Live sample: 2026-06-10 (1 day).

### QUERY 2: Sample Raw Confirmed Tickets (1 Hour)
Smallest-window raw confirmed India tickets from bus_ticket_events. Live-pulled 50 rows for 2026-06-10 00:00-01:00 UTC.

### QUERY 3: Discover UGC Review / Rating Tables
Lists ugc schema tables whose names contain review or rating for catalog discovery before writing UGC analytics.

### QUERY 4: Android Lob Funnel Header
With LOB - session count per step by DBD, Tier, User_type, DRFM No cross-step joins. Build funnel manually in Excel / Sheets. DBD / Tier / User_type from first Search-Routes event per session. DRFM: rb_user_id joined to umsuserid on svoc.cltv_data Engine: Trino / Presto.

### QUERY 5: RTC TIN Comparison via BTE
Compares confirmed TINs for RTC operators using bus_ticket_events with grouping sets including ALL_RTC.

### QUERY 6: Top 200 Routes by Confirmed Transactions
Ranks India city-to-city SD pairs by distinct confirmed TINs. Sample pull uses a 1-day window (2026-06-10) limited to top 50.

### QUERY 7: SRP to Confirm CR by Android / iOS
Computes SRP load vs confirmed TIN conversion for Android and iOS. Live sample is a 1-day India window (2026-06-10).

### QUERY 8: Rtc Shared Base
SHARED BASE (use identically in Funnel + Transactions queries).

### QUERY 9: RTC Conversion Funnel — Confirms Only
Daily confirmed TIN counts for WBTC/WBSTC/NBSTC/SBSTC on RTC city pairs. Live sample: 2026-06-10.

### QUERY 10: User SD ASP Percentile Deciles (Txn > 3)
Bins user-SD average seat price into deciles for users with more than 3 bookings. Live sample: 2026-06-01 to 2026-06-11.

### QUERY 11: User SD ASP Percentile Deciles (Min 5 Txns)
Same ASP decile banding requiring at least 5 confirmed bookings per user in the lookback window.

### QUERY 12: Android Lob No Offer Attached
Confirmed TINs with NO offer attached (offer_status NULL / blank, or no order_info_details row) LOB Android cohort only. Engine: Trino / Presto.

### QUERY 13: Route Coverage By City
City-level (DESTINATION) route coverage vs POI proximity "How many route_ids (out of Top 1000 SD routes serving a destination city) have a dropping point within 1 km / within 3 km of that city's POI" Grain : one row per destination city sd_pairs(source_id, destination_id) -> the "Top 1000.

### QUERY 14: HF GenZ User SD ASP Percentile Deciles
ASP decile banding for high-frequency users aged 15–27 with at least 3 bookings.

### QUERY 15: GenZ / Event-Src Month CR
Month-level conversion by event_src (SRP sessions vs confirms). Sample uses June 2026 India window.

### QUERY 16: Poi Dp City Coverage Query
City-level route coverage: boarding points within 3 km and 5 km of POI Distance: Haversine (open-source, straight-line / crow-flies) SQL dialect: Presto / Trino (adjust table name as needed) Replace `your_schema.poi_dp_mapping` with your actual table/view name after loading "POI and DP Mapping.xlsx".

### QUERY 17: Android Lob Funnel Optimized
Android LOB funnel — optimized Engine: Trino / Presto Optimizations vs original: 1. Single scan of ui_ux_events (android cohort + offer filter merged) 2. offer_sessions materialized once; downstream steps use INNER JOIN 3. Each fact table scanned once with GROUP BY session (no repeated DISTINCT) 4. One UNION.

### QUERY 18: Ritual Share Pair Agg Query
Stored SQL query for ritual share pair agg query. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 19: Asp Asset Class Operator Vfm Part B
Stored SQL query for asp asset class operator vfm part b. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 20: Asp Asset Class Sd Coverage Part A
Stored SQL query for asp asset class sd coverage part a. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 21: Tin Comparison Funnel
Funnel confirm_tins total (RTC operators) using rtc-derived route pairs.

### QUERY 22: Rtc Search Funnel By Date
OPTIONAL: Search-date funnel (SRP inventory view, by funnel_date) Use this for search-to-seat conversion. Do NOT use confirm_tins from here for reconciliation — use the issue_date query above or Transactions query.

### QUERY 23: Rtc Conversion Funnel Period
RTC CONVERSION FUNNEL — period-level rollup (lowest resource use) Same logic as rtc_conversion_funnel_aligned.sql but grouped by operator only. confirm_tins still matches Transactions query when summed.

### QUERY 24: Rtc Transactions Aligned
RTC TRANSACTIONS (aligned with Conversion Funnel query) Period: 2026-05-20 to 2026-06-11 (exclusive end) confirm_tins here = confirm_tins in Funnel query (same confirmed_tickets CTE).

### QUERY 25: Pilgrim Tminus1H Destination Query
Stored SQL query for pilgrim tminus1h destination query. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 26: Rtc Conversion Funnel Aligned
RTC CONVERSION FUNNEL (like-to-like with Transactions) — OPTIMIZED v2 Period: 2026-05-20 to 2026-06-11 (exclusive end) If daily grain still exhausts resources, use rtc_conversion_funnel_period.sql or rtc_conversion_funnel_confirms_only.sql + rtc_search_funnel_by_date.sql.

### QUERY 27: Android Lob Funnel Footer
Stored SQL query for android lob funnel footer. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 28: Top20 Sd Route Seat Ranking 4K
Top 20 SDs × Top 20 Routes × Top 10 Seats (~4,000 rows) Metrics per seat: prob_sold_within_dbd2 = P(booked ≤ 2 days before departure) prob_sold_beyond_dbd2 = P(booked > 2 days before departure) asp_diff_abs / asp_diff_pct = median fare beyond DBD2 minus within DBD2 DBD 2 threshold = 48.

### QUERY 29: Funnel Queries
Funnel export: SRP → SL → Cust Info → Create Order → Payment Page → Pay Now → Order Confirmed Engine: Trino-style. Tables: align with your Iceberg catalog (see NOTEs below). Cohort: distinct mri_session_id with search (SRP) in [t_start, t_end). Funnel_date: first calendar day of SRP in that.

### QUERY 30: Asp Asset Class Sd Txn Share Pivot
Stored SQL query for asp asset class sd txn share pivot. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 31: Repeat Visit Funnel Optimized
Repeat-visit funnel (optimized) Engine: Trino / Presto Optimizations vs original: 1. Single filtered scan each of search_route_details and seat_layout_details 2. Merged sl_sessions + session_routes (eliminates 2nd seat_layout scan) 3. Pre-computed casts on filtered base CTEs (route_id, doj) 4. Filter non-transacted rows before ROW_NUMBER window 5. Split visit2 CTE.

### QUERY 32: Rtc Immediate Return Trip
Stored SQL query for rtc immediate return trip. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 33: Asp Asset Class Operator Count Top200 Sd
Stored SQL query for asp asset class operator count top200 sd. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 34: Cancellation Policy Sl Funnel With Post Cancel
SL funnel (dest_id list) + post-confirm cancellations from transaction.bus_cancellation_events Time before journey = date_of_journey - cancellation timestamp (hours) Cancellations looked up up to 30 days after confirm window (adjust cancel_bounds if needed).

### QUERY 35: Asp Asset Class Sd Coverage Unified
Stored SQL query for asp asset class sd coverage unified. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 36: Orig Asp Sql
ASP x Asset Class analysis across SD Buckets LT_80_ASP_PCT : route ASP percentile within SD < 80th percentile GTE_80_ASP_PCT : route ASP percentile within SD >= 80th percentile Asset classes (from search_route_details; a route can belong to multiple) Volvo : bus_type ILIKE '%volvo%' Bharat Benz : bus_type ILIKE.

### QUERY 37: Sd Day Android Funnel Last10
Android Day-on-Day IST Conversion Funnel Throughput Grain: search_date_ist x src_id x dest_id Window: last 10 days IST (no DBD / LMB cuts) Country: IND | Channel: MOBILE_APP | OS: Android.

### QUERY 38: Sd Day Android Funnel Date Only
Android Day-on-Day IST Conversion Funnel Throughput Grain: search_date_ist ONLY (all listed SDs rolled up) Cohort: SVOC age <= 23 Window: last 10 days IST (no DBD / LMB cuts) Country: IND | Channel: MOBILE_APP | OS: Android.

### QUERY 39: Repeat Visit Overlap Attr Optimized
Repeat-visit overlap + attribute match (optimized) Cohort: Same SD, non-transacted Visit1 (>=2 SL routes) + Visit2 Segments: overlap_group (No Same Routes | 0-50% | 50-100%) x revisit_gap (<6h | >=6h) Metrics: same price +/-100, same rating +/-0.2, same bus_type (any route pair V1 vs V2).

### QUERY 40: Pilgrim Tminus1H Destination Query Supported
Stored SQL query for pilgrim tminus1h destination query supported. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 41: Route Pairs Values
Stored SQL query for route pairs values. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 42: Pilgrim Tminus1H Destination Query Union
Stored SQL query for pilgrim tminus1h destination query union. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 43: Cancellation Policy Full Analysis
FULL ANALYSIS: Cancellation policy on SL (Android, India BUS, dest_id list) Part A — SL → Confirm funnel (3 cuts: Overall | Seen | Not seen) Part B — Post-confirm cancellations + time-before-DOJ buckets Adjust bounds / cancel_bounds as needed. Verify column names on bus_cancellation_events: cancellation_date_time, date_of_journey, refund_amount.

### QUERY 44: Ritual Share Query
Stored SQL query for ritual share query. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 45: Repeat Visit Attr Analysis Optimized
Repeat-visit attribute analysis (optimized) Engine: Trino / Presto Cohort: Same SD + Same DOJ, Visit 1 (>=2 SL routes, non-transacted) + Visit 2 Segments: journey_duration_cut : Visit 1 median route duration < 6h vs >= 6h route_share_bucket : No Same Routes | < 50% Route Share | >=.

### QUERY 46: Pilgrim Tminus1H Destination Query Flat
Stored SQL query for pilgrim tminus1h destination query flat. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 47: City Tier Cte
Stored SQL query for city tier cte. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 48: Android Lob No Offer Funnel
No Offer Attached funnel — step counts by DBD, Tier, User_type, DRFM Cohort: LOB Android -> confirmed TIN, no offer (NULL/blank/no order_info row) Engine: Trino / Presto.

### QUERY 49: Student Deal Section Sd Daily
Stored SQL query for student deal section sd daily. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 50: Primo Sd Operator Day Metrics
Stored SQL query for primo sd operator day metrics. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 51: Android Lob Funnel Simple
With LOB - session count per step by DBD, Tier, User_type, DRFM Steps 8-10: Of confirmed TINs -> Offer Attached / No Offer Attached / Failure Engine: Trino / Presto.

### QUERY 52: Rtc Srp To Txn Funnel
Stored SQL query for rtc srp to txn funnel. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 53: Route Bucket Variant Funnel
Stored SQL query for route bucket variant funnel. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 54: Updated Sd Operator Query
Stored SQL query for updated sd operator query. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 55: Women Funnel Query Corrected
Women Funnel Query (corrected) Fixes vs original broken query: 1. SRP window 7 days (matches working query; 3 days was too thin for Female + p40-p65) 2. session_group_counts from session_dim at session grain (not sxr_target route grain) 3. Explicit is_reddeal flag for pricing (deal_type = 'REDDEAL') 4. Step.

### QUERY 56: Women Funnel Optimized
Optimized Women Funnel Query Key changes vs original: 1. Single scan of search_route_details (7d) via FIRST_VALUE window instead of 2 passes 2. Hygiene path: direct urt↔srd join (drops sd_sessions_2m materialization + IN subquery) 3. Pre-computed deal/cohort string + comfort index (avoids repeated REGEXP/array lookups) 4. route_facets pre-aggregation reused.

### QUERY 57: Student Deal Query Summary
Stored SQL query for student deal query summary. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 58: Student Deal Query
Stored SQL query for student deal query. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 59: Comfort Score Ctr Band Array Mapping
Stored SQL query for comfort score ctr band array mapping. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 60: Comfort Score Ctr Band Array Mapping Chunked
Stored SQL query for comfort score ctr band array mapping chunked. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 61: Comfort Score Ab Query With Median
Stored SQL query for comfort score ab query with median. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 62: Route Coverage By City Filled
City-level (DESTINATION) route coverage vs POI proximity [WHOLE QUERY] "Out of the Top 1000 SD routes serving each destination city, how many route_ids have a dropping point within 1 km / within 3 km of that city's POI" Grain : one row per destination city bucket : 'Less.

### QUERY 63: New Tagging City Route Coverage 1Km 3Km
Top 1000 SD scope: DESTINATION CITY-level route coverage + transaction share within 1 km and 3 km of pilgrim POI Distance tagging source: New Distance Tagging.xlsx Tag mapping: 'Less than 1 KM' -> <=1km | 'Between 1-3 Kms' -> 1-3km Source : transaction.bus_ticket_events (confirmed bookings, event rows =.

### QUERY 64: New Tagging Sd Route Coverage 1Km 3Km
Top 1000 SD scope: SD-level route coverage + transaction share within 1 km and 3 km of pilgrim POI Distance tagging source: New Distance Tagging.xlsx Tag mapping: 'Less than 1 KM' -> <=1km | 'Between 1-3 Kms' -> 1-3km Source : transaction.bus_ticket_events (confirmed bookings, event rows = txns).

### QUERY 65: Top1000 City Route Coverage 1Km 3Km
Top 1000 SD scope: DESTINATION CITY-level route coverage + transaction share within 1 km and 3 km of pilgrim POI (Maps driving distance) Source : transaction.bus_ticket_events (confirmed bookings, event rows = txns) Window : 2026-06-11 to 2026-06-18 (7 days, end exclusive) Grain : one row per destination city.

### QUERY 66: Top1000 Sd City Route Coverage 1Km 3Km
Top 1000 SD pairs: SD-level + destination city-level route coverage (1km / 3km) Source : transaction.bus_ticket_events (confirmed bookings) Window : 2026-06-11 to 2026-06-18 (7 days, end exclusive) Buckets: Maps driving distance to pilgrim POI (dp_buckets hard-pasted) SD pairs embedded: 982 | DP buckets embedded: 3813 Engine : Trino.

### QUERY 67: Newbus Funnel Overall
Stored SQL query for newbus funnel overall. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 68: Comfort Score Ctr By Band
Stored SQL query for comfort score ctr by band. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 69: Comfort Score Ctr Each Band Separate
Stored SQL query for comfort score ctr each band separate. Adjust date params in the CTE before running; sample output uses a short India window where live pull is available.

### QUERY 70: Poi Dp Route Txn Coverage Query
City-level POI coverage using Maps Dropping Point ID POI-DP mapping data HARD-PASTED from: POI and DP Mapping.xlsx Rows with valid coordinates: 5955 | Destinations: 79.

## Topic routing (quick)

| Topic | Query #s |
|-------|----------|
| Pilgrim / ritual / T−1h | 1, 18, 25, 40, 42, 44, 46 |
| RTC funnel / TIN / return | 5, 8, 9, 21–24, 26, 32, 41, 52 |
| Android LOB / offer | 4, 12, 17, 27, 48, 51 |
| ASP / asset class / VFM | 10, 11, 14, 19, 20, 30, 33, 35, 36 |
| CR / GenZ / SD day funnel | 7, 15, 37, 38 |
| Repeat visit | 31, 39, 45 |
| Cancellation policy | 34, 43 |
| POI / route coverage 1–3 km | 13, 16, 62–66, 70 |
| Comfort score CTR | 59–61, 68, 69 |
| Student deal / Primo / NewBus / Women | 49, 50, 53, 54, 55–58, 67 |
| Raw sample / UGC discover / generic funnel | 2, 3, 29 |
| City tier CTE | 47 |

## Notes

- Heavy array / VALUES-filled mapping queries are intentional; do not strip ID lists.
- Some files are CTE fragments (`city_tier_cte.sql`, `route_pairs_values.sql`, LOB header/footer) — compose with the matching sibling file.
- Live sample rows: [`references/samples/live-pulls.md`](references/samples/live-pulls.md).
