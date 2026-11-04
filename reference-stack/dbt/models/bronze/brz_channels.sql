-- Bronze mirrors the source 1:1 with explicit columns and types. No business rule lives here.
select
    channel_code::varchar            as channel_code,
    channel_name::varchar            as channel_name,
    kind::varchar                    as kind,
    supplied_from::varchar           as supplied_from,
    sells::boolean                   as sells,
    lead_time_days::integer          as lead_time_days,
    purchase_frequency_days::integer as purchase_frequency_days,
    safety_days::integer             as safety_days
from {{ ref('channels') }}
