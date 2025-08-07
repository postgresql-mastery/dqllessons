-- Individual records (overwhelming)
SELECT order_id, total_amount FROM orders;

-- Aggregated insight (actionable)
SELECT COUNT(*) as total_orders,
  SUM(total_amount)::numeric(10,2) as total_revenue,
  AVG(total_amount)::numeric(10,2) as average_order
FROM orders;

-- Individual records (overwhelming)
SELECT order_id, total_amount
FROM orders
WHERE order_date >= '2025-01-01';

-- Aggregated insight (actionable)
SELECT COUNT(*) as total_orders,
  SUM(total_amount)::numeric(10,2) as total_revenue,
  AVG(total_amount)::numeric(10,2) as average_order
FROM orders
WHERE order_date >= '2025-01-01';

-- COUNT Function Variations
SELECT * FROM orders ORDER BY payment_method NULLS FIRST, customer_id;
SELECT
  COUNT(*) AS count_star, -- counts all rows including NULL values
  COUNT(payment_method) AS count_col, -- counts only non-NULL values
  COUNT(DISTINCT payment_method) AS count_dist -- counts unique non-NULL values
FROM orders;

-- Numeric Aggregations
SELECT 
  SUM(total_amount)::NUMERIC(10,2) as total_revenue,
  AVG(total_amount)::NUMERIC(10,2) as average_order_amount,
  (SUM(total_amount) / COUNT(*))::NUMERIC(10,2) as true_average
FROM orders;

-- Basic MIN and MAX
SELECT 
  MIN(order_date) as earliest_order,
  MAX(order_date) as latest_order,
  MIN(total_amount)::numeric(10,2) as smallest_order,
  MAX(total_amount)::numeric(10,2) as largest_order
FROM orders;

-- Statistical functions
SELECT
    VARIANCE(price)::numeric(10,2) as var_spread,
    VAR_POP(price)::numeric(10,2) as var_pop_spread,
    VAR_SAMP(price)::numeric(10,2) as var_samp_spread,
    STDDEV(price)::numeric(10,2) as price_spread,
    STDDEV_POP(price)::numeric(10,2) as price_pop_spread,
    STDDEV_SAMP(price)::numeric(10,2) as price_samp_spread,
	COUNT(*) as product_count,
    AVG(price)::numeric(10,2) as avg_price,
    MIN(price) as smallest_price,
    MAX(price) as largests_price
FROM products;

-- Using CASE within COUNT
SELECT 
    COUNT(*) as total_products,
    COUNT(CASE WHEN price > 100 THEN 1 END) as premium_products,
    COUNT(CASE WHEN price <= 100 THEN 1 END) as regular_products
FROM products;

-- Using FILTER clause
SELECT 
    COUNT(*) as total_products,
    COUNT(*) FILTER (WHERE price > 100) as premium_products,
    COUNT(*) FILTER (WHERE price <= 100) as regular_products
FROM products;

-- Three approaches compared
SELECT 
    -- Total count of all products in price range
    COUNT(*) as total_products,
    -- Calculate total value of premium products (price > 100) using CASE
    SUM(CASE WHEN price > 100 THEN price ELSE 0 END) as premium_value_case,
    -- Calculate total value of premium products using FILTER
    SUM(price) FILTER (WHERE price > 100) as premium_value_filter,
    -- Calculate total value of regular products (price <= 100) using CASE
    SUM(CASE WHEN price <= 100 THEN price ELSE 0 END) as regular_value_case,
    -- Calculate total value of regular products using FILTER
    SUM(price) FILTER (WHERE price <= 100) as regular_value_filter
FROM ecommerce.products
WHERE price BETWEEN 50 AND 500;

-- Basic GROUP BY syntax
SELECT category_id,
  COUNT(*) as product_count,
  AVG(price)::numeric(10,2) as avg_price
FROM products
GROUP BY category_id;

-- Hierarchical grouping
SELECT country, state, city,
  COUNT(*) as customer_count,
  MIN(created_at) as first_date
FROM customers
GROUP BY country, state, city;

-- GROUP BY with DATE_TRUNC
SELECT 
  DATE_TRUNC('month', order_date) as sales_month,
  COUNT(*) as total_orders,
  COUNT(DISTINCT customer_id) as unique_customers,
  SUM(total_amount)::numeric(10,2) as total_revenue,
  AVG(total_amount)::numeric(10,2) as average_order,
  SUM(total_amount)::numeric(10,2) / COUNT(DISTINCT customer_id)::numeric(10,2) as revenue_per_customer,
  MIN(total_amount)::numeric(10,2) as smallest_order,
  MAX(total_amount)::numeric(10,2) as largest_order,
  STDDEV(total_amount)::numeric(10,2) as order_total_amount_stddev,
  VARIANCE(total_amount)::numeric(10,2) as order_total_amount_variance
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY sales_month DESC;

-- Multiple sort criteria with grouped data
SELECT 
    c.country,
    c.state,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    COUNT(*) as order_count,
    SUM(o.total_amount)::numeric(10,2) as total_revenue
FROM orders o
JOIN customers c USING (customer_id)
GROUP BY c.country, c.state
ORDER BY country, state DESC;

-- Time-based grouping with rollup
SELECT 
  EXTRACT(YEAR FROM order_date) as year,
  EXTRACT(MONTH FROM order_date) as month,
  COUNT(*) as order_count,
  SUM(total_amount)::numeric(10,2) 
  	AS total_revenue,
  COUNT(DISTINCT customer_id) 
  	AS unique_customers
FROM orders
GROUP BY year, month
ORDER BY year, month;

-- Multiple sort criteria with grouped data
SELECT c.country, c.state,
  COUNT(DISTINCT o.customer_id) as unique_customers,
  COUNT(*) as order_count,
  SUM(o.total_amount)::numeric(10,2) as total_revenue
FROM orders o JOIN customers c USING (customer_id)
GROUP BY c.country, c.state
ORDER BY country, state DESC;

-- HAVING clause fundamentals
SELECT order_id as orid,
   COUNT(*) as item_count,
   SUM(unit_price * quantity)::numeric(10,2) as total_price
FROM order_items
GROUP BY order_id
HAVING SUM(unit_price * quantity)::numeric(10,2) > 1000

-- Handling NULLs
SELECT
  AVG(discount_percentage) AS discount_avg,
  SUM(discount_percentage) / COUNT(*) actual_discount_avg
FROM products
WHERE discount_percentage IS NOT NULL
