WITH delivered_order_revenue AS (
    SELECT
        o.order_id,
        strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
        SUM(oi.price + oi.freight_value) AS order_revenue
    FROM olist_orders o
    JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        o.order_id,
        order_month
)
SELECT
    order_month,
    COUNT(DISTINCT order_id) AS delivered_orders,
    ROUND(SUM(order_revenue), 2) AS revenue,
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM delivered_order_revenue
GROUP BY order_month
ORDER BY order_month;
