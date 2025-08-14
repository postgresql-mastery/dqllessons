-- Subqueries in the FROM Clause
SELECT avg_prices.category_id, avg_prices.avg_price, COUNT(*) AS product_count
FROM (
  SELECT category_id, AVG(price) AS avg_price, COUNT(*) AS product_count
  FROM products
  GROUP BY category_id
) avg_prices
JOIN products p ON p.category_id = avg_prices.category_id
GROUP BY avg_prices.category_id, avg_prices.avg_price;

-- Find all premium products that exceed their category's average price by at least 20%
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    c.category_name,
    cat_stats.avg_price,
    ROUND((p.price / cat_stats.avg_price * 100) - 100, 1) AS percent_above_avg
FROM products p
JOIN (
    -- Derived table with category statistics
    SELECT 
        category_id,
        AVG(price) AS avg_price
    FROM products
    GROUP BY category_id
) cat_stats USING (category_id)
JOIN categories c USING (category_id)
WHERE p.price > cat_stats.avg_price * 1.2  -- 20% above average
ORDER BY percent_above_avg DESC;

/* Find all premium products that exceed their
category's average price by at least 20% */
SELECT p.product_id, p.product_name, p.price, c.category_name, cat_stats.avg_price,
  ROUND((p.price / cat_stats.avg_price * 100) - 100, 1) AS percent_above_avg
FROM products p
  JOIN (
    SELECT category_id, AVG(price) AS avg_price
    FROM products GROUP BY category_id
  ) cat_stats USING (category_id)
  JOIN categories c USING (category_id)
WHERE p.price > cat_stats.avg_price * 1.2  -- 20% above average
ORDER BY percent_above_avg DESC;

-- Pattern 1: Comparison with a single value
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Pattern 2: Comparison with a list of values
SELECT c.first_name, c.last_name, c.email
FROM crm.contacts c
WHERE c.email IN (SELECT email FROM customers);

-- Pattern 3: Existence check
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE EXISTS (
  SELECT 1 
  FROM products p 
  WHERE p.supplier_id = s.supplier_id AND p.stock_quantity > 0
);

-- Find products priced higher than the most expensive product in category 9 (Furniture)
SELECT product_id, product_name, price
FROM products
WHERE price > (
  SELECT MAX(price) 
  FROM products 
  WHERE category_id = 9
);

-- Find customers who placed orders with above-average total amounts
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.total_amount > (
  SELECT AVG(total_amount) 
  FROM orders
);

-- Find products that have received more reviews than average
SELECT p.product_id, p.product_name, COUNT(r.review_id) as review_count
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(r.review_id) > (
  SELECT AVG(review_count)
  FROM (
    SELECT COUNT(review_id) as review_count
    FROM reviews
    GROUP BY product_id
  ) as product_reviews
);

-- Find campaigns that have more participants than the average campaign
SELECT c.campaign_id, c.campaign_name, COUNT(cc.contact_id) AS participant_count
FROM crm.campaigns c
  JOIN crm.campaign_contacts cc ON c.campaign_id = cc.campaign_id
GROUP BY c.campaign_id, c.campaign_name
HAVING COUNT(cc.contact_id) > (
  SELECT AVG(participant_count)
  FROM (
    SELECT COUNT(contact_id) AS participant_count
    FROM crm.campaign_contacts
    GROUP BY campaign_id
  ) AS campaign_participants
);

-- Find products priced above average for their category
SELECT category_id, c.category_name, product_id, product_name, price
FROM products outer_p
JOIN categories c USING (category_id)
WHERE price > (
    SELECT AVG(price)
    FROM products
    WHERE category_id = outer_p.category_id
);

-- Basic scalar subquery example
SELECT product_name, price,
  (SELECT AVG(price) FROM products) AS avg_price
FROM products
WHERE category_id = 2;

-- Using scalar subqueries in calculations
SELECT product_name, price, 
  (SELECT AVG(price) FROM products) AS avg_price,
  price - (SELECT AVG(price) FROM products) AS price_difference,
  (price / (SELECT AVG(price) FROM products) * 100)::numeric(10,2) AS percentage_of_avg
FROM products
WHERE category_id = 2;

-- Finding products priced higher than their category average
SELECT product_id, product_name, category_id, price
FROM products p
WHERE price > (
  SELECT AVG(price) 
  FROM products 
  WHERE category_id = p.category_id
);

-- Potential performance issue: Correlated subquery executed for each row
SELECT  c.contact_id, c.first_name, c.last_name,
  (SELECT COUNT(*)
   FROM crm.interactions i
   WHERE i.contact_id = c.contact_id) AS interaction_count
FROM crm.contacts c;

-- Calculate what percentage each product contributes to total inventory value
SELECT product_id, product_name, price, stock_quantity,
  (price * stock_quantity) AS inventory_value,
  ((price * stock_quantity) / (
    SELECT SUM(price * stock_quantity) 
    FROM products
  ) * 100)::NUMERIC(10,2) AS percent_of_total_inventory
FROM products
WHERE stock_quantity > 0
ORDER BY percent_of_total_inventory DESC;

-- Calculate what percentage each campaign represents of total budget
SELECT campaign_id, campaign_name, budget,
  (budget / 
    (SELECT SUM(budget) FROM crm.campaigns) * 100)::NUMERIC(10,2)
  AS percent_of_total_budget
FROM crm.campaigns
ORDER BY percent_of_total_budget DESC;

-- Basic derived table example
SELECT  category_name, product_count, avg_price
FROM (
  SELECT c.category_id, c.category_name,
    COUNT(*) AS product_count,
    AVG(p.price)::numeric(10,2) AS avg_price
  FROM categories c
  JOIN products p ON c.category_id = p.category_id
  GROUP BY c.category_id, c.category_name) AS category_stats
WHERE product_count > 3
ORDER BY avg_price DESC;

-- This won't work because the expression lacks an alias
SELECT category_id, MAX(price) - MIN(price)
FROM (
  SELECT  category_id, MAX(price), MIN(price)
  FROM products
  GROUP BY category_id
) AS price_spread;  -- Error: subquery in FROM must have an alias for each column

-- IN Operator
-- Find customers who exist in both our e-commerce and CRM systems
SELECT  customer_id, first_name, last_name, email
FROM customers
WHERE email IN (
  SELECT email FROM crm.contacts
);

-- Find products more expensive than ANY product in the 'Audio' category
SELECT product_id, product_name, price
FROM products
WHERE price > ANY (
  SELECT price
  FROM products JOIN categories USING (category_id)
  WHERE category_name = 'Audio'
)
ORDER BY price;

-- Find products more expensive than ALL products in the 'Audio' category
SELECT product_id, product_name, price
FROM products
WHERE price > ALL (
  SELECT price
  FROM products JOIN categories USING (category_id)
  WHERE category_name = 'Audio'
)
ORDER BY price;

-- Multi-row subquery approach
SELECT c.first_name, c.last_name, c.email
FROM customers c
WHERE c.customer_id IN (
  SELECT o.customer_id FROM orders o
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
  WHERE p.is_featured
);

-- Equivalent JOIN approach
SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customers c
  JOIN orders o USING (customer_id)
  JOIN order_items oi USING (order_id)
  JOIN products p USING (product_id)
WHERE p.is_featured;

-- Find customers who haven't placed any orders in 2025: Subquery approach
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE customer_id NOT IN (
  SELECT DISTINCT customer_id FROM orders
  WHERE EXTRACT(YEAR FROM order_date) = 2025
);

-- LEFT JOIN WHERE IS NULL approach
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customers c
  LEFT JOIN orders o ON c.customer_id = o.customer_id
    AND EXTRACT(YEAR FROM order_date) = 2025
WHERE o.customer_id IS NULL;

-- LEFT JOIN to derived table approach
SELECT customer_id, c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2025
) o USING (customer_id)
WHERE o.customer_id IS NULL;


-- To find customers who have placed at least one order
-- The JOIN method
SELECT DISTINCT customer_id, first_name, last_name
FROM customers c JOIN orders o USING (customer_id);

-- The IN operator method (correlated query on WHERE clause)
SELECT customer_id, first_name, last_name
FROM customers c
WHERE customer_id IN (
  SELECT customer_id FROM orders o
  WHERE o.customer_id = c.customer_id
);

-- The EXISTS operator method (correlated query on WHERE clause)
SELECT customer_id, first_name, last_name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.customer_id
);

-- Find CRM contacts who are not in our e-commerce customer database
SELECT contact_id, first_name, last_name, email
FROM crm.contacts c
WHERE NOT EXISTS (
  SELECT 1 FROM customers ec
  WHERE ec.email = c.email
);

-- Find products with no inventory (zero stock)
SELECT product_id, product_name, category_id
FROM products p
WHERE NOT EXISTS (
  SELECT 1 FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
  WHERE oi.product_id = p.product_id AND o.status = 'pending'
) 
AND stock_quantity = 0;

-- Find products with no inventory - The NOT IN method
SELECT product_id, product_name, category_id
FROM products p
WHERE product_id NOT IN (
  SELECT product_id FROM order_items oi
    JOIN orders o USING (order_id)
  WHERE o.status = 'pending'
) 
AND stock_quantity = 0;

-- Using NOT EXISTS to find customers not in CRM
SELECT c.campaign_name FROM crm.campaigns c
WHERE NOT EXISTS (
  SELECT 1 FROM crm.campaign_contacts cc
    JOIN crm.contacts ct USING (contact_id)
  WHERE cc.campaign_id = c.campaign_id
    AND ct.email = 'michael.davis@example.com'
);

-- Using EXCEPT to find customers not in CRM
SELECT campaign_name FROM crm.campaigns
EXCEPT
SELECT c.campaign_name
FROM crm.campaign_contacts cc
  JOIN crm.contacts ct USING (contact_id)
  JOIN crm.campaigns c USING (campaign_id)
WHERE ct.email = 'michael.davis@example.com';

-- Using NOT EXISTS to find customers not in CRM
SELECT c.campaign_name FROM crm.campaigns c
WHERE NOT EXISTS (
  SELECT 1 FROM crm.campaign_contacts cc
    JOIN crm.contacts ct USING (contact_id)
  WHERE cc.campaign_id = c.campaign_id
    AND ct.email = 'michael.davis@example.com'
);
-- Find products priced above their category average
SELECT p.product_id, p.product_name, p.price, p.category_id
FROM products p
WHERE p.price > (
  SELECT AVG(price) FROM products p2
  WHERE p2.category_id = p.category_id
);

-- Find products with above-average ratings in their category
SELECT p.product_id, p.product_name, 
  (SELECT AVG(r.rating)
   FROM reviews r WHERE r.product_id = p.product_id) AS avg_rating
FROM products p
WHERE EXISTS (
  SELECT 1 FROM reviews r WHERE r.product_id = p.product_id
  GROUP BY r.product_id HAVING AVG(r.rating) > (
    SELECT AVG(r2.rating)
    FROM products p2
      JOIN reviews r2 ON p2.product_id = r2.product_id
    WHERE p2.category_id = p.category_id
  )
)