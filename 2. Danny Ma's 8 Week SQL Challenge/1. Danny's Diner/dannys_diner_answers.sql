--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Joseph Godin
--Date: 10/24/2022
--Tool used: MS SQL Server

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

SELECT *
FROM dbo.members;

SELECT *
FROM dbo.menu;

SELECT *
FROM dbo.sales;

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?

-- SELECTing all tables to see what kind of data I am working with

SELECT TOP 10 *
FROM members

SELECT TOP 10 *
FROM menu

SELECT TOP 10 *
FROM sales

-- JOINing the tables together to get the customer, product, and price of product 

SELECT m.customer_id	
		,SUM(mn.price) AS total_cost
FROM members AS m
INNER JOIN sales AS s
ON m.customer_id = s.customer_id
INNER JOIN menu AS mn
ON mn.product_id = s.product_id
GROUP BY m.customer_id
ORDER BY total_cost DESC

-- Customer A spent $76
-- Customer B spent $74

-- 2. How many days has each customer visited the restaurant?

-- had to get the COUNT(DISTINCT) of the order date to get each seperate date that the custoemr visited
SELECT m.customer_id
		,COUNT(DISTINCT s.order_date) AS total_days_visited
FROM members AS m		
INNER JOIN sales AS s
ON m.customer_id = s.customer_id
GROUP BY m.customer_id
ORDER BY customer_id

-- 3. What was the first item from the menu purchased by each customer?

-- had to find the earliest date by using a MIN function on the order date column, but that makes the query unaggregatable, so had to put it into a CTE to be able to put earliest date in a WHERE clause

WITH CTE_Date AS (
SELECT  m.customer_id
		--,s.order_date
		--,mn.product_name
		,MIN(s.order_date) AS earliest_date
FROM members AS m		
INNER JOIN sales AS s
ON m.customer_id = s.customer_id
INNER JOIN menu AS mn
ON mn.product_id = s.product_id
GROUP BY m.customer_id
--ORDER BY s.order_date 
--WHERE MIN(s.order_date) = s.order_date
)
SELECT c.customer_id	
		,c.earliest_date
		,mn.product_name
FROM CTE_Date AS c
INNER JOIN members AS m
ON m.customer_id = c.customer_id
INNER JOIN sales AS s
on s.customer_id = m.customer_id
INNER JOIN menu AS mn
ON mn.product_id = s.product_id
WHERE s.order_date = c.earliest_date

-- First order from customer A was sushi & curry
-- First order from customer B was curry

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- top product by getting the count and then top 1 to see it is product_id 3, so then next just filter by that 
SELECT TOP 1 --customer_id
		product_id
		,COUNT(product_id) AS total_product_orders
FROM sales
GROUP BY --customer_id
		product_id 
		
ORDER BY product_id DESC

-- product 3 is ramen

SELECT product_name 
FROM menu
WHERE product_id = 3

-- DICT(customer,product orders) = {A:3,B:2,C:3}

SELECT customer_id
		,product_id
		,COUNT(product_id) AS total_product_orders
FROM sales
WHERE product_id = 3
GROUP BY customer_id
		,product_id 
ORDER BY product_id DESC

-- 5. Which item was the most popular for each customer?

-- TOP 1 WITH TIES goes along with the Partitioned row_number
--can order by COUNT() but cannot call the total column by name as it is aggr func

SELECT TOP 1 WITH TIES
	 customer_id
	,product_id
	,COUNT(product_id) AS total
FROM sales
GROUP BY customer_id
		,product_id
ORDER BY 
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC)

-- DICT(customer,most_popular_item) = {A:3,B:1,C:3}

-- 6. Which item was purchased first by the customer after they became a member?

SELECT TOP 1 WITH TIES 
	 	 m.customer_id
		,s.order_date
		,m.join_date
		,s.product_id
FROM sales AS s
INNER JOIN members AS m
ON m.customer_id = s.customer_id
WHERE s.order_date >= m.join_date 
ORDER BY ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY m.join_date)

-- DICT(customer,product) = {A:2,B:1}

-- 7. Which item was purchased just before the customer became a member?

-- similar to last question

SELECT TOP 1 WITH TIES
	 	 m.customer_id
		,s.order_date
		,m.join_date
		,s.product_id
FROM sales AS s
INNER JOIN members AS m
ON m.customer_id = s.customer_id
WHERE s.order_date < m.join_date 
ORDER BY ROW_NUMBER() OVER(PARTITION BY m.customer_id ORDER BY s.order_date DESC)

-- 8. What is the total items and amount spent for each member before they became a member?

-- simple jsut get sum and count

SELECT
	 	 m.customer_id
		,COUNT(s.product_id) AS num_orders
		,SUM(mn.price) total_spend
FROM sales AS s
INNER JOIN members AS m
ON m.customer_id = s.customer_id
INNER JOIN menu AS mn
ON mn.product_id = s.product_id
WHERE s.order_date < m.join_date 
GROUP BY m.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

-- have to use a CTE to create a CASE stament to create the pointd metric and then aggr the sum of all points in the following statement

WITH CTE_Points AS (
SELECT s.customer_id
		,s.product_id
		,m.product_name
		,price
		,CASE
			WHEN m.product_name = 'sushi'
			THEN m.price * 20
			ELSE m.price * 10
		 END AS points
FROM sales AS s
INNER JOIN menu AS m
ON m.product_id = s.product_id
)
SELECT p.customer_id
		,SUM(p.points) AS total_points
FROM CTE_Points AS p
GROUP BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--Create CTE to create the last_day column using a DATE function called DATEADD()

WITH CTE_Date AS (
SELECT join_date
	,DATEADD(day,7,join_date) AS last_day
FROM members

)
--Create second CTE to create the points metric/column
,CTE_Price AS (
SELECT 
		 m.customer_id
		 ,s.order_date
		--,mn.product_name
		--,mn.price
		,CASE
			WHEN s.order_date < d.last_day 
				AND s.order_date >= m.join_date
			THEN mn.price * 20
			WHEN mn.product_name = 'sushi'
			THEN mn.price * 20
			ELSE mn.price * 10
		 END AS points
		 ,ROW_NUMBER() OVER(ORDER BY m.customer_id) AS cnt
		--,COUNT(*) AS cnt
FROM menu AS mn
INNER JOIN sales AS s
ON mn.product_id = s.product_id
INNER JOIN members AS m
ON m.customer_id = s.customer_id
INNER JOIN CTE_Date AS d
ON d.join_date = m.join_date
WHERE s.order_date < '2021-02-01'
--GROUP BY 

)
-- had to create a third CTE to filter by only the rows i wanted becuase for some reason the CTEs were creating extra rows. So, ordered by ROW_NUMBER() WITH TIES TOP 12 to fix that 
,CTE_Ties AS (
SELECT TOP 11 WITH TIES 
		 m.customer_id
		--,m.join_date
		--,s.order_date
		--,mn.product_name
		--,mn.price
		--,d.last_day
		,p.points
		,p.cnt
FROM CTE_Date AS d
INNER JOIN members AS m
ON m.join_date = d.join_date
INNER JOIN sales AS s
ON s.customer_id = m.customer_id
INNER JOIN menu AS mn
ON mn.product_id = s.product_id
INNER JOIN CTE_Price AS p
ON s.customer_id = p.customer_id
ORDER BY ROW_NUMBER() OVER(PARTITION BY cnt ORDER BY cnt)
--GROUP BY m.customer_id
)
-- bring them all together for a aggr SUM of the points 
SELECT customer_id
	,SUM(points) AS total_points
FROM CTE_Ties
GROUP BY customer_id

------------------------
--BONUS QUESTIONS-------
------------------------

-- Join All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

--simple just needed to do a CASE statement and LEFT or FULL OUTER JOIN the members so that C's orders were not left out
SELECT s.customer_id
		,s.order_date
		,mn.product_name
		,mn.price
		,CASE
			WHEN s.order_date >= m.join_date
			THEN 'Y'
			ELSE 'N'
		 END AS member
FROM sales AS s
INNER JOIN menu AS mn
ON mn.product_id = s.product_id
FULL OUTER JOIN members AS m
ON m.customer_id = s.customer_id

--Rank All The Things - Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

WITH CTE_Member AS (
SELECT s.customer_id
		,s.order_date
		,mn.product_name
		,mn.price
		,CASE
			WHEN s.order_date >= m.join_date
			THEN 'Y'
			ELSE 'N'
		 END AS member
FROM sales AS s
INNER JOIN menu AS mn
ON mn.product_id = s.product_id
FULL OUTER JOIN members AS m
ON m.customer_id = s.customer_id
)
SELECT *
		,CASE
			WHEN member = 'N'
			THEN NULL
			ELSE RANK() OVER(PARTITION BY customer_id,member ORDER BY order_date)
		 END AS ranking
FROM CTE_Member



