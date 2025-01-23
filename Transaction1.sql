DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL
);

INSERT INTO orders (order_date, total_amount) VALUES
('2023-10-01', 50.00),
('2023-10-01', 20.00),
('2023-10-01', 30.00);


--Dirty Read
-- 1st Session
BEGIN;
UPDATE orders SET total_amount = total_amount + 5 WHERE order_id = 1;

-- 2nd Session
COMMIT;


--Non-Repeatable Read
-- 1st Session
BEGIN;
SELECT * FROM orders WHERE order_id = 1;

-- 2nd Session
SELECT * FROM orders WHERE order_id = 1;
COMMIT;


--Solution for Non-Repeatable Read
-- 1st Session
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM orders WHERE order_id = 1;

-- 2nd Session
SELECT * FROM orders WHERE order_id = 1;
COMMIT;


--Phantom Read
-- 1st Session
BEGIN;
SELECT COUNT(*) FROM orders WHERE total_amount = 100;

-- 2nd Session
SELECT COUNT(*) FROM orders WHERE total_amount = 100;
COMMIT;



--Solution for Phantom Read
-- 1st Session
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM orders WHERE total_amount = 100;

-- 2nd Session
SELECT COUNT(*) FROM orders WHERE total_amount = 100;
COMMIT;

-- Assume negative amounts are allowed but the total for a date must be positive.
-- 1st Session
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT SUM(total_amount) FROM orders WHERE order_date = '2023-10-01';

-- 2nd Session (potentially negative update)
UPDATE orders SET total_amount = total_amount - 80 WHERE order_id = 2;
COMMIT;

SELECT SUM(total_amount) FROM orders WHERE order_date = '2023-10-01';

-- Allowing negative amounts but ensuring positive totals.
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT SUM(total_amount) FROM orders WHERE order_date = '2023-10-01';

-- Update that might violate the condition.
UPDATE orders SET total_amount = total_amount - 80 WHERE order_id = 2;
COMMIT;

SELECT * FROM orders;

BEGIN;
UPDATE orders SET total_amount = total_amount - 30.00 WHERE order_id = 1;
SELECT * FROM orders;

SAVEPOINT my_savepoint;

UPDATE orders SET total_amount = total_amount + 30.00 WHERE order_id = 2;
SELECT * FROM orders;

ROLLBACK TO my_savepoint;

SELECT * FROM orders;

UPDATE orders SET total_amount = total_amount + 30.00 WHERE order_id = 3;
COMMIT;

SELECT * FROM orders;










-- Грязное чтение
SELECT * FROM bookings WHERE book_id = 1;

-- Неповторяющееся чтение
UPDATE bookings SET total_amount = total_amount - 2 WHERE book_id = 1;

-- Фантомное чтение
INSERT INTO bookings (book_date, total_amount) VALUES ('2023-10-04', 1000.00);

-- Несогласованная запись
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT sum(total_amount) FROM bookings WHERE book_date = '2023-10-01';
UPDATE bookings SET total_amount = total_amount - 60 WHERE book_id = 3;
COMMIT;
SELECT sum(total_amount) FROM bookings WHERE book_date = '2023-10-01';

--Решение (Несогласованная запись)
-- Пусть допускается отрицательная сумма заказа при условии, что итоговая сумма за дату должна быть положительной.
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT sum(total_amount) FROM bookings WHERE book_date = '2023-10-01';
UPDATE bookings SET total_amount = total_amount - 60 WHERE book_id = 2;
COMMIT;


