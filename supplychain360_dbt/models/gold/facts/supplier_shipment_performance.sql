SELECT
    s.supplier_name,
    AVG(delivery_delay_days) AS avg_delay
FROM {{ref('shipments')}} f
JOIN {{ref('products')}} p ON f.product_id = p.product_id
JOIN {{ref('suppliers')}} s ON p.supplier_id = s.supplier_id
GROUP BY 1
ORDER BY avg_delay