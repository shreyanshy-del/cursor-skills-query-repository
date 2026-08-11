-- SL funnel (dest_id list) + post-confirm cancellations from transaction.bus_cancellation_events
-- Time before journey = date_of_journey - cancellation timestamp (hours)
-- Cancellations looked up up to 30 days after confirm window (adjust cancel_bounds if needed)

WITH
bounds AS (
    SELECT
        TIMESTAMP '2026-05-04 00:00:00' AS ts_start,
        TIMESTAMP '2026-05-05 00:00:00' AS ts_end
),

-- Wider window to capture cancellations after booking day
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
    SELECT DISTINCT
        sl.mri_session_id,
        sl.dest_id
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

funnel AS (
    SELECT
        sl.dest_id,
        sl.mri_session_id,
        CASE
            WHEN cc.mri_session_id IS NOT NULL THEN 'Cancellation policy click'
            ELSE 'Rest (no cancellation policy click)'
        END AS cohort,
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

-- Confirmed bookings from funnel (strict path), one row per dest_id + cohort + tin
confirmed_tins AS (
    SELECT DISTINCT
        f.dest_id,
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
        bc.time_of_event
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

-- One cancellation record per tin (latest in window)
bus_cancellations AS (
    SELECT tin, cancel_ts, doj_ts
    FROM (
        SELECT
            tin,
            cancel_ts,
            doj_ts,
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
        ct.dest_id,
        ct.cohort,
        ct.tin,
        bc.cancel_ts,
        bc.doj_ts,
        DATE_DIFF('hour', bc.cancel_ts, bc.doj_ts) AS hours_before_doj
    FROM confirmed_tins ct
    LEFT JOIN bus_cancellations bc
        ON ct.tin = bc.tin
),

with_bucket AS (
    SELECT
        dest_id,
        cohort,
        tin,
        cancel_ts,
        doj_ts,
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

-- Summary: confirmed vs cancelled counts per dest_id + cohort
confirm_summary AS (
    SELECT
        dest_id,
        cohort,
        COUNT(DISTINCT tin) AS confirmed_tins,
        COUNT(DISTINCT CASE WHEN cancel_ts IS NOT NULL THEN tin END) AS cancelled_tins,
        ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN cancel_ts IS NOT NULL THEN tin END)
            / NULLIF(COUNT(DISTINCT tin), 0),
            2
        ) AS pct_confirmed_cancelled
    FROM with_bucket
    GROUP BY 1, 2
),

-- Distribution among cancelled only
cancel_bucket_counts AS (
    SELECT
        dest_id,
        cohort,
        time_before_doj_bucket,
        COUNT(DISTINCT tin) AS cancelled_tins_in_bucket
    FROM with_bucket
    WHERE cancel_ts IS NOT NULL
      AND time_before_doj_bucket NOT IN ('Cancelled after DOJ')
    GROUP BY 1, 2, 3
)

SELECT
    s.dest_id,
    s.cohort,
    s.confirmed_tins,
    s.cancelled_tins,
    s.pct_confirmed_cancelled,
    b.time_before_doj_bucket,
    COALESCE(b.cancelled_tins_in_bucket, 0) AS cancelled_tins_in_bucket,
    ROUND(
        100.0 * COALESCE(b.cancelled_tins_in_bucket, 0)
        / NULLIF(s.cancelled_tins, 0),
        2
    ) AS pct_of_cancelled_in_bucket
FROM confirm_summary s
LEFT JOIN cancel_bucket_counts b
    ON s.dest_id = b.dest_id
   AND s.cohort = b.cohort
ORDER BY
    s.dest_id,
    s.cohort,
    CASE b.time_before_doj_bucket
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
