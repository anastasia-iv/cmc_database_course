DROP SCHEMA IF EXISTS stat CASCADE;
CREATE SCHEMA stat;

CREATE TABLE stat.location (
  	location_id SERIAL PRIMARY KEY,
    location_name text[],
    years_of_existance integer,
    num_exhibitions integer,
    raiting real
);

CREATE TABLE stat.students (
  	student_id SERIAL PRIMARY KEY,
  	student_name varchar(50) NOT NULL,
  	student_surname	varchar(50) NOT NULL,
    student_patronymic varchar(50) NOT NULL,
    university_name varchar(50),
    city varchar(50),
    course integer,
    marks integer[],
    achievments text
);

CREATE TABLE stat.tickets (
  	ticket_id	SERIAL PRIMARY KEY,
    student_id integer REFERENCES stat.students ON DELETE CASCADE,
  	price_dollars numeric(8, 2),
  	info jsonb,
  	location_id integer REFERENCES stat.location ON DELETE CASCADE,
    date_of_purchase timestamp
);

CREATE OR REPLACE FUNCTION marks_array_gen()
RETURNS integer[] AS $$
DECLARE
  marks_array integer[] := '{}';
  marks_num INT;
BEGIN
  marks_num := ceil(random() * 6);

  -- FOR i IN 1..marks_num LOOP
  --   marks_array := marks_array || (ceil(random()*10);
  -- END LOOP;

  RETURN (SELECT array_agg(ceil(random()*10)) FROM generate_series(0, marks_num));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION achievments_gen()
RETURNS TEXT AS $$
DECLARE
  levels TEXT[];
  type_of_event TEXT[];
  num_of_events INT;
  achievment TEXT:='';
BEGIN
  levels := ARRAY['Всемирн', 'Национальн', 'Муниципаль', 'Учебн', 'Профессиональн'];
  type_of_event := ARRAY['ая олипмиада', 'ый хакатон', 'ая конференция', 'ый вебинар', 'ое соревнование', 'ый митап'];
  num_of_events := ceil(random()*4);

  FOR i IN 1..num_of_events LOOP
    achievment :=  achievment || levels[ceil(random() * 5)] || type_of_event[ceil(random() * 6)] || ',' ;
  END LOOP;
    
  RETURN achievment;
END;
$$ LANGUAGE plpgsql;

INSERT INTO stat.students (student_name, student_surname, student_patronymic, 
  university_name, city, course, marks, achievments)
SELECT 
  ('{Беспалов, Минина, Кузнецов, Котов, Федорова, Волкова, Анисимова, Артемова, Пантелеев, Панов, Степанова, Морозов, Борисова, Федосеева, Балашов, Антонова, Булатов, Зиновьев, Петров, Дмитриев}'::text[])[ceil(random()*20)],
  ('{Вячеслав, Давид, Кира, Александр, Вероника, София, Арина, Дарья, Роман, Платон, Амелия, Мария, Олег, Лев, Майя, Марк, Макар, Агата, Екатерина, Юрий}'::text[])[ceil(random()*20)],
  ('{Романович, Давидович, Владиславовна, Матвеевна, Викторовна, Платоновна, Матвеевич, Николаевич, Захарович, Русланович, Никитович, Феликсович, Мироновна, Евгеньевна, Святославович, Платонович, Николаевна, Федоровна, Андреевна, Тимофеевна}'::text[])[ceil(random()*20)],
  ('{РУДН, СПбГУ, МГУ, МГИМО, МАРХИ, Paris College of Art, Sorbonne Université, Университет Мачераты, СПбРси, Университет Феррары, Университет Болоньи, University of York, Berlin School Of Business&Innovation, Oxford, University of London}'::text[])[ceil(random()*15)],
  ('{Москва, Санкт-Петербург, Краснодар, Ростов-на-Дону, Воронеж, Рязань, Хабаровск, Екатеринбург, Новосибирск, Пекин, Нурсултан, Минск, Лондон, Рим, Копенгаген, Варшава, Осло, Париж, Флоренция, Лейпциг, Берлин, Вена, Калининград}'::text[])[ceil(random()*23)],
  (random() * 6)::integer, 
  marks_array_gen(),
  achievments_gen()
FROM generate_series(1, 1000000);

