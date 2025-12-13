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
  id             SERIAL PRIMARY KEY,
  first_name     VARCHAR(255)        NOT NULL,
  last_name      VARCHAR(255)        NOT NULL,
  email          VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
  phone          VARCHAR(50) UNIQUE  NOT NULL,
  avatar         VARCHAR(255),
  registered_at  TIMESTAMP           NOT NULL DEFAULT NOW(),
  is_active      BOOLEAN             NOT NULL DEFAULT true
);

CREATE TABLE user_addresses
(
  id               SERIAL PRIMARY KEY,
  user_id          INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  country          VARCHAR(100) NOT NULL,
  city             VARCHAR(100) NOT NULL,
  street           VARCHAR(255) NOT NULL,
  house_number     VARCHAR(50)  NOT NULL,
  apartment_number VARCHAR(50),
  postal_code      VARCHAR(20)  NOT NULL,
  is_default       BOOLEAN      NOT NULL DEFAULT false,
  created_at       TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE categories
(
  id                 SERIAL PRIMARY KEY,
  name               VARCHAR(255) NOT NULL CHECK (name <> ''),
  parent_category_id INT          REFERENCES categories (id) ON DELETE SET NULL,
  is_active          BOOLEAN      NOT NULL DEFAULT true,
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
  created_at     TIMESTAMP    NOT NULL DEFAULT NOW(),
  is_active      BOOLEAN      NOT NULL DEFAULT true
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
  updated_at     TIMESTAMP      NOT NULL DEFAULT NOW(),
  is_active      BOOLEAN        NOT NULL DEFAULT true
);

CREATE TABLE orders
(
  id                  SERIAL PRIMARY KEY,
  user_id             INT          NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
  shipping_address_id INT          NOT NULL REFERENCES user_addresses (id) ON DELETE RESTRICT,
  status              order_status NOT NULL DEFAULT 'NEW',
  created_at          TIMESTAMP    NOT NULL DEFAULT NOW()
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