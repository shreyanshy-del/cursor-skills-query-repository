-- Primo transacting BO_ID queries
-- Source: transaction.bus_ticket_events
-- Filters: country_code = IND, event_type = 101 (issued), hft = 2 (Primo)
-- Window: 2026-09-17 inclusive to 2026-09-23 exclusive (last 5 days)
-- BO_ID = operator_id
-- 263 SDs

-- =============================================================================
-- CASE ALL SDS: every listed SD x transacting Primo operator
-- =============================================================================
WITH target_sds AS (
    SELECT *
    FROM (
        VALUES
            (71929, 123),
            (602, 123),
            (1439, 733),
            (69802, 74820),
            (624, 130),
            (777, 733),
            (696, 123),
            (979, 313),
            (248, 124),
            (309, 130),
            (95222, 122),
            (78027, 733),
            (690, 123),
            (458, 123),
            (216, 122),
            (131, 122),
            (698, 123),
            (76079, 462),
            (131, 124),
            (236, 123),
            (833, 733),
            (233, 123),
            (233, 122),
            (575, 130),
            (130, 641),
            (235, 123),
            (71929, 122),
            (135, 124),
            (641, 130),
            (137, 124),
            (130, 1476),
            (229, 123),
            (90883, 74701),
            (123, 229),
            (602, 122),
            (74678, 74820),
            (95083, 122),
            (1377, 733),
            (601, 123),
            (309, 462),
            (130, 65976),
            (733, 90355),
            (995, 122),
            (1476, 130),
            (74661, 122),
            (123, 601),
            (74672, 74820),
            (71757, 124),
            (74676, 74820),
            (76079, 130),
            (74701, 90883),
            (248, 134),
            (284, 124),
            (123, 499),
            (65976, 130),
            (193533, 74820),
            (90355, 733),
            (123, 599),
            (499, 123),
            (599, 123),
            (364, 123),
            (71425, 122),
            (74820, 74678),
            (472, 551),
            (236, 122),
            (95217, 122),
            (122, 95217),
            (624, 462),
            (124, 121),
            (624, 124),
            (123, 364),
            (74701, 75814),
            (75814, 74701),
            (130, 311),
            (124, 246),
            (246, 124),
            (95083, 130),
            (137, 122),
            (74676, 124),
            (74820, 193533),
            (696, 141),
            (121, 124),
            (71929, 141),
            (284, 122),
            (124, 347),
            (473, 551),
            (502, 123),
            (74820, 74672),
            (311, 130),
            (222, 122),
            (504, 123),
            (467, 123),
            (235, 122),
            (122, 222),
            (123, 467),
            (124, 316),
            (1608, 123),
            (124, 634),
            (123, 502),
            (347, 124),
            (313, 94152),
            (123, 437),
            (422, 124),
            (130, 1382),
            (123, 1608),
            (316, 124),
            (437, 123),
            (123, 504),
            (197222, 74820),
            (122, 163),
            (473, 130),
            (624, 309),
            (163, 122),
            (124, 422),
            (309, 624),
            (444, 130),
            (428, 123),
            (551, 1125),
            (634, 124),
            (123, 428),
            (458, 141),
            (94152, 313),
            (698, 141),
            (733, 76481),
            (167, 122),
            (690, 141),
            (443, 979),
            (690, 122),
            (74701, 79598),
            (497, 123),
            (125, 122),
            (76481, 733),
            (248, 122),
            (122, 167),
            (973, 123),
            (911, 122),
            (696, 122),
            (216, 123),
            (233, 141),
            (130, 571),
            (1382, 130),
            (123, 973),
            (80089, 123),
            (123, 497),
            (219, 123),
            (123, 219),
            (470, 807),
            (135, 122),
            (1125, 551),
            (123, 80089),
            (122, 95220),
            (571, 130),
            (123, 506),
            (1290, 733),
            (130, 450),
            (470, 551),
            (729, 124),
            (124, 71586),
            (1439, 807),
            (455, 123),
            (125, 124),
            (1003, 551),
            (737, 733),
            (124, 321),
            (321, 124),
            (506, 123),
            (71586, 124),
            (122, 911),
            (95220, 122),
            (624, 70024),
            (124, 729),
            (1437, 733),
            (79598, 74701),
            (130, 1492),
            (979, 443),
            (230, 123),
            (123, 230),
            (123, 455),
            (470, 1169),
            (733, 1437),
            (653, 122),
            (736, 733),
            (229, 122),
            (473, 472),
            (123, 619),
            (664, 123),
            (70014, 93966),
            (1169, 470),
            (122, 229),
            (472, 473),
            (122, 634),
            (450, 130),
            (634, 122),
            (188, 122),
            (70024, 624),
            (502, 122),
            (123, 81152),
            (74676, 122),
            (619, 123),
            (130, 643),
            (1492, 130),
            (443, 313),
            (123, 488),
            (130, 79169),
            (83760, 70024),
            (462, 571),
            (136, 124),
            (571, 462),
            (130, 1384),
            (81152, 123),
            (313, 443),
            (422, 122),
            (401, 124),
            (130, 65907),
            (124, 330),
            (70024, 313),
            (954, 123),
            (124, 675),
            (124, 85637),
            (123, 664),
            (122, 188),
            (124, 352),
            (71425, 123),
            (124, 136),
            (122, 422),
            (488, 123),
            (84793, 70024),
            (122, 502),
            (124, 262),
            (122, 653),
            (352, 124),
            (74820, 197222),
            (93966, 70014),
            (130, 237),
            (122, 557),
            (262, 124),
            (330, 124),
            (557, 122),
            (390, 122),
            (95083, 462),
            (124, 320),
            (611, 123),
            (685, 123),
            (292, 123),
            (123, 954),
            (95040, 733),
            (74701, 79589),
            (122, 390),
            (1384, 130),
            (1439, 70015),
            (123, 1123),
            (1123, 123),
            (675, 124),
            (248, 123),
            (70024, 83760),
            (123, 685),
            (123, 292),
            (624, 313),
            (320, 124),
            (122, 601),
            (79169, 130),
            (141, 506),
            (123, 611)
    ) AS t(source_location_id, destination_location_id)
)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    CAST(b.operator_id AS BIGINT) AS operator_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
INNER JOIN target_sds r
    ON CAST(b.source_location_id AS BIGINT) = r.source_location_id
   AND CAST(b.destination_location_id AS BIGINT) = r.destination_location_id
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
GROUP BY 1, 2, 3, 4, 5
ORDER BY tickets DESC;

-- =============================================================================
-- CASE DISTINCT BO_IDS: unique Primo operators that transacted on ANY listed SD
-- =============================================================================
WITH target_sds AS (
    SELECT *
    FROM (
        VALUES
            (71929, 123),
            (602, 123),
            (1439, 733),
            (69802, 74820),
            (624, 130),
            (777, 733),
            (696, 123),
            (979, 313),
            (248, 124),
            (309, 130),
            (95222, 122),
            (78027, 733),
            (690, 123),
            (458, 123),
            (216, 122),
            (131, 122),
            (698, 123),
            (76079, 462),
            (131, 124),
            (236, 123),
            (833, 733),
            (233, 123),
            (233, 122),
            (575, 130),
            (130, 641),
            (235, 123),
            (71929, 122),
            (135, 124),
            (641, 130),
            (137, 124),
            (130, 1476),
            (229, 123),
            (90883, 74701),
            (123, 229),
            (602, 122),
            (74678, 74820),
            (95083, 122),
            (1377, 733),
            (601, 123),
            (309, 462),
            (130, 65976),
            (733, 90355),
            (995, 122),
            (1476, 130),
            (74661, 122),
            (123, 601),
            (74672, 74820),
            (71757, 124),
            (74676, 74820),
            (76079, 130),
            (74701, 90883),
            (248, 134),
            (284, 124),
            (123, 499),
            (65976, 130),
            (193533, 74820),
            (90355, 733),
            (123, 599),
            (499, 123),
            (599, 123),
            (364, 123),
            (71425, 122),
            (74820, 74678),
            (472, 551),
            (236, 122),
            (95217, 122),
            (122, 95217),
            (624, 462),
            (124, 121),
            (624, 124),
            (123, 364),
            (74701, 75814),
            (75814, 74701),
            (130, 311),
            (124, 246),
            (246, 124),
            (95083, 130),
            (137, 122),
            (74676, 124),
            (74820, 193533),
            (696, 141),
            (121, 124),
            (71929, 141),
            (284, 122),
            (124, 347),
            (473, 551),
            (502, 123),
            (74820, 74672),
            (311, 130),
            (222, 122),
            (504, 123),
            (467, 123),
            (235, 122),
            (122, 222),
            (123, 467),
            (124, 316),
            (1608, 123),
            (124, 634),
            (123, 502),
            (347, 124),
            (313, 94152),
            (123, 437),
            (422, 124),
            (130, 1382),
            (123, 1608),
            (316, 124),
            (437, 123),
            (123, 504),
            (197222, 74820),
            (122, 163),
            (473, 130),
            (624, 309),
            (163, 122),
            (124, 422),
            (309, 624),
            (444, 130),
            (428, 123),
            (551, 1125),
            (634, 124),
            (123, 428),
            (458, 141),
            (94152, 313),
            (698, 141),
            (733, 76481),
            (167, 122),
            (690, 141),
            (443, 979),
            (690, 122),
            (74701, 79598),
            (497, 123),
            (125, 122),
            (76481, 733),
            (248, 122),
            (122, 167),
            (973, 123),
            (911, 122),
            (696, 122),
            (216, 123),
            (233, 141),
            (130, 571),
            (1382, 130),
            (123, 973),
            (80089, 123),
            (123, 497),
            (219, 123),
            (123, 219),
            (470, 807),
            (135, 122),
            (1125, 551),
            (123, 80089),
            (122, 95220),
            (571, 130),
            (123, 506),
            (1290, 733),
            (130, 450),
            (470, 551),
            (729, 124),
            (124, 71586),
            (1439, 807),
            (455, 123),
            (125, 124),
            (1003, 551),
            (737, 733),
            (124, 321),
            (321, 124),
            (506, 123),
            (71586, 124),
            (122, 911),
            (95220, 122),
            (624, 70024),
            (124, 729),
            (1437, 733),
            (79598, 74701),
            (130, 1492),
            (979, 443),
            (230, 123),
            (123, 230),
            (123, 455),
            (470, 1169),
            (733, 1437),
            (653, 122),
            (736, 733),
            (229, 122),
            (473, 472),
            (123, 619),
            (664, 123),
            (70014, 93966),
            (1169, 470),
            (122, 229),
            (472, 473),
            (122, 634),
            (450, 130),
            (634, 122),
            (188, 122),
            (70024, 624),
            (502, 122),
            (123, 81152),
            (74676, 122),
            (619, 123),
            (130, 643),
            (1492, 130),
            (443, 313),
            (123, 488),
            (130, 79169),
            (83760, 70024),
            (462, 571),
            (136, 124),
            (571, 462),
            (130, 1384),
            (81152, 123),
            (313, 443),
            (422, 122),
            (401, 124),
            (130, 65907),
            (124, 330),
            (70024, 313),
            (954, 123),
            (124, 675),
            (124, 85637),
            (123, 664),
            (122, 188),
            (124, 352),
            (71425, 123),
            (124, 136),
            (122, 422),
            (488, 123),
            (84793, 70024),
            (122, 502),
            (124, 262),
            (122, 653),
            (352, 124),
            (74820, 197222),
            (93966, 70014),
            (130, 237),
            (122, 557),
            (262, 124),
            (330, 124),
            (557, 122),
            (390, 122),
            (95083, 462),
            (124, 320),
            (611, 123),
            (685, 123),
            (292, 123),
            (123, 954),
            (95040, 733),
            (74701, 79589),
            (122, 390),
            (1384, 130),
            (1439, 70015),
            (123, 1123),
            (1123, 123),
            (675, 124),
            (248, 123),
            (70024, 83760),
            (123, 685),
            (123, 292),
            (624, 313),
            (320, 124),
            (122, 601),
            (79169, 130),
            (141, 506),
            (123, 611)
    ) AS t(source_location_id, destination_location_id)
)
SELECT DISTINCT
    CAST(b.operator_id AS BIGINT) AS bo_id
FROM transaction.bus_ticket_events b
INNER JOIN target_sds r
    ON CAST(b.source_location_id AS BIGINT) = r.source_location_id
   AND CAST(b.destination_location_id AS BIGINT) = r.destination_location_id
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
ORDER BY bo_id;

-- =============================================================================
-- CASE PER SD: one query per source-destination pair
-- =============================================================================

-- [1/263]
-- CASE 71929-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 71929
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [2/263]
-- CASE 602-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 602
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [3/263]
-- CASE 1439-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1439
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [4/263]
-- CASE 69802-74820: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 69802
  AND CAST(b.destination_location_id AS BIGINT) = 74820
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [5/263]
-- CASE 624-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 624
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [6/263]
-- CASE 777-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 777
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [7/263]
-- CASE 696-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 696
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [8/263]
-- CASE 979-313: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 979
  AND CAST(b.destination_location_id AS BIGINT) = 313
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [9/263]
-- CASE 248-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 248
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [10/263]
-- CASE 309-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 309
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [11/263]
-- CASE 95222-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 95222
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [12/263]
-- CASE 78027-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 78027
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [13/263]
-- CASE 690-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 690
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [14/263]
-- CASE 458-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 458
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [15/263]
-- CASE 216-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 216
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [16/263]
-- CASE 131-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 131
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [17/263]
-- CASE 698-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 698
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [18/263]
-- CASE 76079-462: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 76079
  AND CAST(b.destination_location_id AS BIGINT) = 462
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [19/263]
-- CASE 131-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 131
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [20/263]
-- CASE 236-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 236
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [21/263]
-- CASE 833-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 833
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [22/263]
-- CASE 233-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 233
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [23/263]
-- CASE 233-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 233
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [24/263]
-- CASE 575-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 575
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [25/263]
-- CASE 130-641: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 641
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [26/263]
-- CASE 235-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 235
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [27/263]
-- CASE 71929-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 71929
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [28/263]
-- CASE 135-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 135
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [29/263]
-- CASE 641-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 641
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [30/263]
-- CASE 137-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 137
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [31/263]
-- CASE 130-1476: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 1476
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [32/263]
-- CASE 229-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 229
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [33/263]
-- CASE 90883-74701: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 90883
  AND CAST(b.destination_location_id AS BIGINT) = 74701
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [34/263]
-- CASE 123-229: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 229
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [35/263]
-- CASE 602-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 602
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [36/263]
-- CASE 74678-74820: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74678
  AND CAST(b.destination_location_id AS BIGINT) = 74820
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [37/263]
-- CASE 95083-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 95083
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [38/263]
-- CASE 1377-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1377
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [39/263]
-- CASE 601-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 601
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [40/263]
-- CASE 309-462: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 309
  AND CAST(b.destination_location_id AS BIGINT) = 462
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [41/263]
-- CASE 130-65976: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 65976
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [42/263]
-- CASE 733-90355: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 733
  AND CAST(b.destination_location_id AS BIGINT) = 90355
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [43/263]
-- CASE 995-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 995
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [44/263]
-- CASE 1476-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1476
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [45/263]
-- CASE 74661-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74661
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [46/263]
-- CASE 123-601: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 601
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [47/263]
-- CASE 74672-74820: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74672
  AND CAST(b.destination_location_id AS BIGINT) = 74820
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [48/263]
-- CASE 71757-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 71757
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [49/263]
-- CASE 74676-74820: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74676
  AND CAST(b.destination_location_id AS BIGINT) = 74820
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [50/263]
-- CASE 76079-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 76079
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [51/263]
-- CASE 74701-90883: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74701
  AND CAST(b.destination_location_id AS BIGINT) = 90883
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [52/263]
-- CASE 248-134: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 248
  AND CAST(b.destination_location_id AS BIGINT) = 134
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [53/263]
-- CASE 284-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 284
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [54/263]
-- CASE 123-499: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 499
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [55/263]
-- CASE 65976-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 65976
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [56/263]
-- CASE 193533-74820: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 193533
  AND CAST(b.destination_location_id AS BIGINT) = 74820
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [57/263]
-- CASE 90355-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 90355
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [58/263]
-- CASE 123-599: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 599
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [59/263]
-- CASE 499-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 499
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [60/263]
-- CASE 599-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 599
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [61/263]
-- CASE 364-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 364
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [62/263]
-- CASE 71425-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 71425
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [63/263]
-- CASE 74820-74678: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74820
  AND CAST(b.destination_location_id AS BIGINT) = 74678
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [64/263]
-- CASE 472-551: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 472
  AND CAST(b.destination_location_id AS BIGINT) = 551
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [65/263]
-- CASE 236-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 236
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [66/263]
-- CASE 95217-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 95217
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [67/263]
-- CASE 122-95217: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 95217
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [68/263]
-- CASE 624-462: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 624
  AND CAST(b.destination_location_id AS BIGINT) = 462
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [69/263]
-- CASE 124-121: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 121
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [70/263]
-- CASE 624-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 624
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [71/263]
-- CASE 123-364: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 364
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [72/263]
-- CASE 74701-75814: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74701
  AND CAST(b.destination_location_id AS BIGINT) = 75814
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [73/263]
-- CASE 75814-74701: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 75814
  AND CAST(b.destination_location_id AS BIGINT) = 74701
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [74/263]
-- CASE 130-311: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 311
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [75/263]
-- CASE 124-246: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 246
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [76/263]
-- CASE 246-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 246
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [77/263]
-- CASE 95083-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 95083
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [78/263]
-- CASE 137-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 137
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [79/263]
-- CASE 74676-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74676
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [80/263]
-- CASE 74820-193533: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74820
  AND CAST(b.destination_location_id AS BIGINT) = 193533
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [81/263]
-- CASE 696-141: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 696
  AND CAST(b.destination_location_id AS BIGINT) = 141
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [82/263]
-- CASE 121-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 121
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [83/263]
-- CASE 71929-141: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 71929
  AND CAST(b.destination_location_id AS BIGINT) = 141
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [84/263]
-- CASE 284-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 284
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [85/263]
-- CASE 124-347: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 347
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [86/263]
-- CASE 473-551: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 473
  AND CAST(b.destination_location_id AS BIGINT) = 551
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [87/263]
-- CASE 502-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 502
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [88/263]
-- CASE 74820-74672: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74820
  AND CAST(b.destination_location_id AS BIGINT) = 74672
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [89/263]
-- CASE 311-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 311
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [90/263]
-- CASE 222-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 222
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [91/263]
-- CASE 504-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 504
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [92/263]
-- CASE 467-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 467
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [93/263]
-- CASE 235-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 235
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [94/263]
-- CASE 122-222: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 222
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [95/263]
-- CASE 123-467: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 467
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [96/263]
-- CASE 124-316: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 316
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [97/263]
-- CASE 1608-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1608
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [98/263]
-- CASE 124-634: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 634
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [99/263]
-- CASE 123-502: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 502
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [100/263]
-- CASE 347-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 347
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [101/263]
-- CASE 313-94152: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 313
  AND CAST(b.destination_location_id AS BIGINT) = 94152
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [102/263]
-- CASE 123-437: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 437
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [103/263]
-- CASE 422-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 422
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [104/263]
-- CASE 130-1382: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 1382
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [105/263]
-- CASE 123-1608: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 1608
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [106/263]
-- CASE 316-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 316
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [107/263]
-- CASE 437-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 437
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [108/263]
-- CASE 123-504: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 504
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [109/263]
-- CASE 197222-74820: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 197222
  AND CAST(b.destination_location_id AS BIGINT) = 74820
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [110/263]
-- CASE 122-163: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 163
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [111/263]
-- CASE 473-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 473
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [112/263]
-- CASE 624-309: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 624
  AND CAST(b.destination_location_id AS BIGINT) = 309
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [113/263]
-- CASE 163-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 163
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [114/263]
-- CASE 124-422: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 422
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [115/263]
-- CASE 309-624: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 309
  AND CAST(b.destination_location_id AS BIGINT) = 624
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [116/263]
-- CASE 444-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 444
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [117/263]
-- CASE 428-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 428
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [118/263]
-- CASE 551-1125: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 551
  AND CAST(b.destination_location_id AS BIGINT) = 1125
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [119/263]
-- CASE 634-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 634
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [120/263]
-- CASE 123-428: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 428
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [121/263]
-- CASE 458-141: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 458
  AND CAST(b.destination_location_id AS BIGINT) = 141
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [122/263]
-- CASE 94152-313: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 94152
  AND CAST(b.destination_location_id AS BIGINT) = 313
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [123/263]
-- CASE 698-141: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 698
  AND CAST(b.destination_location_id AS BIGINT) = 141
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [124/263]
-- CASE 733-76481: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 733
  AND CAST(b.destination_location_id AS BIGINT) = 76481
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [125/263]
-- CASE 167-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 167
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [126/263]
-- CASE 690-141: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 690
  AND CAST(b.destination_location_id AS BIGINT) = 141
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [127/263]
-- CASE 443-979: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 443
  AND CAST(b.destination_location_id AS BIGINT) = 979
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [128/263]
-- CASE 690-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 690
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [129/263]
-- CASE 74701-79598: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74701
  AND CAST(b.destination_location_id AS BIGINT) = 79598
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [130/263]
-- CASE 497-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 497
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [131/263]
-- CASE 125-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 125
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [132/263]
-- CASE 76481-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 76481
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [133/263]
-- CASE 248-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 248
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [134/263]
-- CASE 122-167: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 167
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [135/263]
-- CASE 973-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 973
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [136/263]
-- CASE 911-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 911
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [137/263]
-- CASE 696-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 696
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [138/263]
-- CASE 216-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 216
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [139/263]
-- CASE 233-141: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 233
  AND CAST(b.destination_location_id AS BIGINT) = 141
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [140/263]
-- CASE 130-571: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 571
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [141/263]
-- CASE 1382-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1382
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [142/263]
-- CASE 123-973: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 973
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [143/263]
-- CASE 80089-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 80089
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [144/263]
-- CASE 123-497: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 497
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [145/263]
-- CASE 219-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 219
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [146/263]
-- CASE 123-219: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 219
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [147/263]
-- CASE 470-807: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 470
  AND CAST(b.destination_location_id AS BIGINT) = 807
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [148/263]
-- CASE 135-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 135
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [149/263]
-- CASE 1125-551: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1125
  AND CAST(b.destination_location_id AS BIGINT) = 551
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [150/263]
-- CASE 123-80089: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 80089
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [151/263]
-- CASE 122-95220: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 95220
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [152/263]
-- CASE 571-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 571
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [153/263]
-- CASE 123-506: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 506
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [154/263]
-- CASE 1290-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1290
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [155/263]
-- CASE 130-450: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 450
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [156/263]
-- CASE 470-551: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 470
  AND CAST(b.destination_location_id AS BIGINT) = 551
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [157/263]
-- CASE 729-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 729
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [158/263]
-- CASE 124-71586: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 71586
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [159/263]
-- CASE 1439-807: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1439
  AND CAST(b.destination_location_id AS BIGINT) = 807
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [160/263]
-- CASE 455-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 455
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [161/263]
-- CASE 125-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 125
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [162/263]
-- CASE 1003-551: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1003
  AND CAST(b.destination_location_id AS BIGINT) = 551
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [163/263]
-- CASE 737-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 737
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [164/263]
-- CASE 124-321: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 321
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [165/263]
-- CASE 321-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 321
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [166/263]
-- CASE 506-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 506
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [167/263]
-- CASE 71586-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 71586
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [168/263]
-- CASE 122-911: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 911
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [169/263]
-- CASE 95220-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 95220
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [170/263]
-- CASE 624-70024: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 624
  AND CAST(b.destination_location_id AS BIGINT) = 70024
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [171/263]
-- CASE 124-729: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 729
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [172/263]
-- CASE 1437-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1437
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [173/263]
-- CASE 79598-74701: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 79598
  AND CAST(b.destination_location_id AS BIGINT) = 74701
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [174/263]
-- CASE 130-1492: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 1492
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [175/263]
-- CASE 979-443: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 979
  AND CAST(b.destination_location_id AS BIGINT) = 443
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [176/263]
-- CASE 230-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 230
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [177/263]
-- CASE 123-230: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 230
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [178/263]
-- CASE 123-455: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 455
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [179/263]
-- CASE 470-1169: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 470
  AND CAST(b.destination_location_id AS BIGINT) = 1169
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [180/263]
-- CASE 733-1437: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 733
  AND CAST(b.destination_location_id AS BIGINT) = 1437
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [181/263]
-- CASE 653-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 653
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [182/263]
-- CASE 736-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 736
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [183/263]
-- CASE 229-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 229
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [184/263]
-- CASE 473-472: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 473
  AND CAST(b.destination_location_id AS BIGINT) = 472
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [185/263]
-- CASE 123-619: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 619
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [186/263]
-- CASE 664-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 664
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [187/263]
-- CASE 70014-93966: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 70014
  AND CAST(b.destination_location_id AS BIGINT) = 93966
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [188/263]
-- CASE 1169-470: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1169
  AND CAST(b.destination_location_id AS BIGINT) = 470
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [189/263]
-- CASE 122-229: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 229
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [190/263]
-- CASE 472-473: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 472
  AND CAST(b.destination_location_id AS BIGINT) = 473
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [191/263]
-- CASE 122-634: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 634
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [192/263]
-- CASE 450-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 450
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [193/263]
-- CASE 634-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 634
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [194/263]
-- CASE 188-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 188
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [195/263]
-- CASE 70024-624: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 70024
  AND CAST(b.destination_location_id AS BIGINT) = 624
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [196/263]
-- CASE 502-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 502
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [197/263]
-- CASE 123-81152: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 81152
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [198/263]
-- CASE 74676-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74676
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [199/263]
-- CASE 619-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 619
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [200/263]
-- CASE 130-643: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 643
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [201/263]
-- CASE 1492-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1492
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [202/263]
-- CASE 443-313: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 443
  AND CAST(b.destination_location_id AS BIGINT) = 313
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [203/263]
-- CASE 123-488: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 488
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [204/263]
-- CASE 130-79169: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 79169
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [205/263]
-- CASE 83760-70024: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 83760
  AND CAST(b.destination_location_id AS BIGINT) = 70024
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [206/263]
-- CASE 462-571: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 462
  AND CAST(b.destination_location_id AS BIGINT) = 571
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [207/263]
-- CASE 136-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 136
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [208/263]
-- CASE 571-462: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 571
  AND CAST(b.destination_location_id AS BIGINT) = 462
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [209/263]
-- CASE 130-1384: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 1384
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [210/263]
-- CASE 81152-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 81152
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [211/263]
-- CASE 313-443: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 313
  AND CAST(b.destination_location_id AS BIGINT) = 443
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [212/263]
-- CASE 422-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 422
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [213/263]
-- CASE 401-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 401
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [214/263]
-- CASE 130-65907: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 65907
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [215/263]
-- CASE 124-330: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 330
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [216/263]
-- CASE 70024-313: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 70024
  AND CAST(b.destination_location_id AS BIGINT) = 313
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [217/263]
-- CASE 954-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 954
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [218/263]
-- CASE 124-675: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 675
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [219/263]
-- CASE 124-85637: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 85637
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [220/263]
-- CASE 123-664: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 664
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [221/263]
-- CASE 122-188: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 188
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [222/263]
-- CASE 124-352: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 352
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [223/263]
-- CASE 71425-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 71425
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [224/263]
-- CASE 124-136: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 136
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [225/263]
-- CASE 122-422: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 422
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [226/263]
-- CASE 488-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 488
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [227/263]
-- CASE 84793-70024: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 84793
  AND CAST(b.destination_location_id AS BIGINT) = 70024
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [228/263]
-- CASE 122-502: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 502
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [229/263]
-- CASE 124-262: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 262
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [230/263]
-- CASE 122-653: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 653
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [231/263]
-- CASE 352-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 352
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [232/263]
-- CASE 74820-197222: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74820
  AND CAST(b.destination_location_id AS BIGINT) = 197222
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [233/263]
-- CASE 93966-70014: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 93966
  AND CAST(b.destination_location_id AS BIGINT) = 70014
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [234/263]
-- CASE 130-237: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 130
  AND CAST(b.destination_location_id AS BIGINT) = 237
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [235/263]
-- CASE 122-557: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 557
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [236/263]
-- CASE 262-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 262
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [237/263]
-- CASE 330-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 330
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [238/263]
-- CASE 557-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 557
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [239/263]
-- CASE 390-122: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 390
  AND CAST(b.destination_location_id AS BIGINT) = 122
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [240/263]
-- CASE 95083-462: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 95083
  AND CAST(b.destination_location_id AS BIGINT) = 462
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [241/263]
-- CASE 124-320: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 124
  AND CAST(b.destination_location_id AS BIGINT) = 320
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [242/263]
-- CASE 611-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 611
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [243/263]
-- CASE 685-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 685
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [244/263]
-- CASE 292-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 292
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [245/263]
-- CASE 123-954: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 954
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [246/263]
-- CASE 95040-733: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 95040
  AND CAST(b.destination_location_id AS BIGINT) = 733
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [247/263]
-- CASE 74701-79589: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 74701
  AND CAST(b.destination_location_id AS BIGINT) = 79589
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [248/263]
-- CASE 122-390: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 390
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [249/263]
-- CASE 1384-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1384
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [250/263]
-- CASE 1439-70015: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1439
  AND CAST(b.destination_location_id AS BIGINT) = 70015
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [251/263]
-- CASE 123-1123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 1123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [252/263]
-- CASE 1123-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 1123
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [253/263]
-- CASE 675-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 675
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [254/263]
-- CASE 248-123: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 248
  AND CAST(b.destination_location_id AS BIGINT) = 123
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [255/263]
-- CASE 70024-83760: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 70024
  AND CAST(b.destination_location_id AS BIGINT) = 83760
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [256/263]
-- CASE 123-685: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 685
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [257/263]
-- CASE 123-292: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 292
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [258/263]
-- CASE 624-313: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 624
  AND CAST(b.destination_location_id AS BIGINT) = 313
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [259/263]
-- CASE 320-124: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 320
  AND CAST(b.destination_location_id AS BIGINT) = 124
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [260/263]
-- CASE 122-601: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 122
  AND CAST(b.destination_location_id AS BIGINT) = 601
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [261/263]
-- CASE 79169-130: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 79169
  AND CAST(b.destination_location_id AS BIGINT) = 130
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [262/263]
-- CASE 141-506: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 141
  AND CAST(b.destination_location_id AS BIGINT) = 506
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;

-- [263/263]
-- CASE 123-611: Primo transacting BO_IDs (last 5 days, IND, issued)
SELECT
    CAST(b.source_location_id AS BIGINT) AS source_location_id,
    CAST(b.destination_location_id AS BIGINT) AS destination_location_id,
    CAST(CONCAT(CAST(b.source_location_id AS VARCHAR), '-', CAST(b.destination_location_id AS VARCHAR)) AS VARCHAR) AS sd,
    CAST(b.operator_id AS BIGINT) AS bo_id,
    COUNT(DISTINCT b.tin) AS tickets,
    SUM(b.seat_count) AS seats
FROM transaction.bus_ticket_events b
WHERE b.event_type = 101
  AND b.country_code = 'IND'
  AND b.hft = 2
  AND b.time_of_event >= TIMESTAMP '2026-09-17 00:00:00'
  AND b.time_of_event < TIMESTAMP '2026-09-23 00:00:00'
  AND CAST(b.source_location_id AS BIGINT) = 123
  AND CAST(b.destination_location_id AS BIGINT) = 611
GROUP BY 1, 2, 3, 4
ORDER BY tickets DESC;
