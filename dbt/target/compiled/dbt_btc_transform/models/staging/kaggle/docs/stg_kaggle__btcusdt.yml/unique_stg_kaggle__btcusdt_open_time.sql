
    
    

select
    open_time as unique_field,
    count(*) as n_records

from "company_dw"."dev"."stg_kaggle__btcusdt"
where open_time is not null
group by open_time
having count(*) > 1


