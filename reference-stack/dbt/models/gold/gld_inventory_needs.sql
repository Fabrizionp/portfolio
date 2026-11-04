-- One row per channel and SKU as of `as_of_date`: stock, demand, the status by the one rule, and the quantity to
-- buy or transfer by the one macro. A missing metric shows its reason, never a 0: days_of_cover is null when the
-- SKU had no demand in the window, and days_of_cover_note says so.

with as_of as (

    select '{{ var("as_of_date") }}'::date as as_of_date

),

stock as (

    select i.channel_code, i.sku, i.on_hand, i.on_order
    from {{ ref('slv_inventory_daily') }} as i
    cross join as_of
    where i.snapshot_date = as_of.as_of_date

),

base as (

    select
        as_of.as_of_date,
        c.channel_code,
        c.kind                                              as channel_kind,
        c.supplied_from,
        p.sku,
        p.product_name,
        p.category,
        p.case_size,
        coalesce(s.on_hand, 0)                              as on_hand,
        coalesce(s.on_order, 0)                             as on_order,
        coalesce(v.units_window, 0)                         as units_window,
        coalesce(v.units_per_day, 0)                        as units_per_day,
        c.lead_time_days,
        c.purchase_frequency_days,
        ceil(coalesce(v.units_per_day, 0) * c.safety_days)  as safety_stock
    from {{ ref('brz_channels') }} as c
    cross join as_of
    cross join {{ ref('brz_products') }} as p
    left join stock as s on s.channel_code = c.channel_code and s.sku = p.sku
    left join {{ ref('slv_sku_velocity') }} as v on v.channel_code = c.channel_code and v.sku = p.sku

),

scored as (

    select
        *,
        {{ stock_status('on_hand', 'safety_stock', 'units_per_day', 'lead_time_days') }} as status,
        {{ reorder_quantity('on_hand', 'on_order', 'units_per_day', 'lead_time_days',
                            'purchase_frequency_days', 'safety_stock', 'case_size') }}    as recommended_qty
    from base

)

select
    as_of_date::date                                                        as as_of_date,
    channel_code::varchar                                                   as channel_code,
    channel_kind::varchar                                                   as channel_kind,
    supplied_from::varchar                                                  as supplied_from,
    sku::varchar                                                            as sku,
    product_name::varchar                                                   as product_name,
    category::varchar                                                       as category,
    on_hand::integer                                                        as on_hand,
    on_order::integer                                                       as on_order,
    units_window::integer                                                   as units_window,
    round(units_per_day, 2)::decimal(10, 2)                                 as units_per_day,
    safety_stock::integer                                                   as safety_stock,
    lead_time_days::integer                                                 as lead_time_days,
    purchase_frequency_days::integer                                        as purchase_frequency_days,
    (case when units_per_day > 0 then round(on_hand / units_per_day, 1) end)::decimal(10, 1) as days_of_cover,
    (case when units_per_day = 0 then 'no demand in the last {{ var("velocity_window_days") }} days' end)::varchar as days_of_cover_note,
    status::varchar                                                         as status,
    recommended_qty::integer                                                as recommended_qty,
    (recommended_qty / case_size)::integer                                  as recommended_cases,
    case_size::integer                                                      as case_size
from scored
