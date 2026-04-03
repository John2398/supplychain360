{{ config(materialized='incremental') }}

WITH source AS (
    SELECT *
    FROM {{ ref('inventory_cleaned') }}
),

inventory AS (
    SELECT
        product_id,
        warehouse_id,
        quantity_available,
        reorder_threshold,
        snapshot_date,
        CASE 
            WHEN quantity_available <= reorder_threshold THEN 1
            ELSE 0
        END AS is_stockout
    FROM source
    {% if is_incremental() %}
    WHERE snapshot_date > (SELECT MAX(snapshot_date) FROM {{ this }})
    {% endif %}
)

SELECT * 
FROM inventory