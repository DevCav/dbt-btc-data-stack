select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select open_time
from "company_dw"."analytics"."stg_kaggle__btcusdt"
where open_time is null



      
    ) dbt_internal_test