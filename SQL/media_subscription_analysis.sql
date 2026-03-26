/* ============================================================
   MEDIA SUBSCRIPTION ANALYTICS
   Dataset: SaaS Subscriptions (treated as Media Subscriptions)
   Clean Final Version – Revenue Corrected (Cents → Currency)
   ============================================================ */


/* ============================================================
   0. CLEAN REVENUE VIEW (Correcting cents to currency)
   ============================================================ */

-- This view converts mrr_amount and arr_amount from cents to decimal currency

CREATE OR ALTER VIEW vw_subscriptions_clean AS
SELECT
    account_id,
    plan_tier,
    billing_frequency,
    is_trial,
    start_date,
    end_date,

    CAST(mrr_amount AS DECIMAL(18,2)) / 100.0 AS mrr_amount,
    CAST(arr_amount AS DECIMAL(18,2)) / 100.0 AS arr_amount

FROM subscriptions;
GO


/* ============================================================
   1. ACTIVE PAID SUBSCRIPTIONS
   Definition:
   - Paid subscription
   - No end_date (currently active)
   - COUNT(*) = total subscriptions
   - COUNT(DISTINCT account_id) = unique customers
   - Dataset contains multiple subscriptions per account
   ============================================================ */

-- Total active paid subscriptions
SELECT
    COUNT(*) AS active_subscriptions
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL;


-- Total active paid subscriptions by plan tier
SELECT
    plan_tier,
    COUNT(*) AS active_paid_subscriptions
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL
GROUP BY plan_tier
ORDER BY active_paid_subscriptions DESC;


-- Total active paid subscriptions by billing frequency
SELECT
    billing_frequency,
    COUNT(*) AS active_paid_subscriptions
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL
GROUP BY billing_frequency
ORDER BY active_paid_subscriptions DESC;


-- Unique customers with active paid subscriptions
SELECT
    COUNT(DISTINCT account_id) AS active_paid_subscribers
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL;


-- Total accounts with multiple active paid subscriptions (potential upsells or multiple products)
SELECT
    account_id,
    COUNT(*) AS active_subscriptions
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY active_subscriptions DESC;



/* ============================================================
   2. TRIAL → PAID CONVERSION
   ============================================================ */

-- Trial to paid conversion within 30 days
WITH trial_subs AS (
    SELECT
        account_id,
        start_date AS trial_start
    FROM vw_subscriptions_clean
    WHERE is_trial = 1
),
paid_subs AS (
    SELECT
        account_id,
        MIN(start_date) AS paid_start
    FROM vw_subscriptions_clean
    WHERE is_trial = 0
    GROUP BY account_id
)
SELECT
    COUNT(DISTINCT CASE
        WHEN p.paid_start IS NOT NULL
         AND p.paid_start <= DATEADD(day, 30, t.trial_start)
        THEN t.account_id
    END) * 1.0
    / COUNT(DISTINCT t.account_id) AS conversion_rate_30d
FROM trial_subs t
LEFT JOIN paid_subs p
    ON t.account_id = p.account_id;



/* ============================================================
   3. CHURN ANALYSIS
   Definition:
   - Paid subscription with end_date
   - Churn rate represents total churned users over total paid users, not time-based churn. Monthly churn is calculated in Power BI
   ============================================================ */

-- Overall churn rate (paid users only)
SELECT
    COUNT(DISTINCT CASE
        WHEN end_date IS NOT NULL AND is_trial = 0
        THEN account_id
    END) * 1.0
    / COUNT(DISTINCT CASE
        WHEN is_trial = 0
        THEN account_id
    END) AS churn_rate
FROM vw_subscriptions_clean;


-- Churn rate by plan tier
SELECT
    plan_tier,
    COUNT(DISTINCT CASE
        WHEN end_date IS NOT NULL AND is_trial = 0
        THEN account_id
    END) * 1.0
    / COUNT(DISTINCT CASE
        WHEN is_trial = 0
        THEN account_id
    END) AS churn_rate
FROM vw_subscriptions_clean
GROUP BY plan_tier
ORDER BY churn_rate DESC;


-- Churn rate by billing frequency
SELECT
    billing_frequency,
    COUNT(DISTINCT CASE
        WHEN end_date IS NOT NULL AND is_trial = 0
        THEN account_id
    END) * 1.0
    / COUNT(DISTINCT CASE
        WHEN is_trial = 0
        THEN account_id
    END) AS churn_rate
FROM vw_subscriptions_clean
GROUP BY billing_frequency;



/* ============================================================
   4. MONTHLY CHURN TREND
   ============================================================ */

-- Monthly churned users (paid only)
SELECT
    DATEFROMPARTS(YEAR(end_date), MONTH(end_date), 1) AS churn_month,
    COUNT(DISTINCT account_id) AS churned_users
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(end_date), MONTH(end_date), 1)
ORDER BY churn_month;



/* ============================================================
   5. REVENUE METRICS (Monthly Recurring Revenue - MRR / Annual Recurring Revenue - ARR)
   -- MRR is calculated at subscription level
   -- If accounts have multiple active subscriptions, revenue reflects total subscriptions, not unique customers
   ============================================================ */

-- Total MRR and ARR from active paid subscriptions
SELECT
    SUM(mrr_amount) AS total_mrr,
    SUM(arr_amount) AS total_arr
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL;


-- New MRR from newly started paid subscriptions
-- This represents MRR from new subscriptions, not true Net New MRR
SELECT
    DATEFROMPARTS(YEAR(start_date), MONTH(start_date), 1) AS revenue_month,
    SUM(mrr_amount) AS new_mrr
FROM vw_subscriptions_clean
WHERE is_trial = 0
GROUP BY DATEFROMPARTS(YEAR(start_date), MONTH(start_date), 1)
ORDER BY revenue_month;


-- New ARR from newly started paid subscriptions
SELECT
    DATEFROMPARTS(YEAR(start_date), MONTH(start_date), 1) AS revenue_month,
    SUM(arr_amount) AS new_arr
FROM vw_subscriptions_clean
WHERE is_trial = 0
GROUP BY DATEFROMPARTS(YEAR(start_date), MONTH(start_date), 1)
ORDER BY revenue_month;


-- MRR by plan tier (active paid subscriptions)
SELECT
    plan_tier,
    SUM(mrr_amount) AS total_mrr
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL
GROUP BY plan_tier
ORDER BY total_mrr DESC;


-- MRR by billing frequency (active paid subscriptions)
SELECT
    billing_frequency,
    SUM(mrr_amount) AS total_mrr
FROM vw_subscriptions_clean
WHERE is_trial = 0
  AND end_date IS NULL
GROUP BY billing_frequency
ORDER BY total_mrr DESC;
