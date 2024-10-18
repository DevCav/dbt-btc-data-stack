





with validation_errors as (

    select
        open_date, open_hour
    from "company_dw"."dev"."fct_hourly_trades"
    group by open_date, open_hour
    having count(*) > 1

)

select *
from validation_errors


