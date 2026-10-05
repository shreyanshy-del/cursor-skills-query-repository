-- CR dim: GA Plugin from ui_ux_events
-- INPUT: set event_group / event_name / event_value filters below
WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
),
ga AS (
  SELECT
    u.mri_session_id,
    u.event_group,
    u.event_name,
    u.event_value,
    u.event_src
  FROM user_interaction.ui_ux_events u
  CROSS JOIN params p
  WHERE u.__time >= p.t_start AND u.__time < p.t_end
    AND u.mri_session_id IS NOT NULL
    AND u.header_country = 'IND'
    AND u.header_bu = 'BUS'
    AND u.selected_country = 'India'
    -- >>> USER INPUT (example — replace) <<<
    AND u.event_group = 'srp_click_event'
    AND u.event_name = 'SRP loaded'
    -- AND u.event_value = 'Women'
)
SELECT DISTINCT
  mri_session_id,
  event_group,
  event_name,
  event_value,
  event_src,
  TRUE AS ga_hit
FROM ga;
