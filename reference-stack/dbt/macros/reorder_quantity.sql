{#-
  Units to order so that on hand plus on order covers the safety stock and the demand until the next order can
  arrive (lead time plus the purchase cycle), rounded up to whole cases. Zero when already covered.
  The same macro serves buying channels and transfer channels; the channel row supplies the parameters.
-#}
{% macro reorder_quantity(on_hand, on_order, units_per_day, lead_time_days, purchase_frequency_days, safety_stock, case_size) -%}
    greatest(
        0,
        ceil(
            ({{ safety_stock }} + {{ units_per_day }} * ({{ lead_time_days }} + {{ purchase_frequency_days }})
             - {{ on_hand }} - {{ on_order }}) / {{ case_size }}
        )
    ) * {{ case_size }}
{%- endmacro %}
