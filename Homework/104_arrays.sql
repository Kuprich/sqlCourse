-- Создать функцию, которая вычисляет средний фрахт по заданным странам (функция принимает список стран).

CREATE FUNCTION get_avg_freight(VARIADIC countries text[], OUT avg_freight real) AS $$ 
SELECT AVG(freight)
FROM orders
WHERE ship_country = ANY (countries);
$$ LANGUAGE SQl;

SELECT * FROM get_avg_freight('USA', 'Brazil');