import random
from pathlib import Path
from datetime import date, timedelta
import pandas as pd

random.seed(42)
ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
RAW.mkdir(parents=True, exist_ok=True)

regions = pd.DataFrame([
    {"region_id": 1, "region_name": "Western Europe", "country": "France"},
    {"region_id": 2, "region_name": "Western Europe", "country": "Germany"},
    {"region_id": 3, "region_name": "Northern Europe", "country": "Netherlands"},
    {"region_id": 4, "region_name": "Southern Europe", "country": "Spain"},
    {"region_id": 5, "region_name": "Northern Europe", "country": "Sweden"},
])
segments = ["SMB", "Mid-Market", "Enterprise"]
countries = ["France", "Germany", "Netherlands", "Spain", "Sweden"]
customers = pd.DataFrame([
    {"customer_id": i, "customer_name": f"Customer {i:03d}",
     "segment": random.choice(segments), "country": random.choice(countries)}
    for i in range(1, 101)
])
categories = ["Electronics", "Office Supplies", "Furniture", "Industrial"]
products = pd.DataFrame([
    {"product_id": i, "product_name": f"Product {i:03d}",
     "category": random.choice(categories),
     "unit_cost": round(random.uniform(10, 250), 2),
     "list_price": round(random.uniform(30, 500), 2)}
    for i in range(1, 31)
])

orders, items = [], []
for order_id in range(1, 1001):
    customer = customers.iloc[random.randrange(len(customers))]
    order_date = date(2025, 1, 1) + timedelta(days=random.randint(0, 364))
    orders.append({
        "order_id": order_id, "customer_id": int(customer.customer_id),
        "order_date": order_date.isoformat(), "country": customer.country,
        "status": random.choices(["Completed", "Cancelled", "Pending"],
                                 weights=[85, 8, 7])[0]
    })
    for _ in range(random.randint(1, 4)):
        product = products.iloc[random.randrange(len(products))]
        items.append({
            "order_item_id": len(items)+1, "order_id": order_id,
            "product_id": int(product.product_id),
            "quantity": random.randint(1, 20),
            "unit_price": float(product.list_price),
            "discount_pct": random.choice([0, 0.05, 0.10, 0.15])
        })

tables = {
    "regions": regions, "customers": customers, "products": products,
    "orders": pd.DataFrame(orders), "order_items": pd.DataFrame(items)
}
for name, df in tables.items():
    df.to_csv(RAW / f"{name}.csv", index=False)
    print(f"{name}: {len(df):,} rows")
print(f"\nSynthetic CSVs saved to {RAW}")
