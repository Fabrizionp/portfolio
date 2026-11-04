{{ config(materialized='ephemeral') }}

-- Units per day over the velocity window, per channel and SKU, as of `as_of_date`.
-- A stocking channel's demand is the sales of the channels it supplies (AWD reads FBA; the Shopify 3PL reads
-- Shopify and Walmart), because that is where its stock flows to.

with as_of as (

    select '{{ var("as_of_date") }}'::date as as_of_date

),

sales as (

    select
        l.channel_code,
        l.sku,
        sum(l.quantity) as units
    from {{ ref('slv_order_lines') }} as l
    cross join as_of
    where l.order_date > as_of.as_of_date - interval {{ var('velocity_window_days') }} day
      and l.order_date <= as_of.as_of_date
    group by 1, 2

),

channels as (

    select channel_code, supplied_from from {{ ref('brz_channels') }}

),

demand as (

    select c.channel_code, s.sku, s.units
    from channels as c
    inner join sales as s on s.channel_code = c.channel_code

    union all

    select c.channel_code, s.sku, s.units
    from channels as c
    inner join channels as t on t.supplied_from = c.channel_code
    inner join sales as s on s.channel_code = t.channel_code

)

select
    channel_code,
    sku,
    sum(units)                                      as units_window,
    sum(units) / {{ var('velocity_window_days') }}.0 as units_per_day
from demand
group by 1, 2
