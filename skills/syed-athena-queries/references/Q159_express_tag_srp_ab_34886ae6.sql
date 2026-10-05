-- Athena saved query (Product_B2C_Intl)
-- ID: 34886ae6-3f3b-4ead-9e47-8d6c0af99e44
-- Name: EXPRESS_TAG_SRP_AB - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT DISTINCT DATE(date_add('minute',330, srp.__time)) AS session_date, -- srp.mri_session_id, confirm.tin, CASE WHEN contains(srp.channel_exp_info, 'EXPRESS_TAG_SRP_AB:V0') THEN 'V0' WHEN contains(srp.channel_exp_info, 'EXPRESS_TAG_SRP_AB:V1') THEN 'V1' WHEN contains(srp.channel_exp_info, 'EXPRESS_TAG_SRP_AB:V2') THEN 'V2' ELSE 'OTHER' END AS variant FROM "user_interaction"."search_route_details" srp RIGHT JOIN "user_interaction"."confirm_order_details" confirm ON srp.mri_session_id = confirm.mri_session_id AND srp.route_id = confirm.route_id AND confirm.os = 'Android' AND confirm.country = 'IND' AND confirm.__time >= TIMESTAMP '2025-11-24 18:30:00' AND confirm.__time < TIMESTAMP '2025-12-09 18:30:00' AND confirm.status = 200 AND confirm.tin IS NOT NULL AND confirm.tin <> '' AND confirm.tin <> 'null' WHERE srp.os = 'Android' AND srp.country = 'IND' AND srp.__time >= TIMESTAMP '2025-11-24 18:30:00' AND srp.__time < TIMESTAMP '2025-12-09 18:30:00' AND contains(srp.channel_exp_info, 'EXPRESS_TAG_SRP_AB:V2') GROUP BY 1, 2, 3 -- , 4, 5 -- HAVING variant NOT IN ('OTHER') ORDER BY 1, 2
