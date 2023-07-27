 /*Q1
      find how much amount spent by each customer on artists ? Write a query to
	  return customer name ,artist name and total spent
 */
with best_seller_artist as(
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum (invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1 -- 1=artist.artist_id
	order by 3 desc-- 3= total_sales
	limit 1
	
)

select c.customer_id,c.first_name,c.last_name,bsa.artist_name,sum(il.unit_price*il.quantity) as amount_spent
from customer c
join invoice  i on i.customer_id =c.customer_id
join invoice_line  il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_seller_artist bsa on bsa.artist_id =alb.artist_id
group by 1,4
order by 5 desc;

/*Q2
     we determine the most popular music genre as the genre with the highest amount of purchases.
	 Write a query that returns each country along with the top genre .For countries where maximum
	 number of purchases is shared return all genres.
*/

with popular_genre as(
	select count(invoice_line.quantity) as purchases,customer.country,genre.name,genre.genre_id,
	row_number ()over(partition by customer.country order by count (invoice_line.quantity) desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4 -- 1=artist.artist_id
	order by 2 asc,1 desc-- 3= total_sales
	
	
),

best_country as(
	select count(invoice_line.quantity) as purchases,invoice.billing_country
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	group by 2-- 1=artist.artist_id
	order by 2 asc,1 desc-- 3= total_sales
	limit 1
	
	
)

select * from popular_genre where Rowno <=1 or country IN (SELECT country FROM best_country);


/* Q3
     Write a query that determines the customer that has spent the most on music for each country.Write a 
	 query that returns the country along with the top customer and how much they spent.for countries where
	 the top amount spent is shared ,provide all customers who spent this amount

*/

WITH bic AS (
    SELECT
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        invoice.billing_country,
        SUM(invoice.total) AS total
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    GROUP BY 1,4
	ORDER BY 1,5 desc
),
max_spending AS (
    SELECT
        billing_country,
        MAX(total) AS max_spending
    FROM
        bic
    GROUP BY
        billing_country
)
SELECT
    bic.*
FROM
    bic
JOIN
    max_spending ON bic.billing_country = max_spending.billing_country
	AND bic.total = max_spending.max_spending
ORDER BY  bic.billing_country;
     
	 
	 -- OR USING RECURSIVE 


WITH RECURSIVE
       customer_with_country AS (
		 select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country,
         sum(invoice.total) as total
         from customer
         join invoice on customer.customer_id = invoice.customer_id
         group by 1,4
         order by 1,5 desc  
	   ),
	   
	   country_max_spending as (
		   select billing_country,MAX(total) as max_spending
           from customer_with_country
           group by billing_country
		   
	   )
	   
select cc.billing_country,cc.total,cc.first_name, cc.last_name,cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total = ms.max_spending
order by 1


WITH bic AS (
    SELECT
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        invoice.billing_country,
        SUM(invoice.total) AS total,
	ROW_NUMBER () OVER(PARTITION BY billing_country order by sum(total) desc) as rowno
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    GROUP BY 1,4
	ORDER BY 4 asc,5 desc
)

SELECT*
FROM bic
where rowno <=1
   
