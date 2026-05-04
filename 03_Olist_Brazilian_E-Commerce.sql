-- ============================================
-- CUSTOMER RETENTION AND REVENUE ANALYSIS
-- Dataset: Olist Brazilian E-Commerce
-- Database: ecommerce_analytics
-- ============================================

USE ecommerce_analytics;


-- ============================================
-- I. DATA VALIDATION
-- ============================================

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_order_items
FROM order_items;


-- ============================================
-- II. CORE BUSINESS KPIs
-- ============================================

-- Total revenue
SELECT 
    ROUND(SUM(price), 2) AS total_product_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight_revenue,
    ROUND(SUM(price + freight_value), 2) AS total_order_item_value
FROM order_items;

-- Average order value
SELECT 
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id;


-- ============================================
-- III. CUSTOMER ENGAGEMENT ANALYSIS
-- ============================================

-- Number of customer records vs real unique customers
SELECT 
    COUNT(customer_id) AS total_customer_records,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;

-- Orders per real customer
SELECT 
    customer_unique_id,
    COUNT(customer_id) AS total_orders
FROM customers
GROUP BY customer_unique_id
ORDER BY total_orders DESC;

-- Repeat purchase distribution
SELECT
    total_orders,
    COUNT(*) AS number_of_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM (
    SELECT
        customer_unique_id,
        COUNT(customer_id) AS total_orders
    FROM customers
    GROUP BY customer_unique_id
) customer_orders
GROUP BY total_orders
ORDER BY total_orders;


-- ============================================
-- IV. CUSTOMER VALUE ANALYSIS
-- ============================================

-- Top customers by total spent
SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_spent,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- Top customers by order frequency
SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_spent
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;


-- ============================================
-- V. CUSTOMER SEGMENTATION MODEL
-- ============================================

SELECT 
    customer_segment,
    COUNT(*) AS number_of_customers,
    ROUND(AVG(total_spent), 2) AS avg_total_spent,
    ROUND(AVG(total_orders), 2) AS avg_total_orders,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.price) AS total_spent,
        SUM(oi.price) / COUNT(DISTINCT o.order_id) AS avg_order_value,
        CASE 
            WHEN COUNT(DISTINCT o.order_id) >= 5 THEN 'High Frequency'
            WHEN SUM(oi.price) >= 1000 THEN 'High Value'
            WHEN SUM(oi.price) / COUNT(DISTINCT o.order_id) >= 300 THEN 'High Ticket'
            ELSE 'Regular'
        END AS customer_segment
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) segmented_customers
GROUP BY customer_segment
ORDER BY avg_total_spent DESC;


-- ============================================
-- VI. GEOGRAPHIC ANALYSIS
-- ============================================

-- Customer concentration by state
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(
        COUNT(DISTINCT customer_unique_id) * 100.0 
        / SUM(COUNT(DISTINCT customer_unique_id)) OVER (),
        2
    ) AS percentage_of_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Orders by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0
        / SUM(COUNT(DISTINCT o.order_id)) OVER (),
        2
    ) AS percentage_of_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

-- Revenue by state
SELECT 
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================
-- VII. TIME ANALYSIS
-- ============================================

-- Monthly revenue trend
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- ============================================
-- VIII. BUSINESS INSIGHTS
-- ============================================

-- Insight 1:
-- Most customers buy only once, which shows weak repeat-purchase behavior.

-- Insight 2:
-- High Frequency customers are rare, so customer retention is a major opportunity.

-- Insight 3:
-- High Value and High Ticket customers are important because they generate strong revenue.

-- Insight 4:
-- Customers, orders, and revenue are concentrated in specific states.

-- Insight 5:
-- Monthly revenue trends can help identify growth periods and seasonal patterns.

-- Recommendation:
-- Focus on retention campaigns for High Value and High Ticket customers,
-- especially in the states with the highest customer and revenue concentration.