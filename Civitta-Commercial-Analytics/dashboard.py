from pathlib import Path
import pandas as pd
import streamlit as st
import plotly.express as px
import duckdb

st.set_page_config(page_title="Commercial Performance Analytics", page_icon="📊", layout="wide")
st.title("Commercial Performance Analytics")
st.caption("Independent portfolio simulation • Synthetic 2025 wholesale distribution data")

DB_PATH = Path("civitta_analytics.duckdb")

@st.cache_data
def load_data(db_path: str):
    con = duckdb.connect(db_path, read_only=True)
    tables = {r[0] for r in con.execute("SHOW TABLES").fetchall()}
    required = {"customers", "products", "orders", "order_items"}
    missing = required - tables
    if missing:
        con.close()
        raise ValueError(f"Missing database tables: {', '.join(sorted(missing))}")

    customers = con.execute("SELECT * FROM customers").fetchdf()
    products = con.execute("SELECT * FROM products").fetchdf()
    orders = con.execute("SELECT * FROM orders").fetchdf()
    items = con.execute("SELECT * FROM order_items").fetchdf()
    con.close()
    return customers, products, orders, items

if not DB_PATH.exists():
    st.error("Database not found. Put dashboard.py in the same folder as civitta_analytics.duckdb.")
    st.code("python scripts/load_data.py")
    st.stop()

try:
    customers, products, orders, items = load_data(str(DB_PATH.resolve()))

    # Join transaction lines to their descriptive dimensions.
    sales = (items.merge(orders, on="order_id", suffixes=("_item", "_order"))
                  .merge(customers, on="customer_id", suffixes=("", "_customer"))
                  .merge(products, on="product_id", suffixes=("", "_product")))

    # Resolve common column names from the generated dataset.
    date_col = next((c for c in ["order_date", "date"] if c in sales.columns), None)
    status_col = next((c for c in ["status", "order_status"] if c in sales.columns), None)
    qty_col = next((c for c in ["quantity", "qty"] if c in sales.columns), None)
    price_col = next((c for c in ["unit_price", "selling_price", "price"] if c in sales.columns), None)
    cost_col = next((c for c in ["unit_cost", "cost_price", "cost"] if c in sales.columns), None)
    discount_col = next((c for c in ["discount", "discount_pct", "discount_rate"] if c in sales.columns), None)

    needed = [("date", date_col), ("quantity", qty_col), ("unit price", price_col), ("unit cost", cost_col)]
    absent = [label for label, col in needed if col is None]
    if absent:
        st.error("Could not identify these fields in your database: " + ", ".join(absent))
        st.write("Available fields:", list(sales.columns))
        st.stop()

    sales[date_col] = pd.to_datetime(sales[date_col])
    if status_col:
        sales = sales[sales[status_col].astype(str).str.lower().isin(["completed", "complete", "delivered", "shipped"])]

    sales["net_revenue"] = sales[qty_col] * sales[price_col]
    if discount_col:
        # Supports discounts stored either as 0–1 fractions or 0–100 percentages.
        discount = pd.to_numeric(sales[discount_col], errors="coerce").fillna(0)
        discount = discount.where(discount <= 1, discount / 100)
        sales["net_revenue"] *= (1 - discount)
    sales["cost_of_goods_sold"] = sales[qty_col] * sales[cost_col]
    sales["gross_profit"] = sales["net_revenue"] - sales["cost_of_goods_sold"]
    sales["month"] = sales[date_col].dt.to_period("M").dt.to_timestamp()

    country_col = next((c for c in ["country", "customer_country"] if c in sales.columns), None)
    segment_col = next((c for c in ["segment", "customer_segment"] if c in sales.columns), None)
    category_col = next((c for c in ["category", "product_category"] if c in sales.columns), None)
    customer_name_col = next((c for c in ["customer_name", "name"] if c in sales.columns), None)

    st.sidebar.header("Filters")
    date_min, date_max = sales[date_col].min().date(), sales[date_col].max().date()
    date_range = st.sidebar.date_input("Order date", value=(date_min, date_max), min_value=date_min, max_value=date_max)
    filtered = sales.copy()
    if isinstance(date_range, tuple) and len(date_range) == 2:
        filtered = filtered[(filtered[date_col].dt.date >= date_range[0]) & (filtered[date_col].dt.date <= date_range[1])]

    for col, label in [(country_col, "Country"), (segment_col, "Customer segment"), (category_col, "Product category")]:
        if col:
            choices = sorted(filtered[col].dropna().astype(str).unique())
            selected = st.sidebar.multiselect(label, choices, default=choices)
            filtered = filtered[filtered[col].astype(str).isin(selected)]

    revenue = filtered["net_revenue"].sum()
    profit = filtered["gross_profit"].sum()
    cogs = filtered["cost_of_goods_sold"].sum()
    margin = (profit / revenue * 100) if revenue else 0
    orders_count = filtered["order_id"].nunique()
    customers_count = filtered["customer_id"].nunique()
    aov = revenue / orders_count if orders_count else 0

    k1, k2, k3, k4, k5 = st.columns(5)
    k1.metric("Net revenue", f"€{revenue:,.0f}")
    k2.metric("Gross profit", f"€{profit:,.0f}")
    k3.metric("Gross margin", f"{margin:.1f}%")
    k4.metric("Completed orders", f"{orders_count:,}")
    k5.metric("Average order value", f"€{aov:,.0f}")

    left, right = st.columns(2)
    with left:
        monthly = filtered.groupby("month", as_index=False).agg(net_revenue=("net_revenue", "sum"), gross_profit=("gross_profit", "sum"))
        fig = px.line(monthly, x="month", y=["net_revenue", "gross_profit"], markers=True,
                      title="Monthly revenue and gross profit", labels={"value": "EUR", "month": "Month", "variable": "Metric"})
        st.plotly_chart(fig, use_container_width=True)
    with right:
        if category_col:
            by_category = filtered.groupby(category_col, as_index=False)["net_revenue"].sum().sort_values("net_revenue", ascending=False)
            fig = px.bar(by_category, x=category_col, y="net_revenue", title="Revenue by product category",
                         labels={category_col: "Category", "net_revenue": "Net revenue (EUR)"})
            st.plotly_chart(fig, use_container_width=True)

    left, right = st.columns(2)
    with left:
        if country_col:
            by_country = filtered.groupby(country_col, as_index=False)["net_revenue"].sum().sort_values("net_revenue", ascending=False)
            fig = px.bar(by_country, x=country_col, y="net_revenue", title="Revenue by country",
                         labels={country_col: "Country", "net_revenue": "Net revenue (EUR)"})
            st.plotly_chart(fig, use_container_width=True)
    with right:
        if segment_col:
            by_segment = filtered.groupby(segment_col, as_index=False).agg(net_revenue=("net_revenue", "sum"), gross_profit=("gross_profit", "sum"))
            fig = px.bar(by_segment, x=segment_col, y="net_revenue", title="Revenue by customer segment",
                         labels={segment_col: "Segment", "net_revenue": "Net revenue (EUR)"})
            st.plotly_chart(fig, use_container_width=True)

    st.subheader("Top 10 customers")
    if customer_name_col:
        top = filtered.groupby(customer_name_col, as_index=False)["net_revenue"].sum().nlargest(10, "net_revenue")
        st.dataframe(top.rename(columns={customer_name_col: "Customer", "net_revenue": "Net revenue (EUR)"}),
                     use_container_width=True, hide_index=True)
    else:
        st.info("Customer name field was not detected.")

    st.subheader("Transaction detail")
    st.dataframe(filtered.head(500), use_container_width=True, hide_index=True)
    st.caption(f"Showing {min(len(filtered), 500):,} of {len(filtered):,} filtered sales lines. COGS uses the synthetic unit-cost assumptions in this dataset.")

except Exception as exc:
    st.exception(exc)
    st.info("If this is a schema mismatch, share the error and I'll adapt the dashboard to your exact table columns.")
