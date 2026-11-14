# Data dictionary

| Table | Grain | Key fields | Description |
|---|---|---|---|
| regions | One row per country-region mapping | region_id | Five target markets and their regions |
| customers | One row per customer | customer_id | Customer segment and country |
| products | One row per product | product_id | Category, unit cost and list price |
| orders | One row per order | order_id | Customer, date, country and order status |
| order_items | One row per order line | order_item_id | Product, quantity, selling price and discount |

## Important fields
- `status`: Completed, Cancelled or Pending.
- `discount_pct`: decimal fraction (0.10 means 10%).
- `unit_price`: selling price per unit before discount.
- `unit_cost`: assumed cost per unit.
- `net_sales`: quantity × unit price × (1 − discount).
- `gross_profit`: net sales − quantity × unit cost.

All values are synthetic and generated for demonstration.
