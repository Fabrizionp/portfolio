-- One row per day and channel. The contract in _gold.yml is what the sales overview reads; a column cannot
-- change type or disappear without this model failing to build.
select
    order_date::date                              as order_date,
    channel_code::varchar                         as channel_code,
    count(distinct order_id)::integer             as orders,
    sum(quantity)::integer                        as units,
    round(sum(net_revenue), 2)::decimal(18, 2)    as net_revenue,
    round(sum(cogs), 2)::decimal(18, 2)           as cogs,
    round(sum(gross_profit), 2)::decimal(18, 2)   as gross_profit,
    count(distinct customer_id)::integer          as customers
from {{ ref('slv_order_lines') }}
group by 1, 2
