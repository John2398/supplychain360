{{ config(
    materialized='incremental'
) }}

WITH source AS (
    SELECT 
        VALUE:discount_pct::float AS discount,
        VALUE:product_id::STRING AS product_id,
        VALUE:quantity_sold::INTEGER AS quantity_sold,
        VALUE:sale_amount::FLOAT AS sale_amount,
        VALUE:store_id::STRING AS store_id,
        VALUE:transaction_id::STRING AS transaction_id,
        TO_TIMESTAMP_NTZ(VALUE:transaction_timestamp::NUMBER / 1000000) AS transaction_ts,
        VALUE:unit_price::FLOAT AS unit_price
FROM {{ source('bronze', 'SALES_EXT') }} raw
{% if is_incremental() %}
WHERE TO_TIMESTAMP_NTZ(RAW:transaction_timestamp::NUMBER / 1000000) > (SELECT MAX(transaction_ts) FROM {{ this }})
{% endif %}
)

SELECT * FROM source