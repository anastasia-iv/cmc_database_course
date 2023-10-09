--1)
--Информация по студентами-искусствоведами со средним баллом > 4.00 
--с целью возвращения полной стоимости билета организацией.

WITH refund_of_the_cost AS (
	SELECT student_id, student_name, university, average_score, ticket_id, ticket_cost_dollars
	FROM  art.students_tickets AS st
	JOIN art.students s USING(student_id)
	JOIN art.tickets t USING(ticket_id)
	WHERE s.average_score > 4
)
SELECT student_id AS "id",
student_name AS "Имя студента",
university AS "Университет", 
average_score AS "Средний балл",
SUM(ticket_cost_dollars) AS "Суммарная стоимость"
FROM refund_of_the_cost
	GROUP BY student_id, student_name, university, average_score
	ORDER BY student_name


--В каких направлениях работал каждый художник, родившийся до 1900 года

WITH creators_main_dir AS (
	SELECT cr_id, cr_name, direction_name
	FROM art.creators AS cr
	JOIN art.compositions USING(cr_id)
	JOIN art.direction USING(direction_id)
	WHERE cr.birth_date < '01/01/2018'
)
SELECT cr_name AS "Имя создателя",
direction_name AS "Направление",
COUNT(*) AS "Количество картин"
FROM creators_main_dir
	GROUP BY cr_id, cr_name, direction_name
	
--Сколько книг по каждому направлению содержатся в библиотеках России

WITH books_in_libs AS(
	SELECT library_id, library_name, book_id, direction_id, direction_name
	FROM art.library AS lib
	JOIN art.cities USING(city_id)
	JOIN art.books_in_libraries USING(library_id)
	JOIN art.book_to_direction USING(book_id)
	JOIN art.direction USING(direction_id)
	JOIN art.countries ON countries.country_id = cities.country_id
	WHERE  countries.country_name = 'Россия'
)
SELECT library_id AS "id",
library_name AS "Библиотека",
direction_name AS "Направление",
COUNT(*) AS "Книг по данному направлению:"
FROM books_in_libs
GROUP BY library_id, library_name, direction_id,direction_name
ORDER BY "id";

--2)

--В библиотеке с индексом 9 забрали 2 книги с индексом 4

UPDATE art.Books_in_libraries
SET amount = amount - 2
WHERE library_id = 9 AND book_id = 4;

/*
ERROR:  new row for relation "books_in_libraries" violates check constraint "positive_amount"
Подробности: Failing row contains (9, 4, 0).
*/

SELECT * FROM art.Books_in_libraries



--Вчесть всемирного дня искусства цену входных билетов понизили на 4 доллара
UPDATE art.Tickets
SET ticket_cost_dollars = ticket_cost_dollars - 4.5
WHERE ticket_type = 'входной' OR ticket_type = 'льготный_входной';

/*
ERROR:  new row for relation "tickets" violates check constraint "positive_price"
SQL-состояние: 23514
Подробности: Failing row contains (1, 1, льготный_входной, -0.5).
*/

--Студент-искусствовед отчислился или перевелся на ПМИ
DELETE FROM art.students
WHERE student_id = 6;

SELECT * FROM art.students

--Задаётся ticket: comp_id = 1, ticket_type = "входной", ticket_cost = 5
--Добавляем его в таблицу tickets
--В таблице students_tickets отображаем покупку этого билета студентом student_id = 2

WITH loc_for_comp AS (
	SELECT location_id FROM art.compositions
	WHERE comp_id = 1
),
new_ticket_id AS (
	INSERT INTO art.tickets (ticket_id, location_id, ticket_type, ticket_cost_dollars)
 	VALUES (DEFAULT, (SELECT location_id FROM art.compositions
	WHERE comp_id = 1), 'входной', 5)
	RETURNING ticket_id
)
	
INSERT INTO art.students_tickets VALUES (2, (SELECT * FROM new_ticket_id))
