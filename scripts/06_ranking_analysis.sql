/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

USE data_warehouse;
GO

-- Which 5 subcategories Generating the Highest Revenue?
-- Simple Ranking
SELECT TOP 5
    p.subcategory,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
    ON s.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC;

-- Complex but Flexibly Ranking Using Window Functions
SELECT TOP 5
    ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount) DESC) AS rank_subcat,
    p.subcategory,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
    ON s.product_key = p.product_key
GROUP BY p.subcategory;

-- Complex but Flexibly Ranking Using Window Functions and Subquery
SELECT *
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount) DESC) AS rank_subcat,
        p.subcategory,
        SUM(s.sales_amount) AS total_revenue
    FROM gold.fact_sales AS s
        LEFT JOIN gold.dim_products AS p
        ON s.product_key = p.product_key
    GROUP BY p.subcategory
    ) AS t
WHERE rank_subcat <= 5;

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
    RANK() OVER (ORDER BY SUM(s.sales_amount) DESC) AS rank_customers,
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_customers AS c
    ON s.customer_key = c.customer_key
GROUP BY c.customer_key,
        c.first_name,
        c.last_name;

-- The 3 customers with the fewest orders placed
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_customers AS c
    ON s.customer_key = c.customer_key
GROUP BY c.customer_key,
        c.first_name,
        c.last_name
ORDER BY total_orders ASC;