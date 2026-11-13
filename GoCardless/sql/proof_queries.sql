-- GoCardless Junior Data Analyst case study — STEP 2: PROOF
-- Dialect: standard SQL, tested in DuckDB. For BigQuery: change read_csv_auto(...) to your table,
-- and replace `date_trunc('month', created_at)` with DATE_TRUNC(DATE(created_at), MONTH).
-- Grain: one row per payment ATTEMPT. attempt_number = 1 is the first attempt; > 1 is a retry.

-- name: 00_setup
CREATE OR REPLACE VIEW attempts AS
SELECT * FROM read_csv_auto('data/synthetic_payment_attempts.csv');

-- name: 01_data_quality
-- Can we trust the table? Every check should return 0 (or equal values) before we read any KPI.
SELECT
  COUNT(*)                                                         AS rows_total,
  COUNT(DISTINCT transaction_id)                                   AS distinct_transactions,   -- must equal rows_total
  COUNT(DISTINCT payment_id)                                       AS distinct_payments,
  COUNT(*) FILTER (WHERE amount_eur IS NULL OR amount_eur <= 0)    AS bad_amount,
  COUNT(*) FILTER (WHERE status NOT IN ('Succeeded','Failed'))     AS bad_status,
  COUNT(*) FILTER (WHERE payment_id IS NULL OR transaction_id IS NULL) AS missing_keys,
  COUNT(*) FILTER (WHERE status = 'Failed' AND failure_reason IS NULL)    AS failed_without_reason,
  COUNT(*) FILTER (WHERE status = 'Succeeded' AND failure_reason IS NOT NULL) AS success_with_reason,
  COUNT(*) FILTER (WHERE (attempt_number > 1) <> is_retry)         AS retry_flag_mismatch,
  COUNT(*) FILTER (WHERE created_at >= TIMESTAMP '2026-11-01')     AS rows_after_oct_window
FROM attempts;

-- name: 02_payment_grain_check
-- Does every payment have exactly one first attempt, and are retries only on failed first attempts?
SELECT
  COUNT(*) FILTER (WHERE n_first <> 1)                    AS payments_without_exactly_one_first_attempt,
  COUNT(*) FILTER (WHERE n_retry > 0 AND first_status <> 'Failed') AS retries_on_non_failed_payment
FROM (
  SELECT payment_id,
         COUNT(*) FILTER (WHERE attempt_number = 1) AS n_first,
         COUNT(*) FILTER (WHERE attempt_number > 1) AS n_retry,
         MAX(status) FILTER (WHERE attempt_number = 1) AS first_status
  FROM attempts GROUP BY payment_id
);

-- name: 03_Q3_how_often_do_payments_fail
-- Headline + monthly trend (month = month of the first attempt).
SELECT strftime(date_trunc('month', created_at), '%Y-%m') AS month,
       COUNT(*)                                            AS first_attempts,
       COUNT(*) FILTER (WHERE status = 'Failed')           AS failed,
       ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Failed') / COUNT(*), 1) AS first_attempt_failure_pct
FROM attempts WHERE attempt_number = 1
GROUP BY 1
UNION ALL
SELECT 'ALL', COUNT(*), COUNT(*) FILTER (WHERE status = 'Failed'),
       ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Failed') / COUNT(*), 1)
FROM attempts WHERE attempt_number = 1
ORDER BY 1;

-- name: 04_Q1_why_do_payments_fail
-- Reasons by count AND value, with the share of each (frequency alone can mislead).
SELECT failure_reason,
       COUNT(*)                                        AS failed_first_attempts,
       ROUND(SUM(amount_eur), 2)                       AS failed_value_eur,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)        AS pct_of_failures,
       ROUND(100.0 * SUM(amount_eur) / SUM(SUM(amount_eur)) OVER (), 1) AS pct_of_failed_value
FROM attempts WHERE attempt_number = 1 AND status = 'Failed'
GROUP BY failure_reason ORDER BY failed_value_eur DESC;

-- name: 05_Q2_do_retries_work
-- Retry coverage (how many failures get retried) and recovery (how many retries succeed), by failure reason.
WITH first_failed AS (
  SELECT payment_id, failure_reason, amount_eur FROM attempts
  WHERE attempt_number = 1 AND status = 'Failed'
), retry AS (
  SELECT payment_id, status AS retry_status FROM attempts WHERE attempt_number > 1
)
SELECT f.failure_reason,
       COUNT(*)                                                    AS failed_first,
       COUNT(r.payment_id)                                         AS retried,
       ROUND(100.0 * COUNT(r.payment_id) / COUNT(*), 1)            AS retry_coverage_pct,
       COUNT(*) FILTER (WHERE r.retry_status = 'Succeeded')        AS recovered,
       ROUND(100.0 * COUNT(*) FILTER (WHERE r.retry_status = 'Succeeded') / NULLIF(COUNT(r.payment_id),0), 1) AS recovery_pct_of_retried
FROM first_failed f LEFT JOIN retry r USING (payment_id)
GROUP BY ROLLUP (f.failure_reason) ORDER BY retried DESC NULLS FIRST;

-- name: 06_Q5_failed_value_after_retries
-- The number the business actually cares about: value still uncollected after retries.
WITH last_attempt AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY attempt_number DESC) AS rn FROM attempts
), first_failed AS (
  SELECT payment_id, amount_eur FROM attempts WHERE attempt_number = 1 AND status = 'Failed'
)
SELECT ROUND((SELECT SUM(amount_eur) FROM first_failed), 2)                               AS initial_failed_value_eur,
       ROUND((SELECT SUM(amount_eur) FROM last_attempt WHERE rn = 1 AND status = 'Failed'), 2) AS still_failed_after_retries_eur,
       ROUND((SELECT SUM(amount_eur) FROM first_failed) -
             (SELECT SUM(amount_eur) FROM last_attempt WHERE rn = 1 AND status = 'Failed'), 2) AS recovered_by_retries_eur,
       ROUND((SELECT SUM(amount_eur) FROM attempts WHERE attempt_number = 1), 2)           AS total_initial_value_eur;

-- name: 07_Q4_which_merchants_fail
-- Segment x method, with sample size so small groups are not over-read. Ranked by money at risk.
SELECT merchant_segment, payment_method,
       COUNT(*)                                          AS first_attempts,
       COUNT(*) FILTER (WHERE status = 'Failed')         AS failed,
       ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Failed') / COUNT(*), 1) AS failure_pct,
       ROUND(SUM(amount_eur) FILTER (WHERE status = 'Failed'), 2)             AS failed_value_eur
FROM attempts WHERE attempt_number = 1
GROUP BY 1, 2 ORDER BY failed_value_eur DESC;

-- name: 08_reconciliation
-- Proof that the pieces add up. Every diff should be 0.
SELECT
  (SELECT COUNT(*) FROM attempts WHERE attempt_number = 1) - (SELECT COUNT(DISTINCT payment_id) FROM attempts) AS first_attempts_minus_payments,
  (SELECT SUM(failed_value) FROM (SELECT SUM(amount_eur) AS failed_value FROM attempts WHERE attempt_number = 1 AND status='Failed' GROUP BY failure_reason))
   - (SELECT SUM(amount_eur) FROM attempts WHERE attempt_number = 1 AND status='Failed')                       AS reasons_vs_total_value,
  (SELECT SUM(failed) FROM (SELECT COUNT(*) FILTER (WHERE status='Failed') AS failed FROM attempts WHERE attempt_number=1 GROUP BY merchant_segment, payment_method))
   - (SELECT COUNT(*) FROM attempts WHERE attempt_number=1 AND status='Failed')                               AS segment_method_vs_total_failures;
