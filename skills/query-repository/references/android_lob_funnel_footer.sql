-- DRFM: rb_user_id joined to umsuserid on svoc.cltv_data
session_user_ids AS (
    SELECT DISTINCT rd.rb_user_id AS ums_user_id
    FROM user_interaction.search_route_details rd
    CROSS JOIN params p
    WHERE rd.__time >= p.t_start
      AND rd.__time <  p.t_end
      AND rd.country = 'IND'
      AND rd.rb_user_id > 0
),

drfm_users AS (
    SELECT
        TRY_CAST(d.umsuserid AS BIGINT) AS umsuserid,
        CASE
            WHEN MAX(TRY_CAST(d.discaffinityrfm AS INTEGER)) BETWEEN 0 AND 3 THEN 'Low'
            WHEN MAX(TRY_CAST(d.discaffinityrfm AS INTEGER)) BETWEEN 4 AND 10 THEN 'Middle'
            WHEN MAX(TRY_CAST(d.discaffinityrfm AS INTEGER)) BETWEEN 11 AND 15 THEN 'High'
            ELSE 'Unknown'
        END AS drfm_cut
    FROM svoc.cltv_data d
    INNER JOIN session_user_ids u
        ON TRY_CAST(d.umsuserid AS BIGINT) = u.ums_user_id
    GROUP BY 1
),

session_attrs AS (
    SELECT
        base.mri_session_id,
        base.dbd,
        base.tier,
        base.user_type,
        COALESCE(d.drfm_cut, 'Unknown') AS drfm_cut
    FROM (
        SELECT
            rd.mri_session_id,
            min_by(
                CASE
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 0 THEN 'DBD 0'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 1 THEN 'DBD 1'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 2 THEN 'DBD 2'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 3 THEN 'DBD 3'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 4 THEN 'DBD 4'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) = 5 THEN 'DBD 5'
                    WHEN date_diff('day', date(date_add('minute', 330, rd.__time)), TRY_CAST(rd.doj AS DATE)) > 5 THEN 'DBD 5+'
                    ELSE 'Unknown'
                END,
                rd.__time
            ) AS dbd,
            min_by(COALESCE(ct.tier, 'Other'), rd.__time) AS tier,
            min_by(
                CASE UPPER(TRIM(COALESCE(rd.user_type, '')))
                    WHEN 'NEW' THEN 'New'
                    WHEN 'RETURNING' THEN 'Returning'
                    WHEN 'RETURN' THEN 'Returning'
                    WHEN 'GUEST' THEN 'Guest'
                    ELSE 'Unknown'
                END,
                rd.__time
            ) AS user_type,
            min_by(rd.rb_user_id, rd.__time) AS ums_user_id
        FROM user_interaction.search_route_details rd
        CROSS JOIN params p
        LEFT JOIN city_tier ct
            ON TRY_CAST(rd.src_id AS BIGINT) = ct.src_id
        WHERE rd.__time >= p.t_start
          AND rd.__time <  p.t_end
          AND rd.mri_session_id IS NOT NULL
          AND rd.country = 'IND'
          AND rd.event_type = 'Search-Routes'
          AND rd.status < 400
          AND rd.rb_user_id > 0
        GROUP BY 1
    ) base
    LEFT JOIN drfm_users d
        ON base.ums_user_id = d.umsuserid
)

SELECT
    COALESCE(sa.dbd, 'Unknown') AS dbd,
    COALESCE(sa.tier, 'Other') AS tier,
    COALESCE(sa.user_type, 'Unknown') AS user_type,
    COALESCE(sa.drfm_cut, 'Unknown') AS drfm_cut,
    1 AS step_order,
    'Step 1: Offer Section (LOB)' AS funnel_step,
    COUNT(DISTINCT o.mri_session_id) AS sessions
FROM offer_sessions o
LEFT JOIN session_attrs sa ON o.mri_session_id = sa.mri_session_id
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    2,
    'Step 2: SRP',
    COUNT(DISTINCT sd.mri_session_id)
FROM user_interaction.search_details sd
CROSS JOIN params p
LEFT JOIN session_attrs sa ON sd.mri_session_id = sa.mri_session_id
WHERE sd.__time >= p.t_start
  AND sd.__time <  p.t_end
  AND sd.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
  AND sd.status = 200
  AND sd.country = 'IND'
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    3,
    'Step 3: Seat Layout',
    COUNT(DISTINCT s.mri_session_id)
FROM user_interaction.seat_layout_details s
CROSS JOIN params p
LEFT JOIN session_attrs sa ON s.mri_session_id = sa.mri_session_id
WHERE s.__time >= p.t_start
  AND s.__time <  p.t_end
  AND s.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    4,
    'Step 4: Cust Info',
    COUNT(DISTINCT c.mri_session_id)
FROM user_interaction.cust_info_details c
CROSS JOIN params p
LEFT JOIN session_attrs sa ON c.mri_session_id = sa.mri_session_id
WHERE c.__time >= p.t_start
  AND c.__time <  p.t_end
  AND c.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    5,
    'Step 5: Payload',
    COUNT(DISTINCT co.mri_session_id)
FROM user_interaction.create_order_details co
CROSS JOIN params p
LEFT JOIN session_attrs sa ON co.mri_session_id = sa.mri_session_id
WHERE co.__time >= p.t_start
  AND co.__time <  p.t_end
  AND co.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    6,
    'Step 6: Pay',
    COUNT(DISTINCT mp.mri_session_id)
FROM user_interaction.make_payment_details mp
CROSS JOIN params p
LEFT JOIN session_attrs sa ON mp.mri_session_id = sa.mri_session_id
WHERE mp.__time >= p.t_start
  AND mp.__time <  p.t_end
  AND mp.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
GROUP BY 1, 2, 3, 4

UNION ALL

SELECT
    COALESCE(sa.dbd, 'Unknown'),
    COALESCE(sa.tier, 'Other'),
    COALESCE(sa.user_type, 'Unknown'),
    COALESCE(sa.drfm_cut, 'Unknown'),
    7,
    'Step 7: TIN (Confirmed)',
    COUNT(DISTINCT cf.mri_session_id)
FROM user_interaction.confirm_order_details cf
CROSS JOIN params p
LEFT JOIN session_attrs sa ON cf.mri_session_id = sa.mri_session_id
WHERE cf.__time >= p.t_start
  AND cf.__time <  p.t_end
  AND cf.mri_session_id IN (SELECT mri_session_id FROM offer_sessions)
  AND cf.country = 'IND'
  AND cf.error_code = 'CONFIRMED'
  AND cf.status_str = 'SUCCESS'
  AND NULLIF(TRIM(cf.tin), '') IS NOT NULL
  AND LOWER(TRIM(cf.tin)) <> 'null'
GROUP BY 1, 2, 3, 4

ORDER BY step_order, dbd, tier, user_type, drfm_cut;
