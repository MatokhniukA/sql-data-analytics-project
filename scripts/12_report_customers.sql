/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

USE data_warehouse;

WITH
    t1
    AS
    (
        SELECT c. customer_key,
            c. first_name,
            c.last_name,
            DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age,
            s.order_number,
            s.sales_amount,
            s.quantity,
            s.order_date,
            p.product_name
        FROM gold.fact_sales AS s
            LEFT JOIN gold.dim_customers AS c
            ON s.customer_key = c.customer_key
            LEFT JOIN gold.dim_products AS p
            ON s.product_key = p.product_key
    )

SELECT CONCAT(first_name, ' ', last_name) AS full_name,
    age,
    SUM(sales_amount) AS total_sales,
    COUNT(order_number) AS total_orders,
    SUM(quantity) AS total_quantity,
    COUNT(product_name) AS total_priducts,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM t1
GROUP BY CONCAT(first_name, ' ', last_name), age