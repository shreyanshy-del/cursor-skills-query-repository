-- =============================================================================
-- Funnel export: SRP → SL → Cust Info → Create Order → Payment Page → Pay Now → Order Confirmed
-- Engine: Trino-style. Tables: align with your Iceberg catalog (see NOTEs below).
--
-- Cohort: distinct mri_session_id with search (SRP) in [t_start, t_end).
-- Funnel_date: first calendar day of SRP in that window (for daily / WoW / MoM joins).
--
-- Steps 4–6 (Create order / Payment page / Pay now): placeholders — replace CTE bodies
-- when you confirm table + column names. Until then they return no rows (has_* stays 0).
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-01-01 00:00:00' AS t_start,
        TIMESTAMP '2026-02-01 00:00:00' AS t_end
),

srp AS (
    SELECT
        mri_session_id,
        MIN(DATE(__time)) AS funnel_date,
        ARBITRARY(channel) AS channel
    FROM user_interaction.search_details
    CROSS JOIN params p
    WHERE __time >= p.t_start
      AND __time < p.t_end
      AND country = 'IND'
    GROUP BY 1
),

sl AS (
    SELECT DISTINCT mri_session_id
    FROM user_interaction.seat_layout_details
    CROSS JOIN params p
    WHERE __time >= p.t_start
      AND __time < p.t_end
      AND country = 'IND'
),

cust AS (
    SELECT DISTINCT mri_session_id
    FROM user_interaction.cust_info_details
    CROSS JOIN params p
    WHERE __time >= p.t_start
      AND __time < p.t_end
),

-- TODO: replace with real interaction tables / event filters for your pipeline.
co AS (
    SELECT mri_session_id
    FROM (VALUES (CAST('' AS VARCHAR))) AS t(mri_session_id)
    WHERE FALSE
),
pp AS (
    SELECT mri_session_id
    FROM (VALUES (CAST('' AS VARCHAR))) AS t(mri_session_id)
    WHERE FALSE
),
pn AS (
    SELECT mri_session_id
    FROM (VALUES (CAST('' AS VARCHAR))) AS t(mri_session_id)
    WHERE FALSE
),

oc AS (
    SELECT DISTINCT mri_session_id
    FROM user_interaction.confirm_order_details
    CROSS JOIN params p
    WHERE __time >= p.t_start
      AND __time < p.t_end
      AND country = 'IND'
      AND status_str = 'SUCCESS'
),

base AS (
    SELECT
        s.mri_session_id,
        s.funnel_date,
        s.channel,
        (sl.mri_session_id IS NOT NULL) AS has_sl,
        (cust.mri_session_id IS NOT NULL) AS has_cust,
        (co.mri_session_id IS NOT NULL) AS has_co,
        (pp.mri_session_id IS NOT NULL) AS has_pp,
        (pn.mri_session_id IS NOT NULL) AS has_pn,
        (oc.mri_session_id IS NOT NULL) AS has_oc
    FROM srp s
    LEFT JOIN sl ON sl.mri_session_id = s.mri_session_id
    LEFT JOIN cust ON cust.mri_session_id = s.mri_session_id
    LEFT JOIN co ON co.mri_session_id = s.mri_session_id
    LEFT JOIN pp ON pp.mri_session_id = s.mri_session_id
    LEFT JOIN pn ON pn.mri_session_id = s.mri_session_id
    LEFT JOIN oc ON oc.mri_session_id = s.mri_session_id
),

-- Strict cumulative funnel: must complete earlier steps before later counts as "reached".
with_depth AS (
    SELECT
        mri_session_id,
        funnel_date,
        channel,
        CASE
            WHEN has_sl AND has_cust AND has_co AND has_pp AND has_pn AND has_oc THEN 6
            WHEN has_sl AND has_cust AND has_co AND has_pp AND has_pn THEN 5
            WHEN has_sl AND has_cust AND has_co AND has_pp THEN 4
            WHEN has_sl AND has_cust AND has_co THEN 3
            WHEN has_sl AND has_cust THEN 2
            WHEN has_sl THEN 1
            ELSE 0
        END AS depth
    FROM base
)

-- CSV-friendly export for the HTML dashboard (see funnel-export README in HTML).
SELECT
    CAST(funnel_date AS VARCHAR) AS dateKey,
    CAST(mri_session_id AS VARCHAR) AS session_id,
    depth,
    channel,
    CAST('BUS' AS VARCHAR) AS vertical,
    CAST('RETURNING' AS VARCHAR) AS customer_type,
    CAST('Private' AS VARCHAR) AS op_type,
    CAST('South' AS VARCHAR) AS region,
    CAST('L0_EN' AS VARCHAR) AS vernac,
    CAST('v5' AS VARCHAR) AS api,
    CAST('Other' AS VARCHAR) AS route,
    CAST('Non-Primo' AS VARCHAR) AS primo,
    CAST('Non_GDS' AS VARCHAR) AS gds,
    CAST('1_Next_day' AS VARCHAR) AS dbd,
    CAST('Non_Sameday' AS VARCHAR) AS lmb,
    CAST('Organic' AS VARCHAR) AS traffic_source
FROM with_depth;

-- =============================================================================
-- Sanity: step volumes (denominator = SRP sessions in window)
-- =============================================================================
/*
WITH params AS (
    SELECT TIMESTAMP '2026-01-01 00:00:00' AS t_start, TIMESTAMP '2026-02-01 00:00:00' AS t_end
),
srp AS (
    SELECT DISTINCT mri_session_id
    FROM user_interaction.search_details
    CROSS JOIN params p
    WHERE __time >= p.t_start AND __time < p.t_end AND country = 'IND'
),
sl AS (
    SELECT DISTINCT mri_session_id FROM user_interaction.seat_layout_details
    CROSS JOIN params p WHERE __time >= p.t_start AND __time < p.t_end AND country = 'IND'
),
cust AS (
    SELECT DISTINCT mri_session_id FROM user_interaction.cust_info_details
    CROSS JOIN params p WHERE __time >= p.t_start AND __time < p.t_end
),
oc AS (
    SELECT DISTINCT mri_session_id FROM user_interaction.confirm_order_details
    CROSS JOIN params p
    WHERE __time >= p.t_start AND __time < p.t_end AND country = 'IND' AND status_str = 'SUCCESS'
)
SELECT
    (SELECT COUNT(*) FROM srp) AS srp_sessions,
    (SELECT COUNT(*) FROM srp s INNER JOIN sl l ON l.mri_session_id = s.mri_session_id) AS srp_and_sl,
    (SELECT COUNT(*) FROM srp s INNER JOIN sl l ON l.mri_session_id = s.mri_session_id
       INNER JOIN cust c ON c.mri_session_id = s.mri_session_id) AS srp_sl_cust,
    (SELECT COUNT(*) FROM srp s INNER JOIN oc o ON o.mri_session_id = s.mri_session_id) AS srp_and_confirm;
*/

-- =============================================================================
-- Daily export (matches Power BI "Channel_Funnel" table — one row per day × slice)
-- Each column = COUNT(DISTINCT mri_session_id) for that step in that calendar day.
-- Payment can exceed Create Order if definitions differ (e.g. retries, alternate paths).
-- Replace pp/pn/co CTEs when wired; below uses placeholders for those three steps.
-- =============================================================================
/*
WITH params AS (
    SELECT TIMESTAMP '2026-03-16 00:00:00' AS t_start, TIMESTAMP '2026-05-15 00:00:00' AS t_end
),
srp AS (
    SELECT DATE(__time) AS d, mri_session_id, ARBITRARY(os) AS sales_channel
    FROM user_interaction.search_details
    CROSS JOIN params p
    WHERE __time >= p.t_start AND __time < p.t_end AND country = 'IND'
    GROUP BY 1, 2
),
sl AS (
    SELECT DATE(__time) AS d, mri_session_id
    FROM user_interaction.seat_layout_details
    CROSS JOIN params p
    WHERE __time >= p.t_start AND __time < p.t_end AND country = 'IND'
    GROUP BY 1, 2
),
cust AS (
    SELECT DATE(__time) AS d, mri_session_id
    FROM user_interaction.cust_info_details
    CROSS JOIN params p
    WHERE __time >= p.t_start AND __time < p.t_end
    GROUP BY 1, 2
),
oc AS (
    SELECT DATE(__time) AS d, mri_session_id
    FROM user_interaction.confirm_order_details
    CROSS JOIN params p
    WHERE __time >= p.t_start AND __time < p.t_end AND country = 'IND' AND status_str = 'SUCCESS'
    GROUP BY 1, 2
)
SELECT
    CAST(s.d AS VARCHAR) AS date,
    s.sales_channel AS channel,
    COUNT(DISTINCT s.mri_session_id) AS srp,
    COUNT(DISTINCT l.mri_session_id) AS sl,
    COUNT(DISTINCT c.mri_session_id) AS cust,
    CAST(NULL AS BIGINT) AS create_order,
    CAST(NULL AS BIGINT) AS payment,
    CAST(NULL AS BIGINT) AS pay_now,
    COUNT(DISTINCT o.mri_session_id) AS order_confirmed
FROM srp s
LEFT JOIN sl l ON l.mri_session_id = s.mri_session_id AND l.d = s.d
LEFT JOIN cust c ON c.mri_session_id = s.mri_session_id AND c.d = s.d
LEFT JOIN oc o ON o.mri_session_id = s.mri_session_id AND o.d = s.d
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
*/
