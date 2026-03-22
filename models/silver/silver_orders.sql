-- Silver: cleaned, filtered
SELECT
  order_id,
  customer_id,
  order_date,
  amount,
  status
FROM {{ ref('bronze_orders') }}
WHERE status != 'returned'