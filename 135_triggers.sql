ALTER TABLE customers
ADD COLUMN last_updated timestamp;

CREATE OR REPLACE FUNCTION track_changes_on_customers() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS customers_timestamp ON customers;
CREATE TRIGGER customers_timestamp BEFORE INSERT OR UPDATE ON customers
    FOR EACH ROW EXECUTE PROCEDURE track_changes_on_customers();

SELECT * FROM customers
WHERE customer_id = 'ALFKI';

UPDATE customers
SET address = 'bla'
WHERE customer_id = 'ALFKI';

INSERT INTO customers
VALUES ('ABCDE', 'company', 'contact', 'title', 'address', 'city', null, 'code', 'country', '', '', null);

ALTER TABLE employees
ADD COLUMN user_changed text;

CREATE OR REPLACE FUNCTION track_changes_on_employees() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.user_changed = session_user;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS employees_user_change ON employees;
CREATE TRIGGER employees_user_change BEFORE INSERT OR UPDATE ON employees
    FOR EACH ROW EXECUTE PROCEDURE track_changes_on_employees();

SELECT * FROM employees;

UPDATE employees
SET salary = 88
WHERE employee_id = 1;

INSERT INTO employees
VALUES (10, '', '', '', '', null, null, '', '', '', '', '', '', '', null, '', null, '', 0, null);


