-- Commercial KPI analysis
-- Revenue is calculated on completed orders only.
-- Net sales = quantity * unit price * (1 - discount).
-- Gross profit = net sales - quantity * unit cost.

CREATE OR REPLACE VIEW sales_detail AS
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.country,
    c.customer_id,
    c.customer_name,
    c.segment,
    oi.order_item_id,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    p.unit_cost,
    oi.discount_pct,
    oi.quantity * oi.unit_price * (1 - oi.discount_pct) AS net_sales,
    oi.quantity * p.unit_cost AS cost_of_goods,
    oi.quantity * oi.unit_price * (1 - oi.discount_pct)
        - oi.quantity * p.unit_cost AS gross_profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed';

-- Executive KPI snapshot
SELECT
    ROUND(SUM(net_sales), 2) AS net_revenue,
    ROUND(SUM(gross_profit), 2) AS gross_profit,
    ROUND(SUM(gross_profit) / NULLIF(SUM(net_sales), 0) * 100, 2) AS gross_margin_pct,
    COUNT(DISTINCT order_id) AS completed_orders,
    COUNT(DISTINCT customer_id) AS purchasing_customers,
    SUM(quantity) AS units_sold,
    ROUND(SUM(net_sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
FROM sales_detail;

-- Revenue by country
SELECT country, ROUND(SUM(net_sales), 2) AS net_revenue
FROM sales_detail
GROUP BY country ORDER BY net_revenue DESC;

-- Revenue by customer segment
SELECT segment, ROUND(SUM(net_sales), 2) AS net_revenue,
       ROUND(SUM(gross_profit) / NULLIF(SUM(net_sales),0) * 100,2) AS gross_margin_pct
FROM sales_detail
GROUP BY segment ORDER BY net_revenue DESC;

-- Revenue by product category
SELECT category, ROUND(SUM(net_sales), 2) AS net_revenue,
       ROUND(SUM(gross_profit), 2) AS gross_profit
FROM sales_detail
GROUP BY category ORDER BY net_revenue DESC;

-- Monthly trend
SELECT DATE_TRUNC('month', CAST(order_date AS DATE)) AS sales_month,
       ROUND(SUM(net_sales), 2) AS net_revenue,
       ROUND(SUM(gross_profit), 2) AS gross_profit
FROM sales_detail
GROUP BY 1 ORDER BY 1;

-- Top 10 customers
SELECT customer_id, customer_name, country,
       ROUND(SUM(net_sales), 2) AS net_revenue
FROM sales_detail
GROUP BY customer_id, customer_name, country
ORDER BY net_revenue DESC LIMIT 10;
