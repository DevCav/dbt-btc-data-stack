select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select hour_end
from "company_dw"."analytics"."stg_kaggle__btcusdt"
where hour_end is null



      
    ) dbt_internal_test