select
    p.product_id,
    p.product_name,
    sum(s.quantity) as total_quantity
from {{ ref("fct_ecom_sales") }} s
join {{ ref("dim_product") }} p on s.product_key = p.product_key
group by p.product_id, p.product_name
order by total_quantity desc, p.product_id
limit 10