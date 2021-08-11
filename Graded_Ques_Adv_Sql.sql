USE sakila;

-- Q.1 Write a query to find the month number (Eg: 4 corresponds to April) in which the most number of payments were made.
SELECT MONTH(payment_date) AS Payment_month,
	   COUNT(payment_id) AS No_of_Payments
FROM payment
GROUP BY
		MONTH(payment_date)
ORDER BY
		COUNT(payment_id) DESC;
        
-- Q.2 List the rounded average film lengths for each film category. Arrange the values in the decreasing order of the average film lengths.
SELECT ROUND(AVG(fm.length)) AS avg_Length,
	   ct.name AS name
FROM 
	film AS fm
INNER JOIN
	film_category AS fc
    ON fm.film_id = fc.film_id
		INNER JOIN
			category AS ct
            ON fc.category_id = ct.category_id
GROUP BY
		ct.name
ORDER BY
		ROUND(AVG(fm.length)) DESC;

-- Q.3 Write a query to find the number of occurrences of each film_category in each city. 
--     Arrange them in the decreasing order of their category count.	

SELECT c.name,
		ci.city,
        COUNT(c.name) AS category_count
        
FROM
    city AS ci
        INNER JOIN
    address AS ad ON ci.city_id = ad.city_id
		INNER JOIN
    customer AS cst ON ad.address_id = cst.address_id
        INNER JOIN
	rental AS rent ON rent.customer_id = cst.customer_id
		INNER JOIN
    inventory AS inv ON rent.inventory_id = inv.inventory_id
        INNER JOIN
    film_category AS fc ON inv.film_id = fc.film_id
        INNER JOIN
    category AS c ON fc.category_id = c.category_id
GROUP BY
		ci.city
ORDER BY
		category_count DESC;
/* Following code written with different path using ERD gives completly different resullt than the above code. The output parameters
   of both codes are same. The code above gives multiple cities and multiple categories while this code gives only two cities and one category.
SELECT c.name,
		ci.city,
        COUNT(c.name) AS category_count
        
FROM
    city AS ci
        INNER JOIN
    address AS ad ON ci.city_id = ad.city_id
		INNER JOIN
    staff AS stf ON ad.address_id = stf.address_id
		INNER JOIN
    store AS st ON stf.store_id = st.store_id
        INNER JOIN
	inventory AS inv ON st.store_id = inv.store_id
        INNER JOIN
    film_category AS fc ON inv.film_id = fc.film_id
        INNER JOIN
    category AS c ON fc.category_id = c.category_id
GROUP BY
		ci.city
ORDER BY
		category_count DESC;
*/
-- Q.4 Suppose you are running an advertising campaign in Canada for which you need the film_ids and titles of all the films released in Canada. 
--     List the films in the alphabetical order of their titles.
SELECT f.film_id,
		f.title
FROM
    country AS co 
		INNER JOIN
    city AS ci ON co.country_id = ci.country_id
        INNER JOIN
    address AS ad ON ci.city_id = ad.city_id
		INNER JOIN
    store AS st ON ad.address_id = st.address_id
        INNER JOIN
	inventory AS inv ON st.store_id = inv.store_id
        INNER JOIN
    film AS f ON inv.film_id = f.film_id
WHERE
		co.country = 'canada'
GROUP BY
		f.title
ORDER BY 
		f.title;
        
-- Q.5 Write a query to list all the films existing in the 'Comedy' category and arrange them in the alphabetical order.

SELECT f.film_id, 
	   c.name,
       title
FROM film_category AS fc
INNER JOIN
category AS c ON c.category_id = fc.category_id
INNER JOIN
film AS f ON f.film_id = fc.film_id
WHERE c.name = 'Comedy'
ORDER BY 
		title;

-- Q.6 List the first and last names of all customers whose first names start with the letters 'A', 'J' or 'T' or last names end with the substring 'on'. 
-- Arrange them alphabetically in the order of their first names.
SELECT First_name,
	   Last_name
FROM customer
WHERE
	first_name  REGEXP '^[A,J,T]' OR
    last_name REGEXP'ON$'
ORDER BY
	first_name;
    
		
