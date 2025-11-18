TRUNCATE users, categories, seller_profiles, products, orders, order_products, reviews, rating, payments, shipments RESTART IDENTITY CASCADE;

INSERT INTO users (first_name, last_name, email, phone, country, city, street, house_number, postal_code)
SELECT
  (ARRAY['Oleksandr', 'Dmytro', 'Maksym', 'Andrii', 'Ivan', 'Serhii', 'Olha', 'Iryna', 'Nataliia', 'Tetiana'])[floor(random() * 10 + 1)],
    (ARRAY['Kovalenko', 'Bondarenko', 'Tkachenko', 'Shevchenko', 'Melnyk', 'Boyko', 'Kravchenko', 'Klymenko'])[floor(random() * 8 + 1)],
    'user_' || seq || '@example.com',
    '+380' || (50 + floor(random() * 49))::text || lpad(seq::text, 7, '0'),
    'Ukraine',
    (ARRAY['Kyiv', 'Lviv', 'Odesa', 'Kharkiv', 'Dnipro'])[floor(random() * 5 + 1)],
    (ARRAY['Shevchenka', 'Lesi Ukrainky', 'Franka', 'Soborna', 'Myru'])[floor(random() * 5 + 1)],
    floor(random() * 100 + 1)::text,
    '0' || floor(random() * 90000 + 10000)::text
FROM generate_series(1, 50) AS seq;

INSERT INTO categories (name, parent_category_id) VALUES
                                                    ('Electronics', NULL), ('Clothing', NULL), ('Books', NULL), ('Home & Garden', NULL);

INSERT INTO categories (name, parent_category_id) VALUES
                                                    ('Laptops', 1), ('Smartphones', 1), ('T-Shirts', 2), ('Fantasy', 3);

INSERT INTO seller_profiles (user_id, store_name, contact_info, is_active)
SELECT
  id,
  'Store of ' || first_name,
  'contact@store' || id || '.com',
  true
FROM users
WHERE id % 5 = 0;

INSERT INTO products (name, description, price, stock_quantity, owner_id, category_id, is_active)
SELECT
  'Product Model ' || seq,
  'Description for product ' || seq || '. High quality item.',
  (random() * 5000 + 100)::numeric(10,2),
  floor(random() * 50 + 1)::int,
  seller.id,
  cat.id,
  (random() > 0.1)
FROM generate_series(1, 100) AS seq
       CROSS JOIN LATERAL (
  SELECT id
  FROM seller_profiles
  WHERE seq IS NOT NULL
  ORDER BY random()
    LIMIT 1
) AS seller
CROSS JOIN LATERAL (
SELECT id
FROM categories
WHERE seq IS NOT NULL
ORDER BY random()
  LIMIT 1
  ) AS cat;

INSERT INTO orders (user_id, status, created_at)
SELECT
  u.id,
  (ARRAY['NEW', 'PAID', 'SHIPPED', 'COMPLETED', 'CANCELED']::order_status[])[floor(random()*5 + 1)],
  NOW() - (random() * interval '90 days')
FROM generate_series(1, 300) AS seq
  CROSS JOIN LATERAL (
  SELECT id
  FROM users
  WHERE seq IS NOT NULL
  ORDER BY random()
  LIMIT 1
) AS u;

DO $$
DECLARE
o_rec RECORD;
    i INT;
BEGIN
FOR o_rec IN SELECT id FROM orders LOOP
  FOR i IN 1..floor(random() * 4 + 1) LOOP
             INSERT INTO order_products (order_id, product_id, quantity, price_at_purchase)
SELECT
  o_rec.id,
  p.id,
  floor(random() * 3 + 1),
  p.price
FROM products p
ORDER BY random() LIMIT 1
ON CONFLICT DO NOTHING;
END LOOP;
END LOOP;
END $$;

INSERT INTO payments (order_id, amount, method, status, created_at)
SELECT
  o.id,
  calc.total_amt,
  (ARRAY['CARD', 'PAYPAL', 'CASH_ON_DELIVERY']::payment_method[])[floor(random()*3 + 1)],
  (ARRAY['PENDING', 'SUCCESS', 'FAILED']::payment_status[])[floor(random()*3 + 1)],
    o.created_at + interval '1 minute'
FROM orders o
  JOIN LATERAL (
  SELECT SUM(op.quantity * op.price_at_purchase) as total_amt
  FROM order_products op
  WHERE op.order_id = o.id
  ) calc ON true
WHERE o.status IN ('PAID', 'SHIPPED', 'COMPLETED')
  AND calc.total_amt IS NOT NULL
  AND calc.total_amt > 0;

INSERT INTO shipments (order_id, method, status, tracking_number, created_at)
SELECT
  o.id,
  (ARRAY['COURIER', 'POST']::shipment_method[])[floor(random()*2 + 1)],
    CASE WHEN o.status = 'COMPLETED' THEN 'DELIVERED'::shipment_status ELSE 'IN_TRANSIT'::shipment_status END,
    'TRACK-' || o.id || '-' || floor(random() * 10000),
    o.created_at + interval '1 day'
FROM orders o
WHERE o.status IN ('SHIPPED', 'COMPLETED')
  AND EXISTS (SELECT 1 FROM payments p WHERE p.order_id = o.id);

INSERT INTO rating (user_id, product_id, rating)
WITH random_pairs AS (
  SELECT u.id as uid, p.id as pid
  FROM users u
  CROSS JOIN products p
  ORDER BY random()
  LIMIT 50
)
SELECT
  uid,
  pid,
  floor(random() * 5 + 1)
FROM random_pairs;

INSERT INTO reviews (user_id, product_id, comment)
SELECT
  r.user_id,
  r.product_id,
  (ARRAY['Great product!', 'Bad quality', 'Fast shipping', 'Recommended', 'Not worth the price'])[floor(random()*5 + 1)]
FROM rating r
WHERE random() <= 0.7;