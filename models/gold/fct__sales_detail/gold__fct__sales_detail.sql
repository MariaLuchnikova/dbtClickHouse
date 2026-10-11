{{ config(
    schema='gold'
    , alias='fct__sales_detail'
    , tags=['gold', 'sales', 'detail']
    , materialized='incremental'
    , incremental_strategy='append'
    , engine='ReplacingMergeTree(_loaded_at)'
    , order_by='order_item_id'
    , partition_by='toYYYYMM(order_item_created_at)'
    , post_hook=[
    "{{ optimize_table() }}",
    "{{ add_index('idx_brand', '(brand)', 'bloom_filter') }}",
    "{{ add_index('idx_sale_price', '(sale_price)', 'minmax') }}",
    "{{ add_index('idx_gender', '(gender)', 'set(2)') }}"
]
) }}

WITH
toDateTime(now()) AS load_dttm,
order_items AS (
    SELECT
        id AS order_item_id
        , order_id
        , user_id
        , product_id
        , status AS order_item_status
        , created_at AS order_item_created_at
        , shipped_at AS order_item_shipped_at
        , delivered_at AS order_item_delivered_at
        , returned_at AS order_item_returned_at
        , sale_price
        , delivery_days
        , is_returned
    FROM {{ ref('silver__ecommerce__order_items') }}
),
orders AS (
    SELECT
        order_id
        , status AS order_status
        , created_at AS order_created_at
        , returned_at AS order_returned_at
        , shipped_at AS order_shipped_at
        , delivered_at AS order_delivered_at
        , num_of_item
    FROM {{ ref('silver__ecommerce__orders') }}
),
products AS (
    SELECT
        id
        , cost
        , retail_price
        , profit
        , category
        , name AS product_name
        , brand
        , department
        , sku
        , distribution_center_id
        , distribution_center_name
    FROM {{ ref('silver__ecommerce__products') }}
),
users AS (
    SELECT
        id
        , full_name AS user_full_name
        , email
        , age
        , gender
        , state
        , city
        , country
        , traffic_source
        , created_at AS user_created_at
    FROM {{ ref('silver__ecommerce__users') }}    
)
SELECT
    oi.order_item_id             AS order_item_id
    , oi.order_id                AS order_id
    , oi.user_id                 AS user_id
    , oi.product_id              AS product_id
    , oi.order_item_status       AS order_item_status
    , oi.order_item_created_at   AS order_item_created_at
    , oi.order_item_shipped_at   AS order_item_shipped_at
    , oi.order_item_delivered_at AS order_item_delivered_at
    , oi.order_item_returned_at  AS order_item_returned_at
    , oi.sale_price              AS sale_price
    , oi.delivery_days           AS delivery_days
    , oi.is_returned             AS is_returned
    , o.order_status             AS order_status
    , o.order_created_at         AS order_created_at
    , o.order_shipped_at         AS order_shipped_at
    , o.order_delivered_at       AS order_delivered_at
    , o.order_returned_at        AS order_returned_at
    , o.num_of_item              AS num_of_item
    , p.cost                     AS cost
    , p.retail_price             AS retail_price
    , p.profit                   AS profit
    , p.category                 AS category
    , p.product_name             AS product_name
    , p.brand                    AS brand
    , p.department               AS department 
    , p.sku                      AS sku
    , p.distribution_center_id   AS distribution_center_id
    , p.distribution_center_name AS distribution_center_name
    , u.user_full_name           AS user_full_name
    , u.email                    AS email
    , u.age                      AS age
    , u.gender                   AS gender
    , u.state                    AS state
    , u.city                     AS city
    , u.country                  AS country
    , u.traffic_source           AS traffic_source
    , u.user_created_at          AS user_created_at
    , load_dttm                  AS _loaded_at
FROM order_items AS oi
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
LEFT JOIN products AS p
   ON oi.product_id = p.id
LEFT JOIN users AS u
   ON oi.user_id = u.id

{% if is_incremental() %}
WHERE oi.order_item_created_at >= (
    SELECT max(order_item_created_at) - INTERVAL 30 DAY
    FROM {{ this }}
)
{% endif %}