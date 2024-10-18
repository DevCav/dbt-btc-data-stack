{{ 
    config(
        materialized='table'
        )
}}

with source as (

    select * from {{ source('raw', 'btcusdt') }} where ignore = 0

),


final as (

    -- I hate just putting a distinct to deal with duplicates but doing this because there are dupes in the source data.
    -- I would rather investigate why this is happening at the source and fix there but need to work
    -- with what was given
    select distinct 
        open_time,
        close_time,
        open,
        high,
        low,
        close,
        volume,
        quote_asset_volume,
        number_of_trades,
        taker_buy_base_asset_volume,
        taker_buy_quote_asset_volume,
        open_time::date as open_date,
        -- for this analysis we are only interested in the close and end of every given hour
        -- this flag helps for filtering in the following int_ model
        case
            when extract(minutes from open_time) = 0
            and extract(second from open_time) = 0
                then true
            else false
        end as hour_start,

        case    
            when extract(minutes from close_time) = 59 
            and extract(second from close_time) = 59.999
                then true
            else false
        end as hour_end
            

    from source

)

select * from final
