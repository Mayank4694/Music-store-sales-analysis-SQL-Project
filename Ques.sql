use music_library;

-- Q1. Who is the senior most employee based on job title?
SELECT 
    first_name, last_name, title, levels
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- Calculate the total revenue generated from all sales. Retrieve the total number of sales transactions.
SELECT 
    ROUND(SUM(total), 2) AS Total_Sales,
    COUNT(invoice_id) AS Transactions
FROM
    invoice;

-- Identify the country with the most customers.
SELECT 
    billing_country,
    COUNT(DISTINCT (customer_id)) AS customer_count
FROM
    invoice
GROUP BY billing_country
ORDER BY customer_count DESC
LIMIT 1;

-- Q2. Which countries have the most Invoices?
SELECT 
    billing_country, COUNT(invoice_id) AS invoice_count
FROM
    invoice
GROUP BY billing_country
ORDER BY invoice_count DESC
LIMIT 5;

-- Q3. What are top 3 values of total invoice?
SELECT 
    *
FROM
    invoice
ORDER BY total DESC
LIMIT 3;





/* Q4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

SELECT 
    billing_city, round(SUM(total),2) AS revenue
FROM
    invoice
GROUP BY billing_city
ORDER BY revenue DESC
LIMIT 1;

/* Q5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */

SELECT 
    customer.customer_id,
    CONCAT(first_name, ' ', last_name) AS name,
    SUM(total) AS spent
FROM
    invoice
        JOIN
    customer ON invoice.customer_id = customer.customer_id
GROUP BY customer_id , first_name , last_name
ORDER BY spent DESC
LIMIT 1;

/* Q6. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

SELECT DISTINCT
    email, first_name, last_name, genre.name
FROM
    invoice_line
        JOIN
    invoice ON invoice.invoice_id = invoice_line.invoice_id
        JOIN
    customer ON customer.customer_id = invoice.customer_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name = 'Rock'
ORDER BY email ASC;


-- Revenue Contribution by genre: Calculate the percentage of total revenue contributed by each genre.
SELECT 
    genre.name AS genre,
    ROUND(SUM(invoice_line.quantity * invoice_line.unit_price) * 100 / (SELECT 
                    SUM(total)
                FROM
                    invoice),
            2) AS 'revenue%'
FROM
    invoice
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    genre ON genre.genre_id = track.genre_id
GROUP BY genre.name;


/* Q7. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

SELECT 
    artist.name AS artist_name, COUNT(genre_id) AS track_count
FROM
    artist
        JOIN
    album ON artist.artist_id = album.artist_id
        JOIN
    track ON album.album_id = track.album_id
GROUP BY artist.name , genre_id
HAVING genre_id IN (SELECT 
        genre_id
    FROM
        genre
    WHERE
        name = 'Rock')
ORDER BY track_count DESC
LIMIT 10;

/* Q8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first
*/
SELECT 
    AVG(milliseconds)
FROM
    track AS x;
-- 251177.7432
-- count
SELECT 
    count(track_id)
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;

-- all track id's
SELECT 
    track_id, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;

/* Q9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

select concat(customer.first_name," ", customer.last_name) as customer, artist.name as artist, 
sum(invoice_line.quantity* invoice_line.unit_price) as spent
from invoice join customer on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id 
group by customer.customer_id, first_name, last_name, artist.name order by customer;


/* Q10. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres*/

-- RANK
select billing_country, genre from
(select billing_country, genre, purchases, 
rank() over(partition by billing_country 
order by billing_country asc, purchases desc) as class from
(select billing_country, genre.name as genre, sum(quantity) as purchases
from invoice join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id group by billing_country, genre.name) as a) as b 
where class = 1;

/* Q11. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */

select billing_country, customer_id, first_name,last_name, spent from
(select billing_country, customer_id, first_name,last_name, spent, 
rank() over(partition by billing_country order by spent desc) as class from
(select billing_country, customer.customer_id, first_name,last_name, sum(total) as spent
from customer join invoice on customer.customer_id  =invoice.customer_id 
group by customer.customer_id, first_name,last_name, billing_country 
order by billing_country asc, spent desc) as a) as b where class =1;

























