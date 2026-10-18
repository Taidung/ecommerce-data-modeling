with sales as (
    select *
    from {{ ref("stg_ecom_sales") }}
),

customer as (
    select *
    from {{ ref("dim_customer") }}
),

product as (
    select *
    from {{ ref("dim_product") }}
),

region as (
    select *
    from {{ ref("dim_region") }}
),

date as (
    select *
    from {{ ref("dim_date") }}
)

select
    s.order_id,
    d.date_key as order_date_key,
    c.customer_key,
    s.segment,
    r.region_key,
    p.product_key,
    s.quantity,
    s.revenue,
    s.discount,
    s.profit
from sales s
left join customer c on s.customer_id = c.customer_id
left join product p on s.product_id = p.product_id
left join region r on s.region_id = r.region_id
left join date d on s.order_date = d.full_date
