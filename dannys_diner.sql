/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select sales.customer_id, sum(menu.price) as total_spent
from dannys_diner.sales
join dannys_diner.menu
on sales.product_id = menu.product_id
group by sales.customer_id 
order by sales.customer_id asc; #(done)


-- 2. How many days has each customer visited the restaurant?
select customer_id , count(distinct order_date) as visits 
from dannys_diner.sales
group by customer_id; #( done)

----------------------------------------------------


-- 3. What was the first item from the menu purchased by each customer?

with cte as (
  select 
    sales.customer_id,
    menu.product_name,
    sales.order_date,
    rank() over(partition by sales.customer_id order by sales.order_date) as rnk,
    row_number() over(partition by sales.customer_id order by sales.order_date) as row_num
  from 
    dannys_diner.sales
  join 
    dannys_diner.menu
  on 
    sales.product_id = menu.product_id
)
select 
  customer_id,
  product_name
from 
  cte
where 
  row_num = 1 ;

------------------------------------------------------------









-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select count(sales.product_id) as most_purchased, menu.product_name
from dannys_diner.sales
join dannys_diner.menu
on sales.product_id = menu.product_id
group by menu.product_name 
order by most_purchased desc
limit 1; #(done)





-- 5. Which item was the most popular for each customer?

with cte as (
  select sales.customer_id, menu.product_name, count(sales.order_date) as orders,
  rank() over(partition by sales.customer_id order by count(sales.order_date) desc) as rnk , 
  row_number() over(partition by sales.customer_id order by count(sales.order_date) desc) as row_num
  from dannys_diner.sales
  inner join dannys_diner.menu
  on sales.product_id = menu.product_id 
  group by sales.customer_id, menu.product_name
)
select customer_id, product_name, orders
from cte
where row_num = 1; 




-- 6. Which item was purchased first by the customer after they became a member?
with cte as(
  select 
      sales.customer_id, 
      sales.order_date, 
      members.join_date, 
      menu.product_name,
      rank() over(partition by sales.customer_id order by sales.order_date) as rnk ,
      row_number() over(partition by sales.customer_id order by sales.order_date) as row_num
  from 
      dannys_diner.sales 
  inner join 
      dannys_diner.menu on sales.product_id = menu.product_id 
  inner join 
      dannys_diner.members on sales.customer_id = members.customer_id 
  where 
      sales.order_date >= members.join_date)
select customer_id , product_name
from cte
where row_num = 1 ; #(done)





-- 7. Which item was purchased just before the customer became a member?
with cte as(
  select 
      sales.customer_id, 
      sales.order_date, 
      members.join_date, 
      menu.product_name,
      rank() over(partition by sales.customer_id order by sales.order_date desc) as rnk ,
      row_number() over(partition by sales.customer_id order by sales.order_date) as row_num
  from 
      dannys_diner.sales 
  inner join 
      dannys_diner.menu on sales.product_id = menu.product_id 
  inner join 
      dannys_diner.members on sales.customer_id = members.customer_id 
  where 
      sales.order_date < members.join_date)
select customer_id , product_name
from cte
where rnk = 1 ; #(done)




-- 8. What is the total items and amount spent for each member before they became a member?

select 
      sales.customer_id, 
       
      count(menu.product_name) as orders,
      sum(menu.price) as total
      
  from 
      dannys_diner.sales 
  inner join 
      dannys_diner.menu on sales.product_id = menu.product_id 
  inner join 
      dannys_diner.members on sales.customer_id = members.customer_id 
  where 
      sales.order_date < members.join_date
      group by sales.customer_id; #(done)


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select sales.customer_id , 
sum(case 
  when product_name = 'sushi' then price * 10 * 2
  else price * 10 
  END) as total_points
from dannys_diner.menu
inner join dannys_diner.sales
on menu.product_id = sales.product_id
group by sales.customer_id; #(done)




-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT 
  S.customer_id, 
  SUM(
    CASE 
      WHEN S.order_date BETWEEN MEM.join_date AND DATEADD('day', 6, MEM.join_date) THEN price * 10 * 2 
      WHEN product_name = 'sushi' THEN price * 10 * 2 
      ELSE price * 10 
    END
  ) as points 
FROM 
  dannys_diner.MENU as M 
  INNER JOIN dannys_diner.SALES as S ON S.product_id = M.product_id
  INNER JOIN dannys_diner.MEMBERS AS MEM ON MEM.customer_id = S.customer_id 
WHERE 
  DATE_TRUNC('month', S.order_date) = '2021-01-01' 
GROUP BY 
  S.customer_id;








