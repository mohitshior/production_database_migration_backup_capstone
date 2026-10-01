-- Demo data for the capstone

INSERT INTO customers(customer_name, email, city)
VALUES
('Aman Sharma', 'aman@example.com', 'Gurugram'),
('Riya Verma', 'riya@example.com', 'Delhi'),
('Karan Singh', 'karan@example.com', 'Noida'),
('Neha Gupta', 'neha@example.com', 'Faridabad')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products(product_name, category, price, stock_quantity)
VALUES
('Laptop Stand', 'Accessories', 1499.00, 40),
('Wireless Mouse', 'Accessories', 799.00, 80),
('Mechanical Keyboard', 'Accessories', 2499.00, 50),
('USB-C Hub', 'Electronics', 1899.00, 60),
('Monitor 24 inch', 'Monitors', 11999.00, 25),
('Webcam HD', 'Electronics', 3299.00, 30)
ON CONFLICT DO NOTHING;

DO $$
DECLARE
    v_customer BIGINT;
    v_order BIGINT;
BEGIN
    SELECT customer_id INTO v_customer
    FROM customers
    WHERE email = 'aman@example.com';

    IF NOT EXISTS (
        SELECT 1 FROM orders WHERE customer_id = v_customer
    ) THEN
        CALL create_order(v_customer, v_order);
        CALL add_order_item(v_order, 1, 2);
        CALL add_order_item(v_order, 2, 1);
        UPDATE orders SET order_status = 'COMPLETED' WHERE order_id = v_order;
    END IF;

    SELECT customer_id INTO v_customer
    FROM customers
    WHERE email = 'riya@example.com';

    IF NOT EXISTS (
        SELECT 1 FROM orders WHERE customer_id = v_customer
    ) THEN
        CALL create_order(v_customer, v_order);
        CALL add_order_item(v_order, 3, 1);
        CALL add_order_item(v_order, 4, 2);
        UPDATE orders SET order_status = 'PAID' WHERE order_id = v_order;
    END IF;
END $$;
