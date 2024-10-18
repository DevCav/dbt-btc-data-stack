select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select open_date
from "company_dw"."analytics"."fct_hourly_trades"
where open_date is null



      
    ) dbt_internal_test