{{ config(materialized='incremental') }}

WITH source AS(
    SELECT *
    FROM {{ref('sales_cleaned')}}
),

sales AS(
SELECT
    transaction_id,
    product_id,
    store_id,
    quantity_sold,
    sale_amount,
    discount,
    transaction_ts
FROM source
{% if is_incremental() %}
WHERE transaction_ts > (SELECT MAX(transaction_ts) FROM {{ this }})
{% endif %}
)

SELECT *
FROM sales