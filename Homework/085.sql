-- 1. Создайте функцию, которая делает бэкап таблицы customers (копирует все данные в другую таблицу), предварительно стирая таблицу для бэкапа, 
-- если такая уже существует (чтобы в случае многократного запуска таблица для бэкапа перезатиралась).

CREATE FUNCTION save_customers_table() 
RETURNS void AS $$
	DROP TABLE IF EXISTS customers_bak;
	
	CREATE TABLE customers_bak AS 
	SELECT * fROM customers;
	-- INTO customers_bak
	-- FROM customers;
$$ LANGUAGE SQL;

SELECT * FROM save_customers_table();

-- 2. Создать функцию, которая возвращает средний фрахт (freight) по всем заказам

CREATE FUNCTION get_freight_avg(out freight_avg real) AS $$
	SELECT AVG(freight)
	FROM orders;
$$ LANGUAGE SQL;

SELECT * FROM get_freight_avg();

-- 3. Написать функцию, которая принимает два целочисленных параметра, используемых как нижняя и верхняя границы для генерации случайного числа 
-- в пределах этой границы (включая сами граничные значения).
-- Функция random генерирует вещественное число от 0 до 1.
-- Необходимо вычислить разницу между границами и прибавить единицу.
-- На полученное число умножить результат функции random() и прибавить к результату значение нижней границы.
-- Применить функцию floor() к конечному результату, чтобы не "уехать" за границу и получить целое число.

CREATE FUNCTION get_random(a int, b int) RETURNS real AS $$
	SELECT floor(a + (b - a) * random());
$$ LANGUAGE SQL;

SELECT get_random(-10, 10);

-- 4. Создать функцию, которая возвращает самые низкую и высокую зарплаты среди сотрудников заданного города

ALTER TABLE employees
ADD COLUMN salary decimal(2, 2);
UPDATE employees
SET salary = ROUND((30 + 70 * RANDOM())::decimal, 2);

CREATE FUNCTION get_min_max_salary_by_city(p_city varchar, out min_value decimal, out max_value decimal) AS $$
	SELECT MIN(salary), MAX(salary)
	FROM employees
	WHERE city = p_city;
$$ LANGUAGE SQL;

SELECT * FROM get_min_max_salary_by_city('London');

-- 5. Создать функцию, которая корректирует зарплату на заданный процент, но не корректирует зарплату, 
-- если её уровень превышает заданный уровень при этом верхний уровень зарплаты по умолчанию равен 70, а процент коррекции равен 15%.

CREATE FUNCTION correct_salary() 
RETURNS void AS $$
DECLARE
    p_level decimal := 70.0;
    p_percent decimal := 0.15;
BEGIN
    UPDATE employees
    SET salary = salary * (1.0 - p_percent)
    WHERE salary > p_level;
END;
$$ LANGUAGE plpgsql;

SELECT correct_salary();

-- 6. Модифицировать функцию, корректирующую зарплату таким образом, чтобы в результате коррекции, она так же выводила бы изменённые записи.

CREATE FUNCTION correct_salary_v2() 
RETURNS SETOF employees AS $$
DECLARE
    p_level decimal := 70.0;
    p_percent decimal := 0.15;
BEGIN
	RETURN QUERY
    UPDATE employees
    SET salary = salary * (1.0 + p_percent)
    WHERE salary > p_level
	RETURNING *;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM correct_salary_v2();

-- 7. Модифицировать предыдущую функцию так, чтобы она возвращала только колонки last_name, first_name, title, salary

Drop function correct_salary_v3;

CREATE FUNCTION correct_salary_v3() 
RETURNS TABLE (last_name varchar, first_name varchar, title varchar, salary decimal) AS $$
DECLARE
    p_level decimal := 70.0;
    p_percent decimal := 0.15;
BEGIN
	RETURN QUERY
    UPDATE employees
    SET salary = employees.salary * (1.0 - p_percent)
    WHERE employees.salary > p_level
	RETURNING employees.last_name, employees.first_name, employees.title, employees.salary;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM correct_salary_v3();

-- 8. Написать функцию, которая принимает метод доставки и возвращает записи из таблицы orders в которых freight меньше значения, 
-- определяемого по следующему алгоритму:
-- - ищем максимум фрахта (freight) среди заказов по заданному методу доставки
-- - корректируем найденный максимум на 30% в сторону понижения
-- - вычисляем среднее значение фрахта среди заказов по заданному методому доставки
-- - вычисляем среднее значение между средним найденным на предыдущем шаге и скорректированным максимумом
-- - возвращаем все заказы в которых значение фрахта меньше найденного на предыдущем шаге среднего

CREATE FUNCTION get_some_orders(p_ship_via int)
RETURNS SETOF orders AS $$
DECLARE
	max_freight real;
	avg_freight real;
	result_freight real;
BEGIN
	SELECT MAX(freight), AVG(freight) 
		INTO max_freight, avg_freight
		FROM orders WHERE ship_via = p_ship_via;
	max_freight := max_freight * 0.7;
	result_freight := (max_freight + avg_freight) / 2.0;
	
	RETURN QUERY
	SELECT *
	FROM orders
	WHERE freight < result_freight;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_some_orders(1);

-- 9. Написать функцию, которая принимает:
-- уровень зарплаты, максимальную зарплату (по умолчанию 80) минимальную зарплату (по умолчанию 30), коээфициет роста зарплаты (по умолчанию 20%)
-- Если зарплата выше минимальной, то возвращает false
-- Если зарплата ниже минимальной, то увеличивает зарплату на коэффициент роста и проверяет не станет ли зарплата после повышения превышать максимальную.
-- Если превысит - возвращает false, в противном случае true.

CREATE FUNCTION check_salary(p_c decimal, p_max decimal DEFAULT 80, p_min decimal DEFAULT 30, p_r real DEFAULT 0.2) 
RETURNS boolean AS $$
BEGIN
IF p_c > p_min THEN RETURN false; END IF;
IF p_c < p_min THEN
	p_c := p_c * (1 + p_r);
	IF p_c > p_max THEN 
		RETURN false;
		ELSE RETURN true;
	END IF;
END IF;
END;
$$ LANGUAGE plpgsql;

-- Проверить реализацию, передавая следующие параметры
-- (где c - уровень з/п, max - макс. уровень з/п, min - минимальный уровень з/п, r - коэффициент):
-- c = 40, max = 80, min = 30, r = 0.2 - должна вернуть false

SELECT check_salary(40.0);

-- c = 79, max = 81, min = 80, r = 0.2 - должна вернуть false

SELECT check_salary(79, 81, 80);

-- c = 79, max = 95, min = 80, r = 0.2 - должна вернуть true

SELECT check_salary(79, 95, 80);