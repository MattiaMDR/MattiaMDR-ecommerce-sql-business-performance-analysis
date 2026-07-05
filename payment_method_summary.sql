WITH delivered_payments AS (
    SELECT
        p.payment_type,
        p.payment_installments,
        p.payment_value,
        o.order_id
    FROM olist_order_payments p
    JOIN olist_orders o
        ON p.order_id = o.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS delivered_orders,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value,
    ROUND(AVG(payment_installments), 2) AS average_installments
FROM delivered_payments
GROUP BY payment_type
ORDER BY payment_value DESC;
