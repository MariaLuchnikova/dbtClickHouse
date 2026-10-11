{{ config(
	schema='silver'
	, alias='ecommerce__products'
	, tags=['silver', 'ecommerce', 'products']
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
    , cost
    , category
    , name
    , brand
    , retail_price
    , (retail_price - cost) as profit
    , CASE WHEN department = 'Men' THEN 1 ELSE 0 END AS department
    , sku
    , distribution_center_id
    , dictGet('silver.ecommerce__dict_distribution_centers', 'name', distribution_center_id) AS distribution_center_name
    , load_dttm AS _loaded_at
    , _source
FROM {{ ref('bronze__ecommerce__products') }}
WHERE cost > 0