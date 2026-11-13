-- GoCardless Junior Data Analyst case study
-- Dataset: synthetic_payment_attempts.csv
-- SQL dialect: BigQuery Standard SQL (DATE/TIMESTAMP functions may need minor adaptation).

-- 1. Data quality checks: nulls, duplicates, invalid amounts, unexpected statuses.
SELECT
  COUNT(*) AS row_count,
  COUNT(DISTINCT transaction_id) AS distinct_transactions,
  COUNTIF(amount_eur IS NULL OR amount_eur <= 0) AS invalid_amount_rows,
  COUNTIF(status NOT IN ('Succeeded', 'Failed')) AS unexpected_status_rows,
  COUNTIF(payment_id IS NULL OR transaction_id IS NULL) AS missing_key_rows
FROM `project.dataset.synthetic_payment_attempts`;

-- 2. First-attempt success rate by month.
SELECT
  FORMAT_DATE('%Y-%m', DATE(created_at)) AS month,
  COUNT(*) AS payment_count,
  SAFE_DIVIDE(COUNTIF(status = 'Succeeded'), COUNT(*)) AS first_attempt_success_rate
FROM `project.dataset.synthetic_payment_attempts`
WHERE attempt_number = 1
GROUP BY month
ORDER BY month;

-- 3. Payment success rate by merchant segment and payment method.
SELECT
  merchant_segment,
  payment_method,
  COUNT(*) AS first_attempts,
  SAFE_DIVIDE(COUNTIF(status = 'Succeeded'), COUNT(*)) AS success_rate
FROM `project.dataset.synthetic_payment_attempts`
WHERE attempt_number = 1
GROUP BY merchant_segment, payment_method
ORDER BY success_rate;

-- 4. Retry recovery rate.
SELECT
  COUNT(*) AS retry_attempts,
  COUNTIF(status = 'Succeeded') AS recovered_payments,
  SAFE_DIVIDE(COUNTIF(status = 'Succeeded'), COUNT(*)) AS retry_recovery_rate
FROM `project.dataset.synthetic_payment_attempts`
WHERE is_retry = TRUE;

-- 5. Failure reasons by count and value (first attempts only).
SELECT
  failure_reason,
  COUNT(*) AS failed_attempts,
  SUM(amount_eur) AS failed_payment_value_eur,
  SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER()) AS share_of_failures
FROM `project.dataset.synthetic_payment_attempts`
WHERE attempt_number = 1 AND status = 'Failed'
GROUP BY failure_reason
ORDER BY failed_attempts DESC;

-- 6. Latest known outcome per payment (first attempt or retry).
WITH ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY attempt_number DESC) AS rn
  FROM `project.dataset.synthetic_payment_attempts`
)
SELECT
  COUNT(*) AS payment_count,
  COUNTIF(status = 'Succeeded') AS ultimately_succeeded,
  SAFE_DIVIDE(COUNTIF(status = 'Succeeded'), COUNT(*)) AS final_success_rate
FROM ranked
WHERE rn = 1;
