WITH seller_orders AS (
    SELECT
        s.seller_id,
        s.seller_state,
        o.order_id,
        oi.price,
        oi.freight_value
    FROM olist_orders o
    JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    JOIN olist_sellers s
        ON oi.seller_id = s.seller_id
    WHERE o.order_status = 'delivered'
)
SELECT
    seller_id,
    seller_state,
    COUNT(DISTINCT order_id) AS delivered_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(price + freight_value), 2) AS revenue,
    ROUND(AVG(price + freight_value), 2) AS average_item_value,
    RANK() OVER (ORDER BY SUM(price + freight_value) DESC) AS revenue_rank
FROM seller_orders
GROUP BY
    seller_id,
    seller_state
ORDER BY revenue DESC;
