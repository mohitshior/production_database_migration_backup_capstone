-- Verification script

\echo '=== TABLES ==='
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

\echo '=== ROUTINES ==='
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
      'audit_row_change',
      'create_customer',
      'create_order',
      'add_order_item',
      'change_product_stock',
      'refresh_analytics_views'
  )
ORDER BY routine_name;

\echo '=== TRIGGERS ==='
SELECT trigger_name, event_object_table, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

\echo '=== ROW COUNTS ==='
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log
ORDER BY table_name;

\echo '=== MATERIALIZED VIEW: CUSTOMER SUMMARY ==='
SELECT * FROM mv_customer_order_summary
ORDER BY customer_id;

\echo '=== MATERIALIZED VIEW: PRODUCT SUMMARY ==='
SELECT * FROM mv_product_sales_summary
ORDER BY product_id;

\echo '=== AUDIT SAMPLE ==='
SELECT audit_id, table_name, operation, row_id, changed_by, changed_at
FROM audit_log
ORDER BY audit_id DESC
LIMIT 10;

\echo '=== TRIGGER TEST ==='
UPDATE products
SET price = price + 1
WHERE product_id = (SELECT MIN(product_id) FROM products);

SELECT audit_id, table_name, operation, row_id
FROM audit_log
WHERE table_name = 'products'
ORDER BY audit_id DESC
LIMIT 1;

\echo '=== VERIFICATION COMPLETE ==='
