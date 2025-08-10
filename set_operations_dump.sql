-- Create CRM schema
CREATE SCHEMA IF NOT EXISTS crm;

-- Create leads table
CREATE TABLE crm.leads (
    lead_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    country VARCHAR(50),
    state VARCHAR(50),
    source VARCHAR(100),
    status VARCHAR(50), -- e.g., New, Qualified, Converted
    assigned_to VARCHAR(100),
    interest_level VARCHAR(20), -- High, Medium, Low
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create companies table
CREATE TABLE crm.companies (
    company_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    main_contact_email VARCHAR(100),
    phone VARCHAR(20),
    website VARCHAR(255),
    employee_count INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create contacts table
CREATE TABLE crm.contacts (
    contact_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    company_id INTEGER REFERENCES crm.companies(company_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    country VARCHAR(50),
    state VARCHAR(50),
    contact_type VARCHAR(50), -- e.g., Prospect, Customer, Partner
    status VARCHAR(20), -- e.g., Active, Inactive
    last_contact_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create interactions table
CREATE TABLE crm.interactions (
    interaction_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    contact_id INTEGER REFERENCES crm.contacts(contact_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    interaction_type VARCHAR(50), -- e.g., Email, Call, Meeting
    interaction_date TIMESTAMP NOT NULL,
    notes TEXT,
    follow_up_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create campaigns table
CREATE TABLE crm.campaigns (
    campaign_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    campaign_name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    status VARCHAR(50),
    budget NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create campaign_contacts junction table
CREATE TABLE crm.campaign_contacts (
    campaign_id INTEGER REFERENCES crm.campaigns(campaign_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    contact_id INTEGER REFERENCES crm.contacts(contact_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    status VARCHAR(50), -- e.g., Sent, Opened, Clicked, Converted
    last_activity_date TIMESTAMP,
    PRIMARY KEY (campaign_id, contact_id)
);

-- Insert sample data into companies
-- Include some that match with ecommerce suppliers
INSERT INTO crm.companies (company_name, industry, country, state, city, main_contact_email, phone, website, employee_count) VALUES
-- Matching with ecommerce suppliers (for INTERSECT examples)
('Aussie Tech Distributors', 'Technology', 'Australia', 'New South Wales', 'Sydney', 'michael@aussietech.com.au', '+61 2 9123 4567', 'www.aussietech.com.au', 150),
('Melbourne Electronics Corp', 'Electronics', 'Australia', 'Victoria', 'Melbourne', 'sophia@melbelectronics.com.au', '+61 3 8765 4321', 'www.melbelectronics.com.au', 200),
('São Paulo Eletrônicos', 'Electronics', 'Brazil', 'São Paulo', 'São Paulo', 'rafael@speletronicos.com.br', '+55 11 91234 5678', 'www.speletronicos.com.br', 175),
-- Unique to CRM system (for EXCEPT examples)
('Digital Solutions Ltd', 'Software', 'Australia', 'New South Wales', 'Sydney', 'info@digitalsolutions.com.au', '+61 2 9876 5432', 'www.digitalsolutions.com.au', 85),
('Green Life Products', 'Health & Wellness', 'Australia', 'Victoria', 'Melbourne', 'contact@greenlife.com.au', '+61 3 8765 1234', 'www.greenlife.com.au', 45),
('Tech Innovators', 'Technology', 'Brazil', 'São Paulo', 'São Paulo', 'info@techinnovators.com.br', '+55 11 87654 3210', 'www.techinnovators.com.br', 120),
('Financial Systems Corp', 'Finance', 'Australia', 'New South Wales', 'Sydney', 'contact@finsystems.com.au', '+61 2 1234 5678', 'www.finsystems.com.au', 200),
('Ecotex Brasil', 'Textiles', 'Brazil', 'Rio de Janeiro', 'Rio de Janeiro', 'info@ecotex.com.br', '+55 21 98765 4321', 'www.ecotex.com.br', 150),
('Queensland Renewables', 'Energy', 'Australia', 'Queensland', 'Brisbane', 'contact@qldrenewables.com.au', '+61 7 2345 6789', 'www.qldrenewables.com.au', 75),
('Minas Tech Group', 'Technology', 'Brazil', 'Minas Gerais', 'Belo Horizonte', 'info@minastech.com.br', '+55 31 87654 3210', 'www.minastech.com.br', 95);

-- Insert sample data into contacts
-- Include some contacts that match with ecommerce customers for INTERSECT examples
INSERT INTO crm.contacts (company_id, first_name, last_name, email, phone, address, country, state, contact_type, status, last_contact_date) VALUES
-- Matching with ecommerce customers (for INTERSECT examples)
(1, 'James', 'Smith', 'james.smith@example.com', '+61 2 9876 5432', '123 George St, Sydney', 'Australia', 'New South Wales', 'Customer', 'Active', '2025-03-15 14:30:00'),
(1, 'Emily', 'Johnson', 'emily.johnson@example.com', '+61 2 8765 4321', '45 Hunter St, Newcastle', 'Australia', 'New South Wales', 'Customer', 'Active', '2025-02-20 11:15:00'),
(2, 'William', 'Brown', 'william.brown@example.com', '+61 3 9123 4567', '78 Collins St, Melbourne', 'Australia', 'Victoria', 'Customer', 'Active', '2025-03-10 09:45:00'),
(3, 'Pedro', 'Silva', 'pedro.silva@example.com', '+55 11 91234 5678', 'Av. Paulista, 1000, São Paulo', 'Brazil', 'São Paulo', 'Customer', 'Active', '2025-01-25 16:20:00'),
-- Unique to CRM system (for EXCEPT examples)
(4, 'Michael', 'Davis', 'michael.davis@example.com', '+61 2 1234 5678', '45 York St, Sydney', 'Australia', 'New South Wales', 'Lead', 'Active', '2025-04-05 10:30:00'),
(4, 'Sophia', 'Martinez', 'sophia.martinez@example.com', '+55 11 98765 4321', 'Rua Augusta, 500, São Paulo', 'Brazil', 'São Paulo', 'Lead', 'Active', '2025-03-28 14:15:00'),
(5, 'Robert', 'Thompson', 'robert.thompson@example.com', '+61 3 8765 4321', '22 Brunswick St, Melbourne', 'Australia', 'Victoria', 'Partner', 'Active', '2025-04-10 09:00:00'),
(NULL, 'Emma', 'Garcia', 'emma.garcia@example.com', '+55 21 91234 5678', 'Av. Atlantica, 100, Rio de Janeiro', 'Brazil', 'Rio de Janeiro', 'Customer', 'Inactive', '2025-02-15 11:30:00'),
(9, 'Daniel', 'Wilson', 'daniel.wilson@example.com', '+61 7 2345 6789', '123 Queen St, Brisbane', 'Australia', 'Queensland', 'Lead', 'Active', '2025-04-15 15:45:00'),
(6, 'Isabella', 'Rodriguez', 'isabella.rodriguez@example.com', '+55 11 87654 3210', 'Alameda Santos, 800, São Paulo', 'Brazil', 'São Paulo', 'Partner', 'Active', '2025-04-02 13:20:00'),
(NULL, 'David', 'Anderson', 'david.anderson@example.com', '+61 8 3456 7890', '78 St Georges Tce, Perth', 'Australia', 'Western Australia', 'Lead', 'Inactive', '2025-01-30 09:15:00'),
(10, 'Olivia', 'Lopez', 'olivia.lopez@example.com', '+55 31 91234 5678', 'Av. do Contorno, 200, Belo Horizonte', 'Brazil', 'Minas Gerais', 'Customer', 'Active', '2025-03-25 14:10:00'),
(NULL, 'Joseph', 'Taylor', 'joseph.taylor@example.com', '+61 2 9876 1234', '67 Market St, Sydney', 'Australia', 'New South Wales', 'Lead', 'Active', '2025-04-08 16:30:00'),
(8, 'Ava', 'Perez', 'ava.perez@example.com', '+55 21 98765 4321', 'Rua Barata Ribeiro, 300, Rio de Janeiro', 'Brazil', 'Rio de Janeiro', 'Lead', 'Active', '2025-04-12 10:45:00'),
(NULL, 'Matthew', 'Hill', 'matthew.hill@example.com', '+61 3 1234 9876', '45 Flinders St, Melbourne', 'Australia', 'Victoria', 'Customer', 'Active', '2025-03-30 11:20:00');

-- Insert sample data into leads
-- Include some new leads not in contacts yet
INSERT INTO crm.leads (first_name, last_name, email, phone, country, state, source, status, assigned_to, interest_level) VALUES
-- Some leads matching existing contacts (for demonstration of INTERSECT)
('Michael', 'Davis', 'michael.davis@example.com', '+61 2 1234 5678', 'Australia', 'New South Wales', 'Website', 'New', 'Sarah Jones', 'High'),
('Sophia', 'Martinez', 'sophia.martinez@example.com', '+55 11 98765 4321', 'Brazil', 'São Paulo', 'Referral', 'Qualified', 'John Smith', 'Medium'),
-- Completely new leads (for demonstration of EXCEPT)
('Ethan', 'Clark', 'ethan.clark@example.com', '+61 2 5678 1234', 'Australia', 'New South Wales', 'LinkedIn', 'New', 'Sarah Jones', 'Medium'),
('Victoria', 'Hernandez', 'victoria.hernandez@example.com', '+55 11 91234 8765', 'Brazil', 'São Paulo', 'Trade Show', 'Qualified', 'John Smith', 'High'),
('Andrew', 'Young', 'andrew.young@example.com', '+61 3 6789 1234', 'Australia', 'Victoria', 'Advertisement', 'New', 'Sarah Jones', 'Low'),
('Chloe', 'Gonzalez', 'chloe.gonzalez@example.com', '+55 21 87654 1234', 'Brazil', 'Rio de Janeiro', 'Website', 'Qualified', 'John Smith', 'Medium'),
('Christopher', 'Walker', 'christopher.walker@example.com', '+61 7 7890 1234', 'Australia', 'Queensland', 'Email Campaign', 'New', 'Sarah Jones', 'High'),
('Mia', 'Torres', 'mia.torres@example.com', '+55 31 91234 5678', 'Brazil', 'Minas Gerais', 'Referral', 'New', 'John Smith', 'Medium'),
('Ryan', 'Scott', 'ryan.scott@example.com', '+61 8 2345 6789', 'Australia', 'Western Australia', 'LinkedIn', 'Qualified', 'Sarah Jones', 'Medium'),
('Sofia', 'Flores', 'sofia.flores@example.com', '+55 11 98765 1234', 'Brazil', 'São Paulo', 'Trade Show', 'New', 'John Smith', 'Low');

-- Insert sample data into interactions
INSERT INTO crm.interactions (contact_id, interaction_type, interaction_date, notes, follow_up_date) VALUES
(1, 'Email', '2025-03-15 14:30:00', 'Discussed new product offerings, client showed interest in premium package', '2025-03-25 10:00:00'),
(2, 'Call', '2025-02-20 11:15:00', 'Followed up on previous inquiry, scheduled product demo', '2025-03-01 14:00:00'),
(3, 'Meeting', '2025-03-10 09:45:00', 'In-person meeting at client office, presented full product line', '2025-03-20 10:30:00'),
(4, 'Email', '2025-01-25 16:20:00', 'Sent proposal for new service package', '2025-02-05 11:00:00'),
(5, 'Call', '2025-04-05 10:30:00', 'Initial contact, lead expressed interest in enterprise solution', '2025-04-15 14:00:00'),
(6, 'Email', '2025-03-28 14:15:00', 'Sent information packet on requested services', '2025-04-10 10:00:00'),
(7, 'Meeting', '2025-04-10 09:00:00', 'Partnership discussion, outlined mutual benefits', '2025-04-25 13:30:00'),
(8, 'Email', '2025-02-15 11:30:00', 'Followed up on inactive account, no response', NULL),
(9, 'Call', '2025-04-15 15:45:00', 'Lead requested detailed pricing information', '2025-04-22 10:00:00'),
(10, 'Meeting', '2025-04-02 13:20:00', 'Partner strategy meeting, discussed co-marketing opportunities', '2025-04-20 11:00:00');

-- Insert sample data into campaigns
INSERT INTO crm.campaigns (campaign_name, description, start_date, end_date, status, budget) VALUES
('Spring Promotion 2025', 'Seasonal discount campaign targeting all customers', '2025-03-01 00:00:00', '2025-04-30 23:59:59', 'Active', 15000.00),
('New Product Launch', 'Marketing campaign for latest product line', '2025-04-15 00:00:00', '2025-05-31 23:59:59', 'Active', 25000.00),
('Customer Reactivation', 'Campaign targeting inactive customers', '2025-02-01 00:00:00', '2025-03-15 23:59:59', 'Completed', 8000.00),
('Partner Program', 'Promotional campaign for partner network', '2025-04-01 00:00:00', '2025-06-30 23:59:59', 'Active', 12000.00),
('Lead Generation Webinar', 'Educational webinar series to generate new leads', '2025-05-01 00:00:00', '2025-05-31 23:59:59', 'Planned', 10000.00);

-- Insert sample data into campaign_contacts
INSERT INTO crm.campaign_contacts (campaign_id, contact_id, status, last_activity_date) VALUES
(1, 1, 'Sent', '2025-03-05 10:15:00'),
(1, 2, 'Opened', '2025-03-07 14:30:00'),
(1, 3, 'Clicked', '2025-03-08 09:45:00'),
(1, 4, 'Converted', '2025-03-12 16:20:00'),
(2, 1, 'Sent', '2025-04-16 11:30:00'),
(2, 3, 'Opened', '2025-04-17 10:45:00'),
(2, 5, 'Sent', '2025-04-16 11:30:00'),
(2, 7, 'Clicked', '2025-04-18 14:15:00'),
(3, 8, 'Sent', '2025-02-05 09:30:00'),
(3, 12, 'Opened', '2025-02-06 11:15:00'),
(3, 14, 'Clicked', '2025-02-07 15:40:00'),
(4, 7, 'Converted', '2025-04-05 10:30:00'),
(4, 10, 'Clicked', '2025-04-06 14:45:00');

-- Create indexes to improve query performance
CREATE INDEX idx_contacts_email ON crm.contacts(email);
CREATE INDEX idx_contacts_country_state ON crm.contacts(country, state);
CREATE INDEX idx_contacts_contact_type ON crm.contacts(contact_type);
CREATE INDEX idx_contacts_status ON crm.contacts(status);

CREATE INDEX idx_leads_email ON crm.leads(email);
CREATE INDEX idx_leads_country_state ON crm.leads(country, state);
CREATE INDEX idx_leads_status ON crm.leads(status);
CREATE INDEX idx_leads_source ON crm.leads(source);

CREATE INDEX idx_companies_country_state ON crm.companies(country, state);
CREATE INDEX idx_companies_industry ON crm.companies(industry);

CREATE INDEX idx_interactions_contact_id ON crm.interactions(contact_id);
CREATE INDEX idx_interactions_interaction_date ON crm.interactions(interaction_date);
CREATE INDEX idx_interactions_interaction_type ON crm.interactions(interaction_type);

CREATE INDEX idx_campaign_contacts_campaign_id ON crm.campaign_contacts(campaign_id);
CREATE INDEX idx_campaign_contacts_contact_id ON crm.campaign_contacts(contact_id);
CREATE INDEX idx_campaign_contacts_status ON crm.campaign_contacts(status);
