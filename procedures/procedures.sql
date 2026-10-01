-- Stored procedures / functions for operational workflows

CREATE OR REPLACE PROCEDURE create_customer(
    p_name VARCHAR,
    p_email VARCHAR,
    p_city VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_name IS NULL OR trim(p_name) = '' THEN
        RAISE EXCEPTION 'Customer name cannot be empty';
    END IF;

    IF p_email IS NULL OR trim(p_email) = '' THEN
        RAISE EXCEPTION 'Customer email cannot be empty';
    END IF;

    INSERT INTO customers(customer_name, email, city)
    VALUES (trim(p_name), lower(trim(p_email)), p_city);
END;
$$;

CREATE OR REPLACE PROCEDURE create_order(
    p_customer_id BIGINT,
    OUT p_order_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM customers WHERE customer_id = p_customer_id
    ) THEN
        RAISE EXCEPTION 'Customer % does not exist', p_customer_id;
    END IF;

    INSERT INTO orders(customer_id)
    VALUES (p_customer_id)
    RETURNING order_id INTO p_order_id;
END;
$$;

CREATE OR REPLACE PROCEDURE add_order_item(
    p_order_id BIGINT,
    p_product_id BIGINT,
    p_quantity INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_price NUMERIC(12,2);
    v_stock INTEGER;
BEGIN
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be greater than zero';
    END IF;

    SELECT price, stock_quantity
    INTO v_price, v_stock
    FROM products
    WHERE product_id = p_product_id
      AND active = TRUE
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Active product % does not exist', p_product_id;
    END IF;

    IF v_stock < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product %', p_product_id;
    END IF;

    INSERT INTO order_items(order_id, product_id, quantity, unit_price)
    VALUES (p_order_id, p_product_id, p_quantity, v_price);

    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;

    UPDATE orders
    SET order_total = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM order_items
        WHERE order_id = p_order_id
    )
    WHERE order_id = p_order_id;
END;
$$;

CREATE OR REPLACE PROCEDURE change_product_stock(
    p_product_id BIGINT,
    p_quantity_change INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_stock INTEGER;
BEGIN
    SELECT stock_quantity + p_quantity_change
    INTO v_new_stock
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product % does not exist', p_product_id;
    END IF;

    IF v_new_stock < 0 THEN
        RAISE EXCEPTION 'Stock cannot become negative';
    END IF;

    UPDATE products
    SET stock_quantity = v_new_stock
    WHERE product_id = p_product_id;
END;
$$;

CREATE OR REPLACE PROCEDURE refresh_analytics_views()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mv_customer_order_summary;
    REFRESH MATERIALIZED VIEW mv_product_sales_summary;
END;
$$;
