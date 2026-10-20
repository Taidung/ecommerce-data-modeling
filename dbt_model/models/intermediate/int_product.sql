-- Preserve sales product codes until the source provides their attributes.
with missing_products as (
    select distinct s.product_id
    from {{ ref('stg_ecom_sales') }} s
    where s.product_id is not null
      and not exists (
          select 1 from {{ ref('stg_product') }} p
          where p.product_id = s.product_id
      )
)

select product_id, product_name, category, subcategory
from {{ ref('stg_product') }}

union all

select product_id, 'Unknown', 'Unknown', 'Unknown'
from missing_products
