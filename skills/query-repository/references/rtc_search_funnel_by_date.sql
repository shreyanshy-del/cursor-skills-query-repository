-- =============================================================================
-- OPTIONAL: Search-date funnel (SRP inventory view, by funnel_date)
-- Use this for search-to-seat conversion. Do NOT use confirm_tins from here
-- for reconciliation — use the issue_date query above or Transactions query.
-- =============================================================================

WITH date_filter AS (
    SELECT TIMESTAMP '2026-05-20 00:00:00' AS start_dt, TIMESTAMP '2026-06-11 00:00:00' AS end_dt
),
rtc_operators AS (
    SELECT * FROM (VALUES
        ('WBTC',16426,1),('WBSTC',15443,2),('NBSTC',24978,3),('SBSTC',32272,4),('Rest',NULL,5)
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
route_pairs AS (SELECT src_id, dest_id FROM rtc_city_pairs),
srp_inventory AS (
    SELECT CAST(DATE_ADD('minute', 330, rd.__time) AS DATE) AS funnel_date,
           rd.mri_session_id, TRY_CAST(rd.src_id AS BIGINT) AS src_id,
           TRY_CAST(rd.dest_id AS BIGINT) AS dest_id,
           TRY_CAST(COALESCE(rd.operator_id, rd.op_id) AS BIGINT) AS operator_id
    FROM user_interaction.search_route_details rd
    CROSS JOIN date_filter d
    INNER JOIN route_pairs rp ON TRY_CAST(rd.src_id AS BIGINT) = rp.src_id AND TRY_CAST(rd.dest_id AS BIGINT) = rp.dest_id
    WHERE rd.__time >= d.start_dt AND rd.__time < d.end_dt AND rd.country = 'IND'
      AND rd.event_type = 'Search-Routes' AND rd.status < 400 AND rd.mri_session_id IS NOT NULL
      AND (rd.akamai_bot IS NULL OR rd.akamai_bot = '')
),
srp_spine AS (
    SELECT DISTINCT si.funnel_date, si.mri_session_id, si.src_id, si.dest_id, ob.operator_name, ob.sort_order
    FROM srp_inventory si
    INNER JOIN rtc_operators ob ON (ob.operator_id IS NOT NULL AND si.operator_id = ob.operator_id)
        OR (ob.operator_id IS NULL AND (si.operator_id NOT IN (16426,15443,24978,32272) OR si.operator_id IS NULL))
),
sl_events AS (
    SELECT DISTINCT sl.mri_session_id, TRY_CAST(sl.src_id AS BIGINT) AS src_id,
           TRY_CAST(sl.dest_id AS BIGINT) AS dest_id, TRY_CAST(sl.route_id AS BIGINT) AS route_id,
           TRY_CAST(sl.op_id AS BIGINT) AS operator_id
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN date_filter d
    INNER JOIN route_pairs rp ON TRY_CAST(sl.src_id AS BIGINT) = rp.src_id AND TRY_CAST(sl.dest_id AS BIGINT) = rp.dest_id
    WHERE sl.__time >= d.start_dt AND sl.__time < d.end_dt AND sl.country = 'IND' AND sl.mri_session_id IS NOT NULL
),
sl_by_operator AS (
    SELECT DISTINCT se.mri_session_id, se.src_id, se.dest_id, se.route_id, ob.operator_name
    FROM sl_events se
    INNER JOIN rtc_operators ob ON (ob.operator_id IS NOT NULL AND se.operator_id = ob.operator_id)
        OR (ob.operator_id IS NULL AND (se.operator_id NOT IN (16426,15443,24978,32272) OR se.operator_id IS NULL))
),
sl_matched AS (
    SELECT DISTINCT s.funnel_date, s.mri_session_id, s.src_id, s.dest_id, sl.route_id, s.operator_name, s.sort_order
    FROM srp_spine s
    INNER JOIN sl_by_operator sl ON s.mri_session_id = sl.mri_session_id AND s.src_id = sl.src_id
       AND s.dest_id = sl.dest_id AND s.operator_name = sl.operator_name
),
cust_info_events AS (
    SELECT DISTINCT ci.mri_session_id, TRY_CAST(ci.route_id AS BIGINT) AS route_id
    FROM user_interaction.cust_info_details ci CROSS JOIN date_filter d
    WHERE ci.__time >= d.start_dt AND ci.__time < d.end_dt AND ci.country = 'IND' AND ci.mri_session_id IS NOT NULL
),
create_order_events AS (
    SELECT DISTINCT co.mri_session_id, TRY_CAST(co.route_id AS BIGINT) AS route_id
    FROM user_interaction.create_order_details co CROSS JOIN date_filter d
    WHERE co.__time >= d.start_dt AND co.__time < d.end_dt AND co.country = 'IND' AND co.mri_session_id IS NOT NULL
),
pay_events AS (
    SELECT DISTINCT mp.mri_session_id
    FROM user_interaction.make_payment_details mp CROSS JOIN date_filter d
    WHERE mp.__time >= d.start_dt AND mp.__time < d.end_dt AND mp.country = 'IND' AND mp.mri_session_id IS NOT NULL
),
funnel_joined AS (
    SELECT s.funnel_date, s.mri_session_id, s.operator_name, s.sort_order, sl.route_id,
           ci.mri_session_id AS ci_session, co.mri_session_id AS co_session, mp.mri_session_id AS pay_session
    FROM srp_spine s
    LEFT JOIN sl_matched sl ON s.funnel_date = sl.funnel_date AND s.mri_session_id = sl.mri_session_id
       AND s.src_id = sl.src_id AND s.dest_id = sl.dest_id AND s.operator_name = sl.operator_name
    LEFT JOIN cust_info_events ci ON sl.mri_session_id = ci.mri_session_id AND sl.route_id = ci.route_id
    LEFT JOIN create_order_events co ON sl.mri_session_id = co.mri_session_id AND sl.route_id = co.route_id
    LEFT JOIN pay_events mp ON sl.mri_session_id = mp.mri_session_id
)
SELECT funnel_date, operator_name,
    COUNT(DISTINCT mri_session_id) AS srp_sessions,
    COUNT(DISTINCT CASE WHEN route_id IS NOT NULL THEN mri_session_id END) AS sl_sessions,
    COUNT(DISTINCT ci_session) AS cust_info_sessions,
    COUNT(DISTINCT co_session) AS create_order_sessions,
    COUNT(DISTINCT pay_session) AS pay_sessions
FROM funnel_joined
GROUP BY funnel_date, operator_name, sort_order
ORDER BY funnel_date, sort_order
