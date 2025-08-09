-- Examining some key relationships in our database
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'ecommerce' AND column_name LIKE '%_id'
  AND table_name IN ('customers', 'orders', 'order_items', 'products')
ORDER BY table_name, column_name;

-- Basic Syntax and Structure
SELECT c.first_name, c.last_name, o.order_id, o.order_date
FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id;


-- Using ON
SELECT *
FROM payments p INNER JOIN orders o
  ON o.order_id = p.order_id;

-- VS Using USING
SELECT *
FROM payments p INNER JOIN orders o
  USING (order_id);

-- Multiple table joins
SELECT c.first_name, c.last_name, p.product_name, oi.quantity
FROM customers c
  INNER JOIN orders o ON c.customer_id = o.customer_id
  INNER JOIN order_items oi ON o.order_id = oi.order_id
  INNER JOIN products p ON oi.product_id = p.product_id;

-- Multiple Joins with aggregation groups
SELECT p.product_name, 
    COUNT(*) as purchase_count,
    SUM(oi.quantity) as total_units_sold
FROM customers c
  INNER JOIN orders o ON c.customer_id = o.customer_id
  INNER JOIN order_items oi ON o.order_id = oi.order_id
  INNER JOIN products p ON oi.product_id = p.product_id
WHERE c.country = 'Brazil'
GROUP BY p.product_name
ORDER BY total_units_sold DESC
FETCH FIRST ROW WITH TIES;

-- Finding products with similar prices
SELECT p1.product_name as product1, 
       p2.product_name as product2,
       p1.price, p2.price,
       ABS(p1.price - p2.price) as price_difference
FROM products p1
INNER JOIN products p2 ON p1.product_id < p2.product_id 
                       AND ABS(p1.price - p2.price) <= 10
ORDER BY price_difference

-- Find customers who haven't placed any orders
SELECT c.customer_id, c.first_name, c.last_name,
    o.order_id, o.order_date
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.last_name, c.first_name;

-- Identify products without reviews
SELECT p.product_id, p.product_name, p.price, c.category_name
FROM products p
  INNER JOIN categories c ON p.category_id = c.category_id
  LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL
ORDER BY p.price DESC;

-- Find orders that haven't been shipped yet
SELECT o.order_id,o.order_date,c.first_name,c.last_name, o.total_amount
FROM orders o
  INNER JOIN customers c ON o.customer_id = c.customer_id
  LEFT JOIN shipping s ON o.order_id = s.order_id
WHERE s.shipping_id IS NULL AND o.status != 'pending'
ORDER BY o.order_date;

-- Right join: find all products and their reviews, including unreviewed products
SELECT p.product_name, r.rating, r.review_text
FROM reviews r RIGHT JOIN products p
  ON r.product_id = p.product_id;

-- Finding products ordered by the most recently purchased ones
-- but also including never sold products 
SELECT DISTINCT ON (c.category_name, p.product_name)
  c.category_name, p.product_name, o.order_id, o.order_date
FROM orders o
  LEFT JOIN order_items oi ON o.order_id = oi.order_id
  RIGHT JOIN products p ON oi.product_id = p.product_id
  RIGHT JOIN categories c ON p.category_id = c.category_id;

-- Find mismatches between orders and payments
SELECT o.order_id, o.total_amount AS order_amount,
  p.amount AS payment_amount, p.payment_id,
  CASE
    WHEN p.payment_id IS NULL THEN 'Missing payment'
    WHEN o.order_id IS NULL THEN 'Payment without order'
    WHEN o.total_amount != p.amount THEN 'Amount mismatch'
  END AS issue_type
FROM orders o FULL OUTER JOIN payments p
  ON o.order_id = p.order_id
WHERE p.payment_id IS NULL OR o.order_id IS NULL
   OR o.total_amount != p.amount;

-- FULL OUTER JOIN: Find mismatches between orders and payments
SELECT o.order_id, o.total_amount AS order_amount,
  p.amount AS payment_amount, p.payment_id,
  CASE
    WHEN p.payment_id IS NULL THEN 'Missing payment'
    WHEN o.order_id IS NULL THEN 'Payment without order'
    WHEN o.total_amount != p.amount THEN 'Amount mismatch'
  END AS issue_type
FROM orders o FULL OUTER JOIN payments p
  ON o.order_id = p.order_id
WHERE p.payment_id IS NULL OR o.order_id IS NULL
   OR o.total_amount != p.amount;

-- Check for data integrity issues across customers and orders
SELECT 
  COALESCE(c.customer_id::text, 'MISSING') AS customer_id,
  COALESCE(c.first_name || ' ' || c.last_name, 'Unknown Customer') AS customer_name,
  COALESCE(o.order_id::text, 'MISSING') AS order_id,
  COALESCE(o.status, 'No Status') AS order_status
FROM customers c
  FULL OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL OR o.order_id IS NULL;

-- Reconcile inventory across systems
SELECT p.product_id, p.product_name,
  p.stock_quantity AS system_inventory, w.quantity AS warehouse_count,
  CASE
    WHEN p.product_id IS NULL THEN 'In warehouse only'
    WHEN w.product_id IS NULL THEN 'In system only'
    WHEN p.stock_quantity != w.quantity THEN 'Quantity mismatch'
  END AS discrepancy_type
FROM products p
FULL OUTER JOIN warehouse_inventory w ON p.product_id = w.product_id
WHERE p.product_id IS NULL OR w.product_id IS NULL
   OR p.stock_quantity != w.quantity;

-- Validate customer data migration
SELECT old.customer_id AS old_id, new.customer_id AS new_id,
  old.email AS old_email, new.email AS new_email
FROM old_system_customers old
  FULL OUTER JOIN customers new ON old.email = new.email
WHERE old.customer_id IS NULL OR new.customer_id IS NULL;

-- NATURAL JOIN
SELECT c.category_name, p.product_name, p.created_at
FROM categories c NATURAL JOIN products p;

-- CROSS JOIN
SELECT p.product_name, pm.payment_method
FROM products p
CROSS JOIN payments pm;

-- Pricing matrix
SELECT p.product_id, p.product_name, d.discount_rate,
  ROUND(p.price * (1 - d.discount_rate/100.0), 2) AS discounted_price
FROM products p
  CROSS JOIN (VALUES (5), (10), (15), (20), (25)) AS d(discount_rate)
WHERE p.is_featured = TRUE
ORDER BY p.product_name, d.discount_rate;

-- Self joins: hierarchical data
SELECT parent.category_name AS parent_category,
  child.category_name AS subcategory
FROM categories parent
  JOIN categories child ON child.parent_category_id = parent.category_id
ORDER BY parent_category, subcategory;

