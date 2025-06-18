-- 1. В рамках транзакции с уровнем изоляции Repeatable Read выполнить следующие операции:
-- - заархивировать (SELECT INTO или CREATE TABLE AS) заказчиков, которые сделали покупок менее чем на 2000 у.е.
-- - удалить из таблицы заказчиков всех заказчиков, которые были предварительно заархивированы 
-- (подсказка: для этого придётся удалить данные из связанных таблиц)

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

DROP TABLE IF EXISTS customers_tmp;

CREATE TABLE customers_tmp AS 
WITH orders_tmp AS (
    SELECT customer_id, SUM(unit_price * quantity * (1-discount)) as orders_sum
    FROM orders
    JOIN order_details USING(order_id)
    GROUP BY customer_id
	HAVING SUM(unit_price * quantity * (1-discount)) < 2000
)
SELECT customers.* 
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders_tmp);

DELETE FROM order_details
WHERE order_id IN (SELECT order_id FROM customers_tmp);

DELETE FROM orders
WHERE customer_id IN (SELECT customer_id FROM customers_tmp);

DELETE FROM customers
WHERE customer_id IN (SELECT customer_id FROM customers_tmp);

COMMIT;

ROLLBACK;

-- 2. В рамках транзакции выполнить следующие операции:
-- - заархивировать все продукты, снятые с продажи (см. колонку discontinued)
-- - поставить savepoint после архивации
-- - удалить из таблицы продуктов все продукты, которые были заархивированы
-- - откатиться к savepoint
-- - закоммитить тразнакцию

BEGIN;

CREATE TABLE discontinued_products AS (
    SELECT *
    FROM products
    WHERE discontinued = 1  
);

SAVEPOINT after_backup_discontinued_productss;

DELETE FROM order_details
WHERE product_id IN (SELECT product_id FROM discontinued_products);

DELETE FROM products
WHERE product_id IN (SELECT product_id FROM discontinued_products);

ROLLBACK TO after_backup_discontinued_productss;

COMMIT;


