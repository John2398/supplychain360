-- models/staging/stg_product_master.sql
{{ config(materialized='incremental') }}

WITH source AS(
    SELECT
        VALUE:brand::STRING AS brand,
        VALUE:category::STRING AS category,
        VALUE:product_id::STRING AS product_id,
        VALUE:product_name::STRING AS product_name,
        VALUE:supplier_id::STRING AS supplier_id,
        VALUE:unit_price::FLOAT AS unit_price
FROM {{ source('bronze', 'PRODUCTS_EXT') }}
{% if is_incremental() %}
WHERE VALUE:product_id::STRING NOT IN (
    SELECT product_id FROM {{ this }}
)
{% endif %}
)
SELECT * FROM source