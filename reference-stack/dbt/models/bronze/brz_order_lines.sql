select
    order_id::varchar           as order_id,
    line_no::integer            as line_no,
    sku::varchar                as sku,
    quantity::integer           as quantity,
    unit_price::decimal(10, 2)  as unit_price,
    discount::decimal(10, 2)    as discount,
    loaded_at::timestamp        as loaded_at
from {{ ref('order_lines') }}
