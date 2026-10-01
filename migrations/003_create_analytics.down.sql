-- Migration 003 DOWN: Roll back analytical views

DROP MATERIALIZED VIEW IF EXISTS mv_product_sales_summary;
DROP MATERIALIZED VIEW IF EXISTS mv_customer_order_summary;
