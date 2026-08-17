-- Brazilian E-Commerce Olist: Logistics & Customer Satisfaction Analysis
-- Project Overview/Goals: Identify delivery delays, root causes, regional impact & revenue risk

/*--------------------------------------------------
-- Database Setup & Indexing
--------------------------------------------------*/

-- Handle encoding issues from raw CSV ingestion (these were mostly used by Q4 explained more in README.md) 
ALTER TABLE product_category_name_translation 
RENAME COLUMN `ï»¿product_category_name` TO product_category_name;


-- Create B-Tree indexes on core foreign keys to resolve query timeouts (Error 2013)
CREATE INDEX idx_items_order_id ON olist_order_items_dataset(order_id(32));
CREATE INDEX idx_items_product_id ON olist_order_items_dataset(product_id(32));

/*--------------------------------------------------
-- Data Validation & Preparation
--------------------------------------------------*/

-- Check customer data for duplicate customer IDs
SELECT customer_id, COUNT(*) AS record_count
FROM olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- Result: No duplicate customer IDs identified.


-- Check customer data for missing state values
SELECT COUNT(*) AS missing_customer_states
FROM olist_customers_dataset
WHERE customer_state IS NULL
   OR customer_state = '';
-- Result: 0 missing values.


-- Check order items for missing freight values
SELECT COUNT(*) AS missing_freight_values
FROM olist_order_items_dataset
WHERE freight_value IS NULL
   OR freight_value = '';
-- Result: 383 rows returned with a value of 0 (representing free shipping)


-- Check orders for missing delivery dates
SELECT 
    COUNT(*) AS total_orders,
    COUNT(order_approved_at) AS approved_count,
    COUNT(order_delivered_carrier_date) AS carrier_handed_off_count,
    COUNT(order_delivered_customer_date) AS customer_delivered_count,
    (COUNT(*) - COUNT(order_delivered_customer_date)) AS total_undelivered_or_canceled
FROM olist_orders_dataset;


-- Audit orders table for missing delivery dates
-- Note: MySQL import stored empty CSV cells as empty strings ('') rather than NULLs.
SELECT COUNT(*) AS total_orders, SUM(order_delivered_customer_date = '' OR order_delivered_customer_date IS NULL) AS total_undelivered_or_canceled
FROM olist_orders_dataset;
-- Result: 2,965 orders lack delivery dates (canceled/in-transit). 


/*--------------------------------------------------
-- Exploratory Data Analysis & Insights
--------------------------------------------------*/

-- Q1: Does delivery status impact customer review scores?
-- Insight: Late deliveries are associated with a substantial decline in average review scores from 4.24 for on-time/early deliveries to 2.50 for late deliveries.
SELECT 
CASE
	WHEN orders.order_delivered_customer_date > orders.order_estimated_delivery_date THEN 'Late'
	ELSE 'On-Time / Early'
END AS delivery_status,
COUNT(orders.order_id) as total_orders,
ROUND(AVG(reviews.review_score), 2) as average_review
FROM olist_orders_dataset as orders
INNER JOIN olist_order_reviews_dataset as reviews
	ON orders.order_id = reviews.order_id
WHERE order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'
GROUP BY delivery_status;


-- Q2: What is the primary bottleneck for late orders? (Seller vs. Carrier)
-- Insight: On average sellers take roughly 5.8 days to dispatch, whilst carriers take 25.7 days in transit.
SELECT ROUND(AVG(DATEDIFF(order_delivered_carrier_date, order_purchase_timestamp)), 1) AS avg_seller_days, ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date)), 1) AS avg_carrier_days   
FROM olist_orders_dataset
WHERE order_delivered_customer_date > order_estimated_delivery_date
  AND order_status = 'delivered';
 
 
-- Q3: Which customer states experience the worst carrier delays?
-- Insight: Remote northern states (AP, RR, AM, AC, PA) experience the longest average carrier transit times ranging from approximately 42–84 days.
SELECT customer_state, COUNT(ord.order_id) AS total_orders, ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date)), 1) AS avg_carrier_days
FROM olist_orders_dataset as ord
INNER JOIN olist_customers_dataset as cus
	ON ord.customer_id = cus.customer_id
WHERE order_delivered_customer_date > order_estimated_delivery_date
  AND order_status = 'delivered'
GROUP BY customer_state
ORDER BY avg_carrier_days DESC
LIMIT 5;


-- Q4: Which product categories incur the highest freight costs on delayed orders?
-- Insight: High-volume categories such as bed_bath_table and health_beauty, alongside bulky categories such as furniture_decor, account for the highest freight expenditure among delayed orders.
WITH late_orders AS (
SELECT order_id
FROM olist_orders_dataset
WHERE order_delivered_customer_date > order_estimated_delivery_date
  AND order_status = 'delivered'
)
SELECT prodt.product_category_name_english, COUNT(items.order_item_id) as total_late_items, ROUND(SUM(items.freight_value), 2) as total_freight_spent
FROM late_orders as ord
INNER JOIN olist_order_items_dataset as items
	ON ord.order_id = items.order_id
INNER JOIN olist_products_dataset as prod
	ON items.product_id = prod.product_id
INNER JOIN product_category_name_translation as prodt
	ON prod.product_category_name = prodt.product_category_name
GROUP BY prodt.product_category_name_english
ORDER BY total_freight_spent DESC
LIMIT 5;


-- Q5: What is the exact review score distribution for late deliveries?
-- Insight: 50% of all delayed orders receive a 1-star review; 60% are negative (1 or 2 stars)
SELECT review_score, COUNT(review_score) as total_reviews, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct_of_total
FROM olist_orders_dataset as ord
INNER JOIN olist_order_reviews_dataset as rev
	ON ord.order_id = rev.order_id
WHERE order_delivered_customer_date > order_estimated_delivery_date
  AND order_status = 'delivered'
GROUP BY rev.review_score
ORDER BY rev.review_score ASC;

-- Q6: How long do delivery times affect repeat purchases? 
-- Insight: Customers whose first order arrived on-time converted to repeat buyers at 3.04%, compared to just 2.50% for those who experienced a late first delivery representing an 18% relative drop in customer retention due to initial fulfillment failures.

WITH customer_first_orders AS (
SELECT cus.customer_unique_id, ord.order_id, ord.order_purchase_timestamp,
CASE
	WHEN ord.order_delivered_customer_date > ord.order_estimated_delivery_date THEN 'Late'
	ELSE 'On-Time / Early'
END AS first_order_status,
ROW_NUMBER() OVER(PARTITION BY cus.customer_unique_id ORDER BY ord.order_purchase_timestamp ASC) AS order_rank 
FROM olist_orders_dataset as ord													
INNER JOIN olist_customers_dataset as cus
	ON ord.customer_id = cus.customer_id
WHERE order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'),
customer_order_counts AS (
    SELECT cus.customer_unique_id, COUNT(ord.order_id) AS total_orders
    FROM olist_orders_dataset as ord
    INNER JOIN olist_customers_dataset as cus 
        ON ord.customer_id = cus.customer_id
    WHERE ord.order_status = 'delivered'
    GROUP BY cus.customer_unique_id
)
SELECT fo.first_order_status, COUNT(fo.customer_unique_id) AS total_customers, SUM(CASE WHEN co.total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers, ROUND(SUM(CASE WHEN co.total_orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(fo.customer_unique_id), 2) AS repeat_purchase_rate_pct
FROM customer_first_orders as fo
INNER JOIN customer_order_counts as co
    ON fo.customer_unique_id = co.customer_unique_id
WHERE fo.order_rank = 1
GROUP BY fo.first_order_status;
