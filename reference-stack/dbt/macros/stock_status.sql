{#-
  One status rule for the whole product, read by every surface (the Gold table, the command panel, the e-mail):
    Critical  at or below safety stock
    Warning   at or below safety stock plus the demand of the lead time
    OK        above
  Changing the rule here changes it everywhere; no page recomputes it.
-#}
{% macro stock_status(on_hand, safety_stock, units_per_day, lead_time_days) -%}
    case
        when {{ on_hand }} <= {{ safety_stock }} then 'Critical'
        when {{ on_hand }} <= {{ safety_stock }} + ceil({{ units_per_day }} * {{ lead_time_days }}) then 'Warning'
        else 'OK'
    end
{%- endmacro %}
