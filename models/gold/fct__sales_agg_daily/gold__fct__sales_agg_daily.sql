{{ config(
    schema='gold',
    alias='fct__sales_agg_daily',
    tags=['gold', 'sales', 'aggregate'],
    materialized='incremental',
    incremental_strategy='append',
    engine='ReplacingMergeTree(_loaded_at)',
    order_by='sales_date',
    partition_by='toYYYYMM(sales_date)',
    post_hook="{{ optimize_table() }}"
) }}

WITH sales_detail AS (
    SELECT
        toDate(order_item_created_at) AS sales_date,
        order_item_created_at,
        order_id,
        order_item_id,
        sale_price,
        cost,
        profit,
        delivery_days,
        is_returned
    FROM {{ ref('gold__fct__sales_detail') }}
    {% if is_incremental() %}
    WHERE order_item_created_at >= (
        SELECT max(last_order_item_created_at) - INTERVAL 30 DAY
        FROM {{ this }}
    )
    {% endif %}
)
SELECT
    -- measurements
    sales_date,
    -- order metrics
    sum(sale_price) AS revenue,
    sum(cost) AS total_cost,
    sum(profit) AS total_profit,
    avg(sale_price) AS avg_sale_price,
    avg(profit) AS avg_profit,
    countDistinct(order_id) AS orders_count,
    count() AS order_items_count,
    avg(delivery_days) AS avg_delivery_days,
    countIf(is_returned = 1) AS returned_items_count,
    sumIf(sale_price, is_returned = 1) AS returned_revenue,
    max(order_item_created_at) AS last_order_item_created_at,
    now() AS _loaded_at
FROM sales_detail
GROUP BY
    sales_date