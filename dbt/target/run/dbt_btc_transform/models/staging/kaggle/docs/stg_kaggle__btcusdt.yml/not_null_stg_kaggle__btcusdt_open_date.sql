select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select open_date
from "company_dw"."analytics"."stg_kaggle__btcusdt"
where open_date is null



      
    ) dbt_internal_test