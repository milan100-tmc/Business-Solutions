# 🛒 Retail Data Engineering Pipeline
### Azure Data Factory → ADLS Gen2 → Databricks → Power BI

---

## 📌 Business Goal

Analyze retail sales performance by building a complete end-to-end data pipeline that answers:

- Which products are selling the most?
- Which stores are generating the highest revenue?
- What is the average transaction value per store?
- How many complete transactions were made per day?

> **Definition of a complete transaction:** A transaction that has a matching customer, product, and store record. Incomplete records are excluded from reporting.

---

## 🏗️ Architecture

```
Azure SQL Database          REST API
        │                      │
        └──────────┬───────────┘
                   │
            Azure Data Factory
            (Pipelines / Copy Activity)
                   │
                   ▼
        Azure Data Lake Gen2 (ADLS)
              retail container
                   │
           ┌───────┴───────┐
           │               │
        bronze/          bronze/
      (SQL tables)     (REST API data)
           │
           ▼
        Databricks
     (Transformation)
           │
     ┌─────┴─────┐
     │           │
  silver/      gold/
(cleaned &   (aggregated
  joined)      summary)
                  │
                  ▼
               Power BI
               (Dashboard)
```

---

## 📂 Medallion Architecture

### 🥉 Bronze Layer
Raw data landed directly from sources — no transformations applied.

| Table | Source |
|---|---|
| `customers` | Azure SQL Database via ADF Pipeline |
| `products` | Azure SQL Database via ADF Pipeline |
| `stores` | Azure SQL Database via ADF Pipeline |
| `transactions` | Azure SQL Database via ADF Pipeline |
| `additional data` | REST API via ADF Pipeline |

---

### 🥈 Silver Layer
Cleaned, typed, joined and enriched data.

**Transformations applied:**
- Cast all columns to correct data types
- Removed duplicate customers using `dropDuplicates(["customer_id"])`
- Joined all 4 tables into one complete transaction view
- Calculated `total_amount = quantity * price`
- Used **inner join** to keep only complete transactions (all 4 tables must match)

**Saved as:**
- Delta format to ADLS `silver/` folder
- Registered as table in `hive_metastore.retail.retail_silver_cleaned`

> **Note:** Unity Catalog and DBFS mounts were disabled on this workspace. Used `hive_metastore` (legacy metastore) as a fallback to register the table while actual data stays in ADLS.

---

### 🥇 Gold Layer
Aggregated, business-ready summary table.

**Aggregations:**
- `total_quantity_sold` — sum of quantity per date/product/store
- `total_sales_amount` — sum of revenue per date/product/store
- `number_of_transactions` — count of distinct transaction IDs
- `average_transaction_value` — avg transaction amount

**Saved as:**
- Parquet format to ADLS `gold_parquet/` folder
- Connected to Power BI for reporting

---

## 🔧 Tech Stack

| Tool | Purpose |
|---|---|
| Azure Data Factory | Data ingestion pipelines |
| Azure Data Lake Gen2 | Cloud storage for all layers |
| Azure SQL Database | Source transactional data |
| REST API | Additional data source |
| Databricks | Data transformation (PySpark) |
| Delta Lake | Silver layer storage format |
| Power BI | Business reporting and dashboards |

---

## 📁 Project Structure

```
retail-pipeline/
│
├── adf/
│   ├── pipeline_sql_to_adls.json       # ADF pipeline - SQL to Bronze
│   └── pipeline_api_to_adls.json       # ADF pipeline - REST API to Bronze
│
├── databricks/
│   ├── 01_bronze_ingestion.py          # Read bronze data from ADLS
│   ├── 02_silver_transformation.py     # Clean, join, create silver layer
│   ├── 03_gold_aggregation.py          # Aggregate, create gold layer
│   └── 04_create_tables.py             # Register tables in hive_metastore
│
├── powerbi/
│   └── retail_dashboard.pbix           # Power BI report
│
└── README.md
```

---

## 🚀 How to Run

### Prerequisites
- Azure subscription with ADLS Gen2 storage account
- Databricks workspace
- Azure Data Factory instance
- Power BI account

### Step 1 — Set Storage Key in Databricks Cluster Config
```
Compute → your cluster → Edit → Advanced Options → Spark Config

fs.azure.account.key.<your-storage-account>.dfs.core.windows.net <your-key>
```

### Step 2 — Run ADF Pipelines
```
1. Trigger SQL to Bronze pipeline
2. Trigger REST API to Bronze pipeline
3. Verify files in ADLS bronze/ folder
```

### Step 3 — Run Databricks Notebooks in Order
```
01_bronze_ingestion.py
02_silver_transformation.py
03_gold_aggregation.py
04_create_tables.py
```

### Step 4 — Connect Power BI
```
Get Data → Azure Data Lake Storage Gen2
URL: https://<storage-account>.dfs.core.windows.net/<container>/gold_parquet/
Auth: Account Key
```

---

## 💡 Key Design Decisions

**Why Inner Join for Silver Layer?**
The business goal is to analyze complete transactions only. A transaction missing customer, product, or store data is considered corrupt/incomplete and excluded from reporting.

**Why Delta for Silver, Parquet for Gold?**
Delta gives ACID transactions, schema enforcement and time travel for the silver layer where data quality matters. Parquet is used for gold as it's simpler for Power BI to consume directly.

**Why hive_metastore instead of Unity Catalog?**
Unity Catalog required external location registration and admin permissions that weren't available. hive_metastore allowed table registration with direct ADLS paths as a valid workaround.

---

## 📊 Power BI Dashboard

Built on the gold layer, the dashboard answers:

- 📈 Daily sales trend
- 🏪 Revenue by store
- 👟 Top selling products by quantity
- 🗂️ Sales breakdown by category
- 💰 Average transaction value by store

---

## 👤 Author

Built as part of a retail analytics data engineering project using Microsoft Azure stack.
