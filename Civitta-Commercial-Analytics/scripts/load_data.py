from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
DB = ROOT / "civitta_analytics.duckdb"

con = duckdb.connect(str(DB))
for table in ["regions", "customers", "products", "orders", "order_items"]:
    csv_path = RAW / f"{table}.csv"
    con.execute(
        f"CREATE OR REPLACE TABLE {table} AS SELECT * FROM read_csv_auto(?)",
        [str(csv_path)]
    )
    count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    print(f"{table}: {count:,} rows loaded")
con.close()
print(f"Database ready: {DB}")
