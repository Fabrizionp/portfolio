-- Every loaded version of every order is kept here; Silver decides which version counts.
select
    order_id::varchar       as order_id,
    channel_code::varchar   as channel_code,
    customer_id::varchar    as customer_id,
    order_ts::timestamp     as order_ts,
    order_status::varchar   as order_status,
    loaded_at::timestamp    as loaded_at
from {{ ref('orders') }}
