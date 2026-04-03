SELECT
    warehouse_id,
    AVG(delivery_delay_days) AS avg_delay,
    SUM(quantity_shipped) AS total_shipped
FROM {{ref('shipments')}}
GROUP BY warehouse_id