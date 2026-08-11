# Live sample outputs

Smallest practical windows (often 1 day / 1 hour), LIMIT 50, country **IND**.

Full Excel bank: `Query_Repository_Sample_Outputs_v2.xlsx` (not bundled here).


## top_200_routes_by_transactions.sql

- Window: `2026-06-10 (1 day) — top 50`

| route_rank | source_location_id | destination_location_id | source_location | destination_location | sd_id | transactions |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 122 | 123 | Bangalore | Chennai | 122_123 | 2386 |
| 2 | 123 | 122 | Chennai | Bangalore | 123_122 | 1989 |
| 3 | 122 | 124 | Bangalore | Hyderabad | 122_124 | 1574 |
| 4 | 123 | 141 | Chennai | Coimbatore | 123_141 | 1574 |
| 5 | 124 | 122 | Hyderabad | Bangalore | 124_122 | 1522 |
| 6 | 141 | 123 | Coimbatore | Chennai | 141_123 | 1334 |
| 7 | 123 | 126 | Chennai | Madurai | 123_126 | 1205 |
| 8 | 122 | 141 | Bangalore | Coimbatore | 122_141 | 1022 |
| 9 | 126 | 123 | Madurai | Chennai | 126_123 | 999 |
| 10 | 141 | 122 | Coimbatore | Bangalore | 141_122 | 884 |
| 11 | 124 | 134 | Hyderabad | Vijayawada | 124_134 | 806 |
| 12 | 122 | 71756 | Bangalore | Tirupati | 122_71756 | 697 |
| 13 | 134 | 124 | Vijayawada | Hyderabad | 134_124 | 666 |
| 14 | 123 | 71929 | Chennai | Tiruchirapalli | 123_71929 | 661 |
| 15 | 123 | 602 | Chennai | Salem | 123_602 | 642 |
| 16 | 733 | 1439 | Delhi | Lucknow | 733_1439 | 603 |
| 17 | 1439 | 733 | Lucknow | Delhi | 1439_733 | 600 |
| 18 | 69802 | 74820 | Durgapur (West Bengal) | Kolkata | 69802_74820 | 597 |
| 19 | 71929 | 123 | Tiruchirapalli | Chennai | 71929_123 | 568 |
| 20 | 71756 | 122 | Tirupati | Bangalore | 71756_122 | 559 |
| 21 | 74694 | 74820 | Siliguri | Kolkata | 74694_74820 | 556 |
| 22 | 130 | 624 | Pune | Nagpur | 130_624 | 536 |
| 23 | 733 | 777 | Delhi | Dehradun | 733_777 | 531 |
| 24 | 74820 | 74706 | Kolkata | Digha | 74820_74706 | 525 |
| 25 | 602 | 123 | Salem | Chennai | 602_123 | 517 |


## rtc_conversion_funnel_confirms_only.sql

- Window: `2026-06-10 (1 day)`

| issue_date | operator_name | operator_id | confirm_tins |
| --- | --- | --- | --- |
| 2026-06-10 | WBTC | 16426 | 1492 |
| 2026-06-10 | WBSTC | 15443 | 43 |
| 2026-06-10 | NBSTC | 24978 | 667 |
| 2026-06-10 | SBSTC | 32272 | 2288 |


## tin_comparison_bte.sql

- Window: `2026-06-10 (1 day)`

| operator_name | total_tins |
| --- | --- |
| ALL_RTC | 4490 |
| NBSTC | 667 |
| SBSTC | 2288 |
| WBSTC | 43 |
| WBTC | 1492 |


## genz_month_srp_tin.sql

- Window: `2026-06-10 (1 day)`

| platform | srpload | tin | tin_per_srp_pct |
| --- | --- | --- | --- |
| Android | 1268724 | 151792 | 11.96 |
| iOS | 238032 | 41096 | 17.26 |


## QUERY18_pilgrim_return.sql

- Window: `2026-06-10 (1 day; return join also same-day bookings)`

| destination_type | total_confirmed_bookings | total_distinct_users | return_bookings_24h | return_bookings_72h | source_to_other_bookings_72h |
| --- | --- | --- | --- | --- | --- |
| Pilgrim | 14964 | 13080 | 755 | 1203 | 945 |
| Non-Pilgrim | 212876 | 182845 | 9727 | 13847 | 14519 |


## user_sd_asp_percentile_decile_10pct_all_user_txn_gt_3.sql

- Window: `2026-06-01 to 2026-06-11 — LIMIT 50`

| src_id | dest_id | decile | users | avg_asp | min_asp | max_asp |
| --- | --- | --- | --- | --- | --- | --- |
| 121 | 122 | 1 | 1 | 477.49 | 477.49 | 477.49 |
| 121 | 123 | 1 | 1 | 953.14 | 953.14 | 953.14 |
| 121 | 124 | 1 | 1 | 879.25 | 879.25 | 879.25 |
| 121 | 124 | 2 | 1 | 1211.75 | 1211.75 | 1211.75 |
| 122 | 123 | 1 | 4 | 586.03 | 451.5 | 645.0 |
| 122 | 123 | 2 | 4 | 703.18 | 654.2 | 757.0 |
| 122 | 123 | 3 | 4 | 789.31 | 772.43 | 803.5 |
| 122 | 123 | 4 | 4 | 828.45 | 823.8 | 840.0 |
| 122 | 123 | 5 | 4 | 867.94 | 845.0 | 901.25 |
| 122 | 123 | 6 | 4 | 967.17 | 937.5 | 999.63 |
| 122 | 123 | 7 | 4 | 1086.88 | 1055.0 | 1130.0 |
| 122 | 123 | 8 | 3 | 1166.08 | 1156.75 | 1171.5 |
| 122 | 123 | 9 | 3 | 1265.67 | 1195.0 | 1340.25 |
| 122 | 123 | 10 | 3 | 1565.58 | 1401.25 | 1686.25 |
| 122 | 124 | 1 | 2 | 1008.21 | 956.67 | 1059.75 |
| 122 | 124 | 2 | 1 | 1138.0 | 1138.0 | 1138.0 |
| 122 | 124 | 3 | 1 | 1167.25 | 1167.25 | 1167.25 |
| 122 | 124 | 4 | 1 | 1195.25 | 1195.25 | 1195.25 |
| 122 | 124 | 5 | 1 | 1484.05 | 1484.05 | 1484.05 |
| 122 | 126 | 1 | 1 | 539.0 | 539.0 | 539.0 |
| 122 | 126 | 2 | 1 | 780.25 | 780.25 | 780.25 |
| 122 | 126 | 10 | 1 | 1201.75 | 1201.75 | 1201.75 |


## SAMPLE_raw_confirmed_tickets_1h.sql

- Window: `2026-06-10 00:00–01:00 UTC — 50 rows`

| tin | rb_user_id | source_location_id | destination_location_id | source_location | destination_location | operator_id | date_of_issue | date_of_journey | country_code | event_type | event_class |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S |
| E |
| E |
| _ |
| F |
| I |
| L |
| E |
