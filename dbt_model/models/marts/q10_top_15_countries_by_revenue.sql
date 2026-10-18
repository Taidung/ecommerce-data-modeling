select 
    r.country,
    count(distinct s.region_key) as active_regions,
    count(distinct s.customer_key) as customers,
    count(distinct s.order_id) as orders,
    sum(s.revenue) as total_revenue
from {{ ref("fct_ecom_sales") }} s
join {{ ref("dim_region") }} r on s.region_key = r.region_key
group by r.country
order by total_revenue desc
limit 15