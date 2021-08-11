USE mortgage_details;
select * from customer;
-- Total customers As per Age group
select Age, 
       COUNT(Customer_Number) AS Total_Customers
FROM customer
GROUP BY
        Age;
-- Tota customers As per Gender
SELECT Gender, 
       COUNT(Customer_Number) AS Total_Customers
FROM customer
GROUP BY
        Gender;

-- Tota customers As per Occupation
SELECT Occupation, 
       COUNT(Customer_Number) AS Total_Customers
FROM customer
GROUP BY
        Occupation;

-- Tota customers As per Occupation
SELECT Salary, 
       COUNT(Customer_Number) AS Total_Customers
FROM customer
GROUP BY
        Salary;
-- As per customer Occupation how the Loan applied,sanctioned, recovery amount
SELECT cust.Occupation,
	   SUM(san.sanction_Amt_in_Lacs) AS Total_Sanctioned_Amt,
       SUM(rec.Recovery_Amount) AS Total_Recovery_Amt,
       SUM(cust.Applied_Loan_Amount_in_Lacs) As Total_Applied_Amount
FROM 
    customer AS cust
INNER JOIN
    sanction_data AS san
ON cust.Customer_number = san.Customer_number
INNER JOIN
	recovery_data AS rec
ON cust.Customer_number = rec.Customer_number
GROUP BY
	 cust.Occupation;
-- Month & Yearwise Total_customer data
SELECT 
      MONTH, 
	  Fin_Year,
      COUNT(Customer_Number) AS Total_Customers
FROM
    customer
GROUP BY
		Month,
		Fin_Year
ORDER BY
		Fin_Year,
        Month;
