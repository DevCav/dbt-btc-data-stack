select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select open_hour
from "company_dw"."analytics"."fct_hourly_trades"
where open_hour is null



      
    ) dbt_internal_test