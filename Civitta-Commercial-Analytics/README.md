# Civitta Commercial Performance Analytics

**Independent portfolio simulation | Synthetic data | SQL + DuckDB + Power BI design**

## Project objective
Build a commercial performance analysis for a fictional European wholesale distributor. Explore revenue, gross profit, margin, customer segments, product categories and market trends.

> This is an independent simulation using synthetic data. It is not Civitta client work and does not contain confidential company data.

## Dataset
| CSV | Rows |
|---|---:|
| regions | 5 |
| customers | 100 |
| products | 30 |
| orders | 1,000 |
| order_items | 2,584 |
| **Total** | **3,719** |

Period: 1 January 2025 to 31 December 2025.

## Run locally on macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install duckdb pandas
python scripts/load_data.py
python scripts/run_quality_checks.py
```

## Run SQL analysis

Open `civitta_analytics.duckdb` using a DuckDB-compatible client, or use Python:

```bash
python -c "import duckdb; c=duckdb.connect('civitta_analytics.duckdb'); print(c.execute(open('sql/02_kpi_analysis.sql').read().split(';')[1]).df())"
```

The SQL file contains the full KPI analysis queries. Each statement can also be run individually in a DuckDB SQL editor.

## Project structure

- `data/raw/` — generated CSV source files
- `scripts/` — dataset generator, database loader and quality checks
- `sql/` — data quality, KPI analysis and model notes
- `docs/` — business problem, data dictionary, KPI definitions and handover
- `powerbi/` — suggested DAX measures and model guidance

## Power BI next step
Power BI Desktop is not available natively on macOS. Import the CSVs or connect to the DuckDB database from a Windows Power BI Desktop environment. Build the star schema and measures using `powerbi/DAX_measures.md`.

## Analytical definitions
- Net Revenue = quantity × unit price × (1 − discount)
- Gross Profit = Net Revenue − quantity × unit cost
- Gross Margin % = Gross Profit ÷ Net Revenue
- Only Completed orders contribute to sales KPIs.

## Limitations
Synthetic unit costs, no returns, tax, freight, FX or payment timing. The dataset spans one year, so YoY comparisons are not supported.
