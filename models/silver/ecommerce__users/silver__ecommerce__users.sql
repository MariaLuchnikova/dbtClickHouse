{{ config(
	schema='silver'
	, alias='ecommerce__users'
	, tags=['silver', 'ecommerce', 'users']
	, materialized='materialized_view'
	, engine='ReplacingMergeTree(_loaded_at)'
	, order_by='id'
	, partition_by='toYYYYMM(_loaded_at)'
) }}

WITH
	toDateTime(now()) AS load_dttm
    , 'ecommerce' AS _source
SELECT
    id
    , concat(first_name, ' ', last_name) AS full_name
    , email
    , age
    , CASE WHEN gender = 'M' THEN 1 ELSE 0 END AS gender
    , state
    , street_address
    , postal_code
    , CASE
        WHEN city = 'null' THEN dictGet('silver.ecommerce__dict_country_city', 'city', country)
        ELSE city
    END AS city
    , country
    , traffic_source
    , created_at
	, load_dttm AS _loaded_at
    , _source
FROM {{ ref('bronze__ecommerce__users') }}
WHERE age BETWEEN 12 AND 100