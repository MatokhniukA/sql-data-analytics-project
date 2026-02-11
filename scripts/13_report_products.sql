/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
       - average selling price
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

USE data_warehouse;
GO

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products
AS

    WITH
        base_query
        AS
        (
            -- Step 1. Base Query: Retrieves core columns from fact_sales and dim_products
            SELECT s.order_number,
                s.customer_key,
                s.order_date,
                s.sales_amount,
                s.quantity,
                p.product_key,
                p.product_name,
                p.category,
                p.subcategory,
                p.cost
            FROM gold.fact_sales AS s
                LEFT JOIN gold.dim_products AS p
                ON s.product_key = p.product_key
            WHERE s.order_date IS NOT NULL
            -- only consider valid sales dates
        )
,
        product_aggregation
        AS
        (
            -- Step 2. Customer Aggregations: Summarizes key metrics at the product level
            SELECT product_key,
                product_name,
                category,
                subcategory,
                cost,
                MAX(order_date) AS last_sale_date,
                DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
                COUNT(DISTINCT order_number) AS total_orders,
                COUNT(DISTINCT customer_key) AS total_customers,
                SUM(sales_amount) AS total_sales,
                SUM(quantity) AS total_quantity,
                ROUND(AVG(sales_amount / NULLIF(quantity, 0)), 1) AS avg_selling_price
            FROM base_query
            GROUP BY product_key,
    product_name,
    category,
    subcategory,
    cost
        )
    -- Step 3. Combines all product results into one output
    SELECT product_key,
        product_name,
        category,
        subcategory,
        cost,
        last_sale_date,
        DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months, -- recency (months since last order)
        -- Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers
        CASE WHEN total_sales > 50000 THEN 'High-Performers'
            WHEN total_sales >= 10000 THEN 'Mid-Range'
            ELSE 'Low-Performers'
        END AS product_segment,
        lifespan,
        total_orders,
        total_sales,
        total_quantity,
        total_customers,
        avg_selling_price,

        -- Calculates valuable KPIs
        -- Computes Average Order Revenue (AOR = Total Sales / Total Nr. of Orders)
        CASE WHEN total_orders = 0 THEN 0
            ELSE ROUND(total_sales / total_orders, 2)
        END AS avg_order_revenue,

        -- Computes Average Monthly Revenue (AMR = Total Sales / Nr. of Months)
        CASE WHEN lifespan = 0 THEN total_sales
            ELSE ROUND(total_sales / lifespan, 2)
        END AS avg_monthly_revenue
    FROM product_aggregation;
GO

-- SELECT product_segment,
-- COUNT(product_key) AS total_products,
-- SUM(total_sales) AS total_sales
-- FROM gold.report_products
-- GROUP BY product_segment;

-- SELECT category,
-- COUNT(product_key) AS total_products,
-- SUM(total_sales) AS total_sales
-- FROM gold.report_products
-- GROUP BY category;