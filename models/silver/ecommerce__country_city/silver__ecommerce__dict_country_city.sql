{{ config(
    schema='silver'
    , full_refresh=true
    , alias='ecommerce__dict_country_city'
	, tags=['silver', 'reference', 'country_city']
    , materialized='dictionary'
    , fields=[
        ('country', 'String')
        , ('city', 'String')
    ]
    , primary_key='country'
    , layout='COMPLEX_KEY_HASHED()'
    , lifetime='0'
) }}

SELECT
    country,
    city
FROM {{ ref('country_city') }}