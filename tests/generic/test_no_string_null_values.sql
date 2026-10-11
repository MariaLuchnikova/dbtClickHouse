{% test no_string_null_values(model, column_name) %}
    {# 
        A custom generic test to check for the absence of the string value 'null' in a column.
        Returns rows where the text equals 'null'.
    #}
    SELECT
        *
    FROM {{ model }}
    WHERE lower({{ column_name }}) = 'null'

{% endtest %}