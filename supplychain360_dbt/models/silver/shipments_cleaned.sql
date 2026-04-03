{{ config(materialized='incremental') }}

WITH source AS(
    SELECT
        TO_TIMESTAMP_NTZ(VALUE:actual_delivery_date::STRING) AS actual_delivery_date,
        VALUE:carrier::STRING AS carrier,
        TO_TIMESTAMP_NTZ(VALUE:expected_delivery_date::STRING) AS expected_delivery_date,
        VALUE:product_id::STRING AS product_id,
        VALUE:quantity_shipped::INT AS quantity_shipped,
        TO_TIMESTAMP_NTZ(VALUE:shipment_date::STRING) AS shipment_date,
        VALUE:shipment_id::STRING AS shipment_id,
        VALUE:store_id::STRING AS store_id,
        VALUE:warehouse_id::STRING AS warehouse_id
FROM {{ source('bronze', 'SHIPMENTS_EXT') }}
{% if is_incremental() %}
WHERE VALUE:shipment_id::STRING NOT IN (
    SELECT shipment_id FROM {{ this }}
)
{% endif %}
)

SELECT * FROM source