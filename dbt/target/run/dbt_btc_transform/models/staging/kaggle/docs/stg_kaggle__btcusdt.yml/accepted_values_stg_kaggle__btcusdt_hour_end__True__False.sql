select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        hour_end as value_field,
        count(*) as n_records

    from "company_dw"."analytics"."stg_kaggle__btcusdt"
    group by hour_end

)

select *
from all_values
where value_field not in (
    'True','False'
)



      
    ) dbt_internal_test