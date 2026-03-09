CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products VALUES 
(1, 'Wireless Mouse', 'Electronics', 799.99),
(2, 'Bluetooth Speaker', 'Electronics', 1299.49),
(3, 'Yoga Mat', 'Fitness', 499.00),
(4, 'Laptop Stand', 'Accessories', 999.99),
(5, 'Notebook Set', 'Stationery', 149.00),
(6, 'Water Bottle', 'Fitness', 299.00),
(7, 'Smartwatch', 'Electronics', 4999.00),
(8, 'Desk Organizer', 'Accessories', 399.00),
(9, 'Dumbbell Set', 'Fitness', 1999.00),
(10, 'Pen Drive 32GB', 'Electronics', 599.00);


-- Stores Table
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    location VARCHAR(100)
);

INSERT INTO stores VALUES 
(1, 'City Mall Store', 'Mumbai'),
(2, 'High Street Store', 'Delhi'),
(3, 'Tech World Outlet', 'Bangalore'),
(4, 'Downtown Mini Store', 'Pune'),
(5, 'Mega Plaza', 'Chennai');


-- Transactions Table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    store_id INT,
    quantity INT,
    transaction_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);


INSERT INTO transactions VALUES (1, 127, 8, 4, 4, '2025-03-31');
INSERT INTO transactions VALUES (2, 105, 3, 4, 5, '2024-11-12');
INSERT INTO transactions VALUES (3, 116, 2, 2, 3, '2025-05-01');
INSERT INTO transactions VALUES (4, 120, 8, 1, 1, '2024-11-02');
INSERT INTO transactions VALUES (5, 105, 5, 2, 1, '2025-03-17');
INSERT INTO transactions VALUES (6, 110, 7, 3, 5, '2025-01-04');
INSERT INTO transactions VALUES (7, 110, 7, 2, 5, '2025-01-01');
INSERT INTO transactions VALUES (8, 126, 7, 5, 2, '2025-06-08');
INSERT INTO transactions VALUES (9, 123, 1, 3, 2, '2024-10-08');
INSERT INTO transactions VALUES (10, 124, 2, 2, 5, '2024-08-27');
INSERT INTO transactions VALUES (11, 102, 1, 3, 2, '2024-08-11');
INSERT INTO transactions VALUES (12, 108, 5, 1, 4, '2025-05-26');
INSERT INTO transactions VALUES (13, 104, 3, 3, 4, '2025-05-04');
INSERT INTO transactions VALUES (14, 120, 1, 4, 5, '2024-07-17');
INSERT INTO transactions VALUES (15, 121, 6, 5, 5, '2025-05-19');
INSERT INTO transactions VALUES (16, 118, 6, 2, 4, '2024-11-29');
INSERT INTO transactions VALUES (17, 109, 8, 5, 5, '2024-07-10');
INSERT INTO transactions VALUES (18, 103, 1, 4, 3, '2024-09-05');
INSERT INTO transactions VALUES (19, 116, 8, 4, 4, '2024-07-14');
INSERT INTO transactions VALUES (20, 130, 5, 1, 2, '2024-07-30');
INSERT INTO transactions VALUES (21, 105, 1, 3, 5, '2024-10-02');
INSERT INTO transactions VALUES (22, 107, 9, 3, 4, '2024-11-16');
INSERT INTO transactions VALUES (23, 122, 9, 4, 2, '2025-04-30');
INSERT INTO transactions VALUES (24, 125, 1, 5, 1, '2024-07-14');
INSERT INTO transactions VALUES (25, 116, 8, 4, 5, '2024-12-13');
INSERT INTO transactions VALUES (26, 126, 6, 2, 2, '2024-09-21');
INSERT INTO transactions VALUES (27, 127, 8, 1, 1, '2024-10-10');
INSERT INTO transactions VALUES (28, 101, 7, 5, 3, '2024-11-15');
INSERT INTO transactions VALUES (29, 119, 9, 4, 2, '2025-06-03');
INSERT INTO transactions VALUES (30, 116, 8, 4, 5, '2025-03-16');
