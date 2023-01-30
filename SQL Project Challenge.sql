----- Question 1 ----- 
Provide the list of markets in which customer  "Atliq  Exclusive"  operates its 
business in the  APAC  region. 

Select DISTINCT(market) from dim_customer where customer = "Atliq Exclusive" and region = "APAC";

------ Question2 ------
What is the percentage of unique product increase in 2021 vs. 2020? 
The final output contains these fields: 
unique_products_2020 ,unique_products_2021 , percentage_chg 
 
With cte as (
Select count(distinct(product_code)) as unique_products_2020 from fact_sales_monthly 
where fiscal_year = "2020" ),
cte1 as (Select count(distinct(product_code)) as unique_products_2021 from fact_sales_monthly
where fiscal_year = "2021")
Select unique_products_2020, unique_products_2021, 
round((unique_products_2021-unique_products_2020)*100/unique_products_2020,2) as percentage_chg from cte, cte1;


------ Question3 -------
Provide a report with all the unique product counts for each  segment  and 
sort them in descending order of product counts. The final output contains 2 fields: 
segment , product_count .

Select segment, count(distinct(product_code)) as product_count from dim_product
group by segment
order by product_count desc;

------ Question4 ------
Follow-up: Which segment had the most increase in unique products in 
2021 vs 2020? The final output contains these fields: 
segment ,product_count_2020 , product_count_2021 
 
with cte as(Select p.segment as segment,
count(distinct(p.product_code)) as product_count_2020
from dim_product p join fact_sales_monthly s 
on p.product_code = s.product_code
where fiscal_year = 2020
group by segment
order by product_count_2020 desc),
cte1 as(Select p.segment as segment, 
count(distinct(p.product_code)) as product_count_2021
from dim_product p join fact_sales_monthly s 
on p.product_code = s.product_code
where fiscal_year = 2021
group by segment
order by product_count_2021 desc)
Select
cte.segment , product_count_2020, product_count_2021,
round(((product_count_2021-product_count_2020)*100/product_count_2020), 2) as difference 
from cte JOIN cte1 on cte.segment = cte1.segment
group by segment
order by difference desc;

----- Question5 -----
Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields
product_code , product , manufacturing_cost 

Select 
p.product_code, p.product, m.manufacturing_cost
from dim_product p join fact_manufacturing_cost m
on p.product_code = m.product_code
where manufacturing_cost in ((select min(manufacturing_cost) from fact_manufacturing_cost),
(select max(manufacturing_cost) from fact_manufacturing_cost)) ;

----- Question6 ----
Generate a report which contains the top 5 customers who received an 
average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
Indian  market. The final output contains these fields : 
customer_code ,customer ,average_discount_percentage

Select c.customer_code, c.customer,
round(avg(pre_invoice_discount_pct)*100, 2) as average_discount_percentage
from dim_customer c join fact_pre_invoice_deductions p
on c.customer_code = p.customer_code
where fiscal_year= 2021
and market = "India"
group by customer
order by average_discount_percentage desc
limit 5;

------ Question7 -----
Get the complete report of the Gross sales amount for the customer  “Atliq 
Exclusive”  for each month. This analysis helps to  get an idea of low and 
high-performing months and take strategic decisions. 
The final report contains these columns: 
Month ,Year , Gross sales Amount

Select monthname(f.date) as month, f.fiscal_year as year,
sum(round(f.sold_quantity*g.gross_price, 2))/1000000 as Gross_Sales_Amount from
dim_customer c join fact_sales_monthly f
on c.customer_code = f.customer_code  
join fact_gross_price g 
on f.product_code = g.product_code
and f.fiscal_year= g.fiscal_year
where c.customer = "Atliq Exclusive"
group by month, year
LIMIT 1000000;

----- Question8 ----
In which quarter of 2020, got the maximum total_sold_quantity? The final 
output contains these fields sorted by the total_sold_quantity: 
Quarter , total_sold_quantity

select CASE
when month(date) in (9,10,11) then "Q1"
when month(date) in (12,1,2) then "Q2"
when month(date) in (3,4,5) then "Q3"
when month(date) in (6,7,8) then "Q4"
end as Quarter,
sum(sold_quantity) as total_sold_quantity 
from fact_sales_monthly
where fiscal_year= 2020
group by quarter
order by total_sold_quantity desc;

----- Question9 -----
Which channel helped to bring more gross sales in the fiscal year 2021 
and the percentage of contribution?  The final output  contains these fields: 
channel, gross_sales_mln , percentage 

with cte as(
Select channel,
round(sum(sold_quantity*gross_price)/1000000, 2) as gross_sales_mln
from fact_sales_monthly s 
join dim_customer c on c.customer_code = s.customer_code
join fact_gross_price p on s.product_code = p.product_code
where s.fiscal_year = 2021
group by channel
order by gross_sales_mln desc
)
Select channel, gross_sales_mln, round((gross_sales_mln)/sum(gross_Sales_mln)over()*100, 2) as percentage from cte
group by channel
order by percentage desc;

----- Question10 -----
Get the Top 3 products in each division that have a high 
total_sold_quantity in the fiscal_year 2021? The final output contains these fields: 
division , product_code , product , total_sold_quantity , rank_order

with cte as (SELECT 
p.division, p.product_code, p.product,
sum(sold_quantity) as total_sold_qty
from fact_sales_monthly s 
join dim_product p  
on p.product_code = s.product_code
where fiscal_year =2021
group by p.product),
cte1 as( Select cte.division, cte.product_code, cte.product, cte.total_sold_qty,
dense_rank() over(partition by division order by total_sold_qty desc) as rank_order from cte)
Select * from cte1 where rank_order<=3
 