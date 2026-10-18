with rfm as (
    select 
        c.customer_id,
        date_diff('day', max(d.full_date), (select max(b.full_date) from {{ ref("dim_date") }} as b)) as recency_days,
        count(distinct s.order_id) as frequency,
        sum(s.revenue) as monetary
    from {{ ref("fct_ecom_sales") }} as s
    inner join {{ ref("dim_date") }} as d on s.order_date_key = d.date_key
    inner join {{ ref("dim_customer") }} as c on s.customer_key = c.customer_key
    group by c.customer_id
),

scored as (
    select 
        customer_id,
        recency_days,
        frequency,
        monetary,
        ntile(5) over (order by recency_days desc) as r_score,
        ntile(5) over (order by frequency asc) as f_score,
        ntile(5) over (order by monetary asc) as m_score,
    from rfm 
)

select 
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score as rfm_total
from scored
order by rfm_total desc, monetary desc, customer_id
limit 20