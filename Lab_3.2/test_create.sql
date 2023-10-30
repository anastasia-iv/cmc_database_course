• Создать пользователя test и выдать ему доступ к базе данных.
  
• Составить и выполнить скрипты присвоения новому пользователю прав доступа
  к таблицам, созданным в практическом задании №3.1. При этом права доступа к
  различным таблицам должны быть различными, а именно:
  – По крайней мере, для одной таблицы новому пользователю присваиваются права
  SELECT, INSERT, UPDATE в полном объеме.
  – По крайней мере, для одной таблицы новому пользователю присваиваются права
  SELECT и UPDATE только избранных столбцов.
  – По крайней мере, для одной таблицы новому пользователю присваивается только
  право SELECT.
  
• Составить SQL-скрипты для создания нескольких представлений, которые позволяли
  бы упростить манипуляции с данными или позволяли бы ограничить доступ к данным,
  предоставляя только необходимую информацию.
  
• Присвоить новому пользователю право доступа (SELECT) к одному из представлений

• Создать стандартную роль уровня базы данных, присвоить ей право доступа (UPDATE
  на некоторые столбцы) к одному из представлений, назначить новому пользователю
  созданную роль.
• Выполнить от имени нового пользователя некоторые выборки из таблиц и представлений. 
  Убедиться в правильности контроля прав доступа.

• Выполнить от имени нового пользователя операторы изменения таблиц с ограниченными правами доступа. 
  Убедиться в правильности контроля прав доступа.

REVOKE ALL PRIVILEGES ON SCHEMA stat FROM test;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA stat FROM test;
REVOKE ALL PRIVILEGES ON SCHEMA stat FROM test_view;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA stat FROM test_view;
DROP VIEW students_msu;
DROP VIEW location_list;
DROP USER test;

DROP USER standart_role;
DROP USER test_view;

CREATE USER test PASSWORD '12345';
GRANT USAGE ON SCHEMA stat TO test;

GRANT SELECT, UPDATE, INSERT ON stat.tickets TO test;
GRANT SELECT (student_id, university_id, university_name, course, marks, achievments), UPDATE (course, marks, achievments) ON stat.students TO test;
GRANT SELECT ON stat.location TO test;

CREATE OR REPLACE VIEW students_msu AS
    SELECT student_id, student_name, course, marks
    FROM stat.students
    WHERE university = "МГУ"
    WITH CASCADED CHECK OPTION;
/*
Если оно присутствует, при выполнении операций INSERT и UPDATE с этим представлением будет проверяться,
удовлетворяют ли новые строки условию, определяющему представление 
(то есть, проверяется, будут ли новые строки видны через это представление). 
Если они не удовлетворяют условию, операция не будет выполнена. Если указание CHECK OPTION отсутствует,
команды INSERT и UPDATE смогут создавать в этом представлении строки, которые не будут видны в нём.

CASCADED  -  Новые строки проверяются по условиям данного представления и всех нижележащих базовых. 
Если указано CHECK OPTION, а LOCAL и CASCADED опущено, подразумевается указание CASCADED.
*/

CREATE OR REPLACE VIEW location_list AS
    SELECT location_id, location_name
    FROM schedule.exams;
GRANT SELECT ON location_list TO test;

CREATE ROLE standart_role;
GRANT SELECT, UPDATE (course, marks) ON students_msu TO standart_role;
CREATE USER test_view PASSWORD '12345';

GRANT test_role TO test_view;
GRANT USAGE ON SCHEMA stat to test_view;
GRANT USAGE ON SCHEMA stat to test;
--USAGE доступ к схеме, чтобы использовать объекты внутри нее

REVOKE ALL PRIVILEGES ON table FROM user
