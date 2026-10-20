with source as (
    {{ dbt_date.get_date_dimension("2020-01-01", "2024-01-01") }}
)

select *
from source