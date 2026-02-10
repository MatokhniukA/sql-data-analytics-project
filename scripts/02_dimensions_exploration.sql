/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

USE data_warehouse;
GO

-- Explore All Countries our Customers Come from 
SELECT DISTINCT -- Retrieve a list of unique countries from which customers originate
    country
FROM gold.dim_customers
ORDER BY country;

-- Explore All Categories 'The Major Divisions' 
SELECT DISTINCT -- Retrieve a list of unique categories, subcategories, and products
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;