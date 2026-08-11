/* =============================================================================
   Users booking RETURN trips immediately (within 1 hour) — ONE DAY delta
   -----------------------------------------------------------------------------
   Definition (behavioural / temporal):
     - "Onward" booking   = a confirmed bus ticket (A -> B) by a user.
     - "Immediate return" = the SAME user makes another confirmed booking on the
       reverse leg (B -> A) within 1 hour of the onward booking time.
   Engine : Trino / Presto
   Table  : transaction.bus_ticket_events
   Grain  : confirmed booking (event_class = 2, event_type = 101, TIN generated)
   User id: rb_user_id  (logged-in user id; switch to hashed `mobile` if needed)

   Segments: Overall, RTC (All), Private, and each RTC operator (list below).
   NOTE: duplicate names (SBSTC 16374/32272, TGSRTC 18491/32245) roll up under
         one segment name; both operator_ids stay mapped in the dimension.

   Time note: date_of_issue = ticket purchase time. The 1-hour test is a
   difference, so it is timezone-agnostic. For IST calendar-day boundaries add
   INTERVAL '330' MINUTE to date_of_issue in the window filter.
   ============================================================================= */

WITH params AS (
    SELECT
        TIMESTAMP '2026-06-15 00:00:00' AS ts_start,   -- one-day delta start (edit me)
        TIMESTAMP '2026-06-16 00:00:00' AS ts_end      -- one-day delta end   (edit me)
),

/* RTC operator dimension (Bo Code -> Bo Name) */
rtc_dim AS (
    SELECT * FROM (VALUES
        (10283, 'APSRTC'),
        (16081, 'Assam State Transport Corporation (ASTC)'),
        (7115,  'Kadamba Transport Corporation Limited (KTCL)'),
        (11060, 'PEPSU (Punjab)'),
        (15499, 'RSRTC'),
        (15443, 'West Bengal Transport Corporation'),
        (16227, 'HRTC'),
        (16374, 'South Bengal State Transport Corporation (SBSTC)'),
        (16426, 'WBTC (CTC)'),
        (17889, 'Bihar State Road Transport Corporation (BSRTC)'),
        (18101, 'Himachal Pradesh Tourism Development Corporation (HPTDC)'),
        (18491, 'TGSRTC'),
        (24978, 'North Bengal State Transport Corporation (NBSTC)'),
        (25187, 'KAAC Transport'),
        (25946, 'UPSRTC'),
        (26936, 'Meghalaya Transport Corporation (MTC)'),
        (27455, 'Chandigarh Transport Undertaking (CTU)'),
        (28011, 'KSRTC (Kerala)'),
        (29176, 'JKRTC'),
        (29479, 'Sikkim Nationalised Transport (SNT)'),
        (32000, 'Uttarakhand Transport Corporation (UTC)'),
        (32272, 'South Bengal State Transport Corporation (SBSTC)'),
        (32245, 'TGSRTC'),
        (36981, 'APSTS')
    ) AS t(operator_id, rtc_name)
),

/* All confirmed India bus bookings in the one-day window */
confirmed AS (
    SELECT
        b.rb_user_id,
        b.tin,
        b.operator_id,
        b.source_location_id,
        b.destination_location_id,
        b.date_of_issue
    FROM transaction.bus_ticket_events b
    CROSS JOIN params p
    WHERE b.date_of_issue >= p.ts_start
      AND b.date_of_issue <  p.ts_end
      AND b.country_code = 'IND'
      AND b.event_class  = 2
      AND b.event_type   = 101
      AND b.tin IS NOT NULL
      AND b.rb_user_id IS NOT NULL
      AND b.rb_user_id > 0                       -- exclude guest / not-logged-in
      AND b.source_location_id IS NOT NULL
      AND b.destination_location_id IS NOT NULL
      AND b.source_location_id <> b.destination_location_id
),

/* Flag each onward booking that has a reverse-leg booking within 1 hour after it */
onward_flagged AS (
    SELECT
        o.tin,
        o.rb_user_id,
        o.operator_id,
        CASE WHEN EXISTS (
            SELECT 1
            FROM confirmed r
            WHERE r.rb_user_id              = o.rb_user_id
              AND r.source_location_id      = o.destination_location_id   -- reverse leg
              AND r.destination_location_id = o.source_location_id
              AND r.tin <> o.tin
              AND r.date_of_issue >  o.date_of_issue
              AND r.date_of_issue <= o.date_of_issue + INTERVAL '1' HOUR
        ) THEN 1 ELSE 0 END AS has_immediate_return
    FROM confirmed o
),

/* Expand into the requested segment buckets:
   Overall, RTC (All), APSRTC, TSRTC, KSRTC (Kerala), Private.
   - rtc_dim membership (all 24 codes) decides RTC (All) vs Private.
   - Only APSRTC / TSRTC / KSRTC are broken out individually.
   - TSRTC (Telangana / TGSRTC) = operator_id 18491 and 32245. */
segmented AS (
    SELECT
        f.tin,
        f.rb_user_id,
        f.has_immediate_return,
        s.segment
    FROM onward_flagged f
    LEFT JOIN rtc_dim d ON d.operator_id = f.operator_id
    CROSS JOIN UNNEST(
        CASE
            WHEN d.rtc_name IS NULL THEN ARRAY['Overall', 'Private']
            WHEN f.operator_id = 10283            THEN ARRAY['Overall', 'RTC (All)', 'APSRTC']
            WHEN f.operator_id IN (18491, 32245)  THEN ARRAY['Overall', 'RTC (All)', 'TSRTC']
            WHEN f.operator_id = 28011            THEN ARRAY['Overall', 'RTC (All)', 'KSRTC (Kerala)']
            ELSE ARRAY['Overall', 'RTC (All)']
        END
    ) AS s(segment)
)

SELECT
    segment,
    COUNT(*)                                                               AS onward_bookings,
    SUM(has_immediate_return)                                              AS onward_with_return_1h,
    ROUND(100.0 * SUM(has_immediate_return) / NULLIF(COUNT(*), 0), 2)      AS return_rate_pct,
    COUNT(DISTINCT rb_user_id)                                             AS onward_users,
    COUNT(DISTINCT CASE WHEN has_immediate_return = 1 THEN rb_user_id END) AS users_with_return_1h
FROM segmented
GROUP BY segment
ORDER BY
    CASE segment
        WHEN 'Overall'        THEN 1
        WHEN 'RTC (All)'      THEN 2
        WHEN 'APSRTC'         THEN 3
        WHEN 'TSRTC'          THEN 4
        WHEN 'KSRTC (Kerala)' THEN 5
        WHEN 'Private'        THEN 6
        ELSE 7
    END;


/* =============================================================================
   QUERY 2 (optional) — User-level drilldown of the immediate-return pairs.
   One row per onward booking that had a return within 1 hour (earliest return).
   ============================================================================= */
-- WITH params AS (
--     SELECT TIMESTAMP '2026-06-15 00:00:00' AS ts_start,
--            TIMESTAMP '2026-06-16 00:00:00' AS ts_end
-- ),
-- confirmed AS (
--     SELECT b.rb_user_id, b.tin, b.operator_id,
--            b.source_location_id, b.destination_location_id,
--            b.source_location, b.destination_location, b.date_of_issue
--     FROM transaction.bus_ticket_events b
--     CROSS JOIN params p
--     WHERE b.date_of_issue >= p.ts_start AND b.date_of_issue < p.ts_end
--       AND b.country_code = 'IND' AND b.event_class = 2 AND b.event_type = 101
--       AND b.tin IS NOT NULL AND b.rb_user_id IS NOT NULL AND b.rb_user_id > 0
--       AND b.source_location_id IS NOT NULL AND b.destination_location_id IS NOT NULL
--       AND b.source_location_id <> b.destination_location_id
-- ),
-- pairs AS (
--     SELECT
--         o.rb_user_id,
--         o.operator_id             AS onward_operator_id,
--         o.tin                     AS onward_tin,
--         o.source_location_id      AS onward_src_id,
--         o.destination_location_id AS onward_dst_id,
--         o.date_of_issue           AS onward_booked_at,
--         r.tin                     AS return_tin,
--         r.operator_id             AS return_operator_id,
--         r.date_of_issue           AS return_booked_at,
--         date_diff('minute', o.date_of_issue, r.date_of_issue) AS gap_minutes,
--         ROW_NUMBER() OVER (PARTITION BY o.tin ORDER BY r.date_of_issue) AS rn
--     FROM confirmed o
--     JOIN confirmed r
--       ON r.rb_user_id              = o.rb_user_id
--      AND r.source_location_id      = o.destination_location_id
--      AND r.destination_location_id = o.source_location_id
--      AND r.tin <> o.tin
--      AND r.date_of_issue >  o.date_of_issue
--      AND r.date_of_issue <= o.date_of_issue + INTERVAL '1' HOUR
-- )
-- SELECT * FROM pairs WHERE rn = 1 ORDER BY onward_booked_at;
