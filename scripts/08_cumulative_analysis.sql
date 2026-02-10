/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

USE data_warehouse;

-- Calculate the total sales per month 
-- and the running total of sales over time 
SELECT order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales
FROM (
    SELECT DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t;

-- Calculate the average price per year
-- and the moving average of price over time
WITH
    avg_price_by_year
    AS
    (
        SELECT YEAR(order_date) AS order_year,
            ROUND(AVG(price), 2) AS avg_price
        FROM gold.fact_sales
        WHERE order_date IS NOT NULL
        GROUP BY YEAR(order_date)
    )

SELECT order_year,
    avg_price,
    ROUND(AVG(avg_price) OVER (ORDER BY order_year), 2) AS moving_avg_price
FROM avg_price_by_year;