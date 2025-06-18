DROP TABLE IF EXISTS products_audit;

CREATE TABLE products_audit (
    op CHAR(1) NOT NULL,
    user_changed text NOT NULL,
    time_stamp timestamp NOT NULL,

    product_id SMALLINT NOT NULL,
    product_name VARCHAR(40) NOT NULL,
    supplier_id SMALLINT,
    category_id SMALLINT,
    quantity_per_unit VARCHAR(20),
    unit_price REAL,
    units_in_stock SMALLINT,
    units_on_order SMALLINT,
    reorder_level SMALLINT,
    discontinued INTEGER NOT NULL
);

CREATE OR REPLACE FUNCTION build_audit_products()
RETURNS TRIGGER AS $$ 
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO products_audit
        SELECT 'I', session_user, now(), nt.* FROM new_table nt;
    ELSEIF TG_OP = 'UPDATE' THEN
        INSERT INTO products_audit
        SELECT 'U', session_user, now(), nt.* FROM new_table nt;
    ELSEIF TG_OP = 'DELETE' THEN
        INSERT INTO products_audit
        SELECT 'D', session_user, now(), ot.* FROM old_table ot;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_products_insert ON products;
CREATE TRIGGER audit_products_insert AFTER INSERT ON products
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE PROCEDURE build_audit_products();

DROP TRIGGER IF EXISTS audit_products_update ON products;
CREATE TRIGGER audit_products_update AFTER UPDATE ON products
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE PROCEDURE build_audit_products();

DROP TRIGGER IF EXISTS audit_products_delete ON products;
CREATE TRIGGER audit_products_delete AFTER DELETE ON products
REFERENCING OLD TABLE AS old_table
FOR EACH STATEMENT EXECUTE PROCEDURE build_audit_products();

SELECT * FROM products ORDER BY product_id DESC;

INSERT INTO products
VALUES (80, 'name', 7, 4, 'quantity per unit', 50, 20, 0, 0, 0);

SELECT * FROM products_audit;

UPDATE products
SET unit_price = 60
WHERE product_id = 80;

DELETE FROM products
WHERE product_id = 80;