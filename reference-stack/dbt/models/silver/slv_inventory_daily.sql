-- One row per day, channel and SKU: a snapshot delivered twice counts once (the latest load wins).
select
    snapshot_date,
    channel_code,
    sku,
    on_hand,
    on_order,
    loaded_at
from {{ ref('brz_inventory_snapshots') }}
qualify row_number() over (partition by snapshot_date, channel_code, sku order by loaded_at desc) = 1
