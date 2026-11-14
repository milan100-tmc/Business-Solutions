# KPI definitions

All sales KPIs exclude Cancelled and Pending orders.

| KPI | Definition |
|---|---|
| Net Revenue | Sum of quantity × unit price × (1 − discount) |
| Gross Profit | Net Revenue − quantity × unit cost |
| Gross Margin % | Gross Profit ÷ Net Revenue |
| Completed Orders | Distinct count of completed order IDs |
| Purchasing Customers | Distinct count of customers with completed sales |
| Units Sold | Sum of quantity on completed order lines |
| Average Order Value | Net Revenue ÷ Completed Orders |

## Interpretation cautions
- Unit cost is synthetic and assumed constant per product.
- Revenue is recognised on completed orders only.
- No returns, taxes, freight, currency conversion or payment timing are modelled.
- YoY comparisons are not meaningful with only one year of data.
