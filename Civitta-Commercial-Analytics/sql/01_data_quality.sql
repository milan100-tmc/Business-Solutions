-- Civitta Commercial Performance Analytics
-- Data quality investigation queries

-- Table row counts
SELECT 'regions' AS table_name, COUNT(*) AS row_count FROM regions
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

-- Duplicate keys
SELECT customer_id, COUNT(*) AS occurrences
FROM customers GROUP BY customer_id HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS occurrences
FROM orders GROUP BY order_id HAVING COUNT(*) > 1;

-- Invalid discounts and quantities
SELECT * FROM order_items
WHERE discount_pct IS NULL OR discount_pct < 0 OR discount_pct > 1;

SELECT * FROM order_items
WHERE quantity IS NULL OR quantity <= 0;

-- Referential integrity
SELECT o.* FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT oi.* FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT oi.* FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
