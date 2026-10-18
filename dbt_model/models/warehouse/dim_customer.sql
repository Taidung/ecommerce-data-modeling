with source as (
    select *
    from {{ ref("stg_customer") }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    customer_id,
    first_name,
    last_name,
    full_name,
    birth_date,
    marital_status,
    gender,
    email_address,
    annual_income,
    education_level,
    occupation,
    home_owner
from source