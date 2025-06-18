-- 1. Автоматизировать логирование времени последнего изменения в таблице products. 
-- Добавить в products соответствующую колонку и реализовать построчный триггер.

ALTER TABLE products
ADD COLUMN last_updated timestamp;

CREATE OR REPLACE FUNCTION track_changes_on_products() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS products_timestamp ON products;
CREATE TRIGGER products_timestamp BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE PROCEDURE track_changes_on_products();

UPDATE products
SET product_name = 'Chai2'
WHERE product_id = 1;

SELECT * FROM products
WHERE product_id = 1;



-- 2. Автоматизировать аудит операций в таблице order_details. 
-- Создайте отдельную таблицу для аудита, добавьте туда колонки для хранения наименования операций, имени пользователя и временного штампа. 
-- Реализуйте триггеры на утверждения.

DROP TABLE IF EXISTS order_details_audit;
CREATE TABLE order_details_audit (
	op CHAR(1) NOT NULL,
    user_changed text NOT NULL,
    time_stamp timestamp NOT NULL,
 
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price real NOT NULL,
    quantity smallint NOT NULL,
    discount real NOT NULL
);


CREATE OR REPLACE FUNCTION build_audit_order_details()
RETURNS TRIGGER AS $$ 
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO order_details_audit
        SELECT 'I', session_user, now(), nt.* FROM new_table nt;
    ELSEIF TG_OP = 'UPDATE' THEN
        INSERT INTO order_details_audit
        SELECT 'U', session_user, now(), nt.* FROM new_table nt;
    ELSEIF TG_OP = 'DELETE' THEN
        INSERT INTO order_details_audit
        SELECT 'D', session_user, now(), ot.* FROM old_table ot;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_order_details_insert ON order_details;
CREATE TRIGGER audit_order_details_insert AFTER INSERT ON order_details
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE PROCEDURE build_audit_order_details();

DROP TRIGGER IF EXISTS audit_order_details_update ON order_details;
CREATE TRIGGER audit_order_details_update AFTER UPDATE ON order_details
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE PROCEDURE build_audit_order_details();

DROP TRIGGER IF EXISTS audit_order_details_delete ON order_details;
CREATE TRIGGER audit_order_details_delete AFTER DELETE ON order_details
REFERENCING OLD TABLE AS old_table
FOR EACH STATEMENT EXECUTE PROCEDURE build_audit_order_details();
 
INSERT INTO order_details
VALUES (11077, 19, 20, 5, 0);

UPDATE order_details
SET unit_price = 60
WHERE product_id = 19 AND order_id = 11077;

DELETE FROM order_details
WHERE product_id = 19 AND order_id = 11077;

SELECT * FROM order_details_audit;
