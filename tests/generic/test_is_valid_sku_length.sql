{% test is_valid_sku_length(model, column_name, required_length=32) %}
    {# 
        A custom general test to check the value of a column.
        Returns rows where the value is not equal the required value=32.
    #}
    SELECT
        *
    FROM {{ model }}
    WHERE {{ length(column_name) }} != {{ required_length }}

{% endtest %}