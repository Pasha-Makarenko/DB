# Знайти лоти з найбільшою кількістю ставок
SELECT lot_id,
       title,
       COUNT(b.id) AS bid_count
FROM lots
       LEFT JOIN bids b ON lots.id = b.lot_id
GROUP BY lot_id, title
ORDER BY bid_count DESC;

# Обчислити середню фінальну ціну за категоріями
SELECT c.name        AS category_name,
       AVG(t.amount) as average_final_price,
       COUNT(t.id)   AS total_lots_sold
FROM transactions t
       INNER JOIN lots l ON l.id = t.lot_id
       INNER JOIN categories c ON c.id = l.category_id
GROUP BY c.name
ORDER BY average_final_price DESC;

# Ранжувати користувачів за загальною сумою виграних аукціонів (віконні функції)
WITH winners AS (SELECT l.winner_id, SUM(amount) AS total_winnings
                 FROM transactions t
                        INNER JOIN lots l ON l.id = t.lot_id
                 GROUP BY l.winner_id)
SELECT u.username,
       w.total_winnings,
       RANK() OVER (ORDER BY w.total_winnings DESC) as winner_rank
FROM winners w
       INNER JOIN users u ON u.id = w.winner_id
ORDER BY winner_rank;

# Знайти лоти, які не отримали жодної ставки
SELECT *
FROM lots l
       LEFT JOIN bids b ON l.id = b.lot_id
WHERE b.id IS NULL;