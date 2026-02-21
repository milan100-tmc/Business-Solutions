
End-to-End Azure Data Engineering Project

**ADF + ADLS + Spark + Synapse + SQL**
Medallion Architecture (Bronze → Azure Retail Data Platform | End-to-End Medallion Architecture (ADF • ADLS • Spark • Synapse) → Gold)

---

##  Project Overview

This project demonstrates a complete **end-to-end data engineering pipeline** built on Microsoft Azure using modern cloud data architecture principles.

The solution ingests retail transaction data from a **REST API**, processes it through the **Medallion Architecture**, and delivers daily business reports for clients.

---

##  Business Requirement

We are working for a **retail client**.

###  Objective:

Generate a **daily report** showing:

* Total Purchase Amount
* Total Revenue

The final dataset should be queryable by clients via SQL or report-ready for dashboards.

---

## Architecture Overview

###  Source

* REST API
* Data contains:

  * `customer_id`
  * `order_id`
  * `transaction_type` (purchase, refund, cancel)
  * `amount`
  * `timestamp`
  * `payment_method`

---

##  Medallion Architecture

The project follows the **Bronze → Silver → Gold** layered architecture pattern.

| Layer  | Purpose                        | Storage            |
| ------ | ------------------------------ | ------------------ |
| Bronze | Raw data ingestion             | ADLS               |
| Silver | Cleaned & transformed data     | ADLS (Parquet)     |
| Gold   | Aggregated business-level data | Synapse SQL / ADLS |

---

##  Bronze Layer – Raw Data

###  Objective:

Ingest raw data from REST API without modification.

###  Process:

* Azure Data Factory (ADF) pipeline calls REST API
* Data is stored as-is in:

  ```
  ADLS / bronze /
  ```

###  Characteristics:

* Raw JSON format
* No transformations
* Historical storage enabled

---

##  Silver Layer – Cleaned Data

###  Objective:

Transform and clean the raw purchase dataset.

###  Process:

Using **Azure Synapse Spark / PySpark**:

* Filter only `purchase` transactions
* Drop null values
* Cast `amount` to numeric
* Convert `timestamp` to date
* Convert `payment_method` to lowercase
* Store data in **Parquet format**

###  Output:

```
ADLS / silver / purchase_data.parquet
```

###  Characteristics:

* Cleaned dataset
* Schema enforced
* Optimized format (Parquet)
* Ready for analytics

---

##  Gold Layer – Aggregated Data

###  Objective:

Create business-level daily report.

###  Process:

Using **Spark SQL or Synapse SQL**:

* Group by transaction date
* Calculate:

  * Daily Total Purchase
  * Daily Total Revenue

### Example Aggregation:

```sql
SELECT 
    transaction_date,
    SUM(amount) AS total_purchase
FROM silver_purchase_data
GROUP BY transaction_date;
```

###  Output Options:

* Gold dataset stored in ADLS
* OR
* SQL Table created in Synapse pointing to Gold dataset

```
Gold → SQL Table → Client Query
```

---

##  End-to-End Data Flow

```
REST API 
   ↓
Azure Data Factory (Ingestion)
   ↓
ADLS (Bronze Layer - Raw)
   ↓
Synapse Spark (Transformation)
   ↓
ADLS (Silver Layer - Clean)
   ↓
Synapse SQL (Aggregation)
   ↓
Gold Layer (Daily Report)
   ↓
Client Reporting / BI Tool
```

---

##  Technologies Used

* Azure Data Factory (ADF)
* Azure Data Lake Storage Gen2 (ADLS)
* Azure Synapse Analytics
* Apache Spark (PySpark)
* Synapse SQL
* REST API

---

##  Key Data Engineering Concepts Demonstrated

✔ Medallion Architecture
✔ REST API ingestion
✔ Data Lake design
✔ Spark transformations
✔ Data cleaning & schema enforcement
✔ Parquet optimization
✔ SQL aggregation
✔ End-to-end orchestration

---

##  Possible Enhancements

* Incremental loading
* Partitioning by date
* Delta Lake implementation
* Data quality checks
* Power BI dashboard integration
* CI/CD with Azure DevOps
* Monitoring & alerting

---

##  Repository Structure (Example)

```
├── adf/
│   └── pipeline.json
├── spark/
│   └── silver_transformation.py
├── sql/
│   └── gold_aggregation.sql
├── architecture/
│   └── architecture_diagram.png
└── README.md
```

---

##  Learning Outcome

This project simulates a real-world retail data engineering use case and demonstrates how to:

* Build scalable Azure data pipelines
* Implement layered data architecture
* Transform and optimize large datasets
* Deliver business-ready analytical data

---

##  Author

**Milan Niranjan**
M.Sc. Business Intelligence
Azure Data Engineering | SQL | Spark | Data Analytics
