WITH delivered_state_orders AS (
    SELECT
        c.customer_state,
        o.order_id,
        SUM(oi.price + oi.freight_value) AS order_revenue
    FROM olist_orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_state,
        o.order_id
)
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS delivered_orders,
    ROUND(SUM(order_revenue), 2) AS revenue,
    ROUND(AVG(order_revenue), 2) AS average_order_value,
    ROUND(
        1.0 * COUNT(DISTINCT order_id)
        / SUM(COUNT(DISTINCT order_id)) OVER (),
        4
    ) AS order_share
FROM delivered_state_orders
GROUP BY customer_state
ORDER BY revenue DESC;
