{{ config(
	schema='bronze'
	, alias='ecommerce__distribution_centers'
	, tags=['bronze', 'ecommerce', 'distribution_centers']
	, materialized='materialized_view'
	, engine='MergeTree()'
	, order_by='id'
	, partition_by='toYYYYMM(_loaded_at)'
) }}

WITH
	toDateTime(now()) AS load_dttm
SELECT
	id
	, name
	, load_dttm AS _loaded_at
FROM {{ source('ecommerce_raw', 'ecommerce__distribution_centers') }}