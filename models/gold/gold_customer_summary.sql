-- Gold: business-ready aggregation
SELECT
  customer_id,
  COUNT(order_id) AS total_orders,
  SUM(amount) AS total_spent,
  MAX(order_date) AS last_order_date
FROM {{ ref('silver_orders') }}
GROUP BY customer_id