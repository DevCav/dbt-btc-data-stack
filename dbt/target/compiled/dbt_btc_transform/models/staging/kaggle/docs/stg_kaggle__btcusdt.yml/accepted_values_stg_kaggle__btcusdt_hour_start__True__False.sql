
    
    

with all_values as (

    select
        hour_start as value_field,
        count(*) as n_records

    from "company_dw"."dev"."stg_kaggle__btcusdt"
    group by hour_start

)

select *
from all_values
where value_field not in (
    'True','False'
)


