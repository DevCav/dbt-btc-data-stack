
    
    

select
    open_date as unique_field,
    count(*) as n_records

from "company_dw"."analytics"."fct_hourly_trades"
where open_date is not null
group by open_date
having count(*) > 1


