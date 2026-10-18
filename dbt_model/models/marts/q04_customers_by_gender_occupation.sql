select
    occupation,
    sum(case when gender = 'M' then 1 else 0 end) as male,
    sum(case when gender = 'F' then 1 else 0 end) as female,
    sum(case when gender is null then 1 else 0 end) as unknown,
    count(*) as total_customers
from {{ ref("dim_customer") }} 
group by occupation
order by total_customers desc