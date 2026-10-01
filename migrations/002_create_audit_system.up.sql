-- Migration 002 UP: Audit logging

CREATE TABLE IF NOT EXISTS audit_log (
    audit_id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation VARCHAR(10) NOT NULL,
    row_id TEXT,
    old_data JSONB,
    new_data JSONB,
    changed_by TEXT NOT NULL DEFAULT CURRENT_USER,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_log_table_time
    ON audit_log(table_name, changed_at DESC);


CREATE OR REPLACE FUNCTION audit_row_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    pk_value TEXT;
BEGIN

    IF TG_OP = 'INSERT' THEN

        pk_value := to_jsonb(NEW) ->> CASE TG_TABLE_NAME
            WHEN 'customers' THEN 'customer_id'
            WHEN 'products' THEN 'product_id'
            WHEN 'orders' THEN 'order_id'
            WHEN 'order_items' THEN 'order_item_id'
        END;

        INSERT INTO audit_log(
            table_name,
            operation,
            row_id,
            old_data,
            new_data
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            pk_value,
            NULL,
            to_jsonb(NEW)
        );

        RETURN NEW;


    ELSIF TG_OP = 'UPDATE' THEN

        pk_value := to_jsonb(NEW) ->> CASE TG_TABLE_NAME
            WHEN 'customers' THEN 'customer_id'
            WHEN 'products' THEN 'product_id'
            WHEN 'orders' THEN 'order_id'
            WHEN 'order_items' THEN 'order_item_id'
        END;

        INSERT INTO audit_log(
            table_name,
            operation,
            row_id,
            old_data,
            new_data
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            pk_value,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );

        RETURN NEW;


    ELSE

        pk_value := to_jsonb(OLD) ->> CASE TG_TABLE_NAME
            WHEN 'customers' THEN 'customer_id'
            WHEN 'products' THEN 'product_id'
            WHEN 'orders' THEN 'order_id'
            WHEN 'order_items' THEN 'order_item_id'
        END;

        INSERT INTO audit_log(
            table_name,
            operation,
            row_id,
            old_data,
            new_data
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            pk_value,
            to_jsonb(OLD),
            NULL
        );

        RETURN OLD;

    END IF;

END;
$$;


DROP TRIGGER IF EXISTS trg_customers_audit ON customers;

CREATE TRIGGER trg_customers_audit
AFTER INSERT OR UPDATE OR DELETE ON customers
FOR EACH ROW
EXECUTE FUNCTION audit_row_change();


DROP TRIGGER IF EXISTS trg_products_audit ON products;

CREATE TRIGGER trg_products_audit
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW
EXECUTE FUNCTION audit_row_change();


DROP TRIGGER IF EXISTS trg_orders_audit ON orders;

CREATE TRIGGER trg_orders_audit
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION audit_row_change();


DROP TRIGGER IF EXISTS trg_order_items_audit ON order_items;

CREATE TRIGGER trg_order_items_audit
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION audit_row_change();
