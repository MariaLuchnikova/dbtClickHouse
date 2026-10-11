{% macro optimize_table() %}

    OPTIMIZE TABLE {{ this }} FINAL

{% endmacro %}