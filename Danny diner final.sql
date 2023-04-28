CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);
select * from sales;
INSERT INTO sales
  (customer_id, order_date, product_id)
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
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select *from sales;
  select *from menu;
  select *from members;
  
 # 1. What is the total amount each customer spent at the restaurant?
 select s.customer_id , sum(m.price) as total_pay
 from sales s 
 join menu m
 on s.product_id=m.product_id
 group by customer_id
 order by total_pay;
 
 # 2. How many days has each customer visited the restaurant?
 select customer_id, count(distinct order_date) as visit
 from sales
 group by customer_id;
 
 #3.What was the first item from the menu purchased by each customer?
 select * from menu;
 select *from sales;
select distinct  customer_id, product_name from
(
select customer_id, product_name, order_date,rank()over(partition by customer_id order by order_date) as ranking
from sales s join menu m
on s.product_id=m.product_id
)b
where ranking=1

# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select *from sales;
select *from menu;
SELECT  (COUNT(s.product_id)) AS most_purchased, product_name
from sales s join menu m 
on s.product_id=m.product_id
group by product_name
order by most_purchased desc limit 1;


#5. Which item was the most popular for each customer?
with fav_cte as
(
select s.customer_id, m.product_name,
count(m.product_id) as count_order, 
dense_rank() over (partition by s.customer_id order by count(s.customer_id) desc) as rank_
FROM  menu AS m
JOIN sales AS s
 ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, count_order
FROM fav_cte 
WHERE rank_ = 1;

#  6. Which item was purchased first by the customer after they became a member?
with member_cte as
(
select s.customer_id, s.product_id, m.join_date, s.order_date,
dense_rank () over( partition by customer_id order by s.order_date ) as rnk
from sales as s 
join members as m
on s.customer_id=m.customer_id
where s.order_date>=m.join_date)

select customer_id ,me.product_name , order_date from member_cte  as a
join menu as me
on  a.product_id = me.product_id
where rnk=1;



#7. Which item was purchased just before the customer became a member?
with member_before as
(
select s.customer_id,s.product_id, m.join_date, s.order_date,
dense_rank () over( partition by s.customer_id order by s.order_date  desc ) as rnk
from sales as s 
join members as m
on s.customer_id=m.customer_id
where s.order_date < m.join_date)

select customer_id ,me.product_name , order_date from member_before  as b
join menu as me
on  b.product_id = me.product_id
where rnk=1;


#8.What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(product_name),sum(price) as total
from  sales s join menu m
on s.product_id=m.product_id
join members me 
on s.customer_id=me.customer_id
where order_date< join_date
group by s.customer_id;

#9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
# If 1 dol= 10 pts --- sushi (product_id 1)-- 20pts 
# if customers has product_id 1 then it has 20 pts if not one then 10 pts
with price_pts as
(select *, 
case when product_id=1 then price*20
else 
price*10
end as pts
from menu) 
SELECT s.customer_id, SUM(p.pts) AS total_points
FROM price_pts AS p
JOIN sales AS s
 ON p.product_id = s.product_id
GROUP BY s.customer_id

