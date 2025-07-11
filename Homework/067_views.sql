-- 1. Создать представление, которое выводит следующие колонки:
-- order_date, required_date, shipped_date, ship_postal_code, company_name, contact_name, phone, last_name, first_name, 
-- title из таблиц orders, customers и employees.

CREATE VIEW orders_customers_employees_view_1 AS
SELECT order_date, required_date, shipped_date, ship_postal_code, company_name, contact_name, phone, last_name, first_name, title
FROM orders
JOIN customers USING (customer_id)
JOIN employees USING (employee_id);

-- Сделать select к созданному представлению, выведя все записи, где order_date больше 1го января 1997 года.

SELECT * 
FROM orders_customers_employees_view_1
WHERE order_date > '1997-01-01';

-- 2. Создать представление, которое выводит следующие колонки: 
-- order_date, required_date, shipped_date, ship_postal_code, ship_country, company_name, contact_name, phone, last_name, 
-- first_name, title из таблиц orders, customers, employees.

CREATE VIEW orders_customers_employees_view_2 AS
SELECT order_date, required_date, shipped_date, ship_postal_code, ship_country, company_name, contact_name, phone, 
last_name, first_name, title
FROM orders
JOIN customers USING (customer_id)
JOIN employees USING (employee_id);

-- Попробовать добавить к представлению (после его создания) колонки ship_country, postal_code и reports_to. 
-- Убедиться, что проихсодит ошибка. 
-- Переименовать представление и создать новое уже с дополнительными колонками.

CREATE OR REPLACE VIEW  orders_customers_employees_view_3 AS
SELECT order_date, required_date, shipped_date, ship_postal_code, ship_country, company_name, contact_name, phone, 
last_name, first_name, title, customers.postal_code, reports_to
FROM orders
JOIN customers USING (customer_id)
JOIN employees USING (employee_id);

-- Сделать к нему запрос, выбрав все записи, отсортировав их по ship_county.

SELECT *
FROM orders_customers_employees_view_3
ORDER BY ship_country;

-- Удалить переименованное представление.

DROP VIEW orders_customers_employees_view_3;

-- 3.  Создать представление "активных" (discontinued = 0) продуктов, содержащее все колонки. 
-- Представление должно быть защищено от вставки записей, в которых discontinued = 1.

CREATE VIEW products_view AS
SELECT * 
FROM products
WHERE discontinued = 0
WITH LOCAL CHECK OPTION;

-- Попробовать сделать вставку записи с полем discontinued = 1 - убедиться, что не проходит.

INSERT INTO products_view (product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock,
						  units_on_order, reorder_level, discontinued) 
VALUES ('p_name', 1, 2, 3, 4, 5, 6, 7, 1);