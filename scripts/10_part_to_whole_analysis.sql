/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

USE data_warehouse;

-- Which categories contribute the most to overall sales?
WITH
    category_sales
    AS
    (
        SELECT p.category,
            SUM(s.sales_amount) AS total_sales
        FROM gold.fact_sales AS s
            LEFT JOIN gold.dim_products AS p
            ON s.product_key = p.product_key
        GROUP BY p.category
    )
SELECT category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    ROUND((total_sales / SUM(total_sales) OVER()) * 100, 1) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;