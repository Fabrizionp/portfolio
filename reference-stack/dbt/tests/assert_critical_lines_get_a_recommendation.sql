-- A Critical line with demand and nothing on order always gets a quantity to buy or transfer.
select channel_code, sku, on_hand, units_per_day, status, recommended_qty
from {{ ref('gld_inventory_needs') }}
where status = 'Critical'
  and units_per_day > 0
  and on_order = 0
  and recommended_qty <= 0
