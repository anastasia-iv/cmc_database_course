--testing role "test"
SET ROLE test;

SELECT * FROM stat.tickets LIMIT 5;
UPDATE stat.tickets SET price_dollars = 5 WHERE ticket_id = 1;
INSERT INTO stat.tickets (student_id,price_dollars, info, location_id, date_of_purchase)
SELECT 1, 5, jsonb_build_object('type', 'Входной', 'privileges', 'Обычный'), 1, timestamp '2023-10-29 8:00:00';

UPDATE stat.students SET course = 3 WHERE course = 2;

SELECT * FROM stat.location LIMIT 5;

UPDATE location_list SET location_name = 'Пушкинский музей' WHERE location_id = 1;
SELECT * FROM location_list LIMIT 5;
!!!!ERROR:  permission denied for view location_list -> нет разрешений на изменение 

--testing role role_new

SET ROLE new_user;
SELECT * FROM students_msu LIMIT 5;
UPDATE students_msu SET marks= array[5, 5, 5] WHERE student_id = 2;
SELECT * FROM students_msu  ORDER BY student_id LIMIT 5;

 
