INSERT INTO users (id, username, email, password_hash)
VALUES (1, 'Buyer1', 'buyer1@example.com', 'hashed_password1'),
       (2, 'Buyer2', 'buyer2@example.com', 'hashed_password2'),
       (3, 'Seller1', 'seller1@example.com', 'hashed_password3');

INSERT INTO categories (id, name, parent_category_id)
VALUES (1, 'Books', NULL),
       (2, 'Fiction', 1),
       (3, 'Non-Fiction', 1);

INSERT INTO lots (id, title, description, starting_price, current_price, seller_id, category_id, end_time)
VALUES (1, 'Clean Architecture', 'A book about software architecture.', 10.00, 10.00, 3, 3, NOW() + INTERVAL '7 days'),
       (2, 'DDD', 'A book about domain-driven design.', 15.00, 15.00, 3, 3, NOW() + INTERVAL '7 days'),
       (3, 'Harry Potter', 'A fantasy novel.', 20.00, 20.00, 3, 2, NOW() + INTERVAL '7 days');

INSERT INTO bids (id, lot_id, bidder_id, bid_amount)
VALUES (1, 1, 1, 12.00),
       (2, 1, 2, 14.00),
       (3, 2, 1, 18.00),
       (4, 2, 2, 20.00),
       (5, 2, 1, 25.00);

UPDATE lots
SET status        = 'ENDED',
    current_price = 14.00,
    winner_id     = 2
WHERE id = 1;

UPDATE lots
SET status        = 'ENDED',
    current_price = 25.00,
    winner_id     = 1
WHERE id = 2;

INSERT INTO transactions (id, lot_id, amount)
VALUES (1, 1, 14.00),
       (2, 2, 25.00);

DELETE
FROM bids
WHERE id = 1;

DELETE
FROM lots
WHERE id = 3;

SELECT id, title, description, current_price, seller_id, end_time
FROM lots
WHERE status = 'ACTIVE'
  AND category_id = 2
  AND end_time > NOW();

SELECT bidder_id, bid_amount, bid_time
FROM bids
WHERE lot_id = 2;