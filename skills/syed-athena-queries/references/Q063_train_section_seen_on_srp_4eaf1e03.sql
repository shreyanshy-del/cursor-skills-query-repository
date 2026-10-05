-- Athena saved query (Product_B2C_Intl)
-- ID: 4eaf1e03-2cf6-4a4b-a7ca-4a61c4790cc1
-- Name: Train Section seen on SRP - Syed
-- Source: Syed Athena Saved Queries export
-- Prefer dataplatform MCP / Iceberg for runs; adjust only date params.
-- Default country: IND when applicable.

SELECT -- date_format(__time, '%Y-%b') AS month_period, DATE(__time) AS activity_date, is_train_available AS ShowTrainsOnBusSrp, -- CASE -- WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, "__time")), doj) = 0 THEN '0. Same Day' -- WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, "__time")), doj) = 1 THEN '1. DBD 1' -- WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, "__time")), doj) = 2 THEN '2. DBD 2' -- WHEN DATE_DIFF('day', DATE(DATE_ADD('MINUTE', 330, "__time")), doj) > 2 THEN '3. DBD 2+' -- ELSE 'Others' -- END AS search_day, 'Any DBD' AS search_day, count(distinct mri_session_id) sessions, COUNT(DISTINCT (src_id, dest_id)) SD_Count FROM user_interaction.search_details WHERE __time >= timestamp '2026-04-29 00:00:00' AND __time < timestamp '2026-05-04 00:00:00' AND os = 'Android' AND country = 'IND' AND tp_channel = 'INVALID' AND (akamai_bot = '' OR akamai_bot IS NULL) GROUP BY 1,2,3 ORDER BY 1, 3, 2
