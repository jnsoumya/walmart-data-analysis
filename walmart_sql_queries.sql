-- Walmart Project Queries

SELECT * FROM walmart_db.walmart_sales;

desc walmart_db.walmart_sales;

select distinct(payment_method) from walmart_db.walmart_sales;

select 
	payment_method,
    count(*)
from walmart_db.walmart_sales
group by 1;

select count(distinct branch)
from walmart_db.walmart_sales;

-- **** business problems/analysis ****

-- -- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
select 
	payment_method,
    count(*) as no_of_transactions,
    sum(quantity) as quantity_sold
from walmart_db.walmart_sales
group by 1;

-- Business Problem  Q2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
select * from 
(
	select 
		branch,
		category,
		avg(rating) as avg_rating,
		rank() over (partition by branch order by  avg(rating) desc) as rank_branch
		from walmart_db.walmart_sales
	group by 1,2
) as a
where rank_branch = 1;
    
    
-- Business Problem Q3: Identify the busiest day for each branch based on the number of transactions

select 
	date,
	DAYNAME(DATE_FORMAT(trim(date), '%d-%m-%y')) AS day_of_week
	-- dayname(str_to_date(date,'%d-%m-%y')) as date_of_week
from walmart_db.walmart_sales;

select * from 
(
	select 
		branch,
		DAYNAME(DATE_FORMAT(trim(date), '%d-%m-%y')) AS day_of_week,
		count(*) as no_of_transaction,
		rank() over (partition by branch order by count(*) desc) as rank_branch
		from walmart_db.walmart_sales
group by 1,2
) as a
where rank_branch = 1;

-- Business Problem Q4: Calculate the total quantity of items sold per payment method

select 
	payment_method,
    sum(quantity) as no_qty_sold
from walmart_db.walmart_sales
group by 1;

-- Business Problem Q5: Determine the average, minimum, and maximum rating of categories for each city

select * from walmart_db.walmart_sales;

select 
	city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart_db.walmart_sales
group by 1,2
order by 1;
    

-- Business Problem Q6: Calculate the total profit for each category

select
	category,
    sum(revenue * profit_margin) as total_profit
from walmart_db.walmart_sales
group by 1
order by 2 desc;

-- Business Problem Q7: Determine the most common payment method for each branch

select * from
(
select 
	branch,
    payment_method,
    count(*) as tot_transaction,
    rank() over (partition by branch order by count(*) desc) as rank_common_paymnt_method
from walmart_db.walmart_sales
group by 1,2
) as a
where rank_common_paymnt_method = 1;


with cte 
as (
	select 
		branch,
		payment_method,
		count(*) as tot_transaction,
		rank() over (partition by branch order by count(*) desc) as rank_common_paymnt_method
		from walmart_db.walmart_sales
	group by 1,2 
) 
select * from cte
where rank_common_paymnt_method = 1;


-- Business Problem Q8: Categorize sales into Morning, Afternoon, and Evening shifts

select * from walmart_db.walmart_sales;

SELECT TIME_FORMAT(time, '%H:%i:%s') AS formatted_time from walmart_db.walmart_sales;

select
	branch,
	case 
		when hour(TIME_FORMAT(time, '%H:%i:%s')) < 12 then 'Morning'
		when hour(TIME_FORMAT(time, '%H:%i:%s')) between 12 and 16 then 'Afternoon'
        when hour(TIME_FORMAT(time, '%H:%i:%s')) between 17 and 18  then 'Evening'
        else 'Night'
	end as shift_time,
    count(*) as no_of_transaction
from walmart_db.walmart_sales
group by 1,2
order by 1, 3 desc;

-- Business Problem Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

with revenue_2022 
as (
	select 
	branch,
    sum(revenue) as revenue
from walmart_db.walmart_sales
where year(DATE_FORMAT(trim(date), '%d-%m-%y')) = 2022
group by 1
),
revenue_2023 
as (
	select 
	branch,
    sum(revenue) as revenue
from walmart_db.walmart_sales
where year(DATE_FORMAT(trim(date), '%d-%m-%y')) = 2023
group by 1
)
select 
ly.branch,
ly.revenue as last_year_revenue,
cy.revenue as current_year_revenue,
round(((ly.revenue - cy.revenue)/ly.revenue)*100,2) as revenue_decrease_ratio
from 
	revenue_2022 ly
join 
	revenue_2023 cy
on ly.branch = cy.branch
where 
	ly.revenue > cy.revenue
order by 4 desc
limit 5;

select * from walmart_db.walmart_sales;