select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select close
from "company_dw"."analytics"."stg_kaggle__btcusdt"
where close is null



      
    ) dbt_internal_test