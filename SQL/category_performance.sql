WITH category_orders AS (
    SELECT
        COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
        o.order_id,
        oi.price,
        oi.freight_value
    FROM olist_orders o
    JOIN olist_order_items oi
        ON o.order_id = oi.order_id
    LEFT JOIN olist_products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
)
SELECT
    product_category,
    COUNT(DISTINCT order_id) AS delivered_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(price + freight_value), 2) AS revenue,
    ROUND(AVG(price + freight_value), 2) AS average_item_value
FROM category_orders
GROUP BY product_category
HAVING revenue IS NOT NULL
ORDER BY revenue DESC;
