BEGIN;

-- 1. Clientes
CREATE TABLE IF NOT EXISTS clientes (
    cliente_id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    fecha_registro DATE NOT NULL
);

-- 2. Categorías
CREATE TABLE IF NOT EXISTS categorias (
    categoria_id INTEGER PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

-- 3. Productos
CREATE TABLE IF NOT EXISTS productos (
    producto_id INTEGER PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    precio_actual NUMERIC(12,2) NOT NULL
        CHECK (precio_actual >= 0),
    categoria_id INTEGER NOT NULL
        REFERENCES categorias(categoria_id)
);

-- 4. Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    pedido_id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL
        REFERENCES clientes(cliente_id),
    fecha_pedido DATE NOT NULL,
    estado VARCHAR(20) NOT NULL
        CHECK (estado IN ('pendiente', 'completado', 'cancelado'))
);

-- 5. Detalle de pedidos
CREATE TABLE IF NOT EXISTS detalle_pedido (
    detalle_id INTEGER PRIMARY KEY,
    pedido_id INTEGER NOT NULL
        REFERENCES pedidos(pedido_id),
    producto_id INTEGER NOT NULL
        REFERENCES productos(producto_id),
    cantidad INTEGER NOT NULL
        CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL
        CHECK (precio_unitario >= 0),
    UNIQUE (pedido_id, producto_id)
);

CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado_fecha ON pedidos(estado, fecha_pedido);
CREATE INDEX IF NOT EXISTS idx_detalle_producto ON detalle_pedido(producto_id);
COMMIT;
