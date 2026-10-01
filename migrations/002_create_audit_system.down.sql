-- Migration 002 DOWN: Roll back audit system

DROP TRIGGER IF EXISTS trg_order_items_audit ON order_items;
DROP TRIGGER IF EXISTS trg_orders_audit ON orders;
DROP TRIGGER IF EXISTS trg_products_audit ON products;
DROP TRIGGER IF EXISTS trg_customers_audit ON customers;

DROP FUNCTION IF EXISTS audit_row_change();
DROP TABLE IF EXISTS audit_log;
