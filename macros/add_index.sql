{% macro add_index(index_name, column_expression, index_type, granularity=1) %}

    ALTER TABLE {{ this }} 
    ADD INDEX IF NOT EXISTS {{ index_name }} {{ column_expression }} TYPE {{ index_type }} GRANULARITY {{ granularity }};

{% endmacro %}