
    
    

select
    close_time as unique_field,
    count(*) as n_records

from "company_dw"."dev"."stg_kaggle__btcusdt"
where close_time is not null
group by close_time
having count(*) > 1


