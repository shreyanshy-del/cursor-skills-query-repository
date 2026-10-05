-- CR dim: BO Type RTC / PRIVATE / PRIMO
WITH params AS (
  SELECT
    TIMESTAMP '2026-10-03 18:30:00' AS t_start,
    TIMESTAMP '2026-10-04 18:30:00' AS t_end
),
rtc_ops AS (
  SELECT DISTINCT TRY_CAST(vendor_id AS BIGINT) AS operator_id
  FROM lis.bo_mappings
  WHERE is_rtc = 'RTC'
),
session_ops AS (
  SELECT DISTINCT
    srd.mri_session_id,
    srd.op_id AS operator_id
  FROM user_interaction.search_route_details srd
  CROSS JOIN params p
  WHERE srd.__time >= p.t_start AND srd.__time < p.t_end
    AND srd.country = 'IND'
    AND srd.mri_session_id IS NOT NULL
    AND srd.op_id IS NOT NULL
),
primo AS (
  SELECT DISTINCT bte.mri_session_id
  FROM transaction.bus_ticket_events bte
  CROSS JOIN params p
  WHERE bte.time_of_event >= p.t_start AND bte.time_of_event < p.t_end
    AND bte.country_code = 'IND'
    AND bte.event_type = 101
    AND bte.event_class = 2
    AND bte.hft = 2
    AND bte.mri_session_id IS NOT NULL
),
flags AS (
  SELECT
    so.mri_session_id,
    MAX(CASE WHEN r.operator_id IS NOT NULL THEN 1 ELSE 0 END) AS is_rtc,
    MAX(CASE WHEN p.mri_session_id IS NOT NULL THEN 1 ELSE 0 END) AS is_primo
  FROM session_ops so
  LEFT JOIN rtc_ops r ON so.operator_id = r.operator_id
  LEFT JOIN primo p ON so.mri_session_id = p.mri_session_id
  GROUP BY 1
)
SELECT
  mri_session_id,
  CASE
    WHEN is_primo = 1 THEN 'PRIMO'
    WHEN is_rtc = 1 THEN 'RTC'
    ELSE 'PRIVATE'
  END AS bo_type,
  is_rtc,
  is_primo
FROM flags;
