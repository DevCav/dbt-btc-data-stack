select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select close_time
from "company_dw"."analytics"."stg_kaggle__btcusdt"
where close_time is null



      
    ) dbt_internal_test