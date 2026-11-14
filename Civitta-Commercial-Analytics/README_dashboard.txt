# Civitta Commercial Analytics — Streamlit dashboard

This is an interactive Python dashboard alternative because Power BI Desktop is not available on the user's Mac.

## Setup
1. Put `dashboard.py` in the project root, beside `civitta_analytics.duckdb`.
2. Activate the existing virtual environment:
   `source .venv/bin/activate`
3. Install dashboard packages:
   `python -m pip install streamlit plotly`
4. Start the dashboard:
   `python -m streamlit run dashboard.py`

The app reads the DuckDB tables `customers`, `products`, `orders`, and `order_items`.
It filters out non-completed orders when a status field is available and calculates revenue, COGS, gross profit, gross margin, order count and average order value.

This is a Python/Streamlit portfolio dashboard, not a Power BI report or `.pbix` file.
The dataset is synthetic and must be described as a simulation.
