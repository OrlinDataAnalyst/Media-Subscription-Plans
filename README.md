# 📊 Media Subscription Analytics Dashboard

## 📌 Project Overview

This project analyzes a subscription-based (SaaS/media) business using SQL and Power BI.

The goal is to track key business metrics such as:

* Monthly Recurring Revenue (MRR)
* Customer churn
* Average Revenue Per User (ARPU)
* Customer Lifetime Value (LTV)

The project demonstrates end-to-end data analysis:

* Data cleaning in SQL
* Data modeling
* KPI calculation using DAX
* Dashboard creation in Power BI

---

## 🛠️ Tools & Technologies

* SQL Server
* Power BI
* DAX
* Data Modeling

---

## 🗂️ Dataset

The dataset contains subscription-level data with:

* account_id
* plan_tier (Basic, Pro, Enterprise)
* billing_frequency (monthly / annual)
* start_date, end_date
* mrr_amount, arr_amount (stored in cents)

---

## ⚙️ Data Preparation (SQL)

A clean view was created to:

* Convert revenue from cents to currency
* Standardize fields for Power BI

```sql
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
```

---

## 📈 Key Metrics

### 1. MRR (Monthly Recurring Revenue)

Sum of revenue from active subscriptions.

### 2. Active Subscriptions

Number of active paid subscriptions at a given point in time.

### 3. Monthly Churn Rate

Calculated as:
Monthly Churn = Churned Subscriptions / Active Subscriptions (Start of Month)

### 4. ARPU (Average Revenue Per User)

ARPU = MRR / Active Subscriptions

### 5. LTV (Customer Lifetime Value)

LTV = ARPU / Average Churn Rate

---

## 📊 Dashboards

### 🔹 Business Overview

* Active Subscriptions
* MRR Growth Trend
* Monthly Churn Rate
* ARPU

### 🔹 KPI Analysis

* Churn trend over time
* Subscription distribution by plan
* Customer Lifetime Value

---

## 🔍 Key Insights

* MRR shows strong and accelerating growth, especially in late 2024
* Average churn is around 8%, with spikes up to 33%
* Revenue growth outpaces churn, indicating strong acquisition
* ARPU remains stable (~$26), suggesting consistent pricing
* LTV is approximately $300+, indicating solid customer value

---

## 🧠 Key Learnings

* Churn is a non-additive metric and must be averaged over time
* Data modeling is critical for correct KPI calculations
* Handling multiple subscriptions per account affects metrics like ARPU
* SQL preprocessing simplifies Power BI logic significantly

---

## 🚀 How to Use

1. Run the SQL script to create the clean view
2. Import `vw_subscriptions_clean` into Power BI
3. Create relationships with Date table
4. Use DAX measures to calculate KPIs
5. Build dashboards as shown

---

## 📌 Author

Orlin Data Analyst
---
