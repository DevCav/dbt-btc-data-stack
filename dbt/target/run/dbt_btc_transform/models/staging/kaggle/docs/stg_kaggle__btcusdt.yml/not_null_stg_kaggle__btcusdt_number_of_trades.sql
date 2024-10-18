select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select number_of_trades
from "company_dw"."analytics"."stg_kaggle__btcusdt"
where number_of_trades is null



      
    ) dbt_internal_test