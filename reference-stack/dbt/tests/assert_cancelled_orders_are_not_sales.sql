-- An order whose latest version is cancelled has no line in Silver, even when its first version said fulfilled.
select s.order_id, s.line_no
from {{ ref('slv_order_lines') }} as s
inner join {{ ref('slv_orders') }} as o on o.order_id = s.order_id
where o.order_status = 'cancelled'
