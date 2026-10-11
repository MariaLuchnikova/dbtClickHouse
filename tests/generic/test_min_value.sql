{% test min_value(model, column_name, min_value=0) %}
    {# 
        A custom general test to check the minimum value of a column.
        Returns rows where the value is less than the specified min_value.
    #}
    SELECT
        *
    FROM {{ model }}
    WHERE {{ column_name }} < {{ min_value }}

{% endtest %}