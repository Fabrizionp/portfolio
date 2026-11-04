{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='line_key'
) }}

-- Incremental with a lookback: every run re-reads the last `lookback_days` of loads, so a late or corrected line
-- replaces the version already in the table instead of sitting next to it. Within the window the latest version
-- wins. Cancelled orders are not sales and never reach this table.

with lines as (

    select
        order_id || '-' || line_no as line_key,
        order_id,
        line_no,
        sku,
        quantity,
        unit_price,
        discount,
        loaded_at
    from {{ ref('brz_order_lines') }}
    {% if is_incremental() %}
    where loaded_at > (
        select coalesce(max(loaded_at), '1900-01-01'::timestamp) from {{ this }}
    ) - interval {{ var('lookback_days') }} day
    {% endif %}
    qualify row_number() over (partition by order_id, line_no order by loaded_at desc) = 1

)

select
    l.line_key,
    l.order_id,
    l.line_no,
    o.channel_code,
    o.customer_id,
    o.order_ts,
    o.order_date,
    o.order_status,
    l.sku,
    p.category,
    l.quantity,
    l.unit_price,
    l.discount,
    round(l.quantity * l.unit_price - l.discount, 2)                          as net_revenue,
    round(l.quantity * p.unit_cost, 2)                                        as cogs,
    round(l.quantity * l.unit_price - l.discount - l.quantity * p.unit_cost, 2) as gross_profit,
    l.loaded_at
from lines as l
inner join {{ ref('slv_orders') }} as o on o.order_id = l.order_id
inner join {{ ref('brz_products') }} as p on p.sku = l.sku
where o.order_status <> 'cancelled'
