from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "civitta_analytics.duckdb"
con = duckdb.connect(str(DB))

checks = {
    "Duplicate customer IDs": """
        SELECT customer_id, COUNT(*) AS occurrences
        FROM customers GROUP BY customer_id HAVING COUNT(*) > 1
    """,
    "Duplicate product IDs": """
        SELECT product_id, COUNT(*) AS occurrences
        FROM products GROUP BY product_id HAVING COUNT(*) > 1
    """,
    "Duplicate order IDs": """
        SELECT order_id, COUNT(*) AS occurrences
        FROM orders GROUP BY order_id HAVING COUNT(*) > 1
    """,
    "Missing customer fields": """
        SELECT * FROM customers
        WHERE customer_id IS NULL OR customer_name IS NULL
           OR segment IS NULL OR country IS NULL
    """,
    "Invalid product prices": """
        SELECT * FROM products
        WHERE unit_cost IS NULL OR list_price IS NULL
           OR unit_cost <= 0 OR list_price <= 0
    """,
    "Invalid discounts": """
        SELECT * FROM order_items
        WHERE discount_pct IS NULL OR discount_pct < 0 OR discount_pct > 1
    """,
    "Orders with missing customers": """
        SELECT o.* FROM orders o LEFT JOIN customers c
          ON o.customer_id = c.customer_id
        WHERE c.customer_id IS NULL
    """,
    "Items with missing orders": """
        SELECT oi.* FROM order_items oi LEFT JOIN orders o
          ON oi.order_id = o.order_id
        WHERE o.order_id IS NULL
    """,
    "Items with missing products": """
        SELECT oi.* FROM order_items oi LEFT JOIN products p
          ON oi.product_id = p.product_id
        WHERE p.product_id IS NULL
    """,
    "Invalid quantities": """
        SELECT * FROM order_items WHERE quantity IS NULL OR quantity <= 0
    """
}

failed = 0
for label, sql in checks.items():
    df = con.execute(sql).df()
    status = "PASS" if df.empty else "FAIL"
    failed += not df.empty
    print(f"{status:4} | {label}: {len(df)} issue(s)")
    if not df.empty:
        print(df.head(10).to_string(index=False))
print(f"\nSummary: {len(checks)-failed}/{len(checks)} checks passed.")
con.close()
