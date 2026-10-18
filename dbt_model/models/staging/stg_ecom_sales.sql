with source as (
    select *
    from {{ source("raw", "ecom_sales") }}
)

select
    order_id,
    order_date,
    customer_id,
    segment,
    region_code as region_id,
    product_code as product_id,
    quantity,
    sales as revenue,
    discount,
    profit
from source