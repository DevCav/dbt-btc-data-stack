select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select percent_gain
from "company_dw"."analytics"."fct_hourly_trades"
where percent_gain is null



      
    ) dbt_internal_test