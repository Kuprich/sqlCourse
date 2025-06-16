-- Вывести сумму продаж (цена * кол-во) по каждому сотруднику с подсчётом полного итога (полной суммы по всем сотрудникам) 
-- отсортировав по сумме продаж (по убыванию).

SELECT o.employee_id, SUM(unit_price * quantity)
FROM orders as o
JOIN order_details as od USING (order_id)
GROUP BY ROLLUP (o.employee_id)
ORDER BY SUM(unit_price * quantity) DESC;

-- Вывести отчёт показывающий сумму продаж по сотрудникам и странам отгрузки с подытогами по сотрудникам и общим итогом.

SELECT o.employee_id, o.ship_country, SUM(unit_price * quantity)
FROM orders as o
JOIN order_details as od USING (order_id)
GROUP BY ROLLUP (o.employee_id, o.ship_country)
ORDER BY (o.employee_id,  SUM(unit_price * quantity))

-- Вывести отчёт показывающий сумму продаж по сотрудникам, странам отгрузки, сотрудникам и странам отгрузки с подытогами 
-- по сотрудникам и общим итогом.

SELECT o.employee_id, o.ship_country, SUM(unit_price * quantity)
FROM orders as o
JOIN order_details as od USING (order_id)
GROUP BY CUBE (o.employee_id, o.ship_country)
ORDER BY (o.employee_id,  SUM(unit_price * quantity))