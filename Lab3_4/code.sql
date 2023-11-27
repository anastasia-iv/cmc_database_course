DROP INDEX IF EXISTS stat.student_course;
DROP INDEX IF EXISTS stat.student_achievments;
DROP INDEX IF EXISTS stat.tickets_info;
DROP INDEX IF EXISTS stat.multi_index;

-- обычный int

EXPLAIN ANALYZE SELECT * FROM stat.students WHERE course < 3;
/*
"QUERY PLAN"
"Seq Scan on students  (cost=0.00..51707.00 rows=247233 width=234) (actual time=1.160..939.158 rows=582834 loops=1)"
"  Filter: (course < 3)"
"  Rows Removed by Filter: 417166"
"Planning Time: 0.166 ms"
"Execution Time: 1043.750 ms"
*/

--просмотреть все индексы
/*
select *
from pg_indexes
where tablename not like 'pg%';
*/
CREATE INDEX student_course ON stat.students (course);
--2 secs 928 msec
EXPLAIN ANALYZE SELECT * FROM stat.students WHERE course < 3;
/*
"QUERY PLAN"
"Bitmap Heap Scan on students  (cost=2756.48..45053.89 rows=247233 width=234) (actual time=56.979..815.494 rows=249901 loops=1)"
"  Recheck Cond: (course < 3)"
"  Heap Blocks: exact=33624"
"  ->  Bitmap Index Scan on students_index  (cost=0.00..2694.67 rows=247233 width=0) (actual time=36.055..36.056 rows=249901 loops=1)"
"        Index Cond: (course < 3)"
"Planning Time: 0.359 ms"
"Execution Time: 851.477 ms"
*/


--пример с использованием json
EXPLAIN ANALYZE SELECT * FROM stat.students NATURAL JOIN stat.tickets 
WHERE info @> '{"type": "Экскурсионный", "privileges": "Льготный"}'::jsonb;
/*
"QUERY PLAN"
"Gather  (cost=63010.00..1857356.41 rows=3697273 width=334) (actual time=54417.904..59127.452 rows=3874388 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Hash Join  (cost=62010.00..1486629.11 rows=1540530 width=334) (actual time=54369.434..56566.749 rows=1291463 loops=3)"
"        Hash Cond: (tickets.student_id = students.student_id)"
"        ->  Parallel Seq Scan on tickets  (cost=0.00..1359005.21 rows=1540530 width=104) (actual time=3.066..48688.640 rows=1291463 loops=3)"
"              Filter: (info @> '{""type"": ""Экскурсионный"", ""privileges"": ""Льготный""}'::jsonb)"
"              Rows Removed by Filter: 19375238"
"        ->  Parallel Hash  (cost=43373.67..43373.67 rows=416667 width=234) (actual time=1851.593..1851.595 rows=333333 loops=3)"
"              Buckets: 16384  Batches: 128  Memory Usage: 2304kB"
"              ->  Parallel Seq Scan on students  (cost=0.00..43373.67 rows=416667 width=234) (actual time=0.052..252.122 rows=333333 loops=3)"
"Planning Time: 3.784 ms"
"Execution Time: 59709.638 ms"
*/
CREATE INDEX tickets_info ON stat.tickets USING GIN(info);
EXPLAIN ANALYZE SELECT * FROM stat.students NATURAL JOIN stat.tickets 
WHERE info @> '{"type": "Экскурсионный", "privileges": "Льготный"}'::jsonb;
/*
"QUERY PLAN"
"Gather  (cost=19762.80..71098.78 rows=62906 width=334) (actual time=432.978..1060.221 rows=62191 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Hash Join  (cost=18762.80..63808.18 rows=26211 width=334) (actual time=421.618..995.402 rows=20730 loops=3)"
"        Hash Cond: (students.student_id = tickets.student_id)"
"        ->  Parallel Seq Scan on students  (cost=0.00..43373.67 rows=416667 width=234) (actual time=0.058..272.047 rows=333333 loops=3)"
"        ->  Parallel Hash  (cost=18435.16..18435.16 rows=26211 width=104) (actual time=420.453..420.456 rows=20730 loops=3)"
"              Buckets: 65536  Batches: 1  Memory Usage: 9344kB"
"              ->  Parallel Bitmap Heap Scan on tickets  (cost=1391.53..18435.16 rows=26211 width=104) (actual time=163.396..372.644 rows=20730 loops=3)"
"                    Recheck Cond: (info @> '{""type"": ""Экскурсионный"", ""privileges"": ""Льготный""}'::jsonb)"
"                    Heap Blocks: exact=7226"
"                    ->  Bitmap Index Scan on tickets_info  (cost=0.00..1375.80 rows=62906 width=0) (actual time=162.414..162.414 rows=62191 loops=1)"
"                          Index Cond: (info @> '{""type"": ""Экскурсионный"", ""privileges"": ""Льготный""}'::jsonb)"
"Planning Time: 0.978 ms"
"Execution Time: 1070.686 ms"
*/


-- пример с условием на несколько полей
EXPLAIN ANALYZE SELECT * FROM stat.students JOIN stat.tickets USING (student_id) WHERE student_id < 200003 AND date_of_purchase < '2019-06-25';
/*
"QUERY PLAN"
"Gather  (cost=4664.73..1383688.51 rows=29291 width=334) (actual time=737.210..24862.093 rows=30769 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Hash Join  (cost=3664.73..1379759.41 rows=12205 width=334) (actual time=869.109..24706.179 rows=10256 loops=3)"
"        Hash Cond: (tickets.student_id = students.student_id)"
"        ->  Parallel Seq Scan on tickets  (cost=0.00..1359026.21 rows=6502246 width=104) (actual time=860.040..21079.348 rows=5149810 loops=3)"
"              Filter: (date_of_purchase < '2016-06-25 00:00:00'::timestamp without time zone)"
"              Rows Removed by Filter: 15516891"
"        ->  Hash  (cost=3641.27..3641.27 rows=1877 width=234) (actual time=7.088..7.091 rows=2002 loops=3)"
"              Buckets: 2048  Batches: 1  Memory Usage: 550kB"
"              ->  Index Scan using students_pkey on students  (cost=0.42..3641.27 rows=1877 width=234) (actual time=0.273..5.916 rows=2002 loops=3)"
"                    Index Cond: (student_id < 2003)"
"Planning Time: 0.660 ms"
"JIT:"
"  Functions: 42"
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 11.122 ms, Inlining 606.011 ms, Optimization 1242.895 ms, Emission 730.136 ms, Total 2590.165 ms"
"Execution Time: 24879.620 ms"
*/


CREATE INDEX tickets_info ON stat.tickets(student_id, date_of_purchase)
EXPLAIN ANALYZE SELECT * FROM stat.students JOIN stat.tickets USING (student_id) WHERE student_id = 1000003 AND date_of_purchase < '2023-06-25';
/*
"QUERY PLAN"
"Gather  (cost=1055.54..76678.67 rows=29289 width=334) (actual time=3.662..2755.873 rows=30769 loops=1)"
"  Workers Planned: 1"
"  Workers Launched: 1"
"  ->  Nested Loop  (cost=55.54..72749.77 rows=17229 width=334) (actual time=1.612..2645.398 rows=15384 loops=2)"
"        ->  Parallel Bitmap Heap Scan on students  (cost=54.97..6214.80 rows=1104 width=234) (actual time=0.962..3.594 rows=1001 loops=2)"
"              Recheck Cond: (student_id < 2003)"
"              Heap Blocks: exact=45"
"              ->  Bitmap Index Scan on students_pkey  (cost=0.00..54.50 rows=1877 width=0) (actual time=1.689..1.689 rows=2287 loops=1)"
"                    Index Cond: (student_id < 2003)"
"        ->  Index Scan using tickets_info on tickets  (cost=0.56..60.13 rows=14 width=104) (actual time=0.195..2.599 rows=15 loops=2002)"
"              Index Cond: ((student_id = students.student_id) AND (date_of_purchase < '2016-06-25 00:00:00'::timestamp without time zone))"
"Planning Time: 4.111 ms"
"Execution Time: 2767.854 ms"
*/

-- секционирование таблиц
EXPLAIN ANALYZE SELECT * FROM stat.tickets WHERE date_of_purchase = '2022-01-22';
/*
"QUERY PLAN"
"Gather  (cost=1000.00..1360005.31 rows=1 width=104) (actual time=21234.002..21257.310 rows=0 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on tickets  (cost=0.00..1359005.21 rows=1 width=104) (actual time=21165.819..21165.821 rows=0 loops=3)"
"        Filter: (date_of_purchase = '2022-01-22 00:00:00'::timestamp without time zone)"
"        Rows Removed by Filter: 20666701"
"Planning Time: 0.129 ms"
"Execution Time: 21258.056 ms"
*/

CREATE TABLE meas (
  	ticket_id	SERIAL,
    student_id integer,
  	price_dollars numeric(8, 2),
  	info jsonb,
  	location_id integer,
    date_of_purchase timestamp
) PARTITION BY RANGE (date_of_purchase);

CREATE TABLE meas2021 PARTITION OF meas
    FOR VALUES FROM ('2020-01-10') TO ('2021-01-10');

CREATE TABLE meas2022 PARTITION OF meas
    FOR VALUES FROM ('2021-01-10') TO ('2022-01-10');

CREATE TABLE meas2023 PARTITION OF meas
    FOR VALUES FROM ('2022-01-10') TO ('2023-01-10');

CREATE TABLE oldest PARTITION OF meas
    FOR VALUES FROM ('2000-01-10') TO ('2020-01-10');

CREATE TABLE newest PARTITION OF meas
    FOR VALUES FROM ('2023-01-10') TO ('2024-01-10');

INSERT INTO meas(ticket_id, student_id, price_dollars, info, location_id, date_of_purchase)
SELECT * FROM stat.tickets;
EXPLAIN ANALYZE SELECT * FROM meas WHERE date_of_purchase = '2022-01-22';

/*
"QUERY PLAN"
"Gather  (cost=1000.00..1723722.07 rows=1 width=160) (actual time=1.326..18768.156 rows=3341400 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Append  (cost=0.00..1692993.87 rows=123868 width=160) (actual time=0.388..18341.902 rows=1113800 loops=3)"
"        ->  Parallel Seq Scan on meas2023  (cost=0.00..1692374.53 rows=123868 width=160) (actual time=0.384..15386.676 rows=1113800 loops=3)"
"              Filter: (date_of_purchase = '2022-01-22')"
"              Rows Removed by Filter: 10006100"
"Planning Time: 1.493 ms"
"Execution Time: 122136.370 ms"
*/

-- полнотекстовый поиск
EXPLAIN ANALYZE SELECT achievments FROM stat.students  WHERE to_tsvector('russian', achievments) @@ to_tsquery('russian', 'хакатон | олимпиада');
/*
"QUERY PLAN"
"Gather  (cost=1000.00..150579.50 rows=9975 width=105) (actual time=100.640..19583.614 rows=352721 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on tickets  (cost=0.00..148582.00 rows=4156 width=105) (actual time=72.832..19357.255 rows=117574 loops=3)"
"        Filter: (to_tsvector('russian'::regconfig, achievments) @@ '''хакатон'' | ''олимпиад'''::tsquery)"
"        Rows Removed by Filter: 215760"
"Planning Time: 11.404 ms"
"Execution Time: 19678.737 ms"
*/
CREATE INDEX student_achievments ON stat.students USING GIN(to_tsvector('russian', achievments));
EXPLAIN ANALYZE SELECT achievments FROM stat.students  WHERE to_tsvector('russian', achievments) @@ to_tsquery('russian', 'хакатон | олимпиада');
/*
"QUERY PLAN"
"Bitmap Heap Scan on students  (cost=533.31..25937.70 rows=9975 width=105) (actual time=219.675..952.683 rows=352721 loops=1)"
"  Recheck Cond: (to_tsvector('russian'::regconfig, achievments) @@ '''хакатон'' | ''олимпиад'''::tsquery)"
"  Heap Blocks: exact=39206"
"  ->  Bitmap Index Scan on student_achievments  (cost=0.00..530.81 rows=9975 width=0) (actual time=194.353..194.354 rows=352721 loops=1)"
"        Index Cond: (to_tsvector('russian'::regconfig, achievments) @@ '''хакатон'' | ''олимпиад'''::tsquery)"
"Planning Time: 4.084 ms"
"Execution Time: 996.468 ms"
*/
