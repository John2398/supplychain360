{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ref('stores_cleaned')}}
),

stores AS (
    SELECT
        store_id,
        store_name,
        city,
        region,
        state,
        store_open_date
    FROM source
)

SELECT *
FROM stores