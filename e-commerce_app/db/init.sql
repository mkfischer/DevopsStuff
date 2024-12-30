-- Step 1: Create the database
CREATE DATABASE IF NOT EXISTS product_db;

-- Step 2: Create the application user with a secure password
CREATE USER '${TEMP_MYSQL_USER}'@'%' IDENTIFIED BY '${TEMP_MYSQL_PASSWORD}';
ALTER USER '${TEMP_MYSQL_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${TEMP_MYSQL_PASSWORD}';

-- Step 3: Grant full permissions to the application user on the database
GRANT ALL PRIVILEGES ON product_db.* TO '${TEMP_MYSQL_USER}'@'%';

-- Step 4: Apply the privilege changes
FLUSH PRIVILEGES;

-- Step 5: Use the database
USE product_db;

-- Step 6: Create the schema (products table)
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO products (name, price) VALUES
('Product A', 19.99),
('Product B', 29.99),
('Product C', 39.99);

