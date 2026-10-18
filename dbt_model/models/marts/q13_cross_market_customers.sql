with customer_orders as (
    select 
        c.customer_id,
        r.region_id,
        first_value(r.region_id) over (
            partition by c.customer_key
            order by d.full_date, s.order_id
        ) as first_region_code,
        s.revenue
    from {{ ref("fct_ecom_sales") }} as s
    left join {{ ref("dim_customer") }} as c on s.customer_key = c.customer_key
    left join {{ ref("dim_region") }} as r on s.region_key = r.region_key
    left join {{ ref("dim_date") }} as d on s.order_date_key = d.date_key
),

flagged as (
    select
        customer_id,
        first_region_code,
        max(case when region_id <> first_region_code then 1 else 0 end) as is_multi_region,
        sum(revenue) as total_revenue
    from customer_orders
    group by customer_id, first_region_code
)

select
    f.customer_id,
    r.city as first_city,
    r.country,
    f.total_revenue,
    (select round(100.0 * sum(is_multi_region) / nullif(count(*), 0), 2) from flagged) as multi_region_pct_all
from flagged as f 
inner join {{ ref("dim_region") }} as r on f.first_region_code = r.region_id
where f.is_multi_region = 1
order by f.total_revenue desc, f.customer_id
limit 20