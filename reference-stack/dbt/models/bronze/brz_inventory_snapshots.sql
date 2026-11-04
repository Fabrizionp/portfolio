select
    snapshot_date::date     as snapshot_date,
    channel_code::varchar   as channel_code,
    sku::varchar            as sku,
    on_hand::integer        as on_hand,
    on_order::integer       as on_order,
    loaded_at::timestamp    as loaded_at
from {{ ref('inventory_snapshots') }}
