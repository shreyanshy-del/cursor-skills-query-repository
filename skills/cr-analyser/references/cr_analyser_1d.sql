-- =============================================================================
-- CR Analyser — India BUS CR + funnel throughput (mri_session_id grain)
-- Skill: cr-analyser
--
-- SRP  = user_interaction.search_details
-- SL   = seat_layout_details
-- CI   = cust_info_details
-- TCO  = create_order_details
-- PAY  = order_info_details
-- PAY_NOW = make_payment_details
-- CONFIRM / TIN = transaction.bus_ticket_events
--                 event_type = 101, event_class = 2
--
-- Joins: mri_session_id only (no route_id, no channel cut).
--
-- Ordered rates:
--   1) SRP → SL       = SL / SRP
--   2) SL → CI        = CI / SL
--   3) CI → TCO       = TCO / CI
--   4) TCO → PAY      = PAY / TCO
--   5) PAY → PAY_NOW  = PAY_NOW / PAY
--   6) PAY_NOW → CONFIRM = TIN / PAY_NOW
--   7) CR             = TIN / SRP
-- Identity: CR = (1)×(2)×(3)×(4)×(5)×(6)  → identity_ok must be true
--
-- Change only t_start / t_end. Example window = 4 Oct 2026 IST.
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-10-03 18:30:00' AS t_start,
        TIMESTAMP '2026-10-04 18:30:00' AS t_end
),

srp AS (
    SELECT DISTINCT sd.mri_session_id
    FROM user_interaction.search_details sd
    CROSS JOIN params p
    WHERE sd.__time >= p.t_start
      AND sd.__time <  p.t_end
      AND sd.country = 'IND'
      AND sd.mri_session_id IS NOT NULL
),

sl AS (
    SELECT DISTINCT sl.mri_session_id
    FROM user_interaction.seat_layout_details sl
    INNER JOIN srp s ON sl.mri_session_id = s.mri_session_id
    CROSS JOIN params p
    WHERE sl.__time >= p.t_start
      AND sl.__time <  p.t_end
      AND sl.country = 'IND'
),

ci AS (
    SELECT DISTINCT ci.mri_session_id
    FROM user_interaction.cust_info_details ci
    INNER JOIN srp s ON ci.mri_session_id = s.mri_session_id
    CROSS JOIN params p
    WHERE ci.__time >= p.t_start
      AND ci.__time <  p.t_end
),

tco AS (
    SELECT DISTINCT co.mri_session_id
    FROM user_interaction.create_order_details co
    INNER JOIN srp s ON co.mri_session_id = s.mri_session_id
    CROSS JOIN params p
    WHERE co.__time >= p.t_start
      AND co.__time <  p.t_end
),

pay AS (
    SELECT DISTINCT oi.mri_session_id
    FROM user_interaction.order_info_details oi
    INNER JOIN srp s ON oi.mri_session_id = s.mri_session_id
    CROSS JOIN params p
    WHERE oi.__time >= p.t_start
      AND oi.__time <  p.t_end
),

pay_now AS (
    SELECT DISTINCT mp.mri_session_id
    FROM user_interaction.make_payment_details mp
    INNER JOIN srp s ON mp.mri_session_id = s.mri_session_id
    CROSS JOIN params p
    WHERE mp.__time >= p.t_start
      AND mp.__time <  p.t_end
),

bte AS (
    SELECT
        bte.mri_session_id,
        bte.tin
    FROM transaction.bus_ticket_events bte
    INNER JOIN srp s ON bte.mri_session_id = s.mri_session_id
    CROSS JOIN params p
    WHERE bte.time_of_event >= p.t_start
      AND bte.time_of_event <  p.t_end
      AND bte.country_code = 'IND'
      AND bte.event_type = 101
      AND bte.event_class = 2
      AND bte.tin IS NOT NULL
      AND bte.tin NOT IN ('', 'null')
),

counts AS (
    SELECT
        (SELECT COUNT(*) FROM srp) AS srpload,
        (SELECT COUNT(*) FROM sl) AS slload,
        (SELECT COUNT(*) FROM ci) AS ci_load,
        (SELECT COUNT(*) FROM tco) AS tcoload,
        (SELECT COUNT(*) FROM pay) AS paymentload,
        (SELECT COUNT(*) FROM pay_now) AS add_pay,
        (SELECT COUNT(DISTINCT mri_session_id) FROM bte) AS confirm_sessions,
        (SELECT COUNT(DISTINCT tin) FROM bte) AS tin
)

SELECT
    -- Raw counts
    c.srpload,
    c.slload,
    c.ci_load,
    c.tcoload,
    c.paymentload,
    c.add_pay,
    c.confirm_sessions,
    c.tin,

    -- 1) SRP → SL
    ROUND(100.0 * c.slload / NULLIF(c.srpload, 0), 6) AS step1_srp_to_sl_pct,
    -- 2) SL → CI
    ROUND(100.0 * c.ci_load / NULLIF(c.slload, 0), 6) AS step2_sl_to_ci_pct,
    -- 3) CI → TCO
    ROUND(100.0 * c.tcoload / NULLIF(c.ci_load, 0), 6) AS step3_ci_to_tco_pct,
    -- 4) TCO → PAY
    ROUND(100.0 * c.paymentload / NULLIF(c.tcoload, 0), 6) AS step4_tco_to_pay_pct,
    -- 5) PAY → PAY_NOW
    ROUND(100.0 * c.add_pay / NULLIF(c.paymentload, 0), 6) AS step5_pay_to_pay_now_pct,
    -- 6) PAY_NOW → CONFIRM  (CONFIRM := distinct TIN from BTE)
    ROUND(100.0 * c.tin / NULLIF(c.add_pay, 0), 6) AS step6_pay_now_to_confirm_pct,
    -- 7) CR = TIN / SRP
    ROUND(100.0 * c.tin / NULLIF(c.srpload, 0), 6) AS step7_cr_tin_per_srp_pct,

    -- Product of step rates (fractions) → should equal CR fraction
    ROUND(
        100.0 * (
            (CAST(c.slload AS DOUBLE) / NULLIF(c.srpload, 0))
          * (CAST(c.ci_load AS DOUBLE) / NULLIF(c.slload, 0))
          * (CAST(c.tcoload AS DOUBLE) / NULLIF(c.ci_load, 0))
          * (CAST(c.paymentload AS DOUBLE) / NULLIF(c.tcoload, 0))
          * (CAST(c.add_pay AS DOUBLE) / NULLIF(c.paymentload, 0))
          * (CAST(c.tin AS DOUBLE) / NULLIF(c.add_pay, 0))
        ),
        6
    ) AS product_1_to_6_pct,

    CASE
        WHEN c.srpload = 0
          OR c.slload = 0
          OR c.ci_load = 0
          OR c.tcoload = 0
          OR c.paymentload = 0
          OR c.add_pay = 0
        THEN FALSE
        WHEN ABS(
            (
                (CAST(c.slload AS DOUBLE) / c.srpload)
              * (CAST(c.ci_load AS DOUBLE) / c.slload)
              * (CAST(c.tcoload AS DOUBLE) / c.ci_load)
              * (CAST(c.paymentload AS DOUBLE) / c.tcoload)
              * (CAST(c.add_pay AS DOUBLE) / c.paymentload)
              * (CAST(c.tin AS DOUBLE) / c.add_pay)
            )
            - (CAST(c.tin AS DOUBLE) / c.srpload)
        ) <= 1e-9
        THEN TRUE
        ELSE FALSE
    END AS identity_ok
FROM counts c;
