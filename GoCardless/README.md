# GoCardless Junior Data Analyst — independent case study

This project demonstrates a small payment-operations analytics workflow aligned to the public Junior Data Analyst job description.

**Important:** all records are synthetic. No GoCardless internal, customer, or confidential data is used. The project is not affiliated with GoCardless.

## Files
- `data/synthetic_payment_attempts.csv` — one row per payment attempt
- `sql/analysis_queries.sql` — BigQuery Standard SQL examples
- `docs/business_handover_memo.md` — findings, definitions, caveats and handover
- `requirements.txt` — Python dependencies for optional exploration

## Data model and grain
Each row represents a single attempt to collect a payment. `payment_id` groups attempts belonging to the same payment intent; `transaction_id` identifies the individual attempt. `attempt_number=1` is the initial attempt; higher values are retries.

## Suggested Power BI model
Import the CSV. Create a date table and relate it to `created_at` (date). Use `payment_id` for payment-level measures and `transaction_id` for attempt-level measures. Do not count retries as new payment intents.

Suggested measures:
- First-attempt success rate
- Final payment success rate
- Retry recovery rate
- Retry coverage
- Initial failed payment value
- Failed attempts by reason

## How to reproduce
1. Open the CSV in Excel or load it into DuckDB (or any SQL database).
2. Run `sql/proof_queries.sql` (DuckDB) from the project folder; `sql/analysis_queries.sql` is the earlier BigQuery-dialect draft.
3. Run the quality checks before interpreting KPI outputs.
4. Open `index.html` for the interactive dashboard.

## Scope limitations
The data is simulated and intentionally simplified. It is suitable for demonstrating SQL, KPI logic, data-quality thinking and communication, not for estimating actual payment industry or GoCardless performance.
