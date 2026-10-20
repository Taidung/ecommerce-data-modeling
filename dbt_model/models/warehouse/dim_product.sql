with source as (
    select *
    from {{ ref("int_product") }}
)

select 
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
    product_id,
    product_name,
    category,
    subcategory
from source
