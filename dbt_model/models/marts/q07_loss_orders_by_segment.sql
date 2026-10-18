select
    segment,
    count(distinct order_id) as total_orders,
    count(distinct case when profit < 0 then order_id end) as loss_orders,
    round(100.0 * count(distinct case when profit < 0 then order_id end) 
    / count(distinct order_id), 2) as loss_order_pct,
    sum(case when profit < 0 then profit else 0 end) as total_loss
from {{ ref("fct_ecom_sales") }}
group by segment
order by loss_order_pct desc