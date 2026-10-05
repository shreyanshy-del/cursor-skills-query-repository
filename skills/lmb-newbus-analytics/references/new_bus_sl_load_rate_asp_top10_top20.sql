-- New Bus (persuasion tag 68): SL load rate and ASP, Tag 68 vs Platform
-- Window : 17-21 Sep 2026 IST (five complete days)
-- Scope  : India, Android MOBILE_APP, unfiltered SRP sessions, Top 200 SD universe
--
-- GRAIN: route impression = one distinct (mri_session_id, route_id, doj).
--        Numerator and denominator share this grain so the two rates are comparable.
--
--   tag68_sl_load_rate_pct    = SL-loaded impressions on tag-68 routes
--                               / SRP impressions of tag-68 routes
--   platform_sl_load_rate_pct = SL-loaded impressions on ALL routes
--                               / SRP impressions of ALL routes
--
--   Platform includes tag-68 routes (not a Test-vs-Rest split).
--
-- ASP  = SUM(ticket_fare) / SUM(seat_count) on confirmed tickets, attributed to the
--        route impression that produced them. Tag-68 ASP therefore covers tickets on
--        tag-68 routes only; platform ASP covers all routes.
--        Matches the governed ASP metric (ticket_fare = GMV, seat_count = seats,
--        operators 15926 and 19715 excluded).
--
-- Cuts : tuple scope (Top 10, Top 20) x {Overall, Top 200 SD combined, User Type, DBD}
--        Tuple scopes are inclusive: Top 10 = positions 1-10, Top 20 = positions 1-20.
--        Every cut is scoped to the Top 200 SD universe, so 'Overall' and
--        'Top 200 SD combined' return identical figures under different labels.

WITH params AS (
    SELECT
        TIMESTAMP '2026-09-16 18:30:00' AS start_utc,   -- 17 Sep 2026 00:00 IST
        TIMESTAMP '2026-09-21 18:30:00' AS end_utc      -- 22 Sep 2026 00:00 IST
),

srp_raw AS (
    SELECT
        s.mri_session_id,
        s.route_id,
        s.src_id,
        s.dest_id,
        UPPER(COALESCE(s.user_type, 'UNKNOWN')) AS user_type,
        CAST(s.doj AS DATE) AS doj,
        DATE_DIFF(
            'day',
            DATE(DATE_ADD('MINUTE', 330, s.__time)),
            CAST(s.doj AS DATE)
        ) AS dbd_days,
        s.offset + s.position + 1 AS tuple_position,
        CASE WHEN CONTAINS(s.persuasion_id, '68') THEN 1 ELSE 0 END AS is_new_bus
    FROM user_interaction.search_route_details s
    INNER JOIN user_interaction.search_details d
        ON  s.__time         = d.__time
        AND s.mri_session_id = d.mri_session_id
    CROSS JOIN params p
    WHERE s.__time >= p.start_utc
      AND s.__time <  p.end_utc
      AND s.country = 'IND'
      AND s.channel = 'MOBILE_APP'
      AND s.os      = 'Android'
      AND d.is_filter_applied = FALSE
      AND d.sort < 1
      AND s.mri_session_id IS NOT NULL
      AND s.route_id       IS NOT NULL
      AND s.src_id         IS NOT NULL
      AND s.dest_id        IS NOT NULL
),

-- One row per route impression. A route tagged 68 anywhere in the session counts as tagged.
srp_impressions AS (
    SELECT
        mri_session_id,
        route_id,
        src_id,
        dest_id,
        user_type,
        doj,
        CASE WHEN dbd_days >= 5 THEN '5+' ELSE CAST(dbd_days AS VARCHAR) END AS dbd,
        MIN(tuple_position) AS tuple_position,
        MAX(is_new_bus)     AS is_new_bus
    FROM srp_raw
    WHERE dbd_days >= 0
    GROUP BY 1, 2, 3, 4, 5, 6, 7
),

top_200_sd AS (
    SELECT
        src_id,
        dest_id,
        ROW_NUMBER() OVER (
            ORDER BY COUNT(DISTINCT mri_session_id) DESC
        ) AS sd_rank
    FROM srp_impressions
    GROUP BY src_id, dest_id
),

sl_route AS (
    SELECT
        sl.mri_session_id,
        sl.route_id,
        CAST(sl.doj AS DATE) AS doj,
        COUNT(DISTINCT sl.mri_uuid) AS sl_load_events
    FROM user_interaction.seat_layout_details sl
    CROSS JOIN params p
    WHERE sl.__time >= p.start_utc
      AND sl.__time <  p.end_utc
      AND sl.country = 'IND'
      AND sl.channel = 'MOBILE_APP'
      AND sl.os      = 'Android'
      AND sl.mri_session_id IS NOT NULL
      AND sl.route_id       IS NOT NULL
    GROUP BY 1, 2, 3
),

ticket_dedup AS (
    SELECT
        bte.mri_session_id,
        bte.route_id,
        DATE(DATE_ADD('MINUTE', 330, bte.date_of_journey)) AS doj,
        bte.tin,
        MAX(bte.ticket_fare) AS ticket_fare,
        MAX(bte.seat_count)  AS seat_count
    FROM transaction.bus_ticket_events bte
    CROSS JOIN params p
    WHERE bte.time_of_event >= p.start_utc
      AND bte.time_of_event <  p.end_utc
      AND bte.country_code = 'IND'
      AND bte.event_type   = 101
      AND bte.event_class  = 2
      AND bte.sales_channel = 'RB:MOBILEWEB#droidapp'
      AND bte.operator_id NOT IN (15926, 19715)
      AND bte.tin IS NOT NULL
      AND bte.tin NOT IN ('', 'null')
      AND bte.mri_session_id IS NOT NULL
      AND bte.route_id       IS NOT NULL
    GROUP BY 1, 2, 3, 4
),

ticket_route AS (
    SELECT
        mri_session_id,
        route_id,
        doj,
        COUNT(DISTINCT tin) AS confirmed_tins,
        SUM(ticket_fare)    AS gmv,
        SUM(seat_count)     AS seats
    FROM ticket_dedup
    GROUP BY 1, 2, 3
),

impression_base AS (
    SELECT
        r.src_id,
        r.dest_id,
        r.user_type,
        r.dbd,
        r.tuple_position,
        r.is_new_bus,
        CASE WHEN sl.mri_session_id IS NOT NULL THEN 1 ELSE 0 END AS is_sl_loaded,
        COALESCE(sl.sl_load_events, 0) AS sl_load_events,
        COALESCE(t.confirmed_tins, 0)  AS confirmed_tins,
        COALESCE(t.gmv, 0.0)           AS gmv,
        COALESCE(t.seats, 0)           AS seats
    FROM srp_impressions r
    INNER JOIN top_200_sd sd
        ON  r.src_id  = sd.src_id
        AND r.dest_id = sd.dest_id
        AND sd.sd_rank <= 200
    LEFT JOIN sl_route sl
        ON  r.mri_session_id = sl.mri_session_id
        AND r.route_id       = sl.route_id
        AND r.doj            = sl.doj
    LEFT JOIN ticket_route t
        ON  r.mri_session_id = t.mri_session_id
        AND r.route_id       = t.route_id
        AND r.doj            = t.doj
    WHERE r.tuple_position <= 20
      AND r.dbd IN ('0', '1', '2', '3', '4', '5+')
),

scoped AS (
    SELECT
        scope.tuple_scope,
        b.*
    FROM impression_base b
    CROSS JOIN (
        VALUES
            ('Top 10', 10),
            ('Top 20', 20)
    ) AS scope(tuple_scope, max_position)
    WHERE b.tuple_position <= scope.max_position
),

cut_rows AS (
    SELECT
        s.*,
        cuts.cut_type,
        CASE cuts.cut_type
            WHEN 'Overall'      THEN 'All'
            WHEN 'Top 200 SD'   THEN 'Top 200 SD combined'
            WHEN 'User Type'    THEN s.user_type
            WHEN 'DBD'          THEN s.dbd
        END AS segment
    FROM scoped s
    CROSS JOIN (
        VALUES
            ('Overall'),
            ('Top 200 SD'),
            ('User Type'),
            ('DBD')
    ) AS cuts(cut_type)
),

metrics AS (
    SELECT
        tuple_scope,
        cut_type,
        segment,

        SUM(is_new_bus)                                                    AS tag68_srp_impressions,
        SUM(CASE WHEN is_new_bus = 1 THEN is_sl_loaded ELSE 0 END)         AS tag68_sl_loaded_impressions,
        SUM(CASE WHEN is_new_bus = 1 THEN sl_load_events ELSE 0 END)       AS tag68_sl_load_events,
        SUM(CASE WHEN is_new_bus = 1 THEN confirmed_tins ELSE 0 END)       AS tag68_confirmed_tins,
        SUM(CASE WHEN is_new_bus = 1 THEN seats ELSE 0 END)                AS tag68_seats,
        SUM(CASE WHEN is_new_bus = 1 THEN gmv ELSE 0.0 END)                AS tag68_gmv,

        COUNT(*)                AS platform_srp_impressions,
        SUM(is_sl_loaded)       AS platform_sl_loaded_impressions,
        SUM(sl_load_events)     AS platform_sl_load_events,
        SUM(confirmed_tins)     AS platform_confirmed_tins,
        SUM(seats)              AS platform_seats,
        SUM(gmv)                AS platform_gmv
    FROM cut_rows
    GROUP BY tuple_scope, cut_type, segment
)

SELECT
    tuple_scope,
    cut_type,
    segment,

    tag68_srp_impressions,
    tag68_sl_loaded_impressions,
    ROUND(100.0 * tag68_sl_loaded_impressions / NULLIF(tag68_srp_impressions, 0), 2)
        AS tag68_sl_load_rate_pct,
    tag68_sl_load_events,
    tag68_confirmed_tins,
    tag68_seats,
    ROUND(tag68_gmv, 2) AS tag68_gmv,
    ROUND(tag68_gmv / NULLIF(tag68_seats, 0), 2) AS tag68_asp,

    platform_srp_impressions,
    platform_sl_loaded_impressions,
    ROUND(100.0 * platform_sl_loaded_impressions / NULLIF(platform_srp_impressions, 0), 2)
        AS platform_sl_load_rate_pct,
    platform_sl_load_events,
    platform_confirmed_tins,
    platform_seats,
    ROUND(platform_gmv, 2) AS platform_gmv,
    ROUND(platform_gmv / NULLIF(platform_seats, 0), 2) AS platform_asp,

    ROUND(
        100.0 * tag68_sl_loaded_impressions / NULLIF(tag68_srp_impressions, 0)
        - 100.0 * platform_sl_loaded_impressions / NULLIF(platform_srp_impressions, 0),
        2
    ) AS sl_load_rate_delta_pp,
    ROUND(
        tag68_gmv / NULLIF(tag68_seats, 0)
        - platform_gmv / NULLIF(platform_seats, 0),
        2
    ) AS asp_delta,
    ROUND(100.0 * tag68_srp_impressions / NULLIF(platform_srp_impressions, 0), 2)
        AS tag68_share_of_impressions_pct
FROM metrics
ORDER BY
    CASE tuple_scope WHEN 'Top 10' THEN 1 ELSE 2 END,
    CASE cut_type
        WHEN 'Overall'    THEN 1
        WHEN 'User Type'  THEN 2
        WHEN 'DBD'        THEN 3
        ELSE 4
    END,
    CASE
        WHEN cut_type = 'DBD' THEN
            CASE segment
                WHEN '0' THEN 0
                WHEN '1' THEN 1
                WHEN '2' THEN 2
                WHEN '3' THEN 3
                WHEN '4' THEN 4
                ELSE 5
            END
        ELSE 0
    END,
    segment;
