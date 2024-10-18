select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      





with validation_errors as (

    select
        open_date, open_hour
    from "company_dw"."analytics"."fct_hourly_trades"
    group by open_date, open_hour
    having count(*) > 1

)

select *
from validation_errors



      
    ) dbt_internal_test