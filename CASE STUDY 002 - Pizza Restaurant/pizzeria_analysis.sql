DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);

INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);


INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

-- CLEANING THE DATA 

UPDATE  customer_orders
SET exclusions = 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
	ELSE exclusions
END

UPDATE  customer_orders 
	SET extras = 
	CASE
	  WHEN extras IS NULL or extras LIKE 'null' THEN ' '
	  ELSE extras
	END 

UPDATE runner_orders
SET cancellation = 
	CASE
		WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
		ELSE cancellation
	END,
pickup_time = 
	CASE 
		WHEN pickup_time LIKE 'null' THEN ' '
		ELSE pickup_time
	END,
duration =
	CASE
		WHEN duration LIKE 'null' THEN ' '
		WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
		WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
		ELSE duration
	END,
distance =
	CASE WHEN distance LIKE 'null' THEN ' '
		WHEN distance LIKE '%km' THEN TRIM('km' from distance)
		ELSE distance 
	END

-- EXPLORATORY ANALYSIS

-- PIZZA METRICS

/**

How many pizzas were ordered?
How many unique customer orders were made?
How many successful orders were delivered by each runner?
How many of each type of pizza was delivered?
How many Vegetarian and Meatlovers were ordered by each customer?
What was the maximum number of pizzas delivered ina single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?

**/ 

-- #1 How many pizzas were ordered?
SELECT COUNT(pizza_id) pizza_orders
FROM customer_orders

-- #2 How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders

-- #3 How many successful orders were delivered by each runner?
SELECT
	COUNT(order_id) AS succesful_orders
FROM runner_orders
WHERE cancellation = ' '

-- #4 How many of each type of pizza was delivered?
SELECT 
	CAST(pizza_name AS VARCHAR(100)) AS pizza_name,
	COUNT(runner_orders.order_id) pizza_delivered
FROM customer_orders
JOIN pizza_names
	ON customer_orders.pizza_id = pizza_names.pizza_id
JOIN runner_orders
	ON customer_orders.order_id = runner_orders.order_id
WHERE cancellation = ' '
GROUP BY CAST(pizza_name AS VARCHAR(100))



-- #5 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
	customer_orders.customer_id, 
	CAST(pizza_name AS VARCHAR(100)) AS pizza_name,
	COUNT(customer_orders.order_id) pizza_delivered
FROM customer_orders
JOIN pizza_names
	ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY customer_orders.customer_id, CAST(pizza_name AS VARCHAR(100))
ORDER BY customer_orders.customer_id ASC, pizza_delivered DESC

-- #6 What was the maximum number of pizzas delivered in a single order?
SELECT 
  MAX(pizza_per_order) AS pizza_count
FROM 
(
	SELECT 
	c.order_id, 
	COUNT(c.pizza_id) AS pizza_per_order
	FROM customer_orders AS c
	JOIN runner_orders AS r
	ON c.order_id = r.order_id
	WHERE cancellation = ' '
	GROUP BY c.order_id ) a 

-- #7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
  c.customer_id,
  SUM(
    CASE WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 
    ELSE 0
    END) AS no_change
FROM customer_orders AS c
JOIN runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.cancellation = ' '
GROUP BY c.customer_id
ORDER BY c.customer_id;

-- #8 How many pizzas were delivered that had both exclusions and extras?
SELECT 
	COUNT(c.order_id) both_addons
FROM customer_orders AS c
JOIN runner_orders AS r
ON c.order_id = r.order_id
WHERE r.cancellation = ' '
AND c.exclusions != ' ' AND c.extras != ' '
GROUP BY c.customer_id
ORDER BY c.customer_id
 
--#9 What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  DATEPART(HOUR, [order_time]) AS hour_of_day, 
  COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY DATEPART(HOUR, [order_time]);

-- # What was the volume of orders for each day of the week?
SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');


-- B. Runner and Customer Experience

/**

    How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
    What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
    Is there any relationship between the number of pizzas and how long the order takes to prepare?
    What was the average distance travelled for each customer?
    What was the difference between the longest and shortest delivery times for all orders?
    What was the average speed for each runner for each delivery and do you notice any trend for these values?
    What is the successful delivery percentage for each runner?

**/

-- #1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);

-- #2  What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
	runner_id,
	AVG(DATEPART(MINUTE, pickup_time)) avg_pickup_time
FROM runner_orders
GROUP BY runner_id 
ORDER BY avg_pickup_time DESC

-- #3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.order_id) AS pizza_order, 
    c.order_time, 
    r.pickup_time, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
  FROM customer_orders AS c
  JOIN runner_orders AS r
    ON c.order_id = r.order_id
  GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT 
  pizza_order, 
  AVG(prep_time_minutes) AS avg_prep_time_minutes
FROM prep_time_cte
WHERE prep_time_minutes > 1
GROUP BY pizza_order;

-- #4 What was the average distance travelled for each customer?
