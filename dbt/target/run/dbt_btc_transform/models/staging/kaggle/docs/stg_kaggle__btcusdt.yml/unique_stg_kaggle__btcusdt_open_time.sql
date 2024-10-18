select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    open_time as unique_field,
    count(*) as n_records

from "company_dw"."analytics"."stg_kaggle__btcusdt"
where open_time is not null
group by open_time
having count(*) > 1



      
    ) dbt_internal_test