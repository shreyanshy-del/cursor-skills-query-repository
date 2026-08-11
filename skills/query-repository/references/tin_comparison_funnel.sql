-- Funnel confirm_tins total (RTC operators) using rtc-derived route pairs
WITH params AS (
    SELECT
        TIMESTAMP '2026-05-20 00:00:00' AS t_start,
        TIMESTAMP '2026-06-11 00:00:00' AS t_end
),

route_pairs AS (
    SELECT DISTINCT
        b.source_location_id AS src_id,
        b.destination_location_id AS dest_id
    FROM transaction.bus_ticket_events b
    CROSS JOIN params p
    WHERE b.date_of_issue >= p.t_start
      AND b.date_of_issue < p.t_end
      AND b.event_class = 2
      AND b.event_type = 101
      AND b.country_code = 'IND'
      AND b.operator_id IN (16426, 15443, 24978, 32272)
),

operator_buckets AS (
    SELECT *
    FROM (VALUES
        ('WBTC',  16426, 1),
        ('WBSTC', 15443, 2),
        ('NBSTC', 24978, 3),
        ('SBSTC', 32272, 4)
    ) AS t(operator_name, operator_id, sort_order)
),

srp_inventory AS (
    SELECT
        CAST(DATE_ADD('minute', 330, rd.__time) AS DATE) AS funnel_date,
        rd.mri_session_id,
        TRY_CAST(rd.src_id AS BIGINT) AS src_id,
        TRY_CAST(rd.dest_id AS BIGINT) AS dest_id,
        TRY_CAST(COALESCE(rd.operator_id, rd.op_id) AS BIGINT) AS operator_id
    FROM user_interaction.search_route_details rd
    CROSS JOIN params p
    INNER JOIN route_pairs rp
        ON TRY_CAST(rd.src_id AS BIGINT) = rp.src_id
       AND TRY_CAST(rd.dest_id AS BIGINT) = rp.dest_id
    WHERE rd.__time >= p.t_start
      AND rd.__time < p.t_end
      AND rd.country = 'IND'
      AND rd.event_type = 'Search-Routes'
      AND rd.status < 400
      AND rd.mri_session_id IS NOT NULL
      AND (rd.akamai_bot IS NULL OR rd.akamai_bot = '')
),

srp_spine AS (
    SELECT DISTINCT
        si.funnel_date,
        si.mri_session_id,
        si.src_id,
        si.dest_id,
        ob.operator_name,
        ob.sort_order
    FROM srp_inventory si
    INNER JOIN operator_buckets ob
        ON si.operator_id = ob.operator_id
),

sl_events AS (
    SELECT DISTINCT
        sl.mri_session_id,
        TRY_CAST(sl.src_id AS BIGINT) AS src_id,
        TRY_CAST(sl.dest_id AS BIGINT) AS dest_id,
        TRY_CAST(sl.route_id AS BIGINT) AS route_id,
        TRY_CAST(sl.op_id AS BIGINT) AS operator_id
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN params p
    INNER JOIN route_pairs rp
        ON TRY_CAST(sl.src_id AS BIGINT) = rp.src_id
       AND TRY_CAST(sl.dest_id AS BIGINT) = rp.dest_id
    WHERE sl.__time >= p.t_start
      AND sl.__time < p.t_end
      AND sl.country = 'IND'
      AND sl.mri_session_id IS NOT NULL
),

sl_by_operator AS (
    SELECT DISTINCT
        se.mri_session_id,
        se.src_id,
        se.dest_id,
        se.route_id,
        ob.operator_name
    FROM sl_events se
    INNER JOIN operator_buckets ob
        ON se.operator_id = ob.operator_id
),

sl_matched AS (
    SELECT DISTINCT
        s.funnel_date,
        s.mri_session_id,
        s.src_id,
        s.dest_id,
        sl.route_id,
        s.operator_name,
        s.sort_order
    FROM srp_spine s
    INNER JOIN sl_by_operator sl
        ON s.mri_session_id = sl.mri_session_id
       AND s.src_id = sl.src_id
       AND s.dest_id = sl.dest_id
       AND s.operator_name = sl.operator_name
),

confirm_tin AS (
    SELECT DISTINCT
        cf.mri_session_id,
        cf.tin,
        b.source_location_id AS src_id,
        b.destination_location_id AS dest_id,
        b.route_id,
        CASE
            WHEN b.operator_id = 16426 THEN 'WBTC'
            WHEN b.operator_id = 15443 THEN 'WBSTC'
            WHEN b.operator_id = 24978 THEN 'NBSTC'
            WHEN b.operator_id = 32272 THEN 'SBSTC'
        END AS operator_name
    FROM user_interaction.confirm_order_details cf
    CROSS JOIN params p
    INNER JOIN transaction.bus_ticket_events b
        ON cf.mri_session_id = b.mri_session_id
       AND cf.tin = b.tin
    INNER JOIN route_pairs rp
        ON b.source_location_id = rp.src_id
       AND b.destination_location_id = rp.dest_id
    WHERE cf.__time >= p.t_start
      AND cf.__time < p.t_end
      AND cf.mri_session_id IS NOT NULL
      AND cf.country = 'IND'
      AND cf.error_code = 'CONFIRMED'
      AND cf.status_str = 'SUCCESS'
      AND cf.tin IS NOT NULL
      AND TRIM(cf.tin) <> ''
      AND LOWER(TRIM(cf.tin)) <> 'null'
      AND b.date_of_issue >= p.t_start
      AND b.date_of_issue < p.t_end
      AND b.event_class = 2
      AND b.event_type = 101
      AND b.country_code = 'IND'
      AND b.operator_id IN (16426, 15443, 24978, 32272)
),

funnel_joined AS (
    SELECT
        s.operator_name,
        cf.tin
    FROM srp_spine s
    INNER JOIN sl_matched sl
        ON s.funnel_date = sl.funnel_date
       AND s.mri_session_id = sl.mri_session_id
       AND s.src_id = sl.src_id
       AND s.dest_id = sl.dest_id
       AND s.operator_name = sl.operator_name
    INNER JOIN confirm_tin cf
        ON sl.mri_session_id = cf.mri_session_id
       AND sl.src_id = cf.src_id
       AND sl.dest_id = cf.dest_id
       AND sl.route_id = cf.route_id
       AND s.operator_name = cf.operator_name
),

confirm_only AS (
    SELECT operator_name, tin FROM confirm_tin
)

SELECT
    COALESCE(operator_name, 'ALL_RTC') AS operator_name,
    COUNT(DISTINCT tin) AS funnel_matched_tins
FROM funnel_joined
GROUP BY GROUPING SETS ((operator_name), ())
