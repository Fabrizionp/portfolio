select
    sku::varchar                as sku,
    product_name::varchar       as product_name,
    category::varchar           as category,
    size::varchar               as size,
    unit_cost::decimal(10, 2)   as unit_cost,
    unit_price::decimal(10, 2)  as unit_price,
    case_size::integer          as case_size
from {{ ref('products') }}
