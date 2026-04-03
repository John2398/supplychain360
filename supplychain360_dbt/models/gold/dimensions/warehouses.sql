{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ref('warehouses_cleaned')}}
),

warehouses AS (
    SELECT
        warehouse_id,
        city,
        state
    FROM source
)

SELECT *
FROM warehouses