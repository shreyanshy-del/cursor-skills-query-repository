-- =============================================================================
-- With LOB - session count per step by DBD, Tier, User_type, DRFM
-- No cross-step joins. Build funnel manually in Excel / Sheets.
-- DBD / Tier / User_type from first Search-Routes event per session.
-- DRFM: rb_user_id joined to umsuserid on svoc.cltv_data
-- Engine: Trino / Presto
-- =============================================================================

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-07 18:30:00' AS t_start,
        TIMESTAMP '2026-06-08 18:30:00' AS t_end
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
