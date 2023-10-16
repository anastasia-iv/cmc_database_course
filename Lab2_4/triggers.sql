Необходимо составить скрипт для создания триггера, а также подготовить несколько
запросов для проверки и демонстрации его полезных свойств:
• Изменение данных для сохранения целостности.
• Проверка транзакций и их откат в случае нарушения целостности.


/* Существуют следующие типы билетов: CREATE TYPE ticket_types AS ENUM ('льготный_входной', 'льготный_экскурсионный', 'льготный_абонемент', 'входной', 'экскурсионный', 'абонемент'); */
/*Триггер, который при изменении цены на билет не лаёт сделать её отрицательной и не даёт изменить тип билета на не льготный, если  он был льготным до этого*/

DROP FUNCTION IF EXISTS tickets_trigger() CASCADE;
CREATE FUNCTION tickets_trigger() RETURNS trigger AS $tickets_trigger$
    BEGIN
        IF TG_OP = 'INSERT' THEN
            IF NEW.location_id IS NULL THEN 
                RAISE EXCEPTION 'Please add all information for ticket %. Location_id can`t be null.', NEW.ticket_id;
            END IF;
            IF NEW.ticket_type IS NULL THEN 
                RAISE EXCEPTION 'Please add all information for ticket %. Ticket_type can`t be null.', NEW.ticket_id;
            END IF;
            IF NEW.ticket_cost_dollars < 0 THEN
                RAISE EXCEPTION 'The ticket cannot have a negative value!';
            END IF;
        ELSIF TG_OP = 'UPDATE' THEN
    			IF ((OLD.ticket_type :: varchar LIKE 'льготный_%') AND (NEW.ticket_type :: varchar NOT LIKE 'льготный_%')) THEN
                    RAISE EXCEPTION 'The student has preferential rights, the ticket type must remain preferential.';
          END IF;
          IF (NEW.ticket_cost_dollars < 0) THEN
                    RAISE EXCEPTION 'The ticket cannot have a negative value!';
          END IF;
    		END IF;
        RETURN NEW;
    END;
$tickets_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER tickets_trigger BEFORE INSERT OR UPDATE on art.tickets
    FOR EACH ROW EXECUTE FUNCTION tickets_trigger();

--CHECK

INSERT INTO art.tickets (location_id, ticket_type, ticket_cost_dollars) 
VALUES (9, 'входной', -1);
ERROR:  The ticket cannot have a negative value!

INSERT INTO art.tickets (location_id, ticket_type, ticket_cost_dollars) 
VALUES (9, 'льготный_входной', 5);

SELECT * FROM art.tickets;

40	1	"льготный_входной"	5

UPDATE art.tickets SET ticket_type = 'входной' WHERE ticket_id = 32;
ERROR:  The student has preferential rights, the ticket type must remain preferential./

40	9	"льготный_входной"	5
  
