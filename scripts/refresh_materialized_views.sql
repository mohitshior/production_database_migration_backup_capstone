-- Refresh analytical materialized views

CALL refresh_analytics_views();

SELECT * FROM mv_customer_order_summary
ORDER BY total_spend DESC;

SELECT * FROM mv_product_sales_summary
ORDER BY revenue DESC;
