# Faasos SQL Analysis
A SQL-based analysis of order trends, driver performance, and customer behavior.

## Project Overview
This project performs an in-depth SQL analysis of Faasos customer orders, roll types, delivery performance, and driver efficiency. It aims to provide actionable insights into order patterns, customer preferences, cancellations, and delivery success rates.

## Data Description
The project uses six main tables to model the business:

- **driver**: Information about delivery drivers and their registration dates  
- **ingredients**: List of ingredients used in rolls  
- **rolls**: Different types of rolls (e.g., Veg Roll, Non Veg Roll)  
- **rolls_recipes**: Mapping of rolls to their ingredient IDs  
- **driver_order**: Driver assignments per order, pickup times, distances, durations, and cancellations  
- **customer_orders**: Customer order details including roll types, order date, and any customizations (exclusions or extras)

## Features and Analysis
- Calculation of roll metrics such as total rolls ordered, rolls delivered, and customer-specific preferences  
- Identification of successful vs. canceled orders with detailed filtering of cancellation reasons  
- Use of SQL window functions (`ROW_NUMBER()`) and Common Table Expressions (CTEs) for advanced customer preference analysis  
- Aggregation queries to determine delivery success rates, average driver pickup times, and order frequency by time and day  
- Analysis of order modifications including exclusions and extras  

## Tools and Techniques Used
- SQL aggregations: `COUNT()`, `SUM()`, `AVG()`  
- Conditional logic with `CASE` statements  
- Joins (`INNER JOIN`, `LEFT JOIN`) to combine customer and driver data  
- Window functions such as `ROW_NUMBER()` for ranking  
- Common Table Expressions (CTEs) for modular query building  


## Assumptions & Notes
- Cancellation statuses are standardized for filtering but may require additional cleaning if raw data changes.  
- Null and empty values in customization columns are carefully handled to distinguish changed vs. unchanged orders.  
- Delivery success is defined as orders without cancellation flags in the `driver_order` table.

