select
    p.category,
    round(100.0 * sum(case when s.segment = 'Consumer' then s.revenue else 0 end)
    / nullif(sum(s.revenue), 0), 2) as consumer_pct,
    round(100.0 * sum(case when s.segment = 'Corporate' then s.revenue else 0 end)
    / nullif(sum(s.revenue), 0), 2) as corporate_pct,
    round(100.0 * sum(case when s.segment = 'Self-Employed' then s.revenue else 0 end)
    / nullif(sum(s.revenue), 0), 2) as self_employed_pct,
    sum(s.revenue) as total_revenue
from {{ ref("fct_ecom_sales") }} s 
join {{ ref("dim_product") }} p on s.product_key = p.product_key
group by p.category
order by consumer_pct desc