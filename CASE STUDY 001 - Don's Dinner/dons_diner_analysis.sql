CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


  -- Exploratory Analysis of Don's Diner
/**

What is the total amount each customer spent at the restaurant?
How many days has each customer visited the restaurant?
What was the first item from the menu purchased by each customer?
What is the most purchased item on the menu and how many times was it purchased by all customers?
Which item was the most popular for each customer?
Which item was purchased first by the customer after they became a member?
Which item was purchased just before the customer became a member?
What is the total items and amount spent for each member before they became a member?
If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

**/
-- #1 What is the total amount each customer spent at the restaurant? 
SELECT 
	customer_id, 
	SUM(price) total_sales
FROM sales
INNER JOIN menu 
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY total_sales DESC 

-- #2 How many days has each customer visited the restaurant?
SELECT 
	customer_id,
	COUNT(order_date)
FROM sales
GROUP BY customer_id
ORDER BY customer_id

-- #3 What was the first item from the menu purchased by each customer?
SELECT
	customer_id,
	product_name
FROM (
	SELECT
		customer_id,
		product_name,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date ASC) rnk
	FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id ) a
WHERE rnk = 1

-- #4 What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
	product_name,
	COUNT(sales.product_id) total_sold
FROM menu 
INNER JOIN sales 
ON menu.product_id = sales.product_id
GROUP BY product_name 
ORDER BY total_sold DESC

-- #5 Which item was the most popular for each customer? (Popularity: Total Sold)
SELECT 
	product_name, 
	COUNT(sales.product_id) total_sold
FROM sales 
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY product_name 
ORDER BY total_sold DESC

-- #6 Which item was purchased first by the customer after they became a member?
SELECT 
	customer_id,
	product_name
FROM (
	SELECT 
		sales.customer_id,
		product_name,
		DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY order_date ASC) rnk
	FROM sales 
	INNER JOIN menu ON 
		sales.product_id = menu.product_id
	INNER JOIN members ON 
		sales.customer_id = members.customer_id
	WHERE order_date > join_date ) a
WHERE rnk = 1


-- #7 Which item was purchased just before the customer became a member?
SELECT 
	customer_id,
	product_name
FROM (
	SELECT 
		sales.customer_id,
		product_name,
		order_date,
		join_date,
		DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY order_date DESC) rnk
	FROM sales 
	INNER JOIN menu ON 
		sales.product_id = menu.product_id
	INNER JOIN members ON 
		sales.customer_id = members.customer_id
	WHERE order_date < join_date ) a
WHERE rnk = 1


-- #8 What is the total items and amount spent for each member before they became a member?
SELECT 
	sales.customer_id,
	COUNT(sales.product_id) total_sold,
	SUM(menu.price) total_amount
FROM sales 
INNER JOIN menu ON 
	sales.product_id = menu.product_id
INNER JOIN members ON 
	sales.customer_id = members.customer_id
WHERE order_date < join_date 
GROUP BY sales.customer_id

-- #9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
	customer_id, 
	SUM(CASE WHEN product_name != 'sushi' THEN total_spent * 10 ELSE total_spent * 20 END) AS total_points
FROM 
(
	SELECT 
		customer_id, 
		product_name, 
		SUM(price) total_spent
	FROM sales
	INNER JOIN menu
		ON sales.product_id = menu.product_id
	GROUP BY customer_id, product_name ) a
GROUP BY customer_id


-- #10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates_cte AS 
(
 SELECT *, 
  DATEADD(DAY, 6, join_date) AS valid_date, 
  EOMONTH('2021-01-31') AS last_date
 FROM members AS m
)
SELECT 
	customer_id, 
	SUM(points)
FROM
(
	SELECT d.customer_id, s.order_date, d.join_date, 
	 d.valid_date, d.last_date, m.product_name, m.price,
	 SUM(CASE
	  WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
	  WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
	  ELSE 10 * m.price
	  END) AS points
	FROM dates_cte AS d
	JOIN sales AS s
	 ON d.customer_id = s.customer_id
	JOIN menu AS m
	 ON s.product_id = m.product_id
	WHERE s.order_date < d.last_date
	GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price ) a
GROUP BY customer_id 
