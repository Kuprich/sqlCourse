-- 1. Переписать функцию, которую мы разработали ранее в одном из ДЗ таким образом, чтобы функция возвращала экземпляр композитного типа. Вот та самая функция:

-- create or replace function get_salary_boundaries_by_city(
-- 	emp_city varchar, out min_salary numeric, out max_salary numeric) 
-- AS 
-- $$
-- 	SELECT MIN(salary) AS min_salary,
-- 	   	   MAX(salary) AS max_salary
--   	FROM employees
-- 	WHERE city = emp_city
-- $$ language sql;

CREATE TYPE boundary AS (
	min_value numeric,
	max_value numeric
);
CREATE OR REPLACE FUNCTION get_salary_boundaries_by_city(emp_city varchar, OUT salary_boundary boundary) 
AS $$
	SELECT MIN(salary), MAX(salary)
  	FROM employees
	WHERE city = emp_city
$$ LANGUAGE SQL;

SELECT * FROM get_salary_boundaries_by_city('London');

-- 2. Задание состоит из пунктов:
-- Создать перечисление армейских званий США, включающее следующие значения: Private, Corporal, Sergeant

CREATE TYPE army_rank AS ENUM ( 'Private', 'Corporal', 'Sergeant');

-- Вывести все значения из перечисления.

SELECT enumlabel 
FROM pg_enum 
WHERE enumtypid = 'army_rank'::regtype 
ORDER BY enumsortorder;

-- или
SELECT enum_range(null::army_rank);

--или
SELECT unnest(enum_range(null::army_rank));

-- Добавить значение Major после Sergeant в перечисление

ALTER TYPE army_rank
ADD VALUE 'Major' AFTER 'Sergeant';

SELECT unnest(enum_range(null::army_rank));

-- Создать таблицу личного состава с колонками: person_id, first_name, last_name, person_rank (типа перечисления)
-- Добавить несколько записей, вывести все записи из таблицы

CREATE TABLE army (
	person_id serial PRIMARY KEY,
	first_name text,
	last_name text,
	person_rank army_rank
);

INSERT INTO army (first_name, last_name, person_rank) VALUES
('Ivan', 'Ivanov', 'Private'),
('Petr', 'Petrov', 'Major');

SELECT * FROM army;
