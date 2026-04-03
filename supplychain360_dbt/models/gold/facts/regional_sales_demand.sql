SELECT
    s.region,
    SUM(f.sale_amount) AS total_sales
FROM {{ref('sales')}} f
JOIN {{ref('stores')}} s ON f.store_id = s.store_id
GROUP BY s.region
ORDER BY total_sales DESC