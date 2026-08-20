![Dashboard](dashboard.png)

# Maven Roasters: Sales Performance & Operations Analysis

## Project Overview

This project analyzes 149k+ transactions generating £698k+ in revenue across three retail locations (Lower Manhattan, Astoria and Hell's Kitchen)  for Maven Roasters, a fictional NYC-based coffee shop.

The goal of this analysis is to evaluate revenue performance over time, identify peak operating periods, understand product and category performance and deliver a fully interactive executive dashboard to support data-driven business decisions.

**Data Source:** [Maven Roasters Coffee Shop Sales Dataset](https://www.kaggle.com/datasets/agungpambudi/trends-product-coffee-shop-sales-revenue-dataset)

## Key Insights & Findings

### 1. Revenue & Store Performance

**Total Performance:** Generated **£698,812** in revenue across **149,116 transactions** and **214,470 units sold**, resulting in an Average Transaction Value of **£4.69**.

**Store Performance:** Hell's Kitchen leads total revenue at **£236,511**, followed by Astoria (£232,244) and Lower Manhattan (£230,057).

**Monthly Revenue Growth:** Revenue more than doubled from **£81,677 in January to £166,485 in June**, representing **103.9% growth** over the six-month period.

### 2. Product Categories & Top Performers

**Category Contribution:** Coffee and Tea account for the majority of revenue, generating **£269,952** and **£196,405** respectively.

**Top Revenue Products:** Sustainably Grown Organic Lg generated the highest individual product revenue at **£21,151.75**, followed by Dark Chocolate Lg at **£21,006.00**.

**Volume Leaders:** Earl Grey Rg and Dark Chocolate Lg were the most sold products, with **4,708** and **4,668 units** sold respectively.

### 3. Operational Trends & Customer Behaviour

**Peak Transaction Period:** Transaction volume peaks between **8:00 AM and 10:00 AM**, making the morning period the busiest part of the trading day.

**Revenue vs. Transaction Volume:** Revenue and transaction volume both peak during the morning rush, with revenue reaching its highest hourly level around **10:00 AM**.

**Weekly Consistency:** Transaction volumes remain relatively stable throughout the working week, with Friday recording the highest activity and Saturday showing the lowest.

## Data Cleaning & Preparation

- Audited the source dataset using filters to check for duplicate rows, missing values and blank entries.
- Applied text-cleaning and formatting using **FIND & REPLACE** alongside `=PROPER()` to standardise product and category naming conventions.
- Created helper columns to enable granular analysis by **hour of day, day of week, month and transaction revenue**.
- Converted the raw CSV structure into a formatted Excel table to support Pivot Table analysis and dynamic filtering.

## Dashboard Design & Architecture

Designed an interactive business intelligence dashboard in Microsoft Excel, focusing on visual hierarchy, usability and concise data storytelling.

**Layout & Structure:** Built a structured dashboard layout using KPI cards and visual containers to separate revenue performance, product analysis and operational trends.

**Interactive Control Panel:** Configured a dedicated left-hand sidebar containing global Slicers for **Store Location, Month and Product Category**, connected via Report Connections to dynamically filter the dashboard.

**Key Performance Indicators:** Included Total Revenue, Total Transactions, Units Sold and Average Transaction Value to provide an immediate overview of business performance.

**Actionable Takeaways:** Integrated a dedicated **Key Findings** panel to translate the most important trends into concise business insights.

## Tools Used
Microsoft Excel
