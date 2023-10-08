1)Средняя стоимость билета в классе
SELECT fare_conditions, count(*), avg(amount) AS average
	FROM ticket_flights 
	GROUP BY fare_conditions
	ORDER BY average
2)Сколько женщин и какими классами успешно вылетели из домодедово 
SELECT COUNT(*), t_f.fare_conditions
FROM ticket_flights AS t_f
	 JOIN flights f USING (flight_id)
	 JOIN airports ai ON f.departure_airport = ai.airport_code 
	 JOIN tickets t USING (ticket_no)
	 WHERE ai.city = 'Москва' AND f.departure_airport = 'DME' AND f.status = 'Arrived' AND t.passenger_name LIKE '%A'
	 GROUP BY fare_conditions
3)Средняя цена билета из Екатеринбурга по разным классам, округленная до 2 знаков после запятой к нулю 
SELECT TRUNC(AVG(amount), 2), fare_conditions
FROM ticket_flights
	 JOIN flights USING (flight_id)
	 JOIN airports ON arrival_airport = airport_code
	 WHERE amount IS NOT NULL AND city = 'Екатеринбург'
	 GROUP BY fare_conditions
4)Модель самолёта с самым большим доходом
 SELECT s1.model 
FROM (
	SELECT SUM(t_f2.amount) AS "sum", f.aircraft_code AS model
	FROM ticket_flights AS t_f2
		JOIN flights AS f USING (flight_id)
		GROUP BY model
	) AS s1
		WHERE s1.sum = 
			(SELECT MAX ("sum")
			FROM (
			SELECT SUM(t_f2.amount) AS "sum", f.aircraft_code AS model
			FROM ticket_flights AS t_f2
				JOIN flights AS f USING (flight_id)
				GROUP BY model
			) AS s)
5)Вывести 100 людей из списка пассажиров, которые пользовались услугами самолёта с с самым большим доходом
SELECT t.passenger_name as Passenger
FROM tickets AS t 
	JOIN ticket_flights t_f1 USING (ticket_no)
	JOIN flights f1 USING (flight_id)
	WHERE f1.aircraft_code = (
		SELECT s2.model 
		FROM (
			SELECT SUM(t_f2.amount) AS "sum", f2.aircraft_code AS model
			FROM ticket_flights AS t_f2
				JOIN flights AS f2 USING (flight_id)
				GROUP BY model
			) AS s2
				WHERE s2.sum = (
					SELECT MAX ("sum")
					FROM (
					SELECT SUM(t_f3.amount) AS "sum", f3.aircraft_code AS model
					FROM ticket_flights AS t_f3
						JOIN flights AS f3 USING (flight_id)
						GROUP BY model
					) AS s3
				) 
	)
	LIMIT 100
 

