

-- Q1 who is the senior most employee based on the job title
select * from employee
order by levels desc
limit 1

-- Q2 which country have the most invoices
select count(*) as c,billing_country from invoice
group by billing_country
order by c desc


-- Q3 what are top 3 values of total invoice
select total as top_invoices from invoice
order by total desc
limit 3

/*
Q4 which city has the best customer? write a query that returns one city that 
has the the highest sum of invoice totals.Return both the city name & sum of all the  
invoice totals
*/
select billing_city as city,sum(total) as sum_of_invoice 
from invoice
group by billing_city
order by sum_of_invoice desc
limit 1

/*
Q5 who is the best customer? write a query that returns the person who spent 
 has spent the most money 
*/
select c.customer_id,c.first_name,c.last_name,sum(i.total) as total
from customer as c
inner join invoice as i
on c.customer_id= i.customer_id
group by c.customer_id
order by total desc
limit 1
