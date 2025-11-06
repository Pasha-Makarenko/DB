CREATE TABLE users
(
  id            SERIAL PRIMARY KEY,
  username      VARCHAR(50) UNIQUE  NOT NULL,
  email         VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255)        NOT NULL,
  created_at    TIMESTAMP           NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMP                    DEFAULT NULL
);

CREATE TABLE categories
(
  id                 SERIAL PRIMARY KEY,
  name               VARCHAR(255) NOT NULL CHECK (name <> ''),
  parent_category_id INT          REFERENCES categories (id) ON DELETE SET NULL,
  CHECK (id <> parent_category_id)
);

CREATE TYPE lot_status AS ENUM ('ACTIVE', 'ENDED', 'CANCELLED');

CREATE TABLE lots
(
  id             SERIAL PRIMARY KEY,
  title          VARCHAR(255)   NOT NULL CHECK (title <> ''),
  description    TEXT,
  starting_price DECIMAL(10, 2) NOT NULL CHECK (starting_price >= 0),
  current_price  DECIMAL(10, 2) NOT NULL CHECK (current_price >= starting_price),
  seller_id      INT            NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
  winner_id      INT            REFERENCES users (id) ON DELETE SET NULL,
  category_id    INT            NOT NULL REFERENCES categories (id) ON DELETE RESTRICT,
  created_at     TIMESTAMP      NOT NULL DEFAULT NOW(),
  end_time       TIMESTAMP      NOT NULL,
  status         lot_status     NOT NULL DEFAULT 'ACTIVE',
  CHECK (end_time > created_at)
);

CREATE TABLE bids
(
  id         SERIAL PRIMARY KEY,
  lot_id     INT            NOT NULL REFERENCES lots (id) ON DELETE CASCADE,
  bidder_id  INT            NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  bid_amount DECIMAL(10, 2) NOT NULL CHECK (bid_amount > 0),
  bid_time   TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE TABLE transactions
(
  id               SERIAL PRIMARY KEY,
  lot_id           INT            NOT NULL UNIQUE REFERENCES lots (id) ON DELETE RESTRICT,
  amount           DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  transaction_time TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lots_seller_id ON lots (seller_id);
CREATE INDEX idx_lots_winner_id ON lots (winner_id);
CREATE INDEX idx_lots_category ON lots (category_id);
CREATE INDEX idx_bids_lot_id ON bids (lot_id);
CREATE INDEX idx_bids_bidder_id ON bids (bidder_id);
CREATE INDEX idx_lots_active_ending ON lots (status, end_time) WHERE status = 'ACTIVE';
