{{ config(
	schema='bronze'
	, alias='ecommerce__orders'
	, tags=['bronze', 'ecommerce', 'orders']
	, materialized='materialized_view'
	, engine='MergeTree()'
	, order_by='(order_id, created_at)'
	, partition_by='toYYYYMM(created_at)'
  , ttl='created_at + INTERVAL 10 YEAR'
) }}

WITH
	toDateTime(now()) AS load_dttm
SELECT
	order_id
	, user_id
	, CAST(status AS LowCardinality(String)) AS status
	, toDateTime(created_at) AS created_at
	, toDateTime(returned_at) AS returned_at
	, toDateTime(shipped_at) AS shipped_at
	, toDateTime(delivered_at) AS delivered_at
	, num_of_item
	, load_dttm AS _loaded_at
FROM {{ source('ecommerce_raw', 'ecommerce__orders') }}