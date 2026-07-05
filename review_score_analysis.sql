WITH delivered_reviews AS (
    SELECT
        COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
        r.review_score,
        o.order_id,
        oi.price + oi.freight_value AS item_revenue
    FROM olist_orders o
    JOIN olist_order_reviews r
        ON o.order_id = r.order_id
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
    COUNT(DISTINCT order_id) AS reviewed_orders,
    ROUND(AVG(review_score), 2) AS average_review_score,
    ROUND(SUM(item_revenue), 2) AS reviewed_revenue
FROM delivered_reviews
GROUP BY product_category
HAVING reviewed_orders >= 100
ORDER BY average_review_score DESC;
