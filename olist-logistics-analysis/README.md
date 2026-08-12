# Brazilian E-Commerce Olist: Logistics Bottleneck & Customer Satisfaction Analysis

## Project Overview

This project analyses **99,000+ orders** from Brazilian e-commerce platform **Olist** to investigate the root causes of delivery delays, quantify their financial and regional impacts and evaluates how fulfilment performance directly influences customer retention and review scores.

[View SQL Script Here](olist_logistics_and_satisfaction_analysis.sql)

*Date Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce* 

##  Key Insights & Findings

### 1. Delivery Delays Severely Impact Satisfaction
* **On-Time / Early Orders:** Average Review Score = **4.24 / 5.0**
* **Late Orders:** Average Review Score = **2.50 / 5.0** (a drop of 1.74 points)
* **Score Distribution:** **50.0%** of all late delivery reviews are **1-star** and nearly **60%** are negative (1 or 2 stars).

### 2. Root Cause: Carrier Transit vs. Seller Dispatch
* **Seller Dispatch Time:** Averages **5.8 days** from purchase.
* **Carrier Transit Time:** Averages **25.7 days** from dispatch to delivery.
* **Takeaway:** Fulfilment bottlenecks are almost entirely concentrated within third-party carrier transit networks rather than seller dispatch delays.

### 3. Regional Vulnerabilities
Remote northern states experience extreme carrier transit delays on late orders:
* **Amapá (AP):** 84.3 days transit time
* **Roraima (RR):** 66.0 days transit time
* **Amazonas (AM):** 54.8 days transit time

### 4. High-Risk Product Categories (Freight Spend)
Freight expenditure on delayed orders is driven by a combination of high order volume and bulky items:
1. **`bed_bath_table`**: 920 late items | **$18,376.26** freight spent
2. **`health_beauty`**: 857 late items | **$17,444.49** freight spent
3. **`furniture_decor`**: 688 late items | **$16,278.61** freight spent

## Technical Optimisation & Problem Solving

During development (specifically while executing Q4 in the EDA section), multi-table `JOIN` queries across 99k+ records hit execution timeouts:

> `Error Code: 2013: Lost connection to MySQL server during query`

To resolve this without altering core schema configurations, a two-pronged optimisation strategy was deployed:

1. **Logical Refactoring (CTEs):** I replaced nested joins with a Common Table Expression (`WITH late_orders AS (...)`) to pre-filter late order IDs prior to scanning secondary item tables.
2. **Database Indexing:** When CTEs alone didn't fully prevent connection timeouts, I researched MySQL query optimization and implemented **prefix B-Tree indexes** on foreign keys (`order_id`, `product_id`). Indexing the text columns allowed MySQL to bypass full table scans:

## Strategic Recommendations

1. **Improve Regional Shipping Networks In Northern States:** Partner with local postal hubs or regional delivery providers specifically in states like AP, RR and AM to tackle extreme 40+ day transit delays.
2. **Review High-Freight Product Categories:** Re-evaluate delivery logistics for high-spend categories like `bed_bath_table`, `health_beauty`, and `furniture_decor` where delayed shipments drive heavy freight costs and low review scores.
3. **Automate Delivery Delay Notifications:** Set up automated email or SMS alerts to notify customers *before* their estimated delivery date passes. Since 50% of delayed orders result in immediate 1-star reviews, proactive communication can help set expectations and protect customer satisfaction.

## 🛠️ Tools Used
MySQL Workbench
