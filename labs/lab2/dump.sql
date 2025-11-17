DROP TABLE IF EXISTS shipments, payments, rating, reviews, order_products, orders, products, seller_profiles, categories, users CASCADE;
DROP TYPE IF EXISTS shipment_status, shipment_method, payment_status, payment_method, order_status CASCADE;

CREATE TYPE order_status AS ENUM (
  'NEW',
  'PAID',
  'SHIPPED',
  'COMPLETED',
  'CANCELED'
);

CREATE TYPE payment_method AS ENUM (
  'CARD',
  'PAYPAL',
  'CASH_ON_DELIVERY'
);

CREATE TYPE payment_status AS ENUM (
  'PENDING',
  'SUCCESS',
  'FAILED'
);

CREATE TYPE shipment_method AS ENUM (
  'COURIER',
  'POST',
  'PICKUP'
);

CREATE TYPE shipment_status AS ENUM (
  'PENDING',
  'IN_TRANSIT',
  'DELIVERED',
  'RETURNED'
);

CREATE TABLE users
(
  id               SERIAL PRIMARY KEY,
  first_name       VARCHAR(255)        NOT NULL,
  last_name        VARCHAR(255)        NOT NULL,
  email            VARCHAR(255) UNIQUE NOT NULL  CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
  phone            VARCHAR(50) UNIQUE  NOT NULL,
  country          VARCHAR(100)        NOT NULL,
  city             VARCHAR(100)        NOT NULL,
  street           VARCHAR(255)        NOT NULL,
  house_number     VARCHAR(50)         NOT NULL,
  apartment_number VARCHAR(50),
  postal_code      VARCHAR(20)         NOT NULL,
  avatar           VARCHAR(255),
  registered_at    TIMESTAMP           NOT NULL DEFAULT NOW()
);

CREATE TABLE categories
(
  id                 SERIAL PRIMARY KEY,
  name               VARCHAR(255) NOT NULL CHECK (name <> ''),
  parent_category_id INT          REFERENCES categories (id) ON DELETE SET NULL,
  CHECK (id <> parent_category_id)
);

CREATE TABLE seller_profiles
(
  id             SERIAL PRIMARY KEY,
  user_id        INT          NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
  store_name     VARCHAR(255) NOT NULL CHECK (store_name <> ''),
  store_logo     VARCHAR(255),
  contact_info   TEXT,
  return_policy  TEXT,
  delivery_terms TEXT,
  created_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE products
(
  id             SERIAL PRIMARY KEY,
  name           VARCHAR(255)   NOT NULL CHECK (name <> ''),
  description    TEXT,
  price          DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
  discount       INT            NOT NULL DEFAULT 0 CHECK (discount BETWEEN 0 AND 100),
  stock_quantity INT            NOT NULL CHECK (stock_quantity >= 0),
  owner_id       INT            NOT NULL REFERENCES seller_profiles (id) ON DELETE CASCADE,
  category_id    INT            NOT NULL REFERENCES categories (id) ON DELETE RESTRICT,
  created_at     TIMESTAMP      NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE TABLE orders
(
  id         SERIAL PRIMARY KEY,
  user_id    INT          NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
  status     order_status NOT NULL DEFAULT 'NEW',
  created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE order_products
(
  order_id          INT            NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  product_id        INT            NOT NULL REFERENCES products (id) ON DELETE RESTRICT,
  quantity          INT            NOT NULL CHECK (quantity > 0),
  price_at_purchase DECIMAL(10, 2) NOT NULL CHECK (price_at_purchase >= 0),
  PRIMARY KEY (order_id, product_id)
);

CREATE TABLE reviews
(
  id               SERIAL PRIMARY KEY,
  user_id          INT       REFERENCES users (id) ON DELETE SET NULL,
  product_id       INT       NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  comment          TEXT,
  created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
  parent_review_id INT REFERENCES reviews (id) ON DELETE CASCADE,
  CHECK (id <> parent_review_id)
);

CREATE TABLE rating
(
  id         SERIAL PRIMARY KEY,
  user_id    INT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
  rating     INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  UNIQUE (user_id, product_id)
);

CREATE TABLE payments
(
  id         SERIAL PRIMARY KEY,
  order_id   INT            NOT NULL UNIQUE REFERENCES orders (id) ON DELETE RESTRICT,
  amount     DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  method     payment_method NOT NULL,
  status     payment_status NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP      NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE TABLE shipments
(
  id              SERIAL PRIMARY KEY,
  order_id        INT             NOT NULL UNIQUE REFERENCES orders (id) ON DELETE RESTRICT,
  method          shipment_method NOT NULL,
  status          shipment_status NOT NULL DEFAULT 'PENDING',
  tracking_number VARCHAR(100),
  created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_name ON users (last_name, first_name);
CREATE INDEX idx_categories_parent_category_id ON categories (parent_category_id);
CREATE INDEX idx_products_owner_id ON products (owner_id);
CREATE INDEX idx_products_category_id ON products (category_id);
CREATE INDEX idx_products_name ON products (name);
CREATE INDEX idx_orders_user_id ON orders (user_id);
CREATE INDEX idx_reviews_product_id ON reviews (product_id);
CREATE INDEX idx_rating_product_id ON rating (product_id);

INSERT INTO users (first_name, last_name, email, phone, country, city, street, house_number, postal_code)
VALUES ('Іван', 'Петренко', 'ivan.p@example.com', '+380501234567', 'Україна', 'Київ', 'Хрещатик', '24', '01001'),
       ('Марія', 'Коваленко', 'maria.k@example.com', '+380671234568', 'Україна', 'Львів', 'Площа Ринок', '10', '79008'),
       ('Петро', 'Сидоренко', 'petro.s@example.com', '+380931234569', 'Україна', 'Одеса', 'Дерибасівська', '1',
        '65026'),
       ('Ольга', 'Мельник', 'olga.m@example.com', '+380991234570', 'Україна', 'Харків', 'Сумська', '55', '61022'),
       ('Андрій', 'Шевченко', 'andriy.s@example.com', '+380631234571', 'Україна', 'Київ', 'Проспект Перемоги', '42',
        '03056');

INSERT INTO categories (name, parent_category_id)
VALUES ('Електроніка', NULL),
       ('Одяг', NULL),
       ('Книги', NULL),
       ('Смартфони', 1),
       ('Ноутбуки', 1),
       ('Футболки', 2),
       ('Джинси', 2),
       ('Наукова фантастика', 3);

INSERT INTO seller_profiles (user_id, store_name, contact_info)
VALUES (1, 'ТехноДім Івана', 'support@ivan.tech'),
       (2, 'Модний Куточок Марії', 'sales@maria.fashion'),
       (5, 'Книгарня Андрія', 'books@andriy.store');

INSERT INTO products (name, description, price, stock_quantity, owner_id, category_id)
VALUES ('Смартфон "Galaxy S25"', 'Останнє покоління флагманських смартфонів', 45999.99, 50, 1, 4),
       ('Ноутбук "ThinkPad Z1"', 'Потужний бізнес-ноутбук з 32ГБ ОЗП', 89999.00, 20, 1, 5),
       ('Футболка "Львівський вайб"', 'Бавовняна футболка з принтом', 799.50, 150, 2, 6),
       ('Смартфон "Pixel 10"', 'Чистий Android та найкраща камера', 38500.00, 40, 1, 4),
       ('Книга "Дюна"', 'Класика наукової фантастики', 450.00, 200, 3, 8),
       ('Джинси "Класика"', 'Сині джинси прямого крою', 1899.00, 80, 2, 7);

INSERT INTO orders (user_id, status)
VALUES (3, 'COMPLETED'),
       (4, 'SHIPPED'),
       (3, 'NEW'),
       (5, 'PAID'),
       (4, 'CANCELED');

INSERT INTO order_products (order_id, product_id, quantity, price_at_purchase)
VALUES (1, 1, 1, 45999.99),
       (1, 3, 2, 799.50);
INSERT INTO order_products (order_id, product_id, quantity, price_at_purchase)
VALUES (2, 2, 1, 89999.00);
INSERT INTO order_products (order_id, product_id, quantity, price_at_purchase)
VALUES (3, 4, 1, 38500.00);
INSERT INTO order_products (order_id, product_id, quantity, price_at_purchase)
VALUES (4, 5, 3, 450.00);
INSERT INTO order_products (order_id, product_id, quantity, price_at_purchase)
VALUES (5, 6, 1, 1899.00);

INSERT INTO reviews (user_id, product_id, comment, parent_review_id)
VALUES (3, 1, 'Чудовий телефон! Камера просто неймовірна.', NULL),
       (4, 3, 'Якість футболки гарна, але розмір трохи завеликий.', NULL),
       (2, 3, 'Спробуйте замовити на розмір менше, мені підійшло.', 2),
       (5, 5, 'Одна з найкращих книг, що я читав!', NULL);

INSERT INTO rating (user_id, product_id, rating)
VALUES (3, 1, 5),
       (4, 3, 4),
       (3, 3, 5),
       (5, 5, 5);

INSERT INTO payments (order_id, amount, method, status)
VALUES (1, 47598.99, 'CARD', 'SUCCESS'),
       (2, 89999.00, 'PAYPAL', 'SUCCESS'),
       (4, 1350.00, 'CARD', 'SUCCESS');

INSERT INTO shipments (order_id, method, status, tracking_number)
VALUES (1, 'COURIER', 'DELIVERED', 'NP001122334455UA'),
       (2, 'POST', 'IN_TRANSIT', 'UA9988776655VV'),
       (4, 'PICKUP', 'PENDING', 'STORE-PICKUP-123');

