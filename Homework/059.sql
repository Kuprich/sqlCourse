DROP TABLE IF EXISTS passport;
DROP TABLE IF EXISTS exam;
DROP TABLE IF EXISTS person;

/* 1. Создать таблицу exam с полями:

- идентификатора экзамена - автоинкрементируемый, уникальный, запрещает NULL;
- наименования экзамена
- даты экзамена */
CREATE TABLE exam (
	exam_id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY NOT NULL,
	exam_name varchar(64),
	exam_date date
);

-- 2. Удалить ограничение уникальности с поля идентификатора
ALTER TABLE exam
DROP CONSTRAINT exam_pkey;

-- 3. Добавить ограничение первичного ключа на поле идентификатора
ALTER TABLE exam
ADD CONSTRAINT PK_exam_exam_id PRIMARY KEY (exam_id);

/* 4. Создать таблицу person с полями

- идентификатора личности (простой int, первичный ключ)
- имя
- фамилия */
CREATE TABLE person (
	person_id int PRIMARY KEY,
	p_name varchar(64),
	p_surname varchar(64)
);

/* 5. Создать таблицу паспорта с полями:

- идентификатора паспорта (простой int, первичный ключ)
- серийный номер (простой int, запрещает NULL)
- регистрация
- ссылка на идентификатор личности (внешний ключ) */
CREATE TABLE passport (
	passport_id int PRIMARY KEY,
	person_id int,
	serial varchar(4) NOT NULL,
	register text,
	FOREIGN KEY (person_id) REFERENCES person(person_id)
);

-- 6. Добавить колонку веса в таблицу book (создавали ранее) с ограничением, проверяющим вес (больше 0 но меньше 100)
ALTER TABLE book
ADD COLUMN weight real CHECK (weight > 0 AND weight < 100);

-- 7. Убедиться в том, что ограничение на вес работает (попробуйте вставить невалидное значение)
INSERT INTO book VALUES
(8, 'title', 'isbn', 0);

/*8. Создать таблицу student с полями:

- идентификатора (автоинкремент)
- полное имя
- курс (по умолчанию 1) */

CREATE TABLE student (
	student_id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY NOT NULL,
	full_name varchar(200),
	course smallint DEFAULT 1
);

-- 9. Вставить запись в таблицу студентов и убедиться, что ограничение на вставку значения по умолчанию работает
INSERT INTO student (full_name) VALUES 
('Ivanov Ivan Ivanovich')
RETURNING *;

-- 10. Удалить ограничение "по умолчанию" из таблицы студентов
ALTER TABLE student 
ALTER COLUMN course DROP DEFAULT;

-- 11. Подключиться к БД northwind и добавить ограничение на поле unit_price таблицы products (цена должна быть больше 0)
ALTER TABLE products
ADD CONSTRAINT CHK_products_unit_price CHECK(unit_price > 0);

-- 12. "Навесить" автоинкрементируемый счётчик на поле product_id таблицы products (БД northwind). Счётчик должен начинаться с числа 
-- следующего за максимальным значением по этому столбцу.

CREATE SEQUENCE products_product_id_seq;
ALTER TABLE products
ALTER COLUMN product_id SET DEFAULT nextval('products_product_id_seq');
SELECT setval('products_product_id_seq', 
			 (SELECT MAX(product_id) from products)+ 1);
-- Удалить последовательность (если больше не нужна)
DROP SEQUENCE products_product_id_seq;

-- 13. Произвести вставку в products (не вставляя идентификатор явно) и убедиться, что автоинкремент работает. 
-- Вставку сделать так, чтобы в результате команды вернулось значение, сгенерированное в качестве идентификатора.
INSERT INTO products(product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued)
	VALUES ('p_name', 1, 1, 10, 5, 2, 3, 15, 0.05)
RETURNING *;
	
	
	