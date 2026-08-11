-- =============================================================================
-- FULL ANALYSIS: Cancellation policy on SL (Android, India BUS, dest_id list)
--   Part A — SL → Confirm funnel (3 cuts: Overall | Seen | Not seen)
--   Part B — Post-confirm cancellations + time-before-DOJ buckets
-- =============================================================================
-- Adjust bounds / cancel_bounds as needed.
-- Verify column names on bus_cancellation_events:
--   cancellation_date_time, date_of_journey, refund_amount, reservation_fee

WITH
bounds AS (
    SELECT
        TIMESTAMP '2026-05-04 00:00:00' AS ts_start,
        TIMESTAMP '2026-05-05 00:00:00' AS ts_end
),

cancel_bounds AS (
    SELECT
        ts_start,
        ts_start + INTERVAL '30' DAY AS ts_end
    FROM bounds
),

cancel_click_sessions AS (
    SELECT DISTINCT e.mri_session_id
    FROM user_interaction.ui_ux_events e
    CROSS JOIN bounds b
    WHERE e.__time >= b.ts_start
      AND e.__time < b.ts_end
      AND e.event_group = 'sl_click_info'
      AND e.event_name = 'busDetailsSectionClicked'
      AND e.event_value = 'Cancellation policy'
      AND e.header_bu = 'BUS'
      AND e.selected_country = 'India'
      AND e.event_src = 'Android'
),

sl_sessions AS (
    SELECT DISTINCT sl.mri_session_id
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN bounds b
    WHERE sl.__time >= b.ts_start
      AND sl.__time < b.ts_end
      AND sl.country = 'IND'
      AND (sl.event_src = 'Android' OR sl.os = 'Android')
      AND sl.dest_id IN (
          134, 71756, 70429, 1001, 663, 802, 197504, 293, 735, 842, 84832, 403,
          76480, 74690, 759, 66007, 747, 808, 427, 960, 501, 1136, 489, 496,
          70628, 217, 94782, 517, 471, 750, 231, 78796, 466, 68747, 83409, 1496,
          77705, 133, 1141, 81826, 77093, 76187, 247, 669, 142, 65815, 77167, 1148,
          70346, 275, 879, 305974, 711, 1007, 177, 74130, 1343, 1242, 1061, 93580,
          975, 65805, 68705, 636, 1128, 84310, 534, 198750, 77687, 1528, 1219, 75103,
          69526, 298723, 194482, 987, 70030, 215191, 520, 74708, 196752, 204358,
          94877, 80438, 1351, 576, 216354, 94509, 70983, 200347, 1459, 68871, 1157,
          196420, 189, 77530, 84848, 196, 94515, 202212, 300439, 93189, 77620, 69475
      )
),

cust_sessions AS (
    SELECT DISTINCT ci.mri_session_id
    FROM user_interaction.cust_info_details ci
    CROSS JOIN bounds b
    WHERE ci.__time >= b.ts_start
      AND ci.__time < b.ts_end
      AND ci.country = 'IND'
),

pay_sessions AS (
    SELECT DISTINCT oi.mri_session_id
    FROM user_interaction.order_info_details oi
    CROSS JOIN bounds b
    WHERE oi.__time >= b.ts_start
      AND oi.__time < b.ts_end
      AND oi.country = 'IND'
),

confirm_rows AS (
    SELECT c.mri_session_id, c.tin
    FROM user_interaction.confirm_order_details c
    CROSS JOIN bounds b
    WHERE c.__time >= b.ts_start
      AND c.__time < b.ts_end
      AND c.country = 'IND'
      AND c.channel = 'MOBILE_APP'
      AND c.os = 'Android'
      AND c.error_code = 'CONFIRMED'
      AND c.status_str = 'SUCCESS'
      AND c.tin IS NOT NULL
      AND c.tin <> ''
      AND c.tin <> 'null'
),

funnel_base AS (
    SELECT
        sl.mri_session_id,
        IF(cc.mri_session_id IS NOT NULL, 1, 0) AS is_cancel_click,
        1 AS has_sl,
        IF(ci.mri_session_id IS NOT NULL, 1, 0) AS has_cust,
        IF(py.mri_session_id IS NOT NULL, 1, 0) AS has_pay,
        IF(cf.mri_session_id IS NOT NULL, 1, 0) AS has_confirm
    FROM sl_sessions sl
    LEFT JOIN cancel_click_sessions cc
        ON sl.mri_session_id = cc.mri_session_id
    LEFT JOIN cust_sessions ci
        ON sl.mri_session_id = ci.mri_session_id
    LEFT JOIN pay_sessions py
        ON sl.mri_session_id = py.mri_session_id
    LEFT JOIN (SELECT DISTINCT mri_session_id FROM confirm_rows) cf
        ON sl.mri_session_id = cf.mri_session_id
),

funnel AS (
    SELECT 'Overall' AS cohort, f.*
    FROM funnel_base f
    UNION ALL
    SELECT 'Seen cancellation policy' AS cohort, f.*
    FROM funnel_base f
    WHERE f.is_cancel_click = 1
    UNION ALL
    SELECT 'Not seen cancellation policy' AS cohort, f.*
    FROM funnel_base f
    WHERE f.is_cancel_click = 0
),

-- ---------------------------------------------------------------------------
-- Part A: Funnel metrics
-- ---------------------------------------------------------------------------
metrics AS (
    SELECT
        cohort,
        COUNT(*) AS sl_sessions,
        SUM(CASE WHEN has_sl = 1 AND has_cust = 1 THEN 1 ELSE 0 END) AS custinfo_sessions,
        SUM(CASE WHEN has_sl = 1 AND has_cust = 1 AND has_pay = 1 THEN 1 ELSE 0 END) AS pay_sessions,
        SUM(CASE WHEN has_sl = 1 AND has_cust = 1 AND has_pay = 1 AND has_confirm = 1 THEN 1 ELSE 0 END) AS confirm_sessions
    FROM funnel
    GROUP BY 1
),

tins AS (
    SELECT
        f.cohort,
        COUNT(DISTINCT c.tin) AS tins
    FROM funnel f
    INNER JOIN confirm_rows c
        ON f.mri_session_id = c.mri_session_id
    WHERE f.has_sl = 1
      AND f.has_cust = 1
      AND f.has_pay = 1
    GROUP BY 1
),

funnel_report AS (
    SELECT
        'A_FUNNEL' AS report_section,
        m.cohort,
        m.sl_sessions,
        m.custinfo_sessions,
        m.pay_sessions,
        m.confirm_sessions,
        COALESCE(t.tins, 0) AS tins,
        ROUND(100.0 * m.custinfo_sessions / NULLIF(m.sl_sessions, 0), 2) AS pct_sl_to_custinfo,
        ROUND(100.0 * m.pay_sessions / NULLIF(m.custinfo_sessions, 0), 2) AS pct_custinfo_to_pay,
        ROUND(100.0 * m.confirm_sessions / NULLIF(m.pay_sessions, 0), 2) AS pct_pay_to_confirm,
        ROUND(100.0 * m.confirm_sessions / NULLIF(m.sl_sessions, 0), 2) AS pct_sl_to_confirm,
        CAST(NULL AS BIGINT) AS confirmed_tins,
        CAST(NULL AS BIGINT) AS cancelled_tins,
        CAST(NULL AS DOUBLE) AS pct_confirmed_cancelled,
        CAST(NULL AS VARCHAR) AS time_before_doj_bucket,
        CAST(NULL AS BIGINT) AS cancelled_tins_in_bucket,
        CAST(NULL AS DOUBLE) AS pct_of_cancelled_in_bucket,
        CAST(NULL AS DOUBLE) AS total_refund_amount,
        CAST(NULL AS DOUBLE) AS total_reservation_fee,
        CAST(NULL AS DOUBLE) AS avg_refund_amount,
        CAST(NULL AS DOUBLE) AS avg_reservation_fee
    FROM metrics m
    LEFT JOIN tins t
        ON m.cohort = t.cohort
),

-- ---------------------------------------------------------------------------
-- Part B: Post-confirm cancellations (transaction.bus_cancellation_events)
-- ---------------------------------------------------------------------------
confirmed_tins AS (
    SELECT DISTINCT
        f.cohort,
        c.tin
    FROM funnel f
    INNER JOIN confirm_rows c
        ON f.mri_session_id = c.mri_session_id
    WHERE f.has_sl = 1
      AND f.has_cust = 1
      AND f.has_pay = 1
      AND f.has_confirm = 1
),

bus_cancellations_raw AS (
    SELECT
        bc.tin,
        COALESCE(bc.cancellation_date_time, bc.time_of_event) AS cancel_ts,
        CAST(bc.date_of_journey AS TIMESTAMP) AS doj_ts,
        CAST(bc.refund_amount AS DOUBLE) AS refund_amount,
        CAST(bc.reservation_fee AS DOUBLE) AS reservation_fee
    FROM transaction.bus_cancellation_events bc
    CROSS JOIN cancel_bounds cb
    WHERE bc.time_of_event >= cb.ts_start
      AND bc.time_of_event < cb.ts_end
      AND bc.event_class = 2
      AND bc.event_type = 201
      AND bc.tin IS NOT NULL
      AND bc.tin <> ''
      AND bc.tin <> 'null'
),

bus_cancellations AS (
    SELECT tin, cancel_ts, doj_ts, refund_amount, reservation_fee
    FROM (
        SELECT
            tin,
            cancel_ts,
            doj_ts,
            refund_amount,
            reservation_fee,
            ROW_NUMBER() OVER (
                PARTITION BY tin
                ORDER BY cancel_ts DESC
            ) AS rn
        FROM bus_cancellations_raw
        WHERE cancel_ts IS NOT NULL
          AND doj_ts IS NOT NULL
    ) x
    WHERE rn = 1
),

confirmed_with_cancel AS (
    SELECT
        ct.cohort,
        ct.tin,
        bc.cancel_ts,
        bc.doj_ts,
        bc.refund_amount,
        bc.reservation_fee,
        DATE_DIFF('hour', bc.cancel_ts, bc.doj_ts) AS hours_before_doj
    FROM confirmed_tins ct
    LEFT JOIN bus_cancellations bc
        ON ct.tin = bc.tin
),

with_bucket AS (
    SELECT
        cohort,
        tin,
        cancel_ts,
        doj_ts,
        refund_amount,
        reservation_fee,
        hours_before_doj,
        CASE
            WHEN cancel_ts IS NULL THEN 'Not cancelled'
            WHEN hours_before_doj < 0 THEN 'Cancelled after DOJ'
            WHEN hours_before_doj < 4 THEN '0-4 hours'
            WHEN hours_before_doj < 8 THEN '4-8 hours'
            WHEN hours_before_doj < 12 THEN '8-12 hours'
            WHEN hours_before_doj < 16 THEN '12-16 hours'
            WHEN hours_before_doj < 20 THEN '16-20 hours'
            WHEN hours_before_doj < 24 THEN '20-24 hours'
            WHEN hours_before_doj < 48 THEN '1-2 Days'
            WHEN hours_before_doj < 72 THEN '2-3 Days'
            WHEN hours_before_doj < 96 THEN '3-4 Days'
            WHEN hours_before_doj < 120 THEN '4-5 Days'
            ELSE '5+ Days'
        END AS time_before_doj_bucket
    FROM confirmed_with_cancel
),

confirm_summary AS (
    SELECT
        cohort,
        COUNT(DISTINCT tin) AS confirmed_tins,
        COUNT(DISTINCT CASE WHEN cancel_ts IS NOT NULL THEN tin END) AS cancelled_tins,
        ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN cancel_ts IS NOT NULL THEN tin END)
            / NULLIF(COUNT(DISTINCT tin), 0),
            2
        ) AS pct_confirmed_cancelled,
        ROUND(SUM(COALESCE(refund_amount, 0)), 2) AS total_refund_amount,
        ROUND(SUM(COALESCE(reservation_fee, 0)), 2) AS total_reservation_fee,
        ROUND(
            AVG(CASE WHEN cancel_ts IS NOT NULL THEN refund_amount END),
            2
        ) AS avg_refund_amount,
        ROUND(
            AVG(CASE WHEN cancel_ts IS NOT NULL THEN reservation_fee END),
            2
        ) AS avg_reservation_fee
    FROM with_bucket
    GROUP BY 1
),

cancel_summary_report AS (
    SELECT
        'B_CANCEL_SUMMARY' AS report_section,
        s.cohort,
        CAST(NULL AS BIGINT) AS sl_sessions,
        CAST(NULL AS BIGINT) AS custinfo_sessions,
        CAST(NULL AS BIGINT) AS pay_sessions,
        CAST(NULL AS BIGINT) AS confirm_sessions,
        CAST(NULL AS BIGINT) AS tins,
        CAST(NULL AS DOUBLE) AS pct_sl_to_custinfo,
        CAST(NULL AS DOUBLE) AS pct_custinfo_to_pay,
        CAST(NULL AS DOUBLE) AS pct_pay_to_confirm,
        CAST(NULL AS DOUBLE) AS pct_sl_to_confirm,
        s.confirmed_tins,
        s.cancelled_tins,
        s.pct_confirmed_cancelled,
        CAST(NULL AS VARCHAR) AS time_before_doj_bucket,
        CAST(NULL AS BIGINT) AS cancelled_tins_in_bucket,
        CAST(NULL AS DOUBLE) AS pct_of_cancelled_in_bucket,
        s.total_refund_amount,
        s.total_reservation_fee,
        s.avg_refund_amount,
        s.avg_reservation_fee
    FROM confirm_summary s
),

cancel_bucket_counts AS (
    SELECT
        cohort,
        time_before_doj_bucket,
        COUNT(DISTINCT tin) AS cancelled_tins_in_bucket,
        ROUND(SUM(COALESCE(refund_amount, 0)), 2) AS total_refund_amount,
        ROUND(SUM(COALESCE(reservation_fee, 0)), 2) AS total_reservation_fee,
        ROUND(AVG(refund_amount), 2) AS avg_refund_amount,
        ROUND(AVG(reservation_fee), 2) AS avg_reservation_fee
    FROM with_bucket
    WHERE cancel_ts IS NOT NULL
    GROUP BY 1, 2
),

cancel_bucket_report AS (
    SELECT
        'C_CANCEL_TIME_BUCKETS' AS report_section,
        s.cohort,
        CAST(NULL AS BIGINT) AS sl_sessions,
        CAST(NULL AS BIGINT) AS custinfo_sessions,
        CAST(NULL AS BIGINT) AS pay_sessions,
        CAST(NULL AS BIGINT) AS confirm_sessions,
        CAST(NULL AS BIGINT) AS tins,
        CAST(NULL AS DOUBLE) AS pct_sl_to_custinfo,
        CAST(NULL AS DOUBLE) AS pct_custinfo_to_pay,
        CAST(NULL AS DOUBLE) AS pct_pay_to_confirm,
        CAST(NULL AS DOUBLE) AS pct_sl_to_confirm,
        s.confirmed_tins,
        s.cancelled_tins,
        s.pct_confirmed_cancelled,
        b.time_before_doj_bucket,
        b.cancelled_tins_in_bucket,
        ROUND(
            100.0 * b.cancelled_tins_in_bucket / NULLIF(s.cancelled_tins, 0),
            2
        ) AS pct_of_cancelled_in_bucket,
        b.total_refund_amount,
        b.total_reservation_fee,
        b.avg_refund_amount,
        b.avg_reservation_fee
    FROM confirm_summary s
    INNER JOIN cancel_bucket_counts b
        ON s.cohort = b.cohort
)

SELECT *
FROM funnel_report

UNION ALL

SELECT *
FROM cancel_summary_report

UNION ALL

SELECT *
FROM cancel_bucket_report

ORDER BY
    report_section,
    CASE cohort
        WHEN 'Overall' THEN 1
        WHEN 'Seen cancellation policy' THEN 2
        WHEN 'Not seen cancellation policy' THEN 3
        ELSE 4
    END,
    CASE time_before_doj_bucket
        WHEN '0-4 hours' THEN 1
        WHEN '4-8 hours' THEN 2
        WHEN '8-12 hours' THEN 3
        WHEN '12-16 hours' THEN 4
        WHEN '16-20 hours' THEN 5
        WHEN '20-24 hours' THEN 6
        WHEN '1-2 Days' THEN 7
        WHEN '2-3 Days' THEN 8
        WHEN '3-4 Days' THEN 9
        WHEN '4-5 Days' THEN 10
        WHEN '5+ Days' THEN 11
        WHEN 'Cancelled after DOJ' THEN 12
        ELSE 99
    END;
