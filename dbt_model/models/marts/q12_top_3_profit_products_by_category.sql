with product_profit as (
    select 
        p.category,
        p.product_id,
        p.product_name,
        sum(s.profit) as total_profit
    from {{ ref('fct_ecom_sales') }} s
    join {{ ref("dim_product") }} p on s.product_key = p.product_key
    group by p.category, p.product_id, p.product_name
),

ranked as (
    select 
        category,
        product_name,
        total_profit,
        row_number() over (
            partition by category
            order by total_profit desc, product_id
        ) as rank_in_category
    from product_profit
)

select 
    category,
    product_name,
    total_profit,
    rank_in_category
from ranked 
where rank_in_category <= 3
order by category, rank_in_category