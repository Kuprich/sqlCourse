-- 1. Выбрать все данные из таблицы customers
SELECT * FROM customers;

-- 2. Выбрать все записи из таблицы customers, но только колонки "имя контакта" и "город"
SELECT contact_name, city FROM customers;

-- 3. Выбрать все записи из таблицы orders, но взять две колонки: идентификатор заказа и колонку, значение в которой мы рассчитываем как разницу между датой отгрузки и датой формирования заказа.
SELECT order_id, (shipped_date - order_date) FROM orders;

-- 4. Выбрать все уникальные города в которых "зарегестрированы" заказчики
SELECT DISTINCT city FROM customers;

-- 5. Выбрать все уникальные сочетания городов и стран в которых "зарегестрированы" заказчики
SELECT DISTINCT city, country FROM customers;

-- 6. Посчитать кол-во заказчиков
SELECT COUNT(customer_id) FROM customers;

-- 7. Посчитать кол-во уникальных стран в которых "зарегестрированы" заказчики
SELECT COUNT(DISTINCT(country)) FROM customers;