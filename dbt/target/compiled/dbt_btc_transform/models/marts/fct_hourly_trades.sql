

with source as (

    select * from "company_dw"."dev"."stg_kaggle__btcusdt"

),


hourly as (

    select
        open_date,
        extract(hours from open_time) as open_hour,

        max(
            case
                when hour_start is true
                    then open
            end 
        ) as open_price,

        max(
            case
                when hour_end is true
                    then close
            end
        ) as close_price

    from source

    where
        hour_start is true or hour_end is true
    
    group by 1, 2

),


final as (

    select
        open_date,
        open_hour,
        open_price,
        close_price,       
        (close_price - open_price) * 1.00000000000000 / open_price as percent_gain

    from hourly

    where 
        open_price is not null
        and close_price is not null

)

select * from final