
SELECT 
    c.nombre AS cliente,
    COUNT(DISTINCT p.pedido_id) AS total_pedidos,
   COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
LEFT JOIN detalle_pedidos dp ON p.pedido_id = dp.pedido_id
GROUP BY c.cliente_id, c.nombre
ORDER BY total_gastado DESC;

CREATE VIEW vista_reporte_ventas AS
SELECT 
    c.nombre AS cliente,
    COUNT(DISTINCT p.pedido_id) AS total_pedidos,
    COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
LEFT JOIN detalle_pedidos dp ON p.pedido_id = dp.pedido_id
GROUP BY c.cliente_id, c.nombre
ORDER BY total_gastado DESC;

SELECT * FROM vista_reporte_ventas;


WITH gasto_por_cliente AS (
    SELECT 
        c.nombre AS cliente,
        COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS total_gastado
    FROM clientes c
    LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
    LEFT JOIN detalle_pedidos dp ON p.pedido_id = dp.pedido_id
    GROUP BY c.cliente_id, c.nombre
)
SELECT 
    cliente, 
    total_gastado
FROM gasto_por_cliente
WHERE total_gastado > (SELECT AVG(total_gastado) FROM gasto_por_cliente);

SELECT 
    producto_id, 
    nombre, 
    precio, 
    stock
FROM productos
WHERE producto_id NOT IN (
    SELECT DISTINCT producto_id 
    FROM detalle_pedidos
);

BEGIN;

INSERT INTO pedidos (cliente_id) VALUES (4);

SELECT * FROM pedidos ORDER BY pedido_id DESC LIMIT 1;

ROLLBACK;

SELECT * FROM pedidos ORDER BY pedido_id DESC LIMIT 1;

COMMIT;




-- =============================================================================
-- PROYECTO: Sistema de Control de Inventario y Ventas (E-Commerce)
-- AUTOR: Carmen Capote
-- MOTOR: PostgreSQL 16
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. LIMPIEZA DE ENTORNO (Reinicio controlado)
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vista_reporte_ventas;
DROP TRIGGER IF EXISTS trg_actualizar_stock ON detalle_pedidos;
DROP FUNCTION IF EXISTS actualizar_stock_producto();
DROP TABLE IF EXISTS detalle_pedidos CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- -----------------------------------------------------------------------------
-- 2. ESTRUCTURA DDL (Tablas y Restricciones)
-- -----------------------------------------------------------------------------
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    precio NUMERIC(10, 2) NOT NULL CHECK (precio > 0),
    stock INT NOT NULL CHECK (stock >= 0)
);

CREATE TABLE pedidos (
    pedido_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id) ON DELETE CASCADE,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE detalle_pedidos (
    detalle_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES productos(producto_id) ON DELETE RESTRICT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10, 2) NOT NULL CHECK (precio_unitario > 0)
);

-- -----------------------------------------------------------------------------
-- 3. AUTOMATIZACIÓN (Función y Trigger para Control de Inventario)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION actualizar_stock_producto()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE producto_id = NEW.producto_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_stock
AFTER INSERT ON detalle_pedidos
FOR EACH ROW
EXECUTE FUNCTION actualizar_stock_producto();

-- -----------------------------------------------------------------------------
-- 4. POBLADO DE DATOS (DML Inicial)
-- -----------------------------------------------------------------------------
INSERT INTO clientes (nombre, email) VALUES
('Ana García', 'ana.garcia@email.com'),
('Luis Rodríguez', 'luis.rodriguez@email.com'),
('María Fernández', 'maria.fernandez@email.com'),
('Carlos Gómez', 'carlos.gomez@email.com');

INSERT INTO productos (nombre, precio, stock) VALUES
('Laptop Pro 15', 1200.00, 15),
('Mouse Inalámbrico', 25.50, 50),
('Teclado Mecánico', 85.00, 30),
('Monitor 27 Pulgadas', 300.00, 20),
('Auriculares Noise Cancelling', 150.00, 25);

INSERT INTO pedidos (cliente_id) VALUES (1), (2), (1), (3);

-- Al insertar en detalle_pedidos, el trigger descontará stock automáticamente
INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 1200.00),
(1, 2, 2, 25.50),
(2, 3, 1, 85.00),
(3, 4, 1, 300.00),
(4, 5, 2, 150.00);

-- -----------------------------------------------------------------------------
-- 5. CAPA DE REPORTES Y VISTAS
-- -----------------------------------------------------------------------------
CREATE VIEW vista_reporte_ventas AS
SELECT 
    c.nombre AS cliente,
    COUNT(DISTINCT p.pedido_id) AS total_pedidos,
    COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
LEFT JOIN detalle_pedidos dp ON p.pedido_id = dp.pedido_id
GROUP BY c.cliente_id, c.nombre
ORDER BY total_gastado DESC;










 
