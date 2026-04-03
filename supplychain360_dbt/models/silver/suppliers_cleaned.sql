{{ config(materialized='incremental') }}

with source AS(
    SELECT
        VALUE:category::STRING AS category,
        VALUE:country::STRING AS country,
        VALUE:supplier_id::STRING AS supplier_id,
        VALUE:supplier_name::STRING AS supplier_name
FROM {{ source('bronze', 'SUPPLIERS_EXT') }}
{% if is_incremental() %}
WHERE VALUE:supplier_id::STRING NOT IN (
    SELECT supplier_id FROM {{ this }}
)
{% endif %}
)
SELECT * FROM source