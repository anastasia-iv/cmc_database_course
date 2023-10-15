Необходимо подготовить SQL-скрипты 
-- для проверки наличия аномалий (потерянных изменений, грязных чтений, неповторяющихся чтений, фантомов) при параллельном исполнении транзакций на различных уровнях изолированности SQL/92 (READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE). Подготовленные скрипты должны работать с одной из таблиц, созданных в лабораторной №2.1. 
-- Для проверки наличия аномалий потребуются два параллельных сеанса, операторы в которых выполняются пошагово:

• Установить в обоих сеансах уровень изоляции READ UNCOMMITTED. Выполнить
сценарии проверки наличия аномалий потерянных изменений и грязных чтений
--Грязное чтение невозможно

--вторая транзакция не видит изменение значения из первой — незафиксированной — транзакции.
--в PostgreSQL реализация уровня изоляции READ UNCOMMITTED более строгая, чем того требует стандарт языка
--SQL. Фактически этот уровень тождественен уровню изоляции READCOMMITTED.

--term1
BEGIN;
set search_path = tickets;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
UPDATE art.tickets SET ticket_cost_dollars = ticket_cost_dollars + 1 WHERE location_id = 6;
SELECT * FROM art.tickets WHERE location_id = 6;
 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
         8 |           6 | абонемент        |               30.60
        19 |           6 | экскурсионный    |               24.91
        24 |           6 | экскурсионный    |               24.91
         7 |           6 | льготный_входной |                5.14
--term2
BEGIN;
set search_path = tickets;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM art.tickets WHERE location_id = 6;

 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
         8 |           6 | абонемент        |               29.60
        19 |           6 | экскурсионный    |               23.91
        24 |           6 | экскурсионный    |               23.91
         7 |           6 | льготный_входной |                4.14

--аномалий потерянных изменений 
--term1
BEGIN;
set search_path = tickets;SET
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;SET
--term 2
            BEGIN;
            set search_path = tickets;SET
            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;SET
            UPDATE art.tickets SET ticket_cost_dollars = ticket_cost_dollars + 10 WHERE location_id = 6;
            (UPDATE 4)
            SELECT * FROM ART.TICKETS;
           8 |           6 | абонемент          |               43.60
          19 |           6 | экскурсионный      |               37.91
          24 |           6 | экскурсионный      |               37.91
           7 |           6 | льготный_входной   |               18.14
          
--term1
UPDATE art.tickets SET ticket_cost_dollars = ticket_cost_dollars + 1 WHERE location_id = 6; --в состоянии ожидании коммита из term2 строка заблокирована, а блокировка снимается только при завершении транзакции.
--term2
              COMMIT;
(UPDATE 4)
SELECT * FROM art.tickets;
         8 |           6 | абонемент          |               44.60
        19 |           6 | экскурсионный      |               38.91
        24 |           6 | экскурсионный      |               38.91
         7 |           6 | льготный_входной   |               19.14

• Установить в обоих сеансах уровень изоляции READ COMMITTED. Выполнить
сценарии проверки наличия аномалий грязных чтений и неповторяющихся чтений

--Грязное чтение невозможно
--Аномалия неповторяющегося чтения ~ READ UNCOMMITED
--term2
set search_path = tickets;
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM art.tickets WHERE location_id = 6;

 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
         8 |           6 | абонемент        |               29.60
        19 |           6 | экскурсионный    |               23.91
        24 |           6 | экскурсионный    |               23.91
         7 |           6 | льготный_входной |                4.14
--term1
            BEGIN;
            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
            UPDATE art.tickets SET ticket_cost_dollars = ticket_cost_dollars + 1 WHERE location_id = 6;
            SELECT * FROM art.tickets WHERE location_id = 6; 
             ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
            -----------+-------------+------------------+---------------------
                     8 |           6 | абонемент        |               30.60
                    19 |           6 | экскурсионный    |               24.91
                    24 |           6 | экскурсионный    |               24.91
                     7 |           6 | льготный_входной |                5.14      
            COMMIT;
--term2
SELECT * FROM art.tickets WHERE location_id = 6;
 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
         8 |           6 | абонемент        |               30.60
        19 |           6 | экскурсионный    |               24.91
        24 |           6 | экскурсионный    |               24.91
         7 |           6 | льготный_входной |                5.14

• Установить в обоих сеансах уровень изоляции REPEATABLE READ. Выполнить
сценарии проверки наличия аномалий неповторяющихся чтений и фантомов.

--транзакция, использующая этот уровень изоляции, создает снимок данных однократно, перед выполнением первого запроса транзакции.
--Поэтому транзакции с этим уровнем изоляции не могут изменять строки, которые были изменены другими завершившимися
--транзакциями уже после создания снимка. Вследствие этого PostgreSQL не позволит зафиксировать транзакцию, которая попытается изменить уже измененную строку.

--Важно помнить, что повторный запуск может потребоваться только для транзакций, которые вносят изменения в данные. Для
--транзакций, которые только читают данные, повторный запуск никогда не требуется.

-- неповторяющиеся чтения не возможны
--term1
BEGIN;
set search_path = tickets;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM art.tickets;

 ticket_id | location_id |    ticket_type     | ticket_cost_dollars 
-----------+-------------+--------------------+---------------------
         2 |           2 | экскурсионный      |               22.33
         5 |           4 | льготный_абонемент |               24.71
         6 |           5 | экскурсионный      |               20.41
         9 |           8 | экскурсионный      |               18.08
        10 |           7 | льготный_абонемент |               20.74
        12 |          10 | льготный_абонемент |               27.87
        14 |          12 | абонемент          |               30.83
        15 |          13 | экскурсионный      |               21.87
        17 |           5 | экскурсионный      |               25.04
        21 |           1 | абонемент          |               40.38
        22 |           5 | экскурсионный      |               25.04
        26 |           4 | абонемент          |               40.38
         1 |           1 | льготный_входной   |                   0
         3 |           3 | входной            |                  11
         4 |           4 | льготный_входной   |                1.19
        11 |           9 | льготный_входной   |                1.39
        13 |          11 | входной            |               12.98
        16 |          11 | льготный_входной   |                3.45
        18 |          12 | льготный_входной   |               12.26
        20 |          10 | льготный_входной   |                6.35
        23 |          12 | льготный_входной   |               12.26
        25 |           5 | льготный_входной   |                6.35
        27 |           1 | входной            |                   5
        31 |           1 | входной            |                   5
        32 |           1 | входной            |                   5
         8 |           6 | абонемент          |               43.60
        19 |           6 | экскурсионный      |               37.91
        24 |           6 | экскурсионный      |               37.91
         7 |           6 | льготный_входной   |               18.14

-- term2
                    BEGIN;
                    set search_path = tickets;
                    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
                    INSERT INTO art.tickets (location_id, ticket_type, ticket_cost_dollars) VALUES (6, 'входной', 4);
                    (INSERT 0 1)
                    UPDATE art.tickets SET ticket_cost_dollars = ticket_cost_dollars + 4 WHERE location_id = 1;
                    (UPDATE 5)
                    COMMIT;
-- term1
SELECT * FROM art.tickets;
ticket_id | location_id |    ticket_type     | ticket_cost_dollars 
-----------+-------------+--------------------+---------------------
         2 |           2 | экскурсионный      |               22.33
         5 |           4 | льготный_абонемент |               24.71
         6 |           5 | экскурсионный      |               20.41
         9 |           8 | экскурсионный      |               18.08
        10 |           7 | льготный_абонемент |               20.74
        12 |          10 | льготный_абонемент |               27.87
        14 |          12 | абонемент          |               30.83
        15 |          13 | экскурсионный      |               21.87
        17 |           5 | экскурсионный      |               25.04
        21 |           1 | абонемент          |               40.38
        22 |           5 | экскурсионный      |               25.04
        26 |           4 | абонемент          |               40.38
         1 |           1 | льготный_входной   |                   0
         3 |           3 | входной            |                  11
         4 |           4 | льготный_входной   |                1.19
        11 |           9 | льготный_входной   |                1.39
        13 |          11 | входной            |               12.98
        16 |          11 | льготный_входной   |                3.45
        18 |          12 | льготный_входной   |               12.26
        20 |          10 | льготный_входной   |                6.35
        23 |          12 | льготный_входной   |               12.26
        25 |           5 | льготный_входной   |                6.35
        27 |           1 | входной            |                   5
        31 |           1 | входной            |                   5
        32 |           1 | входной            |                   5
         8 |           6 | абонемент          |               43.60
        19 |           6 | экскурсионный      |               37.91
        24 |           6 | экскурсионный      |               37.91
         7 |           6 | льготный_входной   |               18.14

-- Изменения не видны,  поскольку первая транзакция использовала снимок,сделанный до внесения изменений и их фиксации второй транзакцией. 

--чтение фантомных строк(когда при выборке одних и тех же строк параллельная транзакция изменяет эти строки, в результате чего в первой транзакции менется первая выборка) не допускается
--term1
BEGIN;
set search_path = tickets;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
--term2
          BEGIN;
          set search_path = tickets;
          SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
--term1
SELECT * FROM art.tickets WHERE location_id = 9;
 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
        11 |           9 | льготный_входной |                1.39
--term2
          INSERT INTO art.tickets (location_id, ticket_type, ticket_cost_dollars) VALUES (9, 'входной', 4);
          (INSERT 0 1)
          COMMIT;
--term1
SELECT * FROM art.tickets WHERE location_id = 9;
 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
        11 |           9 | льготный_входной |                1.39

-- Изменения не видны,  поскольку первая транзакция использовала снимок,сделанный до внесения изменений и их фиксации второй транзакцией. 

• Установить в обоих сеансах уровень изоляции SERIALIZABLE. Выполнить сценарий проверки наличия фантомов.

-- Группа транзакций может быть параллельно выполнена и успешно зафиксирована в том случае, когда результат их параллельного
--выполнения был бы эквивалентен результату выполнения этих транзакций при выборе одного из возможных вариантов их
--упорядочения, если бы они выполнялись последовательно, одна за другой.

--приложение должно быть готово к тому, что придется перезапускать транзакцию, которая была прервана системой из-за обнаружения
--зависимостей чтения/записи между транзакциями.

--term1
BEGIN;
set search_path = tickets;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
--term2
          BEGIN;
          set search_path = tickets;
          SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
--term1
SELECT * FROM art.tickets WHERE location_id = 9;
 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
        34 |           9 | входной          |                   4
        11 |           9 | льготный_входной |                1.39

--term2
          INSERT INTO art.tickets (location_id, ticket_type, ticket_cost_dollars) VALUES (9, 'льготный_абонемент', 8);          (INSERT 0 1)
          COMMIT;
--term1
SELECT * FROM art.tickets WHERE location_id = 9;
 ticket_id | location_id |   ticket_type    | ticket_cost_dollars 
-----------+-------------+------------------+---------------------
        34 |           9 | входной          |                   4
        11 |           9 | льготный_входной |                1.39
