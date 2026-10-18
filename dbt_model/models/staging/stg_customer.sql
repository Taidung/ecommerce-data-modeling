with source as (
    select *
    from {{ source("raw", "customer") }}
)

select
    customer_id,
    first_name,
    last_name,
    birth_date,
    marital_status,
    gender,
    email_address,
    annual_income,
    education_level,
    occupation,
    home_owner,
    concat(first_name, ' ', last_name) as full_name
from source