-- stored procedures
use market_star_schema_advsql;

delimiter **

create procedure get_sales_customers(sales_input int)
begin
		select distinct m.cust_id, customer_name, round(sales) as sales_amount
        from market_fact_full as m 
        inner join cust_dimen as c
        on m.cust_id = c.cust_id
        where round(sales) > sales_input
        order by sales;
end **
delimiter ;
call get_sales_customers(500)