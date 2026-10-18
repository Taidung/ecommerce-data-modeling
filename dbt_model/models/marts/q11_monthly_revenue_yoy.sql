with monthly as (
    select
        d.year_month,
        d.month_start_date,
        d.prior_year_month_start_date,
        coalesce(sum(s.revenue), 0) as revenue
    from {{ ref('dim_date') }} as d
    left join {{ ref('fct_ecom_sales') }} as s on d.date_key = s.order_date_key
    group by
        d.year_month,
        d.month_start_date,
        d.prior_year_month_start_date

)

select
    cur.year_month,
    round(cur.revenue, 2) as revenue,
    round(prev.revenue, 2) as revenue_last_year,
    round(
        100.0 * (cur.revenue - prev.revenue)
        / nullif(prev.revenue, 0),
        2
    ) as yoy_growth_pct

from monthly as cur
left join monthly as prev
    on cur.prior_year_month_start_date = prev.month_start_date
where cur.month_start_date >= (
    select max(month_start_date) - interval '23 months'
    from monthly
)
order by cur.month_start_date