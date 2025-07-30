/*
Title: Faasos SQL Analysis
Description: Key queries to analyze orders, customers, and delivery performance.
Author: Jahanavi Sharma

Objective:
Analyze customer orders, roll preferences, delivery performance, and driver efficiency.

Data Description:
- driver: Driver details
- ingredients: Ingredients list
- rolls: Roll types
- rolls_recipes: Ingredients per roll
- driver_order: Delivery and driver info per order
- customer_orders: Customer order details

Tools and SQL Features Used:
- Aggregation functions (COUNT, SUM, AVG)
- Joins and filtering
- Conditional logic with CASE
- Common Table Expressions (CTEs)
- Window functions (ROW_NUMBER)

*/


drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1, '2021-01-01'),
(2, '2021-03-01'),
(3, '2021-08-01'),
(4, '2021-01-15');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1, 1, '2021-01-01 18:15:34', '20km', '32 minutes', ''),
(2, 1, '2021-01-01 19:10:54', '20km', '27 minutes', ''),
(3, 1, '2021-01-03 00:12:37', '13.4km', '20 mins', 'NaN'),
(4, 2, '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
(5, 3, '2021-01-08 21:10:57', '10', '15', 'NaN'),
(6, 3, NULL, NULL, NULL, 'Cancellation'),
(7, 2, '2021-01-08 21:30:45', '25km', '25mins', NULL),
(8, 2, '2021-01-10 00:15:02', '23.4 km', '15 minute', NULL),
(9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
(10, 1, '2021-01-11 18:50:20', '10km', '10minutes', NULL);



drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1, 101, 1, '', '', '2021-01-01 18:05:02'),
(2, 101, 1, '', '', '2021-01-01 19:00:52'),
(3, 102, 1, '', '', '2021-01-02 23:51:23'),
(3, 102, 2, '', 'NaN', '2021-01-02 23:51:23'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 2, '4', '', '2021-01-04 13:23:46'),
(5, 104, 1, NULL, '1', '2021-01-08 21:00:29'),
(6, 101, 2, NULL, NULL, '2021-01-08 21:03:13'),
(7, 105, 2, NULL, '1', '2021-01-08 21:20:29'),
(8, 102, 1, NULL, NULL, '2021-01-09 23:54:33'),
(9, 103, 1, '4', '1,5', '2021-01-10 11:22:59'),
(10, 104, 1, NULL, NULL, '2021-01-11 18:34:49'),
(10, 104, 1, '2,6', '1,4', '2021-01-11 18:34:49');


select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


# A. ROLL METRICS
---------------------

1. How many rolls were ordered? 

SELECT COUNT(order_id) FROM customer_orders;

2. How many different customers ordered rolls?

SELECT COUNT(DISTINCT customer_id) FROM customer_orders;

3. How many successful orders were made?

SELECT driver_id, count(DISTINCT order_id) 
FROM driver_order 
WHERE cancellation IS NULL OR cancellation NOT IN ('cancellation', 'Customer Cancellation')
GROUP BY driver_id;

4.How many rolls of each type were delivered?

SELECT  c.roll_id, 
COUNT( CASE 
WHEN roll_id=1 THEN roll_id END) AS NONVEG, COUNT( 
CASE WHEN roll_id=2 THEN roll_id END) AS VEG
FROM driver_order as d
JOIN customer_orders as c using (order_id)
WHERE cancellation NOT IN ('cancellation', 'Customer Cancellation') or cancellation IS NULL
GROUP BY c.roll_id;

5.How many Veg and NonVeg rolls were ordered by each customer?

SELECT customer_id, COUNT(
CASE WHEN roll_id=1 THEN roll_id END ) AS NONVEG, 
COUNT(
CASE WHEN roll_id=2 THEN roll_id END ) AS VEG
FROM customer_orders
GROUP BY customer_id;

#ALTERNATE SOLUTION -
SELECT 
  A.customer_id,
  r.roll_name,
  A.roll_count
FROM( SELECT 
    customer_id,
    roll_id,
    COUNT(*) AS roll_count
  FROM customer_orders
  GROUP BY customer_id, roll_id) AS A
JOIN rolls r USING (roll_id);

6. Max amount of rolls ordered at a time?

SELECT order_id, count(roll_id) 
FROM customer_orders
GROUP BY order_id
ORDER BY count(roll_id) DESC;

7. What was the maximum amount of rolls dlievred in a single order?

SELECT c.order_id, count(c.roll_id) as rolls_delivered, d.driver_id
FROM customer_orders AS c
JOIN driver_order AS d using(order_id)
WHERE cancellation IS NULL OR cancellation NOT IN ('Cancellation','Customer Cancellation')
GROUP BY c.order_id,d.driver_id
ORDER BY count(roll_id) DESC
;


8. For each customer, how many rolls delivered had atleast one change and how many had no changes?

SELECT SUMMARY.customer_id, ROLLS_DELIVERED,  
CASE 
    WHEN (not_include_items IS NULL OR not_include_items IN ('', 'NaN'))
       AND (extra_items_included IS NULL OR extra_items_included IN ('', 'NaN'))
    THEN 'NO_CHANGES'
    ELSE 'CHANGES'
  END AS CHANGE_STATUS
FROM(
SELECT  
 count(roll_id) AS ROLLS_DELIVERED,c.customer_id, c.not_include_items,c.extra_items_included
FROM customer_orders AS c
JOIN driver_order using(order_id)
WHERE cancellation IS NULL OR cancellation NOT IN ('Cancellation','Customer Cancellation')
GROUP BY  c.customer_id, c.not_include_items,c.extra_items_included) AS SUMMARY
 ;

9. How many rolls were delivered that had both exclusions and extra item(s) included?

SELECT COUNT(A.customer_id)
FROM (SELECT c.customer_id, c.not_include_items,c.extra_items_included
FROM customer_orders AS c
JOIN driver_order using(order_id)
WHERE cancellation IS NULL OR cancellation NOT IN ('Cancellation','Customer Cancellation')) AS A
WHERE (not_include_items IS NOT NULL AND not_include_items NOT IN ('') )
AND (extra_items_included NOT IN ('', 'NaN') AND extra_items_included IS NOT NULL) ;

10. How many rolls were ordered in each hour of the day?

SELECT  COUNT(customer_id) AS ROLLS_ORDERED, CONCAT(EXTRACT(HOUR FROM order_date), '-',EXTRACT(HOUR FROM order_date)+1 ) AS HOUR_SLOT
FROM customer_orders
GROUP BY HOUR_SLOT
ORDER BY HOUR_SLOT ;

11. What was the number of orders for each day of the week?

SELECT COUNT(DISTINCT order_id) AS ROLLS_ORDERED , DAYNAME(order_date) AS DATE_ORDERED
FROM customer_orders
group by DATE_ORDERED; 

# B DRIVER AND CUSTOMER EXPERIENCE METRIC
-----------------------------------------------

 1. What was the average time taken by each driver to reach the Fasoos HQ?
 
 SELECT AVG(diff)AS AVG_TIME_TAKEN, B.driver_id 
 FROM(
SELECT DISTINCT c.order_id,
  d.driver_id, 
TIMESTAMPDIFF( MINUTE,c.order_date, d.pickup_time) as diff
FROM driver_order AS d 
JOIN customer_orders AS c USING (order_id)
WHERE d.cancellation IS NULL OR d.cancellation NOT IN ('Cancellation', 'Customer Cancellation')) AS B
GROUP BY B.driver_id ;

2. For every driver, how many orders were assigned, how many were delivered successfully, and how mnay were cancelled?


SELECT FINAL.driver_id, COUNT(DISTINCT FINAL.order_id  ) AS orders_assigned, SUM(CASE WHEN FINAL.cancellation = 'YES' THEN 1 ELSE 0 END) as orders_cancelled, SUM(CASE WHEN FINAL.cancellation = 'NO' THEN 1 ELSE 0 END) AS orders_delivered
FROM (
SELECT DISTINCT d.driver_id,   d.order_id , 
CASE WHEN d.cancellation IN ('Cancellation','Customer Cancellation') THEN 'YES' ELSE 'NO' END AS CANCELLATION
FROM driver_order AS d
LEFT JOIN customer_orders  AS c using(order_id)
) AS FINAL
GROUP BY FINAL.driver_id;

3. What is the delivery success rate?

SELECT ORD.driver_id, ROUND((ORD.orders_delivered/ORD.orders_assigned)*100,2) AS SUCCESS_RATE
FROM(
SELECT FINAL.driver_id, COUNT(DISTINCT FINAL.order_id  ) AS orders_assigned, SUM(CASE WHEN FINAL.cancellation = 'YES' THEN 1 ELSE 0 END) as orders_cancelled, SUM(CASE WHEN FINAL.cancellation = 'NO' THEN 1 ELSE 0 END) AS orders_delivered
FROM (
SELECT DISTINCT d.driver_id,   d.order_id , 
CASE WHEN d.cancellation IN ('Cancellation','Customer Cancellation') THEN 'YES' ELSE 'NO' END AS CANCELLATION
FROM driver_order AS d
LEFT JOIN customer_orders  AS c using(order_id)
) AS FINAL
GROUP BY FINAL.driver_id)
AS ORD;

4. Which customer has ordered the most rolls?

SELECT c.customer_id, COUNT(DISTINCT c.order_id) AS orders
FROM customer_orders as c
join driver_order as d using (order_id)
WHERE d.cancellation IS NULL OR d.cancellation NOT IN ('Cancellation', 'Customer Cancellation')
GROUP BY c.customer_id;

5. How many customers placed more than 1 order?

SELECT customer_id, orders 
FROM(
SELECT c.customer_id, COUNT(DISTINCT c.order_id) AS orders
FROM customer_orders as c
join driver_order as d using (order_id)
WHERE d.cancellation IS NULL OR d.cancellation NOT IN ('Cancellation', 'Customer Cancellation')
GROUP BY c.customer_id) AS D
WHERE orders>1;

6. Which roll is more preferred by each customer?

WITH roll_count AS (
SELECT c.customer_id,roll_id, COUNT(order_id) as number_of_rolls, 
ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY roll_id DESC ) AS rn
FROM customer_orders AS c
JOIN driver_order using(order_id)
WHERE cancellation IS NULL OR cancellation NOT IN ('Cancellation','Customer Cancellation')
GROUP BY c.customer_id, roll_id)

SELECT customer_id,roll_id, roll_name, number_of_rolls
FROM roll_count
JOIN rolls using(roll_id)
WHERE rn=1;

/*
Summary:
- Total and per-customer roll orders analyzed
- Delivery success rates and average delivery times calculated
- Customer preferences and changes in orders identified

Limitations:
- Cancellation reasons inconsistently recorded
- Some missing pickup time and distance data
 */




