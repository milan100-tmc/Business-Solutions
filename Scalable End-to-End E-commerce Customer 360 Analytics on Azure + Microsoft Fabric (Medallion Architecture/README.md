# Azure + Microsoft Fabric Scalable E-commerce Customer 360 (Medallion Architecture)

End-to-end, scalable data engineering pipeline built using **Azure ADLS Gen2 + Microsoft Fabric** to deliver Customer 360 analytics** with **Bronze/Silver/Gold** layers and Power BI reporting.

---

## 🔧 Tech Stack (Tools)

### Azure
- **Azure Data Lake Storage Gen2 (ADLS)** – raw landing zone for source files

### Microsoft Fabric
- Workspace – project environment
- OneLake – unified storage layer
- Lakehouse – Bronze/Silver/Gold data organization
- Data Pipelines – ingestion/orchestration from ADLS → Fabric
- Notebooks (PySpark) – transformations and data quality
- Delta Tables – curated Silver/Gold datasets (ACID, performance)
- Power BI – semantic model + dashboards on Gold layer

### Data Formats / Processing
- Parquet** – efficient columnar file format for ingestion
- Delta Lake** – reliable table format for incremental processing
- PySpark** – scalable distributed compute for cleaning & transformation

---

##  Architecture Overview

**ADLS (Raw Source) → Fabric Data Pipeline → Lakehouse (Bronze) → PySpark (Silver) → Gold (Star Schema) → Power BI

### Medallion Layers
- **Bronze: raw ingested data (stored as files in Lakehouse)
- **Silver: cleaned/validated data stored as **Delta tables**
- **Gold: business-ready **facts & dimensions** (Customer 360) stored as **Delta tables**

---

## Data Pipeline Flow (Step-by-step)

1. Land raw files in Azure ADLS Gen2**
   - Source datasets stored in containers/folders (raw truth)

2. Ingest ADLS → Fabric Lakehouse Bronze
   - Fabric Data Pipeline** loads files into Lakehouse Files/Bronze**
   - Uses metadata-driven pattern (Get Metadata + ForEach) for scalability

3. Transform Bronze → Silver with PySpark
   - Type casting, deduplication, null handling, business rule validation
   - Writes curated outputs as **Silver Delta tables**

4. Model Silver → Gold (Customer 360)
   - Creates star-schema tables (facts/dimensions)
   - Stores as **Gold Delta tables** for fast analytics

5. Build Power BI Report
   - Semantic model and measures on Gold tables
   - Dashboards for Customer 360 KPIs


##  Key Design Decisions

### Why Parquet for ingestion?
- Columnar format, compressed, faster reads than CSV
- Efficient for moving raw data from ADLS into Fabric

### Why Delta tables for Silver/Gold?
- **ACID transactions** (reliable updates)
- Better performance with optimizations
- Supports incremental processing patterns and time travel

### Why PySpark?
- Distributed compute for large datasets
- Flexible transformations and data quality enforcement

---

## Output (What you get)
- Cleaned and validated Silver tables
- Business-ready **Gold Customer 360 model
- Power BI dashboards built directly from Gold


