{{ config(materialized='incremental') }}

WITH source AS(
    SELECT
        VALUE:city::STRING AS city,
        VALUE:state::STRING AS state,
        VALUE:warehouse_id::STRING AS warehouse_id
FROM {{ source('bronze', 'WAREHOUSES_EXT') }}
{% if is_incremental() %}
WHERE VALUE:warehouse_id::STRING NOT IN (
    SELECT warehouse_id FROM {{ this }}
)
{% endif %}
)
SELECT * FROM source