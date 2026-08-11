WITH params AS (
    SELECT
        CURRENT_DATE - INTERVAL '365' DAY AS txn_start,
        CURRENT_DATE AS txn_end,
        15 AS age_min,
        27 AS age_max,
        3 AS hf_min_txns
),

txns AS (
    SELECT
        bte.rb_user_id,
        bte.tin,
        bte.source_location_id AS src_id,
        bte.destination_location_id AS dest_id,
        CAST(bte.seat_price[1] AS DOUBLE) AS asp,
        CAST(bte.travellers_age[1] AS INTEGER) AS primary_traveller_age
    FROM transaction.bus_ticket_events bte
    CROSS JOIN params p
    WHERE bte.date_of_issue >= p.txn_start
      AND bte.date_of_issue < p.txn_end
      AND bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.event_class = 2
      AND bte.rb_user_id > 0
      AND bte.tin IS NOT NULL
      AND bte.seat_price IS NOT NULL
      AND CARDINALITY(bte.seat_price) > 0
      AND bte.travellers_age IS NOT NULL
      AND CARDINALITY(bte.travellers_age) > 0
      AND bte.source_location_id IS NOT NULL
      AND bte.destination_location_id IS NOT NULL
),

user_cohort_flags AS (
    SELECT
        t.rb_user_id,
        COUNT(DISTINCT t.tin) AS txn_count,
        MAX(
            CASE
                WHEN t.primary_traveller_age BETWEEN p.age_min AND p.age_max
                THEN 1
                ELSE 0
            END
        ) AS has_age_cohort
    FROM txns t
    CROSS JOIN params p
    GROUP BY
        1
),

hf_age_users AS (
    SELECT
        u.rb_user_id
    FROM user_cohort_flags u
    CROSS JOIN params p
    WHERE u.txn_count >= p.hf_min_txns
      AND u.has_age_cohort = 1
),

txns_cohort AS (
    SELECT
        t.rb_user_id,
        t.tin,
        t.src_id,
        t.dest_id,
        t.asp
    FROM txns t
    INNER JOIN hf_age_users h
        ON t.rb_user_id = h.rb_user_id
),

txns_with_percentile AS (
    SELECT
        t.*,
        PERCENT_RANK() OVER (
            PARTITION BY t.src_id, t.dest_id
            ORDER BY t.asp
        ) AS sd_asp_percentile
    FROM txns_cohort t
),

user_metrics AS (
    SELECT
        twp.rb_user_id,
        COUNT(DISTINCT twp.tin) AS txns,
        AVG(twp.sd_asp_percentile) AS user_sd_asp_percentile,
        APPROX_PERCENTILE(twp.sd_asp_percentile, 0.5) AS user_median_sd_asp_percentile
    FROM txns_with_percentile twp
    GROUP BY
        1
),

user_deciled AS (
    SELECT
        um.*,
        CASE
            WHEN um.user_sd_asp_percentile < 0.10 THEN '01_P00_10'
            WHEN um.user_sd_asp_percentile < 0.20 THEN '02_P10_20'
            WHEN um.user_sd_asp_percentile < 0.30 THEN '03_P20_30'
            WHEN um.user_sd_asp_percentile < 0.40 THEN '04_P30_40'
            WHEN um.user_sd_asp_percentile < 0.50 THEN '05_P40_50'
            WHEN um.user_sd_asp_percentile < 0.60 THEN '06_P50_60'
            WHEN um.user_sd_asp_percentile < 0.70 THEN '07_P60_70'
            WHEN um.user_sd_asp_percentile < 0.80 THEN '08_P70_80'
            WHEN um.user_sd_asp_percentile < 0.90 THEN '09_P80_90'
            ELSE '10_P90_100'
        END AS user_segment
    FROM user_metrics um
)

SELECT
    ud.user_segment,
    COUNT(DISTINCT ud.rb_user_id) AS users,
    SUM(ud.txns) AS txns,
    ROUND(CAST(SUM(ud.txns) AS DOUBLE) / NULLIF(COUNT(DISTINCT ud.rb_user_id), 0), 2)
        AS avg_txn_per_user,
    ROUND(AVG(ud.user_median_sd_asp_percentile), 4) AS avg_median_sd_asp_percentile,
    ROUND(AVG(ud.user_sd_asp_percentile), 4) AS avg_user_sd_asp_percentile
FROM user_deciled ud
GROUP BY
    1
ORDER BY
    1
