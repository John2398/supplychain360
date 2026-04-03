{{ config(materialized='incremental') }}

WITH source AS(
    SELECT
        VALUE:store_id::STRING AS store_id,
        VALUE:store_name::STRING AS store_name,
        VALUE:city::STRING AS city,
        VALUE:region::STRING AS region,
        VALUE:state::STRING AS state,
        
        TO_DATE(VALUE:store_open_date::STRING, 'DD/MM/YYYY') AS store_open_date

FROM {{ source('bronze', 'STORES_EXT') }}

{% if is_incremental() %}
WHERE VALUE:store_id::STRING NOT IN (
    SELECT store_id FROM {{ this }}
)
{% endif %}
)

SELECT * FROM source