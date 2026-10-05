SELECT
  CASE
    WHEN CONTAINS(sd.channel_exp_info, 'SEAT_UTILITY_IMAGES_ON_CLICK_AB:V0') THEN 'V0'
    WHEN CONTAINS(sd.channel_exp_info, 'SEAT_UTILITY_IMAGES_ON_CLICK_AB:V1') THEN 'V1'
    WHEN CONTAINS(sd.channel_exp_info, 'SEAT_UTILITY_IMAGES_ON_CLICK_AB:V2') THEN 'V2'
  END AS variant,
  COUNT(DISTINCT CASE WHEN ux.event_name IN ('SeatImgSectionClicked', 'NewImagesClicked') THEN ux.mri_session_id END) AS numerator_sessions,
  COUNT(DISTINCT CASE WHEN ux.event_name = 'NewBusImageLoaded' THEN ux.mri_session_id END) AS denominator_sessions,
  COUNT(DISTINCT CASE WHEN ux.event_name IN ('SeatImgSectionClicked', 'NewImagesClicked') THEN ux.mri_session_id END) * 100.0
    / NULLIF(COUNT(DISTINCT CASE WHEN ux.event_name = 'NewBusImageLoaded' THEN ux.mri_session_id END), 0) AS ctr_pct
FROM user_interaction.search_details AS sd
INNER JOIN user_interaction.ui_ux_events AS ux
  ON sd.mri_session_id = ux.mri_session_id
WHERE
  sd.__time >= CAST('2026-08-05 18:30:00' AS TIMESTAMP)
  AND sd.__time < CAST('2026-08-18 18:30:00' AS TIMESTAMP)
  AND sd.country = 'IND'
  AND ux.__time >= CAST('2026-08-05 18:30:00' AS TIMESTAMP)
  AND ux.__time < CAST('2026-08-18 18:30:00' AS TIMESTAMP)
  AND (ux.selected_country = 'India' OR ux.header_country = 'IND')
  AND ux.event_name IN ('SeatImgSectionClicked', 'NewImagesClicked', 'NewBusImageLoaded')
  AND (
    CONTAINS(sd.channel_exp_info, 'SEAT_UTILITY_IMAGES_ON_CLICK_AB:V0')
    OR CONTAINS(sd.channel_exp_info, 'SEAT_UTILITY_IMAGES_ON_CLICK_AB:V1')
    OR CONTAINS(sd.channel_exp_info, 'SEAT_UTILITY_IMAGES_ON_CLICK_AB:V2')
  )
GROUP BY 1
ORDER BY 1
