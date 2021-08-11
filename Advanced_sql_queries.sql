use market_star_schema_advsql;
-- ranking by sales
select ord_id, customer_name,
		round(sales) as rounded_sales,
        rank() over(order by sales desc) as sales_rank
from market_fact_full as m
inner join cust_dimen as c
on m.Cust_id = c.Cust_id
where city = 'mysore' and customer_name = 'john lucas' ;
-- Common table expression
with rank_info as
(
select ord_id, customer_name,
		round(sales) as rounded_sales,
        rank() over(order by sales desc) as sales_rank
from market_fact_full as m
inner join cust_dimen as c
on m.Cust_id = c.Cust_id
where city = 'mysore' and customer_name = 'john lucas'
)
select * from rank_info
where sales_rank <= 10;

-- ranking by discount
select ord_id, customer_name, discount,
		rank() over(order by discount desc) as discount_rank
from market_fact_full as m
inner join cust_dimen as c
on m.Cust_id = c.Cust_id
where customer_name = 'john lucas';

-- using dense_rank()
select ord_id, customer_name, discount,
		dense_rank() over(order by discount desc) as discount_rank
from market_fact_full as m
inner join cust_dimen as c
on m.Cust_id = c.Cust_id
where customer_name = 'john lucas';

-- using percent_rank()
select ord_id, customer_name, discount,
		percent_rank() over(order by discount desc) as discount_rank
from market_fact_full as m
inner join cust_dimen as c
on m.Cust_id = c.Cust_id
where customer_name = 'john lucas';

-- row_number()
select ord_id, customer_name, discount,
		row_number() over(order by discount desc) as discount_rank
from market_fact_full as m
inner join cust_dimen as c
on m.Cust_id = c.Cust_id
where customer_name = 'john lucas';

-- rank(), dense_rank(), row_number()
select customer_name, count(distinct ord_id),
		rank() over(order by count(distinct ord_id) desc) as rank_order,
        dense_rank() over(order by count(distinct ord_id) desc) as dense_rank_order,
        row_number() over(order by count(distinct ord_id) desc) as row_num_order
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id = c.cust_id
group by customer_name;

-- partition by
select count(*) as shipments, month(ship_date) as shipping_month, ship_mode,
		 row_number() over(partition by ship_mode order by count(*) desc) as order_rank
 from shipping_dimen
 group by ship_mode,
          shipping_month;

-- window
select customer_name, discount,
		rank() over w as rank_order,
        dense_rank() over w as dense_rank_order,
        row_number() over w as row_num_order
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id = c.cust_id
window w as (partition by customer_name order by discount desc);

-- Frames: to calculate  daily running cost and moving average over 7 day period
with daily_shipping_summary as
(select ship_date,
		sum(shipping_cost) as daily_total
from 
shipping_dimen as s
inner join market_fact_full as m
on s.ship_id = m.ship_id
group by ship_date
)
select *,
sum(daily_total) over w1 as Running_total,
avg(daily_total) over (order by ship_date rows 6 preceding) as moving_avg
from daily_shipping_summary
window w1 as (order by ship_date rows unbounded preceding);
	   -- w2 as (order by ship_date rows 6 preceding);

-- Lead & Lag function
with cust_order as
(
select m.ord_id, c.customer_name, o.order_date
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id = c. cust_id
inner join orders_dimen as o
on m.ord_id = o.ord_id
where customer_name = 'Rick Wilson'
group by
		m.ord_id, 
		c.customer_name, 
		o.order_date
),
next_date_summary as
(
select *,
		lead(order_date,1) over(order by order_date, ord_id) as next_order_date
from cust_order
)
select *,
		datediff (next_order_date, order_date) as day_diff
from next_date_summary;

with cust_order as
(
select m.ord_id, c.customer_name, o.order_date
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id = c. cust_id
inner join orders_dimen as o
on m.ord_id = o.ord_id
where customer_name = 'Rick Wilson'
group by
		m.ord_id, 
		c.customer_name, 
		o.order_date
),
previous_date_summary as
(
select *,
		lag(order_date,1) over(order by order_date, ord_id) as previous_order_date
from cust_order
)
select *,
		datediff (order_date, previous_order_date) as day_diff
from previous_date_summary;

-- Case when statement
/* 
profit < -500 --> huge loss
profit -500 to 0 --> bearable loss
profit> 0 and < 500 --> descent profit
profit > 500 ---> huge profit
*/
select market_fact_id, prod_id, sum(profit) as total_profit, count(*) as count,
		case when profit < -500 then 'Huge Loss'
			 when profit < 0 and profit >=-500 then 'Bearable loss'
             when profit > 0 and profit <= 500 then 'Decent profit'
             when profit > 500 then 'Huge profit'
		else 'No profit no loss'
        end as profit_category
from market_fact_full
group by profit_category;

/* 
top 10% customer as Gold
next 40% customer as Silver
Rest 50% customer as Bronze
*/
with cust_info as
(
select m.cust_id, c.customer_name, round(sum(m.sales)) as total_sales,
		percent_rank() over(order by round(sum(m.sales)) desc) as perc_rank 
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id = c.cust_id
group by cust_id
)
select *,
case
	when perc_rank <= 0.1 then 'Gold'
    when perc_rank > 0.1 and perc_rank <= 0.5 then 'Silver'
    else 'Bronze'
end as customer_category
from cust_info;

