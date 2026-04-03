{{ config(materialized='incremental') }}

WITH source AS(
    SELECT *
    FROM {{ref('shipments_cleaned')}}
),

shipments AS(
SELECT
    shipment_id,
    product_id,
    store_id,
    warehouse_id,
    quantity_shipped,
    shipment_date,
    expected_delivery_date,
    actual_delivery_date,
    carrier,
    DATEDIFF(day, expected_delivery_date, actual_delivery_date) AS delivery_delay_days
FROM source
{% if is_incremental() %}
WHERE shipment_date > (SELECT MAX(shipment_date) FROM {{ this }})
{% endif %}
)

SELECT *
FROM shipments