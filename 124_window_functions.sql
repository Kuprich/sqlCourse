SELECT category_id, category_name, product_name, unit_price, 
AVG(unit_price) OVER (PARTITION BY category_id) AS avg_price
FROM products
JOIN categories USING(category_id)


SELECT order_id, order_date, product_id, customer_id, unit_price AS sub_total,
    SUM(unit_price) OVER(PARTITION BY order_id ORDER BY product_id) AS sale_sum
FROM orders
JOIN order_details USING(order_id)
ORDER BY order_id


SELECT row_id, order_id, order_date, product_id, customer_id, unit_price AS sub_total,
    SUM(unit_price) OVER(ORDER BY row_id) AS sale_sum
FROM (
    SELECT order_id, order_date, product_id, customer_id, unit_price, 
        row_number() OVER() AS row_id
    FROM orders
    JOIN order_details USING(order_id)
) subquery
ORDER BY order_id;