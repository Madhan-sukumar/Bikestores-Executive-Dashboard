drop table if exists #bsd
;with bikestoredata
as 
(
select ord.order_id,
       CONCAT(cus.first_name, ' ', cus.last_name) as customer_name,
	   cus.city,
	   cus.state,
	   ord.order_date,
	   year(ord.order_date) as year,
	   month(ord.order_date) as month,
	   sum(ite.quantity) as total_units,
	   sum(ite.quantity * ite.list_price) as revenue,
	   pro.product_name,
	   cat.category_name,
	   sto.store_name,
	   CONCAT(sta.first_name, ' ', sta.last_name) as sales_rep

from [sales].[orders] ord
join [sales].[customers] cus
on ord.customer_id = cus.customer_id
join [sales].[order_items] ite
on ord.order_id = ite.order_id 
join [production].[products] pro
on ite.product_id = pro.product_id
join [production].[categories] cat
on pro.category_id = cat.category_id
join [sales].[stores] sto
on ord.store_id = sto.store_id
join [sales].[staffs] sta
on ord.staff_id = sta.staff_id

group by 
       ord.order_id,
       CONCAT(cus.first_name, ' ', cus.last_name),
	   cus.city,
	   cus.state,
	   ord.order_date,
	   pro.product_name,
	   cat.category_name,
	   sto.store_name,
	   CONCAT(sta.first_name, ' ', sta.last_name)
)

select *
into #bsd
from bikestoredata

-- ANALYSIS -- 

-- checking unique values --
select distinct state from #bsd
select distinct city from #bsd
select distinct product_name from #bsd
select distinct category_name from #bsd
select distinct store_name from #bsd
select distinct year from #bsd

-- Total Revenue and Total Units sold--
select sum(revenue) as total_revenue, avg(revenue) as avg_revenue, sum(total_units) as total_units
from #bsd

-- Revenue by year -- 
select year, sum(revenue) as total_revenue
from #bsd
group by year
order by 1 desc

-- which was the best month for sales based on year -- 
select year,month, sum(revenue) as total_revenue, count(order_id) as total_orders,
       rank () over ( order by count(order_id)desc ) ranking
from #bsd
where year = 2017 -- change year based on need
group by year,month
order by 4 desc

-- Revenue by state & total units sold --
select  state, sum(revenue) as total_revenue, sum(total_units) as total_units
from #bsd
group by state
order by 2 desc

-- Revenue by category -- 
select  category_name, sum(revenue) as total_revenue, sum(total_units) as total_units
from #bsd
group by category_name
order by 2 desc

-- highest units sold by category -- 
select  category_name, sum(total_units) as total_units
from #bsd
group by category_name
order by 2 desc

-- Revenue by store -- 
select  store_name, sum(revenue) as total_revenue, sum(total_units) as total_units
from #bsd
group by store_name
order by 2 desc

-- Which sales rep yields highest revenue -- 
select  sales_rep, store_name, sum(revenue) as total_revenue, sum(total_units) as total_units
from #bsd
group by sales_rep,store_name
order by 3 desc

-- top 10 most selling products and its revenue -- 
select product_name,sum(total_units) as total_units_sold, sum(revenue) as total_revenue
from  #bsd
group by product_name
order by 2 desc
offset 0 rows
fetch next 10 rows only 

-- top 10 least selling products and its revenue -- 
select product_name,sum(total_units) as total_units_sold, sum(revenue) as total_revenue
from  #bsd
group by product_name
order by 3 asc
offset 0 rows
fetch next 10 rows only 


--Top 10 Customers by revenue and units bought -- 
select customer_name, sum(revenue) as total_revenue, sum(total_units) as total_units
from #bsd 
group by customer_name
order by total_revenue desc
offset 0 rows
fetch next 10 rows only 

-- Top 3 Highest valued customers based on year --
select customer_name, sum(revenue) as revenue 
from #bsd
where year = 2016
group by customer_name
order by 2 desc
offset 0 rows
fetch next 3 rows only 
