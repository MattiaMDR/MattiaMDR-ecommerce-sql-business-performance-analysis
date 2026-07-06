SELECT
    order_status,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(
        1.0 * COUNT(DISTINCT order_id)
        / SUM(COUNT(DISTINCT order_id)) OVER (),
        4
    ) AS order_share
FROM olist_orders
GROUP BY order_status
ORDER BY orders DESC;
