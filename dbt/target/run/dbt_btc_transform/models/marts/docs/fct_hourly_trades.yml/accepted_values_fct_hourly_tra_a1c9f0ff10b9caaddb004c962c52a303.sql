select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        open_hour as value_field,
        count(*) as n_records

    from "company_dw"."analytics"."fct_hourly_trades"
    group by open_hour

)

select *
from all_values
where value_field not in (
    '0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23'
)



      
    ) dbt_internal_test