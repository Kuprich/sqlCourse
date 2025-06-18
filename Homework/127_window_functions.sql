-- Вывести отчёт показывающий по сотрудникам суммы продаж SUM(unit_price*quantity), и сопоставляющий их со средним значением суммы продаж по сотрудникам 
-- AVG по SUM(unit_price*quantity)) сортированный по сумме продаж по убыванию.

-- SELECT DISTINCT employee_id, total_by_emp, AVG(total_by_emp) OVER() AS avg_price
-- FROM (
--     SELECT 
--         employee_id, 
--         SUM(unit_price * quantity) OVER (PARTITION BY employee_id) AS total_by_emp
--     FROM orders
--     LEFT JOIN order_details USING(order_id)
-- ) AS subquery
-- ORDER BY total_by_emp DESC;

WITH sub_query AS (
	SELECT employees.employee_id, first_name, last_name, SUM(unit_price * quantity) AS sum_price
	FROM order_details
	JOIN orders USING(order_id)
	JOIN employees ON orders.employee_id = employees.employee_id
	GROUP BY (employees.employee_id, first_name, last_name)
)
SELECT first_name, last_name, sum_price, AVG(sum_price) OVER() AS avg_price
FROM sub_query

-- Вывести ранг сотрудников по их зарплате, без пропусков. Также вывести имя, фамилию и должность.

SELECT first_name, last_name, title, salary,
	DENSE_RANK() OVER (ORDER BY salary) AS salary_rank
FROM employees