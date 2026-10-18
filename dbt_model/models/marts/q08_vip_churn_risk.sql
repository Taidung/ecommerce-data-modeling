with bounds as (
    select max(full_date) as last_date
    from {{ ref("dim_date") }}
),

customer_stats as (
    select
        s.customer_key,
        sum(s.revenue) as lifetime_spend,
        max(d.full_date) as last_order_date
    from {{ ref("fct_ecom_sales") }} s
    join {{ ref("dim_date") }} d on s.order_date_key = d.date_key
    group by s.customer_key
),

top_spenders as (
    select
        customer_key,
        lifetime_spend,
        last_order_date
    from customer_stats
    order by lifetime_spend desc, customer_key
    limit 50
)

select
    c.customer_id,
    c.full_name as customer_name,
    t.lifetime_spend,
    t.last_order_date,
    datediff('day', t.last_order_date, b.last_date) as days_since_last_order
from top_spenders t
join {{ ref("dim_customer") }} c on t.customer_key = c.customer_key
cross join bounds b
where t.last_order_date < b.last_date - interval '180 days'
order by t.lifetime_spend desc