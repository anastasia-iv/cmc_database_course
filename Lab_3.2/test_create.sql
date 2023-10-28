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
• Выполнить от имени нового пользователя некоторые выборки из таблиц и представлений. Убедиться в правильности контроля прав доступа.

• Выполнить от имени нового пользователя операторы изменения таблиц с ограниченными правами доступа. Убедиться в правильности контроля прав доступа.

REVOKE ALL PRIVILEGES ON SCHEMA stat FROM test;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA stat FROM test;
REVOKE ALL PRIVILEGES ON SCHEMA stat FROM test_view;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA stat FROM test_view;
DROP VIEW public.exams_dates;
DROP VIEW public.list_of_examiners;
DROP USER test;
DROP USER test_view;
DROP USER test_role;

CREATE USER test PASSWORD '123';
GRANT USAGE ON SCHEMA stat TO test;

GRANT SELECT, UPDATE, INSERT ON stat.tickets TO test;
GRANT SELECT (student_id, university_id, university_name, course, marks, achievments), UPDATE (course, marks, achievments) ON stat.students TO test;
GRANT SELECT ON stat.location TO test;

CREATE OR REPLACE VIEW public.list_of_examiners AS
    SELECT surname, name, patronymic
    FROM schedule.examiners;
GRANT SELECT ON list_of_examiners TO test;

CREATE OR REPLACE VIEW public.exams_dates AS
    SELECT faculty, subject_name, date
    FROM schedule.exams
    WHERE faculty = 'Факультет 2'
    WITH LOCAL CHECK OPTION;

CREATE ROLE test_role;
GRANT SELECT, UPDATE (date) ON exams_dates TO test_role;
CREATE USER test_view PASSWORD '111';

GRANT test_role TO test_view;
GRANT USAGE ON SCHEMA schedule to test_view;
GRANT USAGE ON SCHEMA schedule to test;


REVOKE ALL PRIVILEGES ON table FROM user
