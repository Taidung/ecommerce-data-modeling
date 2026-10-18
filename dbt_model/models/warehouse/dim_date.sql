with source as (
    select *
    from {{ ref("stg_date") }}
)

select
    strftime(date_day, '%Y%m%d') as date_key,
    date_day as full_date,
    strftime(date_day, '%Y-%m') as year_month,
    month_start_date,
    prior_year_month_start_date,
    month_of_year as month,
    quarter_of_year as quarter,
    year_number as year
from source