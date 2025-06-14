-- 1. Найти заказчиков и обслуживающих их заказы сотрудников таких, что и заказчики и сотрудники из города London, 
-- а доставка идёт компанией Speedy Express. Вывести компанию заказчика и ФИО сотрудника.
SELECT shippers.company_name, employees.first_name || ' ' || employees.last_name
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
JOIN employees ON employees.employee_id = orders.employee_id
JOIN shippers ON shippers.shipper_id = orders.ship_via
WHERE employees.city = 'London' 
AND customers.city = 'London'
AND shippers.company_name = 'Speedy Express';

-- 2. Найти активные (см. поле discontinued) продукты из категории Beverages и Seafood, которых в продаже менее 20 единиц. 
-- Вывести наименование продуктов, кол-во единиц в продаже, имя контакта поставщика и его телефонный номер.
SELECT p.product_name, p.units_in_stock, s.contact_name, s.phone
FROM products p
JOIN categories AS c ON c.category_id = p.category_id
JOIN suppliers AS s ON s.supplier_id = p.supplier_id
WHERE c.category_name IN ('Beverages', 'Seafood')
AND p.units_in_stock < 20
AND p.discontinued <> 1;

-- 3. Найти заказчиков, не сделавших ни одного заказа. Вывести имя заказчика и order_id.
SELECT c.contact_name, o.order_id
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL;

-- 4. Переписать предыдущий запрос, использовав симметричный вид джойна (подсказка: речь о LEFT и RIGHT).
SELECT c.contact_name, o.order_id
FROM orders AS o
RIGHT JOIN customers AS c ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
