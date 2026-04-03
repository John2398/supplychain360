{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ref('products_cleaned')}}
),

products AS (
    SELECT
        product_id,
        product_name,
        category,
        brand,
        supplier_id,
        unit_price
    FROM source
)

SELECT *
FROM products