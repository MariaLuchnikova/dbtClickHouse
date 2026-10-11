{{ config(
    schema='silver'
    , full_refresh=true
    , alias='ecommerce__dict_distribution_centers'
	, tags=['silver', 'ecommerce', 'distribution_centers']
    , materialized='dictionary'
    , fields=[
        ('id', 'Int32')
        , ('name', 'String')
    ]
    , primary_key='id'
    , layout='HASHED()'
    , lifetime='0'
) }}

SELECT
    id,
    name
FROM {{ ref('bronze__ecommerce__distribution_centers') }}