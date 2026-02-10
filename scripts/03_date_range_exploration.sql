/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

USE data_warehouse;
GO

-- Determine the first and last order date and the total duration in years and months
SELECT MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(year, MIN(birthdate), GETDATE()) as oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) as youngest_age
FROM gold.dim_customers;

-- Another option of solving
    SELECT 'The Oldest' AS customer,
        MIN(birthdate) AS birthdate,
        DATEDIFF(YEAR, MIN(birthdate), GETDATE()) as age
    FROM gold.dim_customers
UNION ALL
    SELECT 'The Youngest' AS customer,
        MAX(birthdate),
        DATEDIFF(YEAR, MAX(birthdate), GETDATE())
    FROM gold.dim_customers;