select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select taker_buy_quote_asset_volume
from "company_dw"."analytics"."stg_kaggle__btcusdt"
where taker_buy_quote_asset_volume is null



      
    ) dbt_internal_test