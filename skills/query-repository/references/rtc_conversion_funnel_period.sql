-- =============================================================================
-- RTC CONVERSION FUNNEL — period-level rollup (lowest resource use)
-- Same logic as rtc_conversion_funnel_aligned.sql but grouped by operator only.
-- confirm_tins still matches Transactions query when summed.
-- =============================================================================

WITH date_filter AS (
    SELECT TIMESTAMP '2026-05-20 00:00:00' AS start_dt, TIMESTAMP '2026-06-11 00:00:00' AS end_dt
),
rtc_operators AS (
    SELECT * FROM (VALUES
        ('WBTC',16426,1),('WBSTC',15443,2),('NBSTC',24978,3),('SBSTC',32272,4)
    ) AS t(operator_name, operator_id, sort_order)
),
rtc_city_pairs AS (
    SELECT DISTINCT b.source_location_id AS src_id, b.destination_location_id AS dest_id
    FROM transaction.bus_ticket_events b
    CROSS JOIN date_filter d
    WHERE b.date_of_issue >= d.start_dt AND b.date_of_issue < d.end_dt
      AND b.event_class = 2 AND b.event_type = 101 AND b.country_code = 'IND'
      AND b.operator_id IN (16426, 15443, 24978, 32272)
),
confirmed_tickets AS (
    SELECT CAST(b.date_of_issue AS DATE) AS issue_date, b.tin, ro.operator_name, ro.sort_order,
           b.mri_session_id, b.route_id, b.source_location_id AS src_id, b.destination_location_id AS dest_id
    FROM transaction.bus_ticket_events b
    CROSS JOIN date_filter d
    INNER JOIN rtc_city_pairs cp ON b.source_location_id = cp.src_id AND b.destination_location_id = cp.dest_id
    INNER JOIN rtc_operators ro ON b.operator_id = ro.operator_id
    WHERE b.date_of_issue >= d.start_dt AND b.date_of_issue < d.end_dt
      AND b.event_class = 2 AND b.event_type = 101 AND b.country_code = 'IND'
      AND b.tin IS NOT NULL AND TRIM(b.tin) <> '' AND LOWER(TRIM(b.tin)) <> 'null'
),
session_ids AS (
    SELECT DISTINCT mri_session_id FROM confirmed_tickets WHERE mri_session_id IS NOT NULL
),
rd_filtered AS (
    SELECT rd.mri_session_id, TRY_CAST(rd.src_id AS BIGINT) AS src_id, TRY_CAST(rd.dest_id AS BIGINT) AS dest_id
    FROM user_interaction.search_route_details rd
    INNER JOIN session_ids s ON rd.mri_session_id = s.mri_session_id
    WHERE rd.__time >= TIMESTAMP '2026-05-20 00:00:00' AND rd.__time < TIMESTAMP '2026-06-11 00:00:00'
      AND rd.country = 'IND' AND rd.event_type = 'Search-Routes' AND rd.status < 400
      AND (rd.akamai_bot IS NULL OR rd.akamai_bot = '')
    GROUP BY 1, 2, 3
),
sl_filtered AS (
    SELECT sl.mri_session_id, TRY_CAST(sl.route_id AS BIGINT) AS route_id
    FROM user_interaction.seat_layout_details sl
    INNER JOIN session_ids s ON sl.mri_session_id = s.mri_session_id
    WHERE sl.__time >= TIMESTAMP '2026-05-20 00:00:00' AND sl.__time < TIMESTAMP '2026-06-11 00:00:00' AND sl.country = 'IND'
    GROUP BY 1, 2
),
ci_filtered AS (
    SELECT ci.mri_session_id, TRY_CAST(ci.route_id AS BIGINT) AS route_id
    FROM user_interaction.cust_info_details ci
    INNER JOIN session_ids s ON ci.mri_session_id = s.mri_session_id
    WHERE ci.__time >= TIMESTAMP '2026-05-20 00:00:00' AND ci.__time < TIMESTAMP '2026-06-11 00:00:00' AND ci.country = 'IND'
    GROUP BY 1, 2
),
co_filtered AS (
    SELECT co.mri_session_id, TRY_CAST(co.route_id AS BIGINT) AS route_id
    FROM user_interaction.create_order_details co
    INNER JOIN session_ids s ON co.mri_session_id = s.mri_session_id
    WHERE co.__time >= TIMESTAMP '2026-05-20 00:00:00' AND co.__time < TIMESTAMP '2026-06-11 00:00:00' AND co.country = 'IND'
    GROUP BY 1, 2
),
pay_filtered AS (
    SELECT mp.mri_session_id
    FROM user_interaction.make_payment_details mp
    INNER JOIN session_ids s ON mp.mri_session_id = s.mri_session_id
    WHERE mp.__time >= TIMESTAMP '2026-05-20 00:00:00' AND mp.__time < TIMESTAMP '2026-06-11 00:00:00' AND mp.country = 'IND'
    GROUP BY 1
),
ticket_flags AS (
    SELECT c.operator_name, c.sort_order, c.tin,
        MAX(CASE WHEN rd.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS has_srp,
        MAX(CASE WHEN sl.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS has_sl,
        MAX(CASE WHEN ci.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS has_ci,
        MAX(CASE WHEN co.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS has_co,
        MAX(CASE WHEN pay.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS has_pay
    FROM confirmed_tickets c
    LEFT JOIN rd_filtered rd ON c.mri_session_id = rd.mri_session_id AND c.src_id = rd.src_id AND c.dest_id = rd.dest_id
    LEFT JOIN sl_filtered sl ON c.mri_session_id = sl.mri_session_id AND c.route_id = sl.route_id
    LEFT JOIN ci_filtered ci ON c.mri_session_id = ci.mri_session_id AND c.route_id = ci.route_id
    LEFT JOIN co_filtered co ON c.mri_session_id = co.mri_session_id AND c.route_id = co.route_id
    LEFT JOIN pay_filtered pay ON c.mri_session_id = pay.mri_session_id
    GROUP BY c.operator_name, c.sort_order, c.tin
)
SELECT
    operator_name,
    CASE operator_name WHEN 'WBTC' THEN 16426 WHEN 'WBSTC' THEN 15443 WHEN 'NBSTC' THEN 24978 WHEN 'SBSTC' THEN 32272 END AS operator_id,
    COUNT(*) AS confirm_tins,
    SUM(has_srp) AS srp_tins,
    SUM(has_sl) AS sl_tins,
    SUM(has_ci) AS cust_info_tins,
    SUM(has_co) AS create_order_tins,
    SUM(has_pay) AS pay_tins,
    ROUND(100.0 * SUM(has_sl) / NULLIF(COUNT(*), 0), 2) AS confirm_to_sl_pct,
    ROUND(100.0 * SUM(has_ci) / NULLIF(SUM(has_sl), 0), 2) AS sl_to_ci_cr_pct,
    ROUND(100.0 * SUM(has_co) / NULLIF(SUM(has_ci), 0), 2) AS ci_to_co_cr_pct,
    ROUND(100.0 * SUM(has_pay) / NULLIF(SUM(has_co), 0), 2) AS co_to_pay_cr_pct,
    ROUND(100.0 * COUNT(*) / NULLIF(SUM(has_srp), 0), 2) AS srp_to_confirm_cr_pct
FROM ticket_flags
GROUP BY operator_name, sort_order
ORDER BY sort_order
