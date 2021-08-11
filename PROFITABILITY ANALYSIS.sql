/*---------------------------------------------------------------------------------------------------------------------------------------------------- 
Problem statement: Identify the sustainable (profitable) product categories so that the growth team can capitalise on them to increase sales.

 Metrics: Some of the metrics that can be used for performing the profitability analysis are as follows:

Profits per product category
Profits per product subcategory
Average profit per order
Average profit percentage per order
---------------------------------------------------------------------------------------------------------------------------------------------------*/
USE MARKET_STAR_SCHEMA_ADVSQL;
SELECT 
    p.Product_category,
--    p.Product_sub_category,
    SUM(m.profit) AS Profits
FROM
    market_fact_full AS m
	INNER JOIN
    prod_dimen AS p 
    ON m.prod_id = p.prod_id
GROUP BY p.Product_category 
-- p.Product_sub_category
ORDER BY 
		Profits;
-- This will give profit per product_category
SELECT 
    p.Product_category,
	p.Product_sub_category,
    SUM(m.profit) AS Profits
FROM
    market_fact_full AS m
	INNER JOIN
    prod_dimen AS p 
    ON m.prod_id = p.prod_id
GROUP BY p.Product_category, 
		 p.Product_sub_category
ORDER BY 
		p.Product_category,
        Profits;
-- This will give profit per product_sub_category

SELECT
	p.Product_category,
    p.Product_sub_category,
	SUM(m.profit)/COUNT(DISTINCT order_number) AS Avg_Profits
FROM 
	market_fact_full AS m
	INNER JOIN
    prod_dimen AS p 
    ON m.prod_id = p.prod_id
    INNER JOIN
    orders_dimen AS o
    ON m.ord_id = o.ord_id
GROUP BY
	p.Product_sub_category,
	p.product_category
ORDER BY
	Avg_Profits DESC;
-- This will give average profit per subcategory
SELECT
	p.Product_category,
    p.Product_sub_category,
	SUM(m.profit)/COUNT(DISTINCT order_number) AS Avg_Profits_per_order,
    round(SUM(m.sales)/COUNT(DISTINCT order_number)) AS Avg_sales_per_order,
    round((SUM(m.profit)/COUNT(DISTINCT order_number)) * 100 / (SUM(m.sales)/COUNT(DISTINCT order_number)),2) AS Avg_Perc_profit_per_order
FROM 
	market_fact_full AS m
	INNER JOIN
    prod_dimen AS p 
    ON m.prod_id = p.prod_id
    INNER JOIN
    orders_dimen AS o
    ON m.ord_id = o.ord_id
GROUP BY
	p.Product_sub_category,
	p.product_category
ORDER BY
	Avg_Perc_profit_per_order DESC;
    
-- This will give Avg percent profit per order



/* Top 10 Profitable customers details in the form
cust_id
Rank
Customer_Name
Customer_city
Customer_State
Sales

*/
WITH cust_summary AS
(
	SELECT m.cust_id,
		   RANK() OVER(ORDER BY SUM(m.profit) desc) AS Cust_Rank,
		   c.customer_name,
		   SUM(m.profit) AS profit,
		   c.city AS Customer_city,
		   c.state AS Customer_state,
		   ROUND(SUM(m.sales)) AS sales
	FROM market_fact_full as m
	INNER JOIN 
	cust_dimen as c
	ON m.cust_id = c.cust_id
	GROUP BY c.cust_id
)
SELECT * 
FROM cust_summary
WHERE Cust_Rank <=10;

	
/* Customers without orders yet
cust_id
Customer_name
city
state
customer_segment
Flag to indicate if there is another customer with exact same name and city but with different cust_id
*/
SELECT c.*
FROM 
	cust_dimen AS c
    LEFT JOIN
    market_fact_full AS m
    ON m.cust_id = c.cust_id
    WHERE ord_id is NULL;

-- No customer with zero order is found
-- check if it is true

SELECT
		COUNT(cust_id)
FROM cust_dimen;
-- 1832
SELECT
		COUNT(DISTINCT cust_id)
FROM market_fact_full;
-- 1832
-- Thus there are no customers with zero orders

/* Customers with more than one order
cust_id
Customer_name
city
state
customer_segment
Flag to indicate if there is another customer with exact same name and city but with different cust_id
*/
SELECT
	  c.*,
      COUNT(DISTINCT m.ord_id) AS Order_count
FROM
    cust_dimen AS c
    INNER JOIN
    market_fact_full AS m
    ON c.cust_id = m.Cust_id
GROUP BY
		Cust_id
	HAVING COUNT(DISTINCT m.ord_id) <> 1;

-- check unique customer name and city
SELECT Customer_Name, City,
		COUNT(cust_id) AS cust_id_count
FROM 
	cust_dimen 
GROUP BY Customer_Name,
		 City
HAVING COUNT(cust_id) > 1;

-- Fraud Detection and applying Flag on fraudelent customer

WITH cust_summary AS
(
	SELECT
		  c.*,
		  COUNT(DISTINCT m.ord_id) AS Order_count
	FROM
		cust_dimen AS c
		LEFT JOIN
		market_fact_full AS m
		ON c.cust_id = m.Cust_id
	GROUP BY
			Cust_id
		HAVING COUNT(DISTINCT m.ord_id) <> 1
),
fraud_list AS
(
	SELECT Customer_Name, City,
			COUNT(cust_id) AS cust_id_count
	FROM 
		cust_dimen 
	GROUP BY Customer_Name,
			 City
	HAVING COUNT(cust_id) > 1
)
SELECT cs.*,
		CASE WHEN fl.cust_id_count IS NOT NULL
			 THEN 'Fraudelent' 
        ELSE 'Normal' 
        END AS Fraud_Flag
FROM 
    cust_summary AS cs
LEFT JOIN
	fraud_list AS fl
    ON
      cs.customer_name = fl.customer_name AND 
			  cs. city = fl.city;


    
   
		
