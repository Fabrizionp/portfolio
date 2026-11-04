-- The latest loaded version of each order wins: a cancellation that arrived a day later replaces the first row.
select
    order_id,
    channel_code,
    customer_id,
    order_ts,
    order_ts::date as order_date,
    order_status,
    loaded_at
from {{ ref('brz_orders') }}
qualify row_number() over (partition by order_id order by loaded_at desc) = 1
