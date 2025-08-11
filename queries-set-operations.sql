-- Set operation approach: Find all customer and supplier contact details
SELECT supplier_name AS name, country, state,
  contact_email AS email, contact_phone AS phone
FROM suppliers
UNION
SELECT first_name || ' ' || last_name AS name,
  country, state, email, phone
FROM customers;

SELECT first_name, last_name, 'Customer' AS contact_type
FROM customers
UNION
SELECT first_name, last_name, 'Contact' AS contact_type
FROM crm.contacts;

-- Find all VIP customers and recent leads for a special promotion
SELECT DISTINCT first_name, last_name, email
FROM customers c JOIN customer_segment_assignments csa USING (customer_id)
	JOIN customer_segments cs USING (segment_id)
WHERE segment_name = 'VIP'
UNION
SELECT first_name, last_name, email
FROM crm.leads
WHERE interest_level = 'High';

-- Find contacts that exist in both systems (potential duplicates)
SELECT first_name, last_name, email
FROM ecommerce.customers
INTERSECT
SELECT first_name, last_name, email
FROM crm.contacts;

SELECT country 
FROM customers
INTERSECT ALL
SELECT country 
FROM suppliers;

-- Find customers who both ordered products and responded to campaigns
SELECT c.first_name, c.last_name
FROM orders o JOIN customers c USING (customer_id) 
WHERE order_date >= '2025-01-01'
INTERSECT
SELECT c.first_name, c.last_name
FROM crm.campaign_contacts cc JOIN crm.contacts c USING (contact_id)
WHERE last_activity_date >= '2025-01-01';

-- Find CRM contacts who aren't yet e-commerce customers (sales opportunities)
SELECT first_name, last_name, email
FROM crm.contacts
EXCEPT
SELECT first_name, last_name, email
FROM ecommerce.customers;

-- Find customers who haven't placed any orders (EXCEPT)
SELECT customer_id, first_name, last_name
FROM customers
EXCEPT ALL
SELECT customer_id, c.first_name, c.last_name
FROM customers c JOIN orders o USING (customer_id);

SELECT DISTINCT c.campaign_name, ct.email
FROM crm.campaigns c
  LEFT JOIN crm.campaign_contacts cc USING (campaign_id)
  LEFT JOIN crm.contacts ct ON cc.contact_id = ct.contact_id
    AND ct.email = 'michael.davis@example.com'
WHERE ct.contact_id IS NULL;

-- Find products that have been ordered but not reviewed (using EXCEPT)
SELECT product_id FROM ecommerce.order_items
EXCEPT
SELECT product_id FROM ecommerce.reviews;

-- Implicit conversion between numeric types
SELECT product_id, price
FROM ecommerce.products
UNION
SELECT product_id, rating
FROM reviews;

-- SET operations precedence
(SELECT customer_id FROM customer_segment_assignments WHERE segment_id = 1
UNION
SELECT customer_id FROM customer_segment_assignments WHERE segment_id = 3)
INTERSECT
SELECT customer_id FROM orders WHERE order_date >= '2025-01-01';

-- Using parentheses to apply ORDER BY and FETCH to individual queries
(SELECT first_name, last_name FROM ecommerce.customers 
 WHERE country = 'Australia'
 ORDER BY first_name FETCH FIRST 5 ROWS ONLY)
UNION ALL
(SELECT first_name, last_name FROM crm.contacts 
 WHERE country = 'Australia'
 ORDER BY first_name FETCH FIRST 5 ROWS ONLY)
ORDER BY last_name;