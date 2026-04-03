SELECT
    product_id,
    snapshot_date,
    SUM(is_stockout) AS stockout_events
FROM {{ref('inventory')}}
GROUP BY 1,2
ORDER BY snapshot_date