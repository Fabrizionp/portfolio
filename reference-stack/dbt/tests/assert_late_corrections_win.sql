-- For every order line delivered more than once, Silver carries the quantity of the latest load.
-- A row here is a line where an earlier, wrong version survived.
with latest as (

    select order_id, line_no, quantity
    from {{ ref('brz_order_lines') }}
    qualify row_number() over (partition by order_id, line_no order by loaded_at desc) = 1

)

select l.order_id, l.line_no, l.quantity as latest_quantity, s.quantity as silver_quantity
from latest as l
inner join {{ ref('slv_order_lines') }} as s on s.order_id = l.order_id and s.line_no = l.line_no
where s.quantity <> l.quantity
