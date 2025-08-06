-- PostgreSQL e-commerce database dump for Data Aggregation lecture

-- Create schema
CREATE SCHEMA IF NOT EXISTS ecommerce;

-- Set the search_path to prioritize ecommerce schema
ALTER DATABASE [YOUR-DATABASE-NAME] SET search_path = 'ecommerce', 'public';

-- Regions table (Australia and Brazil)
CREATE TABLE ecommerce.regions (
    region_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    UNIQUE(country, state)
);

-- Customers table
CREATE TABLE ecommerce.customers (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    street_address VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vip_status BOOLEAN DEFAULT FALSE
);

-- Categories table
CREATE TABLE ecommerce.categories (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INTEGER,
    description TEXT,
    CONSTRAINT fk_parent_category FOREIGN KEY (parent_category_id) 
      REFERENCES ecommerce.categories(category_id) 
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Suppliers table (for JOIN examples)
CREATE TABLE ecommerce.suppliers (
    supplier_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    contact_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5)
);

-- Products table
CREATE TABLE ecommerce.products (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INTEGER NOT NULL,
    supplier_id INTEGER,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    discount_percentage NUMERIC(5,2) CHECK (discount_percentage BETWEEN 0 AND 100),
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    weight_kg NUMERIC(8,2),
    dimensions VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_featured BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_category FOREIGN KEY (category_id) 
      REFERENCES ecommerce.categories(category_id) 
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) 
      REFERENCES ecommerce.suppliers(supplier_id) 
      ON UPDATE CASCADE ON DELETE SET NULL
);

-- Orders table
CREATE TABLE ecommerce.orders (
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(50),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) 
      REFERENCES ecommerce.customers(customer_id) 
      ON UPDATE CASCADE ON DELETE CASCADE
);

-- Order items table
CREATE TABLE ecommerce.order_items (
    order_item_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    discount_percentage NUMERIC(5,2) CHECK (discount_percentage BETWEEN 0 AND 100),
    CONSTRAINT fk_order FOREIGN KEY (order_id) 
      REFERENCES ecommerce.orders(order_id) 
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_product FOREIGN KEY (product_id) 
      REFERENCES ecommerce.products(product_id) 
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Payments table
CREATE TABLE ecommerce.payments (
    payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    transaction_id VARCHAR(100),
    CONSTRAINT fk_order_payment FOREIGN KEY (order_id) 
      REFERENCES ecommerce.orders(order_id) 
      ON UPDATE CASCADE ON DELETE CASCADE
);

-- Shipping table (with some NULL values for NULL handling examples)
CREATE TABLE ecommerce.shipping (
    shipping_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    shipping_date TIMESTAMP,
    carrier VARCHAR(50),
    tracking_number VARCHAR(100),
    delivery_date TIMESTAMP,
    shipping_fee NUMERIC(8,2),
    status VARCHAR(20) DEFAULT 'pending',
    CONSTRAINT fk_order_shipping FOREIGN KEY (order_id) 
      REFERENCES ecommerce.orders(order_id) 
      ON UPDATE CASCADE ON DELETE CASCADE
);

-- Product reviews (for aggregation and JOIN examples)
CREATE TABLE ecommerce.reviews (
    review_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_product_review FOREIGN KEY (product_id) 
      REFERENCES ecommerce.products(product_id) 
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_customer_review FOREIGN KEY (customer_id) 
      REFERENCES ecommerce.customers(customer_id) 
      ON UPDATE CASCADE ON DELETE CASCADE
);

-- Promotion campaigns (for subquery examples in Lecture 28)
CREATE TABLE ecommerce.promotions (
    promotion_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    promotion_name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL,
    discount_value NUMERIC(10,2) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    min_purchase_amount NUMERIC(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    CHECK (start_date < end_date)
);

-- Product promotions (many-to-many relationship for JOIN examples)
CREATE TABLE ecommerce.product_promotions (
    product_id INTEGER NOT NULL,
    promotion_id INTEGER NOT NULL,
    PRIMARY KEY (product_id, promotion_id),
    CONSTRAINT fk_product_promo FOREIGN KEY (product_id) 
      REFERENCES ecommerce.products(product_id) 
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_promotion_promo FOREIGN KEY (promotion_id) 
      REFERENCES ecommerce.promotions(promotion_id) 
      ON UPDATE CASCADE ON DELETE CASCADE
);

-- Customer segments (for set operations in Lecture 28)
CREATE TABLE ecommerce.customer_segments (
    segment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    segment_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer segment assignments (many-to-many for set operation examples)
CREATE TABLE ecommerce.customer_segment_assignments (
    customer_id INTEGER NOT NULL,
    segment_id INTEGER NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, segment_id),
    CONSTRAINT fk_customer_segment FOREIGN KEY (customer_id) 
      REFERENCES ecommerce.customers(customer_id) 
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_segment_customer FOREIGN KEY (segment_id) 
      REFERENCES ecommerce.customer_segments(segment_id) 
      ON UPDATE CASCADE ON DELETE CASCADE
);

-- Add foreign key constraints to link tables
ALTER TABLE ecommerce.customers
ADD CONSTRAINT fk_region FOREIGN KEY (country, state) 
REFERENCES ecommerce.regions(country, state) 
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ecommerce.suppliers
ADD CONSTRAINT fk_supplier_region FOREIGN KEY (country, state) 
REFERENCES ecommerce.regions(country, state) 
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Insert regions (Australia and Brazil)
INSERT INTO ecommerce.regions (country, state) VALUES
('Australia', 'New South Wales'),
('Australia', 'Victoria'),
('Australia', 'Queensland'),
('Australia', 'Western Australia'),
('Australia', 'South Australia'),
('Australia', 'Tasmania'),
('Brazil', 'São Paulo'),
('Brazil', 'Rio de Janeiro'),
('Brazil', 'Minas Gerais'),
('Brazil', 'Bahia'),
('Brazil', 'Pernambuco');

-- Insert customers
INSERT INTO ecommerce.customers (first_name, last_name, email, phone, country, state, city, postal_code, street_address, vip_status) VALUES
-- Australian customers
('James', 'Smith', 'james.smith@example.com', '+61 2 9876 5432', 'Australia', 'New South Wales', 'Sydney', '2000', '123 George St', TRUE),
('Emily', 'Johnson', 'emily.johnson@example.com', '+61 2 8765 4321', 'Australia', 'New South Wales', 'Newcastle', '2300', '45 Hunter St', FALSE),
('William', 'Brown', 'william.brown@example.com', '+61 3 9123 4567', 'Australia', 'Victoria', 'Melbourne', '3000', '78 Collins St', TRUE),
('Olivia', 'Jones', 'olivia.jones@example.com', '+61 3 8912 3456', 'Australia', 'Victoria', 'Geelong', '3220', '90 Ryrie St', FALSE),
('Thomas', 'Wilson', 'thomas.wilson@example.com', '+61 7 3456 7890', 'Australia', 'Queensland', 'Brisbane', '4000', '34 Queen St', FALSE),
('Charlotte', 'Taylor', 'charlotte.taylor@example.com', '+61 7 3567 8901', 'Australia', 'Queensland', 'Gold Coast', '4217', '56 Cavill Ave', TRUE),
('Benjamin', 'Anderson', 'benjamin.anderson@example.com', '+61 8 9234 5678', 'Australia', 'Western Australia', 'Perth', '6000', '78 St Georges Tce', FALSE),
('Amelia', 'Lee', 'amelia.lee@example.com', '+61 8 6234 5678', 'Australia', 'Western Australia', 'Fremantle', '6160', '12 Market St', FALSE),
-- Brazilian customers
('Pedro', 'Silva', 'pedro.silva@example.com', '+55 11 91234 5678', 'Brazil', 'São Paulo', 'São Paulo', '01310-200', 'Av. Paulista, 1000', TRUE),
('Ana', 'Santos', 'ana.santos@example.com', '+55 11 92345 6789', 'Brazil', 'São Paulo', 'Campinas', '13015-904', 'Rua 13 de Maio, 123', FALSE),
('Lucas', 'Oliveira', 'lucas.oliveira@example.com', '+55 21 93456 7890', 'Brazil', 'Rio de Janeiro', 'Rio de Janeiro', '22031-001', 'Av. Atlântica, 500', TRUE),
('Julia', 'Pereira', 'julia.pereira@example.com', '+55 21 94567 8901', 'Brazil', 'Rio de Janeiro', 'Niterói', '24220-031', 'Rua Moreira César, 45', FALSE),
('Matheus', 'Costa', 'matheus.costa@example.com', '+55 31 95678 9012', 'Brazil', 'Minas Gerais', 'Belo Horizonte', '30110-013', 'Rua da Bahia, 573', FALSE),
('Isabella', 'Almeida', 'isabella.almeida@example.com', '+55 31 96789 0123', 'Brazil', 'Minas Gerais', 'Juiz de Fora', '36016-000', 'Av. Rio Branco, 3000', TRUE);

-- Insert some customers without state (NULL handling examples)
INSERT INTO ecommerce.customers (first_name, last_name, email, phone, country, city, postal_code, street_address) VALUES
('David', 'Miller', 'david.miller@example.com', '+61 4 1234 5678', 'Australia', 'Adelaide', '5000', '45 Rundle Mall'),
('Sarah', 'Cooper', 'sarah.cooper@example.com', '+61 4 2345 6789', 'Australia', 'Hobart', '7000', '23 Murray St'),
('Gabriel', 'Rocha', 'gabriel.rocha@example.com', '+55 12 97890 1234', 'Brazil', 'Santos', '11010-000', 'Rua João Pessoa, 150');

-- Insert categories with parent-child relationships
INSERT INTO ecommerce.categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories');

INSERT INTO ecommerce.categories (category_name, parent_category_id, description) VALUES
('Smartphones', 1, 'Mobile phones and accessories'),
('Laptops', 1, 'Portable computers'),
('Audio', 1, 'Headphones, speakers and audio equipment');

INSERT INTO ecommerce.categories (category_name, description) VALUES
('Clothing', 'Apparel and fashion items');

INSERT INTO ecommerce.categories (category_name, parent_category_id, description) VALUES
('Men''s Clothing', 5, 'Clothing for men'),
('Women''s Clothing', 5, 'Clothing for women');

INSERT INTO ecommerce.categories (category_name, description) VALUES
('Home & Garden', 'Home decor and garden supplies');

INSERT INTO ecommerce.categories (category_name, parent_category_id, description) VALUES
('Furniture', 8, 'Indoor and outdoor furniture'),
('Kitchen', 8, 'Kitchen appliances and accessories');

INSERT INTO ecommerce.categories (category_name, description) VALUES
('Books', 'Books and publications');

-- Insert suppliers
INSERT INTO ecommerce.suppliers (supplier_name, country, state, contact_name, contact_email, contact_phone, rating) VALUES
-- Australian suppliers
('Aussie Tech Distributors', 'Australia', 'New South Wales', 'Michael Thompson', 'michael@aussietech.com.au', '+61 2 9123 4567', 4),
('Melbourne Electronics Corp', 'Australia', 'Victoria', 'Sophia Williams', 'sophia@melbelectronics.com.au', '+61 3 8765 4321', 5),
('Queensland Apparel', 'Australia', 'Queensland', 'Ethan Robinson', 'ethan@qldapparel.com.au', '+61 7 3456 7890', 3),
-- Brazilian suppliers
('São Paulo Eletrônicos', 'Brazil', 'São Paulo', 'Rafael Gomes', 'rafael@speletronicos.com.br', '+55 11 91234 5678', 4),
('Rio Fashion House', 'Brazil', 'Rio de Janeiro', 'Camila Dias', 'camila@riofashion.com.br', '+55 21 92345 6789', 5);

-- Insert supplier without state (NULL handling example)
INSERT INTO ecommerce.suppliers (supplier_name, country, contact_name, contact_email, contact_phone, rating) VALUES
('Global Books Ltd', 'United Kingdom', 'James Wilson', 'james@globalbooks.co.uk', '+44 20 7123 4567', 4);

-- Insert products
INSERT INTO ecommerce.products (product_name, category_id, supplier_id, price, discount_percentage, stock_quantity, weight_kg, dimensions, is_featured) VALUES
-- Smartphones
('Galaxy S24 Ultra', 2, 1, 1899.99, 5.00, 50, 0.23, '165 x 77 x 8.5 mm', TRUE),
('iPhone 15 Pro', 2, 1, 1849.99, NULL, 45, 0.22, '150 x 72 x 8.2 mm', TRUE),
('Google Pixel 8', 2, 4, 1299.99, 10.00, 30, 0.20, '155 x 73 x 8.3 mm', FALSE),
('Xiaomi 13', 2, 4, 899.99, 15.00, 40, 0.18, '152 x 70 x 7.9 mm', FALSE),
-- Laptops
('MacBook Pro 16"', 3, 1, 3499.99, NULL, 20, 2.20, '355 x 248 x 16 mm', TRUE),
('Dell XPS 15', 3, 2, 2799.99, 7.50, 25, 1.80, '344 x 230 x 15 mm', FALSE),
('HP Spectre x360', 3, 2, 2499.99, 12.00, 15, 1.70, '335 x 225 x 14 mm', FALSE),
-- Audio
('Sony WH-1000XM5', 4, 2, 499.99, 5.00, 60, 0.25, '180 x 200 x 80 mm', TRUE),
('Bose QuietComfort', 4, 1, 449.99, NULL, 40, 0.24, '170 x 190 x 75 mm', FALSE),
('Apple AirPods Pro', 4, 1, 399.99, 8.00, 75, 0.06, '45 x 60 x 21 mm', TRUE),
-- Men's Clothing
('Men''s Cotton Shirt', 6, 3, 59.99, 10.00, 100, 0.20, NULL, FALSE),
('Men''s Slim Jeans', 6, 5, 89.99, 5.00, 80, 0.40, NULL, FALSE),
('Men''s Casual Jacket', 6, 3, 129.99, NULL, 50, 0.70, NULL, TRUE),
-- Women's Clothing
('Women''s Summer Dress', 7, 5, 79.99, 15.00, 90, 0.25, NULL, TRUE),
('Women''s Leather Handbag', 7, 5, 159.99, NULL, 40, 0.50, NULL, TRUE),
('Women''s Yoga Pants', 7, 3, 69.99, 10.00, 120, 0.30, NULL, FALSE),
-- Furniture
('Scandinavian Coffee Table', 9, NULL, 299.99, NULL, 15, 18.00, '120 x 60 x 45 cm', FALSE),
('Modern Sofa Set', 9, NULL, 1299.99, 8.00, 8, 85.00, '280 x 95 x 85 cm', TRUE),
-- Kitchen
('Stainless Steel Cookware Set', 10, NULL, 249.99, 12.00, 25, 5.00, '50 x 30 x 20 cm', FALSE),
('Smart Coffee Maker', 10, 2, 189.99, 5.00, 35, 3.00, '25 x 20 x 35 cm', TRUE),
-- Books
('The Great Australian Novel', 10, 6, 24.99, NULL, 150, 0.40, '23 x 15 x 3 cm', FALSE),
('Modern Cooking: Brazilian Recipes', 10, 6, 34.99, 8.00, 85, 0.60, '25 x 20 x 2 cm', TRUE),
('Business Leadership', 10, 6, 29.99, 5.00, 100, 0.50, '21 x 14 x 2.5 cm', FALSE);

-- Insert orders with varying dates for time-based analysis
INSERT INTO ecommerce.orders (customer_id, order_date, status, total_amount, payment_method) VALUES
-- 2024 Orders
('1', '2024-10-15 09:30:00', 'completed', 1899.99, 'Credit Card'),
('3', '2024-10-20 14:45:00', 'completed', 3499.99, 'PayPal'),
('5', '2024-11-05 11:15:00', 'completed', 129.99, 'Credit Card'),
('7', '2024-11-12 16:20:00', 'completed', 449.99, 'Debit Card'),
('9', '2024-11-28 10:10:00', 'completed', 1299.99, 'Bank Transfer'),
('11', '2024-12-03 15:30:00', 'completed', 499.99, 'Credit Card'),
('13', '2024-12-18 12:45:00', 'completed', 89.99, 'PayPal'),
-- 2025 Q1 Orders
('2', '2025-01-05 08:55:00', 'completed', 399.99, 'Credit Card'),
('4', '2025-01-15 13:40:00', 'completed', 159.99, 'PayPal'),
('6', '2025-01-27 09:25:00', 'completed', 2799.99, 'Bank Transfer'),
('8', '2025-02-08 14:15:00', 'completed', 79.99, 'Credit Card'),
('10', '2025-02-19 10:50:00', 'completed', 249.99, 'Debit Card'),
('12', '2025-03-01 15:05:00', 'completed', 59.99, 'PayPal'),
('14', '2025-03-12 11:30:00', 'completed', 1849.99, 'Credit Card'),
-- Q2 Orders
('1', '2025-04-02 09:15:00', 'completed', 499.99, 'Credit Card'),
('5', '2025-04-14 14:30:00', 'completed', 89.99, 'PayPal'),
('9', '2025-04-25 10:45:00', 'processing', 2499.99, 'Bank Transfer'),
('13', '2025-05-06 16:00:00', 'processing', 34.99, 'Credit Card'),
('2', '2025-05-17 11:20:00', 'processing', 69.99, 'Debit Card'),
('6', '2025-05-28 15:35:00', 'processing', 299.99, 'PayPal'),
-- Orders with NULL payment method (for NULL handling examples)
('10', '2025-06-05 10:10:00', 'pending', 129.99, NULL),
('14', '2025-06-12 16:25:00', 'pending', 24.99, NULL);

-- Insert order items
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
-- Order 1
(1, 1, 1, 1899.99, 0),
-- Order 2
(2, 5, 1, 3499.99, 0),
-- Order 3
(3, 13, 1, 129.99, 0),
-- Order 4
(4, 9, 1, 449.99, 0),
-- Order 5
(5, 18, 1, 1299.99, 0),
-- Order 6
(6, 8, 1, 499.99, 0),
-- Order 7
(7, 12, 1, 89.99, 0),
-- Order 8
(8, 10, 1, 399.99, 0),
-- Order 9
(9, 15, 1, 159.99, 0),
-- Order 10
(10, 6, 1, 2799.99, 0),
-- Order 11
(11, 14, 1, 79.99, 0),
-- Order 12
(12, 19, 1, 249.99, 0),
-- Order 13
(13, 11, 1, 59.99, 0),
-- Order 14
(14, 2, 1, 1849.99, 0),
-- Order 15 (multiple items)
(15, 8, 1, 499.99, 0),
(15, 10, 1, 399.99, 0),
-- Order 16
(16, 12, 1, 89.99, 0),
-- Order 17
(17, 7, 1, 2499.99, 0),
-- Order 18
(18, 22, 1, 34.99, 0),
-- Order 19
(19, 16, 1, 69.99, 0),
-- Order 20
(20, 17, 1, 299.99, 0),
-- Order 21
(21, 13, 1, 129.99, 0),
-- Order 22
(22, 21, 1, 24.99, 0);

-- Insert payments
INSERT INTO ecommerce.payments (order_id, payment_date, amount, payment_method, status, transaction_id) VALUES
-- Completed payments
(1, '2024-10-15 09:35:00', 1899.99, 'Credit Card', 'completed', 'TXN-001-2024'),
(2, '2024-10-20 14:50:00', 3499.99, 'PayPal', 'completed', 'TXN-002-2024'),
(3, '2024-11-05 11:20:00', 129.99, 'Credit Card', 'completed', 'TXN-003-2024'),
(4, '2024-11-12 16:25:00', 449.99, 'Debit Card', 'completed', 'TXN-004-2024'),
(5, '2024-11-28 10:15:00', 1299.99, 'Bank Transfer', 'completed', 'TXN-005-2024'),
(6, '2024-12-03 15:35:00', 499.99, 'Credit Card', 'completed', 'TXN-006-2024'),
(7, '2024-12-18 12:50:00', 89.99, 'PayPal', 'completed', 'TXN-007-2024'),
(8, '2025-01-05 09:00:00', 399.99, 'Credit Card', 'completed', 'TXN-001-2025'),
(9, '2025-01-15 13:45:00', 159.99, 'PayPal', 'completed', 'TXN-002-2025'),
(10, '2025-01-27 09:30:00', 2799.99, 'Bank Transfer', 'completed', 'TXN-003-2025'),
(11, '2025-02-08 14:20:00', 79.99, 'Credit Card', 'completed', 'TXN-004-2025'),
(12, '2025-02-19 10:55:00', 249.99, 'Debit Card', 'completed', 'TXN-005-2025'),
(13, '2025-03-01 15:10:00', 59.99, 'PayPal', 'completed', 'TXN-006-2025'),
(14, '2025-03-12 11:35:00', 1849.99, 'Credit Card', 'completed', 'TXN-007-2025'),
(15, '2025-04-02 09:20:00', 499.99, 'Credit Card', 'completed', 'TXN-008-2025'),
(16, '2025-04-14 14:35:00', 89.99, 'PayPal', 'completed', 'TXN-009-2025'),
-- Processing payments
(17, '2025-04-25 10:50:00', 2499.99, 'Bank Transfer', 'processing', 'TXN-010-2025'),
(18, '2025-05-06 16:05:00', 34.99, 'Credit Card', 'processing', 'TXN-011-2025'),
(19, '2025-05-17 11:25:00', 59.99, 'Debit Card', 'processing', 'TXN-012-2025'),
(20, '2025-05-28 15:40:00', 249.99, 'PayPal', 'processing', 'TXN-013-2025');
-- Orders 21 and 22 don't have payments (for NULL handling examples)

-- Insert shipping details (including some NULL values)
INSERT INTO ecommerce.shipping (order_id, shipping_date, carrier, tracking_number, delivery_date, shipping_fee, status) VALUES
-- Completed deliveries
(1, '2024-10-16 10:00:00', 'Australia Post', 'AP100023456', '2024-10-18 14:30:00', 15.00, 'delivered'),
(2, '2024-10-21 09:30:00', 'DHL Express', 'DHL200034567', '2024-10-23 11:45:00', 25.00, 'delivered'),
(3, '2024-11-06 11:00:00', 'Australia Post', 'AP100034567', '2024-11-09 16:20:00', 10.00, 'delivered'),
(4, '2024-11-13 14:00:00', 'Startrack', 'ST100045678', '2024-11-15 12:30:00', 12.50, 'delivered'),
(5, '2024-11-29 09:00:00', 'DHL Express', 'DHL200045678', '2024-12-02 15:15:00', 30.00, 'delivered'),
(6, '2024-12-04 10:30:00', 'Australia Post', 'AP100056789', '2024-12-07 13:45:00', 15.00, 'delivered'),
(7, '2024-12-19 13:00:00', 'Startrack', 'ST100067890', '2024-12-21 11:20:00', 10.00, 'delivered'),
(8, '2025-01-06 11:30:00', 'Australia Post', 'AP200012345', '2025-01-09 14:40:00', 12.50, 'delivered'),
(9, '2025-01-16 10:00:00', 'Correios', 'BR100023456', '2025-01-20 16:30:00', 15.00, 'delivered'),
(10, '2025-01-28 09:00:00', 'DHL Express', 'DHL300023456', '2025-01-31 15:10:00', 25.00, 'delivered'),
(11, '2025-02-09 13:30:00', 'Correios', 'BR100034567', '2025-02-14 12:15:00', 12.00, 'delivered'),
(12, '2025-02-20 11:00:00', 'Startrack', 'ST200012345', '2025-02-22 17:30:00', 15.00, 'delivered'),
(13, '2025-03-02 14:30:00', 'Australia Post', 'AP200023456', '2025-03-05 11:45:00', 10.00, 'delivered'),
(14, '2025-03-13 10:00:00', 'DHL Express', 'DHL300034567', '2025-03-15 14:20:00', 20.00, 'delivered'),
-- Processing shipments
(15, '2025-04-03 13:00:00', 'Australia Post', 'AP200034567', NULL, 12.50, 'in transit'),
(16, '2025-04-15 11:30:00', 'Correios', 'BR100045678', NULL, 15.00, 'in transit'),
-- Pending shipments with some NULL values
(17, NULL, 'DHL Express', NULL, NULL, 25.00, 'processing'),
(18, NULL, 'Correios', NULL, NULL, 10.00, 'processing'),
(19, NULL, 'Australia Post', NULL, NULL, 12.50, 'processing'),
(20, NULL, 'Startrack', NULL, NULL, 15.00, 'processing');
-- Orders 21 and 22 don't have shipping details (for NULL handling examples)

-- Insert reviews
INSERT INTO ecommerce.reviews (product_id, customer_id, rating, review_text, review_date, is_verified) VALUES
-- Smartphone reviews
(1, 3, 5, 'Amazing camera and battery life. Best phone I''ve ever owned.', '2024-11-15 14:30:00', TRUE),
(1, 6, 4, 'Great phone overall, but a bit pricey.', '2024-12-05 09:45:00', TRUE),
(1, 10, 5, 'Incredible performance and display quality.', '2025-01-20 16:15:00', TRUE),
(2, 1, 5, 'Perfect integration with my other Apple devices.', '2025-03-25 11:30:00', TRUE),
(2, 9, 4, 'Beautiful design but battery could be better.', '2025-04-10 15:20:00', TRUE),
(3, 5, 3, 'Good camera but some software glitches.', '2024-12-12 10:10:00', TRUE),
(3, 11, 4, 'Clean Android experience, very responsive.', '2025-02-05 14:50:00', TRUE),
(4, 8, 4, 'Great value for the features offered.', '2025-01-18 13:25:00', TRUE),
-- Laptop reviews
(5, 2, 5, 'Powerful and elegant. Perfect for creative work.', '2025-01-08 16:40:00', TRUE),
(5, 7, 5, 'Exceptional build quality and performance.', '2025-02-15 10:30:00', TRUE),
(6, 4, 4, 'Great screen and keyboard, battery life is decent.', '2025-03-05 09:15:00', TRUE),
(7, 13, 3, 'Good convertible laptop but fans can get noisy.', '2025-05-10 14:20:00', FALSE),
-- Audio product reviews
(8, 3, 5, 'Best noise cancellation on the market.', '2025-04-08 15:10:00', TRUE),
(9, 6, 4, 'Very comfortable for long listening sessions.', '2024-12-15 11:30:00', TRUE),
(10, 1, 5, 'Perfect integration with my iPhone.', '2025-03-18 09:45:00', TRUE),
-- Clothing reviews
(11, 5, 4, 'Great quality cotton, comfortable fit.', '2024-11-20 14:15:00', TRUE),
(12, 13, 5, 'Perfect fit and very stylish.', '2025-01-08 16:30:00', TRUE),
(13, 3, 4, 'Good for mild weather, stylish design.', '2024-12-20 10:20:00', TRUE),
(14, 6, 5, 'Beautiful design and comfortable fabric.', '2025-02-28 15:40:00', TRUE),
(15, 9, 5, 'Excellent craftsmanship, looks elegant.', '2025-04-05 11:25:00', TRUE),
-- Reviews with NULL text (for NULL handling examples)
(16, 12, 4, NULL, '2025-05-15 09:30:00', FALSE),
(17, 10, 3, NULL, '2025-04-20 14:15:00', FALSE);

-- Insert promotions
INSERT INTO ecommerce.promotions (promotion_name, description, discount_type, discount_value, start_date, end_date, min_purchase_amount, is_active) VALUES
('Summer Sale', 'Big discounts on summer essentials', 'percentage', 15.00, '2025-06-01 00:00:00', '2025-07-31 23:59:59', 50.00, TRUE),
('Winter Clearance', 'Clearance items for winter', 'percentage', 20.00, '2025-01-15 00:00:00', '2025-02-15 23:59:59', 0.00, FALSE),
('Tech Bonanza', 'Special discounts on electronics', 'percentage', 10.00, '2025-05-01 00:00:00', '2025-05-31 23:59:59', 100.00, TRUE),
('Free Shipping', 'Free shipping on all orders', 'fixed', 0.00, '2025-04-01 00:00:00', '2025-04-30 23:59:59', 75.00, FALSE),
('New Customer Discount', 'Special discount for first-time buyers', 'percentage', 5.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 0.00, TRUE);

-- Insert product promotions
INSERT INTO ecommerce.product_promotions (product_id, promotion_id) VALUES
(1, 3), -- Galaxy S24 Ultra in Tech Bonanza
(2, 3), -- iPhone 15 Pro in Tech Bonanza
(5, 3), -- MacBook Pro in Tech Bonanza
(6, 3), -- Dell XPS in Tech Bonanza
(14, 1), -- Women's Summer Dress in Summer Sale
(16, 1), -- Women's Yoga Pants in Summer Sale
(11, 2), -- Men's Cotton Shirt in Winter Clearance
(13, 2), -- Men's Casual Jacket in Winter Clearance
(8, 3), -- Sony WH-1000XM5 in Tech Bonanza
(10, 3); -- Apple AirPods Pro in Tech Bonanza

-- Insert customer segments
INSERT INTO ecommerce.customer_segments (segment_name, description) VALUES
('VIP', 'High-value customers with premium status'),
('New Customers', 'Customers who joined in the last 90 days'),
('Tech Enthusiasts', 'Customers who frequently purchase electronics'),
('Fashion Lovers', 'Customers who frequently purchase clothing items'),
('Dormant', 'Customers who haven''t made a purchase in the last 6 months');

-- Insert customer segment assignments
INSERT INTO ecommerce.customer_segment_assignments (customer_id, segment_id, assigned_date) VALUES
-- VIP Customers
(1, 1, '2024-12-01 00:00:00'),
(3, 1, '2024-12-01 00:00:00'),
(6, 1, '2024-12-01 00:00:00'),
(9, 1, '2024-12-01 00:00:00'),
(14, 1, '2024-12-01 00:00:00'),
-- New Customers (those who joined recently)
(15, 2, '2025-04-01 00:00:00'),
(16, 2, '2025-04-01 00:00:00'),
(17, 2, '2025-04-01 00:00:00'),
-- Tech Enthusiasts
(1, 3, '2025-01-15 00:00:00'),
(2, 3, '2025-01-15 00:00:00'),
(5, 3, '2025-01-15 00:00:00'),
(7, 3, '2025-01-15 00:00:00'),
(9, 3, '2025-01-15 00:00:00'),
-- Fashion Lovers
(4, 4, '2025-02-10 00:00:00'),
(6, 4, '2025-02-10 00:00:00'),
(8, 4, '2025-02-10 00:00:00'),
(10, 4, '2025-02-10 00:00:00'),
(13, 4, '2025-02-10 00:00:00'),
-- Dormant Customers
(12, 5, '2025-03-01 00:00:00'),
(15, 5, '2025-03-01 00:00:00');

-- Create indexes for improved performance
CREATE INDEX idx_customers_country_state ON ecommerce.customers(country, state);
CREATE INDEX idx_products_category_id ON ecommerce.products(category_id);
CREATE INDEX idx_products_supplier_id ON ecommerce.products(supplier_id);
CREATE INDEX idx_products_price ON ecommerce.products(price);
CREATE INDEX idx_orders_customer_id ON ecommerce.orders(customer_id);
CREATE INDEX idx_orders_order_date ON ecommerce.orders(order_date);
CREATE INDEX idx_orders_status ON ecommerce.orders(status);
CREATE INDEX idx_order_items_order_id ON ecommerce.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON ecommerce.order_items(product_id);
CREATE INDEX idx_payments_order_id ON ecommerce.payments(order_id);
CREATE INDEX idx_shipping_order_id ON ecommerce.shipping(order_id);
CREATE INDEX idx_reviews_product_id ON ecommerce.reviews(product_id);
CREATE INDEX idx_reviews_customer_id ON ecommerce.reviews(customer_id);
CREATE INDEX idx_reviews_rating ON ecommerce.reviews(rating);

-- complementary data
-- Add more orders with multiple items, varying quantities, and discounts
-- Additional orders for Australian customers
INSERT INTO ecommerce.orders (customer_id, order_date, status, total_amount, payment_method) VALUES
(1, '2024-02-10 10:15:00', 'completed', 2475.97, 'Credit Card'),
(2, '2024-03-05 13:20:00', 'completed', 529.98, 'PayPal'),
(3, '2024-03-15 09:45:00', 'completed', 979.97, 'Credit Card'),
(4, '2024-03-22 16:30:00', 'completed', 319.97, 'Bank Transfer'),
(5, '2024-04-03 11:25:00', 'completed', 609.98, 'Debit Card'),
(6, '2024-04-10 14:50:00', 'completed', 1299.98, 'Credit Card'),
(7, '2024-04-18 08:40:00', 'processing', 714.98, 'PayPal'),
(8, '2024-04-25 15:10:00', 'processing', 239.97, 'Credit Card');

-- Additional orders for Brazilian customers
INSERT INTO ecommerce.orders (customer_id, order_date, status, total_amount, payment_method) VALUES
(9, '2024-02-15 11:05:00', 'completed', 1124.98, 'Bank Transfer'),
(10, '2024-03-08 14:35:00', 'completed', 509.98, 'Credit Card'),
(11, '2024-03-19 10:20:00', 'completed', 749.98, 'PayPal'),
(12, '2024-04-06 13:15:00', 'completed', 364.97, 'Debit Card'),
(13, '2024-04-15 09:30:00', 'processing', 459.98, 'Credit Card'),
(14, '2024-04-22 16:45:00', 'processing', 649.99, 'Bank Transfer');

-- Order items for order #23 (customer 1)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(23, 5, 1, 1799.99, 0),
(23, 8, 1, 479.99, 5),
(23, 10, 1, 199.99, 0);

-- Order items for order #24 (customer 2)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(24, 12, 2, 84.99, 0),
(24, 16, 3, 64.99, 10),
(24, 21, 2, 24.99, 0);

-- Order items for order #25 (customer 3)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(25, 6, 1, 799.99, 0),
(25, 9, 1, 179.99, 0);

-- Order items for order #26 (customer 4)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(26, 11, 2, 59.99, 0),
(26, 14, 1, 79.99, 15),
(26, 22, 3, 34.99, 8);

-- Order items for order #27 (customer 5)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(27, 7, 1, 549.99, 0),
(27, 10, 1, 59.99, 0);

-- Order items for order #28 (customer 6)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(28, 1, 1, 949.99, 10),
(28, 13, 1, 129.99, 0),
(28, 18, 1, 299.99, 5);

-- Order items for order #29 (customer 7)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(29, 4, 1, 449.99, 15),
(29, 8, 1, 294.99, 0);

-- Order items for order #30 (customer 8)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(30, 15, 1, 159.99, 0),
(30, 16, 2, 39.99, 0);

-- Order items for order #31 (customer 9)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(31, 5, 1, 874.99, 0),
(31, 19, 1, 249.99, 0);

-- Order items for order #32 (customer 10)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(32, 8, 1, 479.99, 5),
(32, 20, 1, 29.99, 0);

-- Order items for order #33 (customer 11)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(33, 6, 1, 679.99, 10),
(33, 10, 2, 34.99, 0);

-- Order items for order #34 (customer 12)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(34, 11, 2, 59.99, 5),
(34, 16, 3, 69.99, 10),
(34, 22, 1, 34.99, 0);

-- Order items for order #35 (customer 13)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(35, 12, 2, 89.99, 0),
(35, 14, 2, 139.99, 10);

-- Order items for order #36 (customer 14)
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price, discount_percentage) VALUES
(36, 2, 1, 649.99, 0);
