– Циклы

--Функция генерации достижений студентов 
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
    IF i = num_of_events THEN
      achievment :=  achievment || levels[ceil(random() * 5)] || type_of_event[ceil(random() * 6)] || '.' ;
    ELSE
      achievment :=  achievment || levels[ceil(random() * 5)] || type_of_event[ceil(random() * 6)] || ',' ;
    END IF;
  END LOOP;
  RETURN achievment;
END;
$$ LANGUAGE plpgsql;

--функция генерации оценок
CREATE OR REPLACE FUNCTION marks_array_gen()
RETURNS integer[] AS $$
DECLARE
  marks_num INT;
BEGIN
  marks_num := ceil(random() * 6);
  RETURN (SELECT array_agg(ceil(random()*10)) FROM generate_series(0, marks_num));
END;
$$ LANGUAGE plpgsql;

--функция генерации информации о билетаъ
CREATE OR REPLACE FUNCTION info_gen()
RETURNS JSONB AS $$
DECLARE
  inf JSONB;
  type_of_ticket TEXT[];
  priv TEXT[];
BEGIN
  type_of_ticket := ARRAY['Входной', 'Абонемент', 'Экскурсионный', 'В рамках учебной программы'];
  priv := ARRAY['Льготный','Обычный', 'Бесплатный', 'Призовой'];
  inf := jsonb_build_object('type', type_of_ticket[ceil(random()*4)], 
                            'privileges', priv[ceil(random()*4)] );
  RETURN inf;
END;
$$ LANGUAGE plpgsql;

--функция, которая считает средний балл у студентов, учащихся в определенном учебном заведении
CREATE OR REPLACE FUNCTION average_uni(university TEXT) RETURNS real AS $$
DECLARE
    st_cur CURSOR FOR SELECT * FROM stat.students;
    flag bool = FALSE;
    marks_sum real = 0;
    marks_num int = 0;
	mark int;
BEGIN
    --в данной реализации курсор открывается и закрывается атвоматически 
    FOR entry in st_cur LOOP
        IF entry.university_name = $1 THEN
            FOREACH mark IN ARRAY entry.marks 
			LOOP
                marks_sum = marks_sum + mark;
                marks_num = marks_num + 1;
            END LOOP;
            flag = TRUE;
        END IF;
    END LOOP;
    IF NOT flag THEN
        RAISE EXCEPTION 'Такого учебного заведения нет в базе данных.';
    END IF;
    RETURN marks_sum/marks_num;
END;
$$ LANGUAGE plpgsql;


-- В данной функции еще можно было бы сделать объявление с курсором,
-- который принимает на вход параметр, но тогда без exeption
st_cur CURSOR(s text) FOR SELECT * FROM stat.students WHERE students.university_name = st_cur.s;




Обосновать преимущества механизма функций перед механизмом представлений:
