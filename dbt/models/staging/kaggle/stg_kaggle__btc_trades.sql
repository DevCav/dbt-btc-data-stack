{{ 
    config(
        materialized='table'
        )
}}

with source as (

    select * from {{ source('raw', 'bitcoin_trades') }} where ignore = 0

),


final as (

    select
        open_timestamp,
        close_timestamp,
        open,
        high,
        low,
        close,
        volume,
        quote,
        number_of_trades,
        taker_buy_base_asset_volume,
        -- messed up load script and don't want to waste time reloading data. renaming here
        take_buy_quote_asset_volume as taker_buy_quote_asset_volume,
        -- for this analysis we are only interested in the close and end of every given hour
        -- this flag helps for filtering in the following int_ model
        case
            when extract(minute from open_timestamp) = 0 
            and extract(second from open_timestamp) = 0
                then true
            when extract(minute from close_timestamp) = 59 
            and extract(second from close_timestamp) = 59.999
                then true
            else false
        end as include_flag
            

    from source

)

select * from final
