# Payment collection performance — analyst handover memo

**Project type:** Independent portfolio demonstration  
**Data:** Entirely synthetic; not GoCardless internal or customer data  
**Observation window:** payments first attempted 1 May–31 October 2026 (11 retries of late-October payments fall in early November 2026)  
**Grain:** One row per payment attempt; a payment may have more than one attempt.

## Executive summary

This sample contains 8,000 unique payment intents and 8,576 payment-attempt records. The first-attempt success rate is **91.1%**. Among retry attempts represented in the sample, **49.1%** succeeded. After the final recorded attempt, the payment-level success rate is **94.6%**.

These figures are generated from synthetic data to demonstrate an analytical workflow. They must not be interpreted as GoCardless performance benchmarks.

## What I would tell an operations stakeholder

1. Monitor first-attempt success separately from final payment success. They answer different questions: initial collection reliability versus recovery after intervention.
2. Prioritise failure reasons by both frequency and value. A frequent low-value issue may need a different response from a rare high-value issue.
3. Compare performance by merchant segment and payment method, but check sample sizes before treating differences as operationally meaningful.
4. Track retry recovery alongside retry coverage. A recovery rate without the proportion of eligible failures retried can be misleading.

## Results from this synthetic sample

- First-attempt success rate: **91.1%**
- Retry attempts: **576**
- Retry recovery rate: **49.1%**
- Final payment-level success rate: **94.6%**
- Initial failed payment value: **€33,172.39**
- Initial payment value: **€370,687.06** (failed first attempts = 8.9% of value)
- Retry coverage: **80.7%** (576 of 714 failed first attempts were retried)

### Largest failure categories

- Insufficient funds: 41.5% of first-attempt failures
- Payment declined: 26.8% of first-attempt failures
- Bank unavailable: 13.2% of first-attempt failures
- Mandate issue: 9.8% of first-attempt failures
- Account closed: 8.8% of first-attempt failures
## Metric definitions

- **First-attempt success rate:** successful attempt-1 rows divided by all attempt-1 rows.
- **Retry recovery rate:** successful retry rows divided by all retry rows. This is attempt-level, not unique-payment-level.
- **Final payment success rate:** latest recorded attempt status per payment, successful payments divided by all unique payments.
- **Initial failed payment value:** sum of amounts for failed attempt-1 rows. This is exposure at first attempt, not necessarily lost revenue.

## Data-quality and interpretation checks

- Confirm one unique transaction ID per attempt and one or more attempts per payment ID.
- Check positive amounts, valid statuses, valid attempt numbers and timestamp consistency.
- Ensure retries are not counted as new unique payment intents in payment-level KPIs.
- Confirm the business definition of “success”, “recovered”, and the observation window with stakeholders.
- The sample has no customer identifiers, bank-level details, chargebacks, fees, refunds, or detailed retry policy. It cannot support causal claims or customer-level segmentation.

## Recommended dashboard pages

1. **Overview:** total unique payments, first-attempt success, final success, retry recovery and initial failed value.
2. **Reliability:** monthly success trend, merchant segment and payment-method breakdown.
3. **Failure analysis:** reason frequency, failed value, retry coverage and recovery.
4. **Data quality:** missing keys, duplicate transaction IDs, invalid amounts/statuses and late/out-of-order attempts.

## Suggested next steps in a real analytics team

1. Validate source tables and metric definitions with the Analytics team.
2. Reconcile payment attempt records against the canonical payment model.
3. Build tested dbt models for payment intents and attempts, keeping the grain explicit.
4. Publish a Looker explore/dashboard with documented dimensions and measures.
5. Review the dashboard with Operations and Business Services users; capture feedback and iterate.

## Tools and stack mapping

This portfolio version uses CSV + SQL (tested in DuckDB), Excel PivotTables for exploration, and an interactive HTML/Plotly dashboard. The GoCardless job listing names SQL, dbt, Looker, DOMO and Amplitude. In that environment I would model payments and attempts in dbt with tested definitions, publish the dashboard in Looker or DOMO, and follow the team's conventions rather than assume this prototype is production-ready. Amplitude (event data) is out of scope for this dataset.
