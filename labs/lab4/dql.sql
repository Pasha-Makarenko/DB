-- 1. SUM, AVG, COUNT, MIN/MAX
SELECT SUM(amount)
FROM payments AS p
WHERE p.status = 'SUCCESS';

SELECT AVG(price)
FROM products AS p
WHERE p.is_active = true;

SELECT COUNT(*)
FROM users AS u
WHERE city = 'Kyiv';

SELECT MAX(stock_quantity)
FROM products AS p
WHERE p.is_active = true;

-- 2. GROUP BY
SELECT method, COUNT(*)
FROM payments
GROUP BY method;

SELECT owner_id, COUNT(*)
FROM products
GROUP BY owner_id;

SELECT status, COUNT(*)
FROM payments
GROUP BY status;

-- 3. HAVING
SELECT p.category_id, COUNT(*) AS product_count
FROM products AS p
       LEFT JOIN categories c ON c.id = p.category_id
WHERE p.is_active = true
  AND c.is_active = true
GROUP BY p.category_id
HAVING COUNT(*) > 5;

SELECT product_id, AVG(rating) AS avg_rating
FROM rating
GROUP BY product_id
HAVING AVG(rating) > 4;

-- 4. JOIN
SELECT u.first_name, u.last_name, o.created_at
FROM orders AS o
       INNER JOIN users u ON o.user_id = u.id;

SELECT p.name AS product_name, c.name AS categoty_name
FROM products AS p
       INNER JOIN categories c ON c.id = p.category_id;

SELECT u.last_name, o.id
FROM users AS u
       LEFT JOIN orders o ON o.user_id = u.id;

-- 5. Complex
SELECT c.name, SUM(op.quantity * op.price_at_purchase) AS total_amout
FROM categories AS c
       INNER JOIN products p ON p.category_id = c.id
       INNER JOIN order_products op ON op.product_id = p.id
GROUP BY c.name;

-- 6. Subqueries
SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

SELECT id
FROM products
WHERE id NOT IN (SELECT product_id FROM order_products);

SELECT *
FROM payments
WHERE amount = (SELECT MAX(amount) FROM payments);

-- 7. CTE
WITH avg_calc AS (SELECT AVG(price) as avg_price FROM products)
SELECT p.name, p.price
FROM products p,
     avg_calc
WHERE p.price > avg_calc.avg_price;

WITH sold_items AS (SELECT DISTINCT product_id FROM order_products)
SELECT p.id, p.name
FROM products p
       LEFT JOIN sold_items s ON p.id = s.product_id
WHERE s.product_id IS NULL;

WITH max_calc AS (SELECT MAX(amount) AS max_amount FROM payments)
SELECT p.*
FROM payments p
       INNER JOIN max_calc m ON m.max_amount = p.amount;