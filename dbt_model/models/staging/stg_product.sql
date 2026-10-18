with source as (
    select *
    from {{ source("raw", "product") }}
)

select
    product_code as product_id,
    product as product_name,
    category,
    subcategory
from source