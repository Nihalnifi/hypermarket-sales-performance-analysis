use hypermarket;

describe customer;
describe product;
describe transactions;

select p.Merchant_location,avg(t.sale_amount) as avg_sale_amount
from product p  join transactions t on p.merchant_id =t.merchant_id and p.product_id =t.product_id
group by p.merchant_location
order by avg(t.sale_amount) desc;


with total_sales as 
(select merchant_location,sum(sale_amount) as total_sales
from product p 
join transactions t on p.merchant_id=t.merchant_id and
 p.product_id=t.product_id
group by merchant_location),
overall_avg_sales as (select avg(sale_amount) as avg_sales from transactions)
select merchant_location,total_sales,avg_sales 
from total_sales cross join overall_avg_sales
where total_sales>avg_sales;

select count(*)as total_transaction ,
(
select count(*)  from transactions 
where promotion_id<>999999999)as promoted_transactions,
((select count(*)  from transactions 
where promotion_id<>999999999)/count(*))*100 as pct
from transactions;


select merchant_location,sum(sale_amount) as total_Sales,
rank() over (order by sum(sale_amount) desc) as "rank"
from product p join transactions t on p.product_id=t.product_id and p.merchant_id=t.merchant_id
group by merchant_location
order by sum(sale_amount) desc;

select sub_category_name,
avg(((sale_price*quantity)-sale_amount)/nullif((sale_price*quantity),0))*100 as avg_discount_pct,
rank() over( 
order by avg(((sale_price*quantity)-sale_amount)/nullif((sale_price*quantity),0)) desc)as "rank"
from product p join transactions t on p.product_id=t.product_id and p.merchant_id=t.merchant_id
group by sub_category_name;

with monthly_sales as (select  year(str_to_date(order_time,'%d-%m-%Y')) as year,
month(str_to_date(order_time,'%d-%m-%Y')) as month,
sum(sale_amount) as total_revenue,
lag(sum(sale_amount)) over(order by year(str_to_date(order_time,'%d-%m-%Y')) 
,month(str_to_date(order_time,'%d-%m-%Y'))) as prev_month_sale
 from  transactions
 group by year(str_to_date(order_time,'%d-%m-%Y')),month(str_to_date(order_time,'%d-%m-%Y')))
 select year,month,total_revenue,prev_month_sale,
 total_revenue-prev_month_sale as mom_change from monthly_sales;

with category_revenue as (select year(str_to_date(order_time,'%d-%m-%Y')) as year,
month(str_to_date(order_time,'%d-%m-%Y'))as month,
sub_category_name,sum(sale_amount) as revenue
from transactions t join product p on 
t.product_id=p.product_id and t.merchant_id=p.merchant_id
group by sub_category_name,year(str_to_date(order_time,'%d-%m-%Y')), 
month(str_to_date(order_time,'%d-%m-%Y'))
order by year(str_to_date(order_time,'%d-%m-%Y')), 
month(str_to_date(order_time,'%d-%m-%Y'))),ranks as (
select year,month,sub_category_name,
revenue,
rank() over(partition by year,month order by revenue desc) as ranks
 from  category_revenue)
 select year,month,sub_category_name,revenue,ranks from ranks
 where ranks=1;

with monthly_revenue as (select year(str_to_date(order_time,'%d-%m-%Y')) as year,
month(str_to_date(order_time,'%d-%m-%y')) as month,
sum(sale_amount) as revenue from transactions
group by  year(str_to_date(order_time,'%d-%m-%Y')),
month(str_to_date(order_time,'%d-%m-%y'))
order by year(str_to_date(order_time,'%d-%m-%Y')),
month(str_to_date(order_time,'%d-%m-%y')) )
select year,month,revenue,
sum(revenue) over( order by year,month) as running_total
from monthly_revenue ;

(select merchant_location,year(str_to_date(order_time,'%d-%m-%Y')) as years ,
yearweek(str_to_date(order_time,'%d-%m-%Y')) as week_number ,
count(*) as total_transaction
from transactions  t join product p on t.product_id=p.product_id
and t.merchant_id=p.merchant_id
group by merchant_location,year(str_to_date(order_time,'%d-%m-%Y')),
yearweek(str_to_date(order_time,'%d-%m-%Y'))
order by year(str_to_date(order_time,'%d-%m-%Y')),
yearweek(str_to_date(order_time,'%d-%m-%Y')));

 
select
case when promotion_id= 999999999 then "not_promoted" else "promoted" end as promotion_flag,
avg(sale_amount) as avg_revenue,
avg((((sale_price*quantity)-sale_amount)/nullif((sale_price*quantity),0))*100 )as disc_pct

from transactions 
group by case when promotion_id= 999999999 then "not_promoted" else "promoted" end ;




select sum(sale_amount) from transactions;
select * from customer;
select * from transactions;

select * from product;


select count(*) from customer;
select count(*) from product;
select count(*) from transactions; 




