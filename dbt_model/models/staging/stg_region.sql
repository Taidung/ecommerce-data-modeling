with source as (
    select *
    from {{ source("raw", "region") }}
)

select
    region_code as region_id,
    city,
    state,
    country,
    country_latitude,
    country_longitude,
    region as region_name,
    market
from source