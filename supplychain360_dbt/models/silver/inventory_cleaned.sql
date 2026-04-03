{{ config(materialized='incremental') }}

WITH source AS(
    SELECT
        VALUE:product_id::STRING AS product_id,
        VALUE:quantity_available::INT AS quantity_available,
        VALUE:reorder_threshold::INT AS reorder_threshold,
        TO_DATE(VALUE:snapshot_date::STRING, 'YYYY-MM-DD') AS snapshot_date,
        VALUE:warehouse_id::STRING AS warehouse_id
FROM {{ source('bronze', 'INVENTORY_EXT') }}
{% if is_incremental() %}
WHERE snapshot_date > (SELECT MAX(snapshot_date) FROM {{ this }})
{% endif %}
)

SELECT * FROM source