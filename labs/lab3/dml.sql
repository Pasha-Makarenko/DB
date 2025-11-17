TRUNCATE users, categories, seller_profiles, products, orders, order_products, reviews, rating, payments, shipments RESTART IDENTITY CASCADE;

/***********************************************************************************
INSERT
***********************************************************************************/

INSERT INTO users (first_name, last_name, email, phone, country, city, street, house_number, postal_code)
VALUES ('Alice', 'Smith', 'alice.smith@example.com', '+380501112233', 'Ukraine', 'Kyiv', 'Khreshchatyk', '10', '01001'),
       ('Bob', 'Johnson', 'bob.johnson@example.com', '+380672223344', 'Ukraine', 'Lviv', 'Rynok Square', '5', '79000'),
       ('Charlie', 'Brown', 'charlie.brown@example.com', '+380993334455', 'Ukraine', 'Odesa', 'Derybasivska', '22', '65000');

INSERT INTO categories (name, parent_category_id)
VALUES ('Electronics', NULL),
       ('Books', NULL),
       ('Laptops', 1),
       ('Smartphones', 1);

INSERT INTO seller_profiles (user_id, store_name, contact_info)
VALUES (2, 'Bobs Bestsellers', 'sales@bobsbooks.com'),
       (3, 'Charlies Tech', 'support@charliestech.com');

INSERT INTO products (name, description, price, stock_quantity, owner_id, category_id)
VALUES ('Pro Laptop X1000', 'A very fast laptop.', 35000.00, 10, 2, 3),
       ('The SQL Enigma', 'A mystery novel about databases.', 450.00, 50, 1, 2),
       ('SmartPhone Z', 'The latest smartphone.', 22000.00, 25, 2, 4),
       ('Classic Sci-Fi', 'A collection of classic stories.', 300.00, 30, 1, 2);

INSERT INTO orders (user_id, status)
VALUES (1, 'NEW');

INSERT INTO order_products (order_id, product_id, quantity, price_at_purchase)
VALUES (1, 1, 1, 35000.00),
       (1, 2, 2, 450.00);

INSERT INTO rating (user_id, product_id, rating)
VALUES (1, 1, 5);

INSERT INTO reviews (user_id, product_id, comment)
VALUES (1, 1, 'Absolutely fantastic laptop! Very fast delivery.');

INSERT INTO payments (order_id, amount, method, status)
VALUES (1, 35900.00, 'CARD', 'PENDING');

INSERT INTO shipments (order_id, method, tracking_number)
VALUES (1, 'COURIER', 'NP000123456');


/***********************************************************************************
SELECT
***********************************************************************************/

SELECT *
FROM users;
SELECT *
FROM categories;
SELECT *
FROM products;
SELECT *
FROM orders;
SELECT *
FROM order_products;
SELECT *
FROM reviews;

SELECT first_name, last_name, email
FROM users
WHERE city = 'Kyiv';

SELECT name, price
FROM products
WHERE price > 10000.00;

SELECT name, price, stock_quantity
FROM products
WHERE category_id = 2;


/***********************************************************************************
UPDATE
***********************************************************************************/

SELECT status, amount
FROM payments
WHERE order_id = 1;

UPDATE payments
SET status = 'SUCCESS'
WHERE order_id = 1;

SELECT status, amount
FROM payments
WHERE order_id = 1;

UPDATE orders
SET status = 'PAID'
WHERE id = 1;

UPDATE shipments
SET status = 'IN_TRANSIT'
WHERE order_id = 1;

UPDATE users
SET phone = '+380509998877'
WHERE email = 'alice.smith@example.com';

UPDATE products
SET discount = 10
WHERE id = 2
  AND owner_id = 1;

SELECT name, price, discount
FROM products
WHERE id = 2;


/***********************************************************************************
DELETE
***********************************************************************************/

INSERT INTO reviews (user_id, product_id, comment)
VALUES (2, 3, 'This review will be deleted.');

SELECT *
FROM reviews
WHERE product_id = 3;

DELETE
FROM reviews
WHERE user_id = 2
  AND product_id = 3;

SELECT *
FROM reviews
WHERE product_id = 3;

-- soft delete
UPDATE seller_profiles
SET is_active = false
WHERE user_id = 3;

UPDATE products
SET is_active = false
WHERE owner_id = 2;

SELECT *
FROM seller_profiles
WHERE user_id = 3;
SELECT *
FROM products
WHERE owner_id = 2;

-- on delete restrict
DELETE
FROM payments
WHERE order_id = 1;

DELETE
FROM shipments
WHERE order_id = 1;

DELETE
FROM orders
WHERE user_id = 1;

DELETE
FROM users
WHERE id = 1;

-- on delete cascade
SELECT *
FROM seller_profiles
WHERE user_id = 3;
SELECT *
FROM products
WHERE owner_id = 2;

DELETE
FROM users
WHERE id = 3;

SELECT *
FROM users
WHERE id = 3;
SELECT *
FROM seller_profiles
WHERE user_id = 3;
SELECT *
FROM products
WHERE owner_id = 2;