-- Migration 003 UP: Analytical materialized views

DROP MATERIALIZED VIEW IF EXISTS mv_customer_order_summary;
CREATE MATERIALIZED VIEW mv_customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id)::BIGINT AS total_orders,
    COALESCE(SUM(o.order_total), 0)::NUMERIC(14,2) AS total_spend,
    MAX(o.ordered_at) AS last_order_at
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.city;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mv_customer_order_summary
    ON mv_customer_order_summary(customer_id);

DROP MATERIALIZED VIEW IF EXISTS mv_product_sales_summary;
CREATE MATERIALIZED VIEW mv_product_sales_summary AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(oi.quantity), 0)::BIGINT AS units_sold,
    COALESCE(SUM(oi.line_total), 0)::NUMERIC(14,2) AS revenue
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mv_product_sales_summary
    ON mv_product_sales_summary(product_id);
