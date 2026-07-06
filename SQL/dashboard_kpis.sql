WITH order_revenue AS (
    SELECT
        o.order_id,
        o.order_status,
        SUM(oi.price + oi.freight_value) AS order_revenue
    FROM olist_orders o
    LEFT JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.order_status
),
delivered_orders AS (
    SELECT *
    FROM order_revenue
    WHERE order_status = 'delivered'
)
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN order_status = 'delivered' THEN order_id END) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN order_status = 'canceled' THEN order_id END) AS canceled_orders,
    ROUND(
        1.0 * COUNT(DISTINCT CASE WHEN order_status = 'canceled' THEN order_id END)
        / COUNT(DISTINCT order_id),
        4
    ) AS cancellation_rate,
    ROUND(SUM(CASE WHEN order_status = 'delivered' THEN order_revenue ELSE 0 END), 2) AS delivered_revenue,
    ROUND(AVG(CASE WHEN order_status = 'delivered' THEN order_revenue END), 2) AS average_order_value
FROM order_revenue;
