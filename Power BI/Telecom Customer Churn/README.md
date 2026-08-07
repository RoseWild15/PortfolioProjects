### Project Overview

This project has a focus on diagnostic & prescriptive analysis, I specifically chose this telecommunication provider dataset so I could not only perform exploratory data analysis and present my findings but also analyse problems and offer strategic solutions backed by data.

I began with data cleaning, followed by exploratory data analysis done in Python using Pandas and then lastly exported the cleaned csv to use in Power BI to create visualisations. 

*Data Source: https://www.kaggle.com/datasets/blastchar/telco-customer-churn/data*

### Phase 1: Python Data Cleaning

• **Initial Quality Check:** Checked structure using `df.info()`, `df.dtypes`, `df.isnull().sum()` and `df.duplicated().sum()` Brief overview of data, no duplicates & null entries found.

• **Type Conversion & Edge Case:** Attempted to convert TotalCharges from object to float64 using `pd.to_numeric()`, which flagged 11 whitespace records (" ").

• **Root Cause:** Filtered for these records `(df[df["TotalCharges"] == " "])` and discovered all 11 had tenure = 0 *(new accounts that had not yet completed a billing cycle)*.

• **Action Taken:** Dropped these 11 entries given they represented only 0.15% of the dataset, ensuring clean lifetime value and churn calculations.

 ### Phase 2: Python Exploratory Data Analysis (EDA)

• Overall churn rate (26.58%) 

• Analyzed customer lifespan distributions *(tenure)* and identified a high-risk window during months 1–12 where churn peaks before steadily declining as customer tenure increases.

• Discovered that Fiber Optic internet users experience the highest churn rate (41.89%) driven by significantly higher average monthly bills ($91.50 vs. $58.09 for DSL).

• Grouped age data to evaluate demographic risk finding that Senior Citizens churn at nearly double the rate of Non-Seniors (41.68% vs. 23.65%).

• Evaluated add-on features and found that customers without tech support or online security services churn at over 40% compared to those who opt into these services.

• Created a custom boolean feature (Both_Streaming) combining StreamingTV and StreamingMovies to analyze package adoption across contract tiers.

• Compared churn rates across PhoneService options confirming a negligible difference (26.7% vs 24.9%) proving that retention efforts should target internet tiers and add-on bundles rather than basic phone plans.

### Phase 3: Power BI Interactive Dashboard

**Data Import & Modelling:** Imported the cleaned CSV into Power BI and established key DAX measures for dynamic reporting (`Churn Rate`, `Avg Monthly Charge`, `Total Customers`, and `Churned Customers`).

**Custom UI & Modern Dark Theme Layout:** Designed a high-contrast dark theme layout utilising custom container cards (#121212 background with rounded borders and subtle drop shadows) over a charcoal canvas (#0A0A0B) for an intuitive modern app-like UI.

**Multi-Page Dashboard Breakdown:**

**Page 1: Executive Overview**
• Displays main numbers at a glance (`Churn Rate`, `Avg Monthly Charge`, `Total Customers`, `Churned Customers`).

• Breaks down churn across **Contract Types** and **Monthly Charge Ranges**.

• Tracks how churn risk drops over time using a **Tenure (Months)** line graph.

**Page 2: Service & Demographic Diagnostics**
• Focuses on key drivers, comparing Senior Citizen churn against Non-Seniors.

• Highlights Fiber Optic pricing impact ($91.50 avg bill) and how Tech Support helps keep customers.

• Features interactive filter buttons for `Contract` type and `Payment Method`.

**Page 3: Add-Ons & Strategic Recommendations**
• Explores how **Online Security**, **Streaming Add-Ons**, and **Phone Service** impact customer loyalty.

• Includes an **Executive Action Plan** box summarizing 4 clear data-backed retention strategies.
