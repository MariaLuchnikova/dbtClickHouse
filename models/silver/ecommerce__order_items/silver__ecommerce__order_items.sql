{{ config(
    schema='silver'
    , alias='ecommerce__order_items'
    , tags=['silver', 'ecommerce', 'order_items']
    , materialized='materialized_view'
    , engine='ReplacingMergeTree(_loaded_at)'
    , order_by='(order_id, id, created_at)'
    , partition_by='toYYYYMM(created_at)'
    , ttl='created_at + INTERVAL 10 YEAR'
) }}

WITH
    toDateTime(now()) AS load_dttm
    , 'ecommerce' AS _source
SELECT
  id
  , order_id
  , user_id
  , product_id
  , status
  , CASE WHEN dateDiff('day', shipped_at, delivered_at) >= 0 THEN dateDiff('day', shipped_at, delivered_at) ELSE 0 END AS delivery_days
  , CASE WHEN returned_at = '1970-01-01 00:00:00' THEN 0 ELSE 1 END AS is_returned
  , created_at
  , shipped_at
  , delivered_at
  , returned_at
  , sale_price
  , load_dttm AS _loaded_at
  , _source
FROM {{ ref('bronze__ecommerce__order_items') }}
WHERE sale_price > 0
AND created_at <= now()