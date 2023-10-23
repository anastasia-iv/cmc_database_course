DROP SCHEMA IF EXISTS stat CASCADE;
CREATE SCHEMA stat;

CREATE TABLE stat.location (
  	location_id SERIAL PRIMARY KEY,
    location_name text,
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
  marks_num INT;
BEGIN
  marks_num := ceil(random() * 6);
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

DO $$
BEGIN
  FOR I IN 1..18 LOOP
  INSERT INTO stat.location (location_name, years_of_existance, num_exhibitions, raiting)
  SELECT 
    ('{Рогожская слобода, Венская ратуша, Церковь Всех Святых во Всехсвятском на Соколе, Кафедральный собор, Федорова, Юдиттен-кирха, Тарау-кирха, Цинтена-кирха, Гамбургский Кунстхалле, Мармоттан-Моне, музей Метрополии Лилля, музей Берлинской живописи, Орсе, Эрмитаж, Санта-Мария дель Кармине, Памятник Давиду, Зимний дворец, Смольный Новодевичий женский монастырь}'::text[])[I],
    (random() * 50)::integer,
    (random() * 6)::integer,
    (random() * 100)::real;
  END LOOP;
END;
$$


CREATE OR REPLACE FUNCTION info_gen()
RETURNS JSONB AS $$
DECLARE
  inf JSONB;
  type_of_ticket TEXT[];
  priv TEXT[];
BEGIN
  type_of_ticket := ARRAY['"Входной"', '"Абонемент"', '"Экскурсионный"', '"В рамках учебной программы"'];
  priv := ARRAY['"Льготный"','"Обычный"', '"Бесплатный"', '"Призовой"'];
  inf := '{"type":' || type_of_ticket[ceil(random()*4)] || ', "privileges": ' || priv[ceil(random()*4)] || '}';
  RETURN inf;
END;
$$ LANGUAGE plpgsql;

INSERT INTO stat.tickets (student_id, price_dollars, info, location_id, date_of_purchase)
SELECT 
  ceil(random() * 1000000)::integer,
  round (CAST(random()*100 + 3 AS numeric),2),
  info_gen(),
  ceil(random() * 18)::integer,
  timestamp '2014-01-10 20:00:00' + random() * (timestamp '2014-01-20 20:00:00' - current_date)
FROM generate_series(1, 100000000); 

