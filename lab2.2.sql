DROP SCHEMA IF EXISTS schedule CASCADE;
CREATE SCHEMA art;
CREATE TYPE comp_types AS ENUM ('живопись', 'графика', 'скульптура', 'литье', 'роспись', 'архитектура', 'витраж', 'литература', 'кинематограф');
CREATE TYPE loc_types AS ENUM ('галерея', 'кинотеатр', 'музей', 'консерватория', 'собор', 'церковь', 'кирха');
CREATE TYPE directions AS ENUM ('готика', 'возрождение', 'маньеризм', 'барокко', 'классицизм', 'романтизм', 'сентиментализм', 'реализм', 'символизм', 'импрессионизм', 'пуантилизм', 'постимпрессионизм', 'модерн', 'авангард', 'сезаннизм','фовизм', 'примитивизм', 'кубизм', 'сюрреализм', 'футуризм');
CREATE TYPE ticket_types AS ENUM ('льготный_входной', 'льготный_экскурсионный', 'входной', 'экскурсионный', 'льготный_абонемент', 'абонемент');

CREATE TABLE art.Countries (
  	country_id SERIAL PRIMARY KEY,
  	country_name varchar(30) NOT NULL
);
CREATE TABLE art.Cities (
  	city_id SERIAL PRIMARY KEY,
  	city_name	varchar(50) NOT NULL,
  	country_id integer CONSTRAINT city_country REFERENCES art.Countries ON UPDATE CASCADE 
);

CREATE TABLE art.Creators (
  	cr_id	SERIAL PRIMARY KEY,
  	cr_name	varchar(60),
  	birth_date date,
  	death_date date,
  	country_id integer CONSTRAINT cr_country REFERENCES art.Countries ON UPDATE CASCADE
);

CREATE TABLE art.Direction (
  	direction_id SERIAL PRIMARY KEY,
  	direction_name directions NOT NULL,
  	age_of_first_mention integer CONSTRAINT year_check CHECK (age_of_first_mention <= 21),
  	country_id integer CONSTRAINT d_country REFERENCES art.Countries ON UPDATE CASCADE
);

CREATE TABLE art.Books (
  	book_id	SERIAL PRIMARY KEY,
  	book_name	varchar(60) NOT NULL,
  	book_author	varchar(60) NOT NULL
);

CREATE TABLE art.Book_to_direction (
  	book_id integer CONSTRAINT btd_book REFERENCES art.Books ON DELETE CASCADE,
  	direction_id integer CONSTRAINT btd_dir REFERENCES art.Direction ON DELETE CASCADE,
  	UNIQUE (book_id, direction_id)
);

CREATE TABLE art.Library (
  	library_id SERIAL PRIMARY KEY,
  	library_name text NOT NULL,
    city_id	integer CONSTRAINT l_city REFERENCES art.Cities ON UPDATE CASCADE,
  	address text NOT NULL UNIQUE
);

CREATE TABLE art.Books_in_libraries (
    library_id integer CONSTRAINT bil_lib REFERENCES art.Library ON DELETE CASCADE,
  	book_id	integer CONSTRAINT bil_book REFERENCES art.Books ON DELETE CASCADE,
  	amount integer CONSTRAINT positive_amount CHECK (amount > 0),
  	UNIQUE(library_id, book_id)
);


CREATE TABLE art.Location (
  	location_id SERIAL PRIMARY KEY,
  	loc_type loc_types NOT NULL, 
  	loc_name	text NOT NULL,
  	adm_phone	varchar(13) UNIQUE,
	loc_address text NOT NULL
);

CREATE TABLE art.Tickets (
  	ticket_id SERIAL PRIMARY KEY,
  	location_id integer CONSTRAINT t_loc REFERENCES art.Location ON DELETE CASCADE,
  	ticket_type	ticket_types NOT NULL,
  	ticket_cost_dollars	numeric CONSTRAINT positive_price CHECK (ticket_cost_dollars >= 0)
);

CREATE TABLE art.Students (
  	student_id SERIAL PRIMARY KEY,
  	student_name varchar(60) NOT NULL,
  	university text NOT NULL,
  	course integer CONSTRAINT course_check CHECK (course >= 0 AND course <= 11),
  	average_score numeric(6, 2) CONSTRAINT positive_average CHECK (average_score > 0 AND average_score < 10)
);

CREATE TABLE art.Students_tickets (
  	student_id integer CONSTRAINT st_student REFERENCES art.Students ON DELETE CASCADE,
  	ticket_id	integer CONSTRAINT st_ticket REFERENCES art.Tickets ON DELETE CASCADE,
  	PRIMARY KEY (student_id, ticket_id)
);

CREATE TABLE art.Compositions (
    comp_id SERIAL PRIMARY KEY,
    comp_name text NOT NULL,
    comp_type comp_types NOT NULL,
    dimension text,
    dimension_units varchar(15),
    location_id integer CONSTRAINT c_loc REFERENCES art.Location ON UPDATE CASCADE,
    cr_id integer CONSTRAINT c_cr REFERENCES art.Creators ON UPDATE CASCADE,
    direction_id integer CONSTRAINT c_dir REFERENCES art.Direction ON UPDATE CASCADE	
);

INSERT INTO art.Countries (country_name) VALUES
  ('Россия'),
  ('Китай'),
  ('Нидерланды'),
  ('Белорусия'),
  ('Великобритания'),
  ('Италия'),
  ('Дания'),
  ('Польша'),
  ('Норвегия'),
  ('Франция'),
  ('Германия'),
  ('Австрия');

INSERT INTO art.Cities (city_name, country_id) VALUES
  ('Москва', 1),
  ('Санкт-Петербург', 1),
  ('Краснодар', 1),
  ('Ростов-на-Дону', 1),
  ('Воронеж', 1),
  ('Рязань', 1),
  ('Хабаровск', 1),
  ('Екатеринбург', 1),
  ('Новосибирск', 1),
  ('Пекин', 2),
  ('Нурсултан', 3),
  ('Минск', 4),
  ('Лондон', 5),
  ('Рим', 6),
  ('Копенгаген', 7),
  ('Варшава', 8),
  ('Осло', 9),
  ('Париж', 10),
  ('Флоренция', 6),
  ('Лейпциг', 11),
  ('Берлин', 11),
  ('Вена', 12),
  ('Калининград', 1);

INSERT INTO art.Creators (cr_name, birth_date, death_date, country_id) VALUES
  ('Матвей Казаков', '20/10/1738', '07/11/1812', 1),
  ('Фридриха Шмидт', '22/10/1825', '23/01/1891', 12),
  ('Федор Соколов', '20/10/1752', '07/11/1824', 1),
  ('Каспара-Давида Фридрих', '20/10/1774', '07/11/1840', 11),
  ('Клода Моне', '20/10/1840', '07/11/1926', 10),
  ('Жоржа Брака ', '20/10/1738', '07/11/1812', 10),
  ('Яна ван Эйка', '20/10/1390', '09/07/1441', 3),
  ('Эдуард Мане', '22/01/1832', '30/04/1883', 10),
  ('Винсент ван Гог', '30/03/1853', '29/07/1890', 10),
  ('Леонардо да Винчи', '15/04/1452', '02/05/1519', 6),
  ('Микеланджело Буонарроти', '06/03/1475', '18/02/1564', 6),
  ('Мазаччо', '21/12/1401', '07/11/1428', 6),
  ('Филиппо Брунеллески', '20/10/1377', '15/04/1446', 6),
  ('Франческо Бартоломео Растрелли', '20/10/1700', '29/04/1771', 10);
  
INSERT INTO art.Direction (direction_name, age_of_first_mention, country_id) VALUES
  ('готика', 8, 10),   
  ('возрождение', 15, 6),
  ('маньеризм', 16, 6),
  ('барокко', 17, 6),
  ('классицизм', 17, 10),
  ('романтизм', 18, 11),
  ('сентиментализм', 18, 5),
  ('реализм', 18, 10),
  ('символизм', 19, 10),
  ('импрессионизм', 19, 10),
  ('постимпрессионизм', 19, 10),
  ('модерн', 20, 10),
  ('авангард', 20, 11),
  ('сезаннизм', 19, 10),
  ('фовизм', 20, 10),
  ('примитивизм', 19, 10),
  ('кубизм', 20, 10),
  ('сюрреализм', 20, 10),
  ('футуризм', 20, 6);

INSERT INTO art.Books (book_name, book_author) VALUES
  ('Очерки по искусству средневековья Франции','Ференци Б.К.'),
  ('Gothic Architecture', 'Batty & Thomas Langley'),
  ('Жизнеописания наиболее знаменитых живописцев', 'Джорджо Вазари'),
  ('Ренессанс и барокко', 'Генрих Вёльфлин'),
  ('Росписи русского классицизма.', 'Белявская В.Ф.'),
  ('Классицизм и романтизм.', 'Рольф Томан.'),
  ('Импрессионизм', 'Вальтер. И'),
  ('Модерн. Лучшие произведения', 'Розалинда Ормистон'),
  ('Искусство модерна', 'Я. Пундик'),
  ('История стилей изобразительных искусств', 'Кон-Винер');

INSERT INTO art.Book_to_direction (book_id, direction_id) VALUES
  (1, 1),
  (2, 1),
  (3, 2),
  (4, 2),
  (4, 4),
  (5, 4),
  (5, 5),
  (6, 5),
  (6, 6),
  (7, 10),
  (8, 12),
  (9, 12),
  (10, 1),
  (10, 2),
  (10, 3),
  (10, 4),
  (10, 5),
  (10, 6),
  (10, 7),
  (10, 8),
  (10, 9),
  (10, 10),
  (10, 11),
  (10, 12),
  (10, 13),
  (10, 14),
  (10, 15),
  (10, 16);

INSERT INTO art.Library (library_name, city_id, address) VALUES
  ('Российская государственная библиотека', 1, 'ул. Воздвиженка, 3/5'),
  ('Библиотека-читальня им. И.С. Тургенева', 1, 'Бобров пер., 6'),
  ('Библиотека иностранной литературы, 1', 1, 'Николоямская ул., 1'),
  ('Библиотека № 19 им. Ф. М. Достоевского', 1, '23 стр.1'),
  ('Библиотека Российской академии наук', 2, 'Биржевая линия, 1/1'),
  ('Центральная городская публичная библиотека', 2, 'наб. р. Фонтанки, д. 46'),
  ('Российская национальная библиотека', 2, 'площадь Островского, 1-3'),
  ('Национальная центральная библиотека', 14, 'Кастро-Преторио'),
  ('Centro Studi Americani', 14, 'улица Каэтани Микеланджело'),
  ('Ватиканская апостольская библиотека', 14, 'Ватикан'),
  ('Национальная центральная библиотека', 19, 'Тоскана'),
  ('Bibliothèque De Lhotel De Ville', 18, 'ул. де Лобо, 5'),
  ('Национальная библиотека Франции', 18, 'набережная Франсуа Морьяк'),
  ('Немецкая национальная библиотека', 19, 	'Adickesallee 1'),
  ('Берлинская государственная библиотека', 21, 'Униферзитетсштрассе, 7'),
  ('Свердловская универсальная научная библиотека', 8, 'ул. Белинского, 15'),
  ('Центральная городская библиотека им. А. И. Герцена', 8, 'ул. Чапаева, д. 5');

INSERT INTO art.Books_in_libraries (library_id, book_id, amount) VALUES
  (1, 2, 4),
  (1, 5, 2),
  (1, 8, 1),
  (2, 1, 3),
  (2, 5, 2),
  (3, 4, 1),
  (3, 10, 1),
  (4, 6, 2),
  (5, 7, 3),
  (6, 3, 5),
  (7, 9, 6),
  (8, 1, 4),
  (9, 4, 2),
  (9, 8, 1),
  (10, 1, 3),
  (11, 2, 5),
  (12, 3, 8),
  (13, 7, 7),
  (14, 5, 3),
  (15, 8, 2),
  (16, 9, 3),
  (17, 10, 2);

INSERT INTO art.Location (loc_type, loc_name, adm_phone, loc_address) VALUES
('музей', 'Рогожская слобода', '89167856342', 'ул. Рогожский Посёлок, 3'),
('музей', 'Венская ратуша', '4317121229', 'Ратхаусплац, 1'), 
('церковь', 'Церковь Всех Святых во Всехсвятском на Соколе', '82338273493', 'Ленинградский просп., 73А'),
('собор', 'Кафедральный собор', '891678342', 'ул. Канта, 1, Калининград'),
('кирха', 'Юдиттен-кирха', '8916444573', 'ул. Тенистая Аллея, 39Б, Калининград'),
('кирха', 'Тарау-кирха', '892044563', 'Калининградская область, посёлок Владимирово'),
('кирха', 'Цинтена-кирха', '89126545423', 'Калининградская обл., Корнево'),
('музей', 'Гамбургский Кунстхалле', '123525', 'Берн, Marienstrasse'),
('музей', 'Мармоттан-Моне', '2324', 'ул. Луи Буайи, 2, XVI округ Парижа'),
('музей', 'Метрополии Лилля', '4568356', 'Ратхаусплац, 1'),
('галерея', 'Берлинской живописи', '223415327', 'Ратхаусплац, 1'),
('музей', 'Орсе', '54688', 'ул. де Лилль, 62, VII округ Парижа'),
('музей', 'Эрмитаж', '43171229', 'Дворцовая наб., 38, Санкт-Петербург'),
('церковь', ' Санта-Мария дель Кармине', '1234523', 'Флоренция'),
('музей', 'Памятник Давиду', '4317125629', 'Тоскана, Флоренция'),
('музей', 'Зимний дворец', '89234567721', 'Дворцовая наб., 38, Санкт-Петербург'),
('музей', 'Смольный Новодевичий женский монастырь', '8924566821', 'ул. Смольного, 1/3, Санкт-Петербург');
  
INSERT INTO art.Tickets (location_id, ticket_type, ticket_cost_dollars) VALUES
  (1 , 'льготный_входной', 4),
  (2 , 'экскурсионный', 22.33),
  (3 , 'входной', 15),
  (4 , 'льготный_входной', 5.19),
  (4 , 'льготный_абонемент', 24.71),
  (5 , 'экскурсионный', 20.41),
  (6 , 'льготный_входной', 8.14),
  (6 , 'абонемент', 29.60),
  (8 , 'экскурсионный', 18.08),
  (7 , 'льготный_абонемент', 20.74),
  (9 , 'льготный_входной', 5.39),
  (10 , 'льготный_абонемент', 27.87),
  (11 , 'входной', 16.98),
  (12 , 'абонемент', 30.83),
  (13 , 'экскурсионный', 21.87),
  (11 , 'льготный_входной', 7.45),
  (5 , 'экскурсионный', 25.04),
  (12 , 'льготный_входной', 16.26),
  (6 , 'экскурсионный', 23.91),
  (10 , 'льготный_входной', 10.35),
  (14 , 'абонемент', 40.38); 
INSERT INTO art.Students (student_name, university, course, average_score) VALUES
  ('Герасимов Глеб Антонович', 'РГУ им. А.Н. Косыгина', 1, 4.50),
  ('Родина Валерия Андреевна', 'РУДН', 3, 4.86),
  ('Миронов Иван Александрович', 'РУДН', 4, 4.44),
  ('Баженов Иван Николаевич', 'РУДН', 5, 3.77),
  ('Ларионов Степан Тимофеевич', 'СПбГУ', 2, 5.00),
  ('Леонова Кира Павловна', 'СПбГУ', 1, 4.67),
  ('Ковалев Семён Александрович', 'СПбГУ', 1, 4.70),
  ('Ульянов Артемий Артурович', 'СПбРси', 1, 4.33),
  ('Белоусова Милана Матвеевна', 'Университет Феррары', 1, 4.25),
  ('Михайлов Андрей Петрович', 'Университет Мачераты', 6, 4.88),
  ('Наумов Демид Дмитриевич', 'Университет Болоньи', 5, 4.12),
  ('Гусев Пётр Николаевич', 'Sorbonne Université', 3, 2.77),
  ('Руднев Никита Георгиевич', 'Paris College of Art', 2, 3.26),
  ('Высоцкий Марк Арсентьевич', 'Berlin School Of Business & Innovation', 2, 4.00),
  ('Голубева Анастасия Артёмовна', 'Fresenius University of Applied Sciences', 2, 4.17),
  ('Лебедев Павел Ярославович', 'Paris College of Art', 3, 3.89),
  ('Соболев Владимир Арсентьевич', 'Университет Болоньи', 1, 4.58),
  ('Леонтьев Матвей Артёмович', 'Oxford', 4, 4.75),
  ('Суханова Вера Ивановна', 'University of London', 1, 4.96),
  ('Афанасьева Ева Никитична', 'University of York', 2, 5.00);

INSERT INTO art.Students_tickets (student_id, ticket_id) VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (1, 4),
  (1, 5),
  (1, 6),
  (1, 7),
  (1, 8),
  (1, 9),
  (1, 10),
  (1, 11),
  (1, 12),
  (1, 13),
  (1, 14),
  (1, 15),
  (1, 16),
  (1, 17),
  (1, 18),
  (1, 19),
  (1, 20);

INSERT INTO art.Compositions (comp_name, comp_type, dimension, dimension_units, location_id, cr_id, direction_id) VALUES
  ('Покровский собор', 'архитектура', '4.75' , 'м', 1, 1, 2),
  ('Витраж в форме цветка с 5-ю лепестками', 'витраж', '1.5 x 1' , 'м', 2, 2, 2),
  ('Успенская соборная часовня', 'архитектура', '5.70' , 'м', 3, 3, 2),
  ('Кафедральный собор', 'архитектура', '6.91' , 'м', 4, NULL, 1),
  ('Кирха Юдиттен', 'архитектура', '3.75' , 'м', 5, NULL, 1),
  ('Кирха Тарау', 'архитектура', '4.12' , 'м', 6, NULL, 1),
  ('Кирха Цинтена', 'архитектура', '3.60' , 'м', 7, NULL, 1),
  ('Мадонна с цветком', 'живопись', '48 × 31,5' , 'см', 13, 10, 2),
  ('Мадонна с младенцем', 'живопись', '25 x 20' , 'см', 13, 10, 2),
  ('Скорчившийся мальчик', 'живопись', '21 x 30' , 'см', 13, 11, 2),
  ('Изгнание из рая', 'роспись', '2 x 3' , 'м', 14, 12, 2),
  ('Давид', 'скульптура', '517 х 199' , 'см', 15, 13, 2),
  ('Зимний дворец', 'архитектура', '22' , 'м', 16, 14, 4),
  ('Воскресенский Новодевичий Смольный монастырь', 'архитектура', '6' , 'м', 17, 14, 4),
  ('Звёздная Ночь над Роной', 'живопись', ' 72,5 х 92' , 'см', 12, 9, 8),
  ('Завтрак на Траве', 'живопись', '208 х 264,5' , 'см', 12, 8, 8),
  ('Мадонна в Церкви', 'живопись', '31 х 14' , 'см', 11, 7, 2),
  ('Дома в Эстаке', 'живопись', '40,5 х 32,5' , 'см', 10, 6, 17),
  ('Впечатление. Восходящее Солнце', 'живопись', '48 х 63' , 'см', 9, 5, 15),
  ('Странник над Морем Тумана', 'архитектура', '94,8 х 74,8' , 'см', 8, 4, 6);




