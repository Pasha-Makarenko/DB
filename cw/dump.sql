INSERT INTO users (id, username, email, password_hash)
VALUES (1, 'seller_a', 'seller_a@example.com', 'hash123'),
       (2, 'seller_b', 'seller_b@example.com', 'hash123'),
       (3, 'buyer_bob', 'bob@example.com', 'hash123'),
       (4, 'buyer_cat', 'cat@example.com', 'hash123'),
       (5, 'buyer_dan', 'dan@example.com', 'hash123');

SELECT setval('users_id_seq', 5, true);

INSERT INTO categories (id, name, parent_category_id)
VALUES (1, 'Electronics', NULL),
       (2, 'Collectibles', NULL),
       (3, 'Books', NULL),
       (4, 'Smartphones', 1);

SELECT setval('categories_id_seq', 4, true);

INSERT INTO lots (id, title, description, starting_price, current_price, seller_id, winner_id, category_id, created_at,
                  end_time, status)
VALUES (1, 'Vintage Watch', 'A rare 1950s watch', 100.00, 350.00, 1, 3, 2,
        NOW() - '10 days'::interval, NOW() - '5 days'::interval, 'ENDED'),
       (2, 'Gaming Laptop', 'Fast laptop, used', 800.00, 1200.00, 2, 4, 1,
        NOW() - '10 days'::interval, NOW() - '5 days'::interval, 'ENDED'),
       (3, 'Modern Smartphone', 'New phone, sealed box', 500.00, 550.00, 1, 5, 4,
        NOW() - '2 days'::interval, NOW() + '3 days'::interval, 'ACTIVE'),
       (4, 'Fantasy Trilogy', 'Signed by author', 50.00, 60.00, 2, NULL, 3,
        NOW() - '3 days'::interval, NOW() + '2 days'::interval, 'CANCELLED'),
       (5, 'Old Book', 'History book from 1890', 20.00, 20.00, 1, NULL, 3,
        NOW() - '7 days'::interval, NOW() - '2 days'::interval, 'ENDED'),
       (6, 'Wireless Headphones', 'Noise-cancelling', 100.00, 150.00, 2, 3, 1,
        NOW() - '6 days'::interval, NOW() - '1 day'::interval, 'ENDED');

SELECT setval('lots_id_seq', 6, true);

INSERT INTO bids (lot_id, bidder_id, bid_amount, bid_time)
VALUES (1, 4, 110.00, NOW() - '9 days'::interval),
       (1, 5, 200.00, NOW() - '8 days'::interval),
       (1, 4, 300.00, NOW() - '7 days'::interval),
       (1, 3, 350.00, NOW() - '6 days'::interval);

INSERT INTO bids (lot_id, bidder_id, bid_amount, bid_time)
VALUES (2, 3, 900.00, NOW() - '9 days'::interval),
       (2, 5, 1000.00, NOW() - '8 days'::interval),
       (2, 4, 1200.00, NOW() - '7 days'::interval);

INSERT INTO bids (lot_id, bidder_id, bid_amount, bid_time)
VALUES (3, 3, 525.00, NOW() - '1 day'::interval),
       (3, 5, 550.00, NOW() - '1 hour'::interval);

INSERT INTO bids (lot_id, bidder_id, bid_amount, bid_time)
VALUES (4, 5, 60.00, NOW() - '2 days'::interval);

INSERT INTO bids (lot_id, bidder_id, bid_amount, bid_time)
VALUES (6, 3, 150.00, NOW() - '3 days'::interval);

INSERT INTO transactions (lot_id, amount, transaction_time)
VALUES (1, 350.00, NOW() - '5 days'::interval + '1 hour'::interval),
       (2, 1200.00, NOW() - '5 days'::interval + '1 hour'::interval),
       (6, 150.00, NOW() - '1 day'::interval + '1 hour'::interval);