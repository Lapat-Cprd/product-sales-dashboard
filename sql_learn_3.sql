--create table 
create table retail_sales(
	Store_ID	varchar(15),
	Product_ID	varchar(15),
	Date	date,
	Units_Sold	int,
	Sales_Revenue	float,
	Discount_Percentage	int,
	Marketing_Spend	int,
	Store_Location	varchar(70),
	Product_Category	varchar(20),
	Day_of_the_Week	varchar(20),
	Holiday_Effect	varchar(20)
);
--create column num-day
alter table retail_sales
add column date_num_week int;
update retail_sales
set date_num_week= extract('dow'from date);
--create column name-month
alter table retail_sales
add column date_name_M varchar(20);
update retail_sales
set date_name_M= to_char(date, 'FMMon');
--create column num-month
alter table retail_sales
add column date_num_M int;
update retail_sales
set date_num_M= extract('MONTH'from date);
--addcolumn year
ALTER TABLE retail_sales
ADD COLUMN date_num_Y INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM date)) STORED;
--rename Day_of_the_Week to date_of_week
alter table retail_sales
rename column Day_of_the_Week to date_of_week;
--
select * from retail_sales
where * is null;
--check duplicate
with duplicate_check as(
select 
	*,
	row_number() over(partition by product_id,date,store_location,Product_Category,date_of_week order by date) as row_num
from retail_sales)
SELECT COUNT(*) 
FROM duplicate_check
WHERE row_num >= 2;
--
SELECT 
  CASE 
    WHEN discount_percentage = 0 THEN 'No Discount'
    WHEN discount_percentage <= 10 THEN 'Low (1–10%)'
    WHEN discount_percentage <= 20 THEN 'Medium (11–20%)'
    WHEN discount_percentage <= 30 THEN 'High (21–30%)'
    ELSE 'Very High (>30%)'
  END AS discount_group,
  SUM(net_revenue) AS total_net_revenue,
  COUNT(*) AS order_count
FROM retail_sales_enriched
GROUP BY discount_group
ORDER BY discount_group;
--check null or outlier
SELECT *
FROM retail_sales
WHERE EXISTS (
    SELECT 1
    FROM json_each_text(row_to_json(retail_sales)) AS kv
    WHERE kv.value IS NULL
);
--
update retail_sales_enriched
set date_of_week= to_char(date, 'FMDy');
--
SELECT store_location,count(*)
FROM retail_sales
group by store_location
order by 1 asc;
--
SELECT *
FROM retail_sales_enriched;
--add column net revenue , marketing efficiency
CREATE TABLE retail_sales_enriched AS
WITH enriched_sales AS (
    SELECT *,
			CAST(
           sales_revenue * (1 - discount_percentage / 100.0)AS DECIMAL(10,2)) AS net_revenue,
           CAST(
               CASE 
                   WHEN marketing_spend > 0 THEN sales_revenue / marketing_spend
                   ELSE 0
               END AS DECIMAL(10,2)
           ) AS marketing_efficiency
    FROM retail_sales
)
SELECT *
FROM enriched_sales;
---------------------------KPI--------------------------------
--total_sale
SELECT sum(sales_revenue)as total_sale
FROM retail_sales;
--total_sale per month
SELECT 
	product_id,
	(date_num_y)as year,
	(date_num_m)as month,
	cast (sum(sales_revenue)as decimal(10,2))as total_sale
FROM retail_sales
group by 1,2,3
order by 1,2,3;
--Total Units Sold
SELECT 
	product_id,
	(date_num_y)as year,
	(date_num_m)as month,
	cast (sum(units_sold)as decimal(10,2))as total_unit_sale
FROM retail_sales
group by 1,2,3
order by 1,2,3;
--Avg Discount % (When Used)
SELECT 
	product_id,
	(date_num_y)as year,
	(date_num_m)as month,
	cast (avg(discount_percentage)as decimal(10,2))as avg_discount_perc
FROM retail_sales
where discount_percentage >0
group by 1,2,3
order by 1,2,3;
--Avg Discount % (All sale)
--per prod year month
SELECT 
	product_id,
	(date_num_y)as year,
	(date_num_m)as month,
	cast (avg(discount_percentage)as decimal(10,2))as avg_discount_perc
FROM retail_sales
group by 1,2,3
order by 1,2,3;
--Total Marketing Spend
select sum(marketing_spend) from retail_sales;
--------------------------
select 
	(date_num_y)as year,
	(date_num_m)as month,
	product_id,
	sum(units_sold) as total_sold
from retail_sales_enriched
group by 1,2,3
order by 1,2;
--
select distinct product_id from retail_sales;