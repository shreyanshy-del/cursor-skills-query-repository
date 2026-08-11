-- =============================================================================
-- Confirmed TINs with NO offer attached
-- (offer_status NULL / blank, or no order_info_details row)
-- LOB Android cohort only. Engine: Trino / Presto
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-05 18:30:00' AS t_start,
        TIMESTAMP '2026-06-06 18:30:00' AS t_end
),

android_sessions AS (
    SELECT u.mri_session_id
    FROM user_interaction.ui_ux_events u
    CROSS JOIN params p
    WHERE u.__time >= p.t_start
      AND u.__time <  p.t_end
      AND u.mri_session_id IS NOT NULL
      AND u.header_bu = 'BUS'
      AND u.selected_country = 'India'
    GROUP BY 1
    HAVING min_by(COALESCE(NULLIF(TRIM(u.event_src), ''), 'UNKNOWN'), u.__time) = 'Android'
),

offer_sessions AS (
    SELECT DISTINCT u.mri_session_id
    FROM user_interaction.ui_ux_events u
    CROSS JOIN params p
    WHERE u.__time >= p.t_start
      AND u.__time <  p.t_end
      AND u.mri_session_id IN (SELECT mri_session_id FROM android_sessions)
      AND u.event_group = 'offer_click_event'
      AND u.event_name = 'lob tile displayed'
      AND u.header_bu = 'BUS'
      AND u.selected_country = 'India'
      AND u.event_src = 'Android'
),

confirmed_tin_sessions AS (
    SELECT DISTINCT cf.mri_session_id
    FROM user_interaction.confirm_order_details cf
    CROSS JOIN params p
    WHERE cf.__time >= p.t_start
      AND cf.__time <  p.t_end
      AND cf.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
      AND cf.country = 'IND'
      AND cf.error_code = 'CONFIRMED'
      AND cf.status_str = 'SUCCESS'
      AND NULLIF(TRIM(cf.tin), '') IS NOT NULL
      AND LOWER(TRIM(cf.tin)) <> 'null'
),

no_offer_tin_sessions AS (
    SELECT cf.mri_session_id
    FROM confirmed_tin_sessions cf
    LEFT JOIN user_interaction.order_info_details oi
        ON cf.mri_session_id = oi.mri_session_id
       AND oi.country = 'IND'
    CROSS JOIN params p
    WHERE oi.mri_session_id IS NULL
       OR (oi.__time >= p.t_start AND oi.__time < p.t_end)
    GROUP BY cf.mri_session_id
    HAVING COALESCE(BOOL_OR(oi.offer_status = 200), FALSE) = FALSE
       AND BOOL_AND(
           oi.mri_session_id IS NULL
           OR oi.offer_status IS NULL
           OR NULLIF(TRIM(CAST(oi.offer_status AS VARCHAR)), '') IS NULL
       )
)

-- Total count
SELECT COUNT(DISTINCT mri_session_id) AS no_offer_attached_sessions
FROM no_offer_tin_sessions;

-- Session list (comment out the SELECT above and use this instead if needed)
-- SELECT mri_session_id
-- FROM no_offer_tin_sessions
-- ORDER BY 1;
