                    ---Project Phase I
---1. Who is the senior most employee based on job title?
select first_name,title from employee
where levels=(select max(levels) from employee);

--2. Which countries have the most Invoices?
--select * from invoice;
                --TOP 5 ountries have the most Invoices
select top 5 billing_country as country,count(invoice_id) as invoice_count
from invoice
group by billing_country
order by  invoice_count desc;
               --OR--ALL COUNTRY-- ACCORDING TO THEIR INVOICE
select billing_country,count(invoice_id) as invoice_count
from invoice
group by billing_country
order by  invoice_count desc;

--3. What are top 3 values of total invoice? 
SELECT top 3 customer_id,SUM(total) total 
FROM invoice
group by customer_id
order by total desc;
    ---or--
SELECT TOP 3 total
FROM invoice
ORDER BY total DESC;

--4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 

select top 1 billing_city,sum(total) invoice_total ,count(total) count_invoice_total
from invoice
group by customer_id,billing_city
order by invoice_total desc;
                     --Write a query that returns one city that has the highest sum of invoice totals.
select top 1 billing_city,sum(total) invoice_total
from invoice
group by billing_city
order by invoice_total desc;
                         --Return both the city name & sum of all invoice totals
select billing_city,sum(total) invoice_total
from invoice
group by billing_city
order by invoice_total desc;

--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money 
                     -- top 5 best customer
select top 5  customer_id,sum(total) total_spent
from invoice
group by customer_id
order by total_spent desc;

                                       --Project Phase II
--1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 
select c.first_name,c.last_name,c.email,g.name
from customer c join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
--join genre g on t.genre_id=g.genre_id
join genre g on g.genre_id=t.genre_id
where g.name='Rock';

--2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands 
select top 10 a.name,count(g.name) as no_track
from artist a join album ab on ab.artist_id = a.artist_id
join  track t on ab.album_id=t.album_id
join genre g on t.genre_id = g.genre_id
where g.name ='Rock'
group by a.name
order by no_track desc;

--3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select name , milliseconds , milliseconds/60000 as minutes
from track
where milliseconds/60000 >  (select avg(milliseconds)/60000  from track)
order by milliseconds desc;
                        --OR--ADVANCE VERSION--
select a.name as artist_name ,t.name as track_name , t.milliseconds , t.milliseconds/60000 as minutes
from track t join album ab on t.album_id =ab.album_id
join artist a on ab.artist_id = a.artist_id
where t.milliseconds/60000 > (select avg(milliseconds)/60000   from track)
order by t.milliseconds desc;

                                   --#--Project Phase III--#--
--1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 
                                -------****----*-BASIC_VERSION---*-----****----------
select c.customer_id,a.name,sum(i.total) total_spent
from customer c join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id = t.track_id
join album ab on t.album_id = ab.album_id
join artist a on ab.artist_id=a.artist_id
group by c.customer_id,a.name
order by c.customer_id desc;

--------------------*****--	AND THE FINAL FORM OF THIS QUESTION IS ---*****----

SELECT c.customer_id,c.first_name,c.last_name,a.name,
 SUM(i.total) AS total_spent,
 SUM(SUM(i.total)) OVER (PARTITION BY c.customer_id) AS total_spent_by_customer
FROM 
    customer c 
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN album ab ON t.album_id = ab.album_id
    JOIN artist a ON ab.artist_id = a.artist_id
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name,
    a.name
ORDER BY 
    c.customer_id DESC;


---2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
WITH k AS (
  SELECT i.billing_country, g.name, SUM(i.total) AS total_spent
  FROM invoice i 
  JOIN invoice_line il ON i.invoice_id = il.invoice_id
  JOIN track t ON il.track_id = t.track_id
  JOIN genre g ON t.genre_id = g.genre_id
  GROUP BY i.billing_country, g.name), 
ranked_k AS (
  SELECT *,ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY total_spent DESC) AS genre_rank
  FROM k)
SELECT billing_country, name, total_spent
FROM ranked_k
WHERE genre_rank = 1
ORDER BY billing_country ASC;

---3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
                                                  ----------------------FIRST_PART------------------
WITH a AS (
  SELECT c.customer_id,c.first_name,c.last_name,i.billing_country,SUM(i.total) AS total_invoice
  FROM customer c JOIN invoice i ON c.customer_id = i.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country), 
b AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY billing_country ORDER BY total_invoice DESC) AS rnk 
  FROM a
)
SELECT * FROM b
where rnk=1
                                       ----------------------------------SECOND_PART----------------------------
								--	   Write a query that returns the country along with the top customer and how much they spent
							
WITH a AS (
  SELECT c.customer_id,c.first_name,c.last_name,i.billing_country,SUM(i.total) AS total_spent_on_music
  FROM customer c JOIN invoice i ON c.customer_id = i.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
b AS (
  SELECT a.customer_id,a.first_name,a.last_name,a.billing_country,a.total_spent_on_music,
    RANK() OVER (PARTITION BY a.billing_country ORDER BY a.total_spent_on_music DESC) AS rnk,
    MAX(a.total_spent_on_music) OVER (PARTITION BY a.billing_country) AS max_spent_on_music
  FROM a
)
SELECT b.first_name,b.last_name,b.billing_country,b.total_spent_on_music
FROM b
WHERE b.total_spent_on_music = b.max_spent_on_music
ORDER BY 
  b.billing_country,
  b.total_spent_on_music DESC
              
