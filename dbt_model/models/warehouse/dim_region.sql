with source as (
    select *
    from {{ ref("stg_region") }}
)

select 
    {{ dbt_utils.generate_surrogate_key(['region_id']) }} as region_key,
    region_id,
    city,
    state,
    country,
    country_latitude,
    country_longitude,
    region_name,
    market
from source