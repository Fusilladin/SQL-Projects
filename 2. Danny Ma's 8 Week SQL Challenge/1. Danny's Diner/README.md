# 🍜 Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
- [Solution on Github](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md)
- [Solution on Medium](https://katiehuangx.medium.com/8-week-sql-challenge-case-study-week-1-dannys-diner-2ba026c897ab?source=friends_link&sk=ed355696f5a70ff8b3d5a1b905e5dabe)

***

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

## Case Study Questions

<details>
<summary>
Click here to expand!
</summary>

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## Bonus Questions
  
# 1. Join All The Things  
Recreate the following table output using the available data:
customer_id 	order_date 	product_name 	price 	member
A 	2021-01-01 	curry 	15 	N
A 	2021-01-01 	sushi 	10 	N
A 	2021-01-07 	curry 	15 	Y
A 	2021-01-10 	ramen 	12 	Y
A 	2021-01-11 	ramen 	12 	Y
A 	2021-01-11 	ramen 	12 	Y
B 	2021-01-01 	curry 	15 	N
B 	2021-01-02 	curry 	15 	N
B 	2021-01-04 	sushi 	10 	N
B 	2021-01-11 	sushi 	10 	Y
B 	2021-01-16 	ramen 	12 	Y
B 	2021-02-01 	ramen 	12 	Y
C 	2021-01-01 	ramen 	12 	N
C 	2021-01-01 	ramen 	12 	N
C 	2021-01-07 	ramen 	12 	N
  
# 2. Rank ALL The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
customer_id 	order_date 	product_name 	price 	member 	ranking
A 	2021-01-01 	curry 	15 	N 	null
A 	2021-01-01 	sushi 	10 	N 	null
A 	2021-01-07 	curry 	15 	Y 	1
A 	2021-01-10 	ramen 	12 	Y 	2
A 	2021-01-11 	ramen 	12 	Y 	3
A 	2021-01-11 	ramen 	12 	Y 	3
B 	2021-01-01 	curry 	15 	N 	null
B 	2021-01-02 	curry 	15 	N 	null
B 	2021-01-04 	sushi 	10 	N 	null
B 	2021-01-11 	sushi 	10 	Y 	1
B 	2021-01-16 	ramen 	12 	Y 	2
B 	2021-02-01 	ramen 	12 	Y 	3
C 	2021-01-01 	ramen 	12 	N 	null
C 	2021-01-01 	ramen 	12 	N 	null
C 	2021-01-07 	ramen 	12 	N 	null
</details>


***
