with order_products as (
    select distinct s.order_id, p.product_id
    from {{ ref("fct_ecom_sales") }} s
    inner join {{ ref("dim_product") }} p on s.product_key = p.product_key
),

pairs as (
    select
        a.product_id as product_a_id,
        b.product_id as product_b_id,
        count(*) as times_together
    from order_products as a 
    inner join order_products as b 
    on a.order_id = b.order_id
    and b.product_id > a.product_id
    group by a.product_id, b.product_id
)

select 
    pa.product_name as product_a,
    pb.product_name as product_b,
    pr.times_together
from pairs as pr 
inner join {{ ref("dim_product") }} as pa 
on pa.product_id = pr.product_a_id
inner join {{ ref("dim_product") }} as pb 
on pb.product_id = pr.product_b_id
order by pr.times_together desc, product_a, product_b
limit 15