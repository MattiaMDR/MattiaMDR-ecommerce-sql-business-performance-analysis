WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_state,
        date(o.order_purchase_timestamp) AS purchase_date,
        date(o.order_delivered_customer_date) AS delivered_date,
        date(o.order_estimated_delivery_date) AS estimated_date,
        julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp) AS delivery_days,
        julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) AS delay_days
    FROM olist_orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS delivered_orders,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    ROUND(AVG(CASE WHEN delay_days > 0 THEN delay_days ELSE 0 END), 2) AS average_delay_days,
    COUNT(DISTINCT CASE WHEN delay_days > 0 THEN order_id END) AS delayed_orders,
    ROUND(
        1.0 * COUNT(DISTINCT CASE WHEN delay_days > 0 THEN order_id END)
        / COUNT(DISTINCT order_id),
        4
    ) AS delayed_order_rate
FROM delivered_orders
GROUP BY customer_state
ORDER BY delayed_order_rate DESC;
