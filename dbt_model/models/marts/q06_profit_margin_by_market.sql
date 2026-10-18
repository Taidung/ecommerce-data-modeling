select
    r.market,
    count(distinct s.order_id) as total_orders,
    sum(s.revenue) as total_revenue,
    sum(s.profit) as total_profit,
    round(100 * sum(s.profit) / nullif(sum(s.revenue), 0), 2) as profit_margin_pct
from {{ ref("fct_ecom_sales") }} s
join {{ ref("dim_region") }} r on s.region_key = r.region_key
group by r.market
having count(distinct s.order_id) >= 100
order by profit_margin_pct desc
