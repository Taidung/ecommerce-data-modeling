select
    segment,
    sum(revenue) as total_revenue,
    sum(profit) as total_profit
from {{ ref("fct_ecom_sales") }}
group by segment
order by total_revenue desc