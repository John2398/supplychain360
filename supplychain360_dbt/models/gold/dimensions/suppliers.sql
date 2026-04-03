{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ref('suppliers_cleaned')}}
),

suppliers AS (
    SELECT
        supplier_id,
        supplier_name,
        country,
        category
    FROM source
)

SELECT *
FROM suppliers