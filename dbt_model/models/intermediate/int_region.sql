-- Preserve sales region codes; coordinates remain unknown rather than fabricated.
with missing_regions as (
    select distinct s.region_id
    from {{ ref('stg_ecom_sales') }} s
    where s.region_id is not null
      and not exists (
          select 1 from {{ ref('stg_region') }} r
          where r.region_id = s.region_id
      )
)

select region_id, city, state, country, country_latitude,
       country_longitude, region_name, market
from {{ ref('stg_region') }}

union all

select region_id, 'Unknown', 'Unknown', 'Unknown', null,
       null, 'Unknown', 'Unknown'
from missing_regions
