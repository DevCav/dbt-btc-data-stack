select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select open_price
from "company_dw"."analytics"."fct_hourly_trades"
where open_price is null



      
    ) dbt_internal_test