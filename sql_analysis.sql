create database Analyse;
use analyse;
describe orders_data;

alter table orders_data rename column `Order Id` to order_id;

alter table orders_data rename column `ship mode` to ship_mode;

alter table orders_data rename column `order date` to order_date;

SELECT * FROM orders_data;



----- Write a SQL query to list all distinct cities where orders have been shipped.
select distinct city from orders_data;

------- Calculate the total selling price and profits for all orders.

select distinct Order_id, round(sum(total_sales),1) as total_sales, round(sum(total_profit),1) as total_profit 
from orders_data 
group by Order_id
order by total_sales desc ,total_profit desc
limit 10 ;



-- Write a query to find all orders from the 'Technology' category 
-- that were shipped using 'Second Class' ship mode, ordered by order date.

select order_id, `order date`,ship_mode,category
from orders_data
where category="technology" and ship_mode="Second class"
order by `order date` desc;


-- Write a query to find the average order value
select round(avg (total_sales),2) as average_sale from orders_data;


-- find the city with the highest total quantity of products ordered.

select city, sum(quantity) as total_qty
from orders_data
group by city
order by total_qty desc;



-- Use a window function to rank orders in each region by quantity in descending order.

select region, sum(quantity) as total_qty,rank() over(order by sum(quantity) desc)as reg_rank
from orders_data
group by region
order by total_qty desc;


-- Write a SQL query to list all orders placed in the first quarter of any year (January to March), including the total cost for these orders.


---- find top 10 highest profit generating products 

select `product id`, round(sum(total_sales),2) as total_sales
from orders_data
group by `product id`
order by total_sales desc
limit 10;

-- now the question couuld also be for top n products acc to revenue/sales.


---- find top 3 highest selling products in each region
select region,`product id`,total_sales,top_rank
from(select region,`product id`,round(sum(Total_sales),1) as total_sales,
dense_rank() over(partition by region order by sum(total_sales) desc) as top_rank
from orders_data
group by region,`product id`) as ranked_data
where top_rank<4;





-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023


with yoy_sales as (select year(`order date`) as year,
		month(`order date`) as month,
        round(sum(total_sales),1)as total_sales
from orders_data
group by year(`order date`),month(`order date`))

select y2022.month,
		y2022.total_sales as total_sales_2022,
        y2023.total_sales as total_sales_2023,
        round(((y2023.total_sales-y2022.total_sales)/y2022.total_sales)*100,2) as yoy_growth
        from yoy_sales y2022
        join yoy_sales y2023
        on y2022.month=y2023.month
			and y2022.year=2022
            and y2023.year=2023
		order by y2022.month;


-- for each category which month had highest sales 


with ranked_sales as (select category,year(`order date`) as year,
	month(`order date`) as month,
    round(sum(total_sales),2) as total_sales,
    rank() over(partition by category,year(`order date`) order by sum(total_sales) desc) as cat_rank
from orders_data
-- where year(`order date`)=2023
group by category,year(`order date`),month(`order date`) )
select category,year,month,total_sales
from ranked_sales
where cat_rank=1 ;


