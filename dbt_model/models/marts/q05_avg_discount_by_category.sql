select 
    p.category,
    round(avg(s.discount) * 100, 2) as avg_discount_pct
from {{ ref("fct_ecom_sales") }} as s
join {{ ref("dim_product") }} as p on s.product_key = p.product_key
group by p.category
order by avg_discount_pct desc