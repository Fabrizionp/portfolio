-- Gold equals Silver to the cent: the sum of daily net revenue by channel is the sum over the sold lines.
-- A row here is a reconciliation failure.
with gold as (

    select sum(net_revenue) as net_revenue from {{ ref('gld_sales_daily_by_channel') }}

),

silver as (

    select sum(net_revenue) as net_revenue from {{ ref('slv_order_lines') }}

)

select gold.net_revenue as gold_net_revenue, silver.net_revenue as silver_net_revenue
from gold
cross join silver
where abs(gold.net_revenue - silver.net_revenue) > 0.005
