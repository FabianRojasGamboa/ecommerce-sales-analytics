-- Ejecutar con psql desde la raíz del repositorio.
-- Usar exclusivamente una base de datos de desarrollo de este proyecto.
\set ON_ERROR_STOP on
BEGIN;
TRUNCATE detalle_pedido, pedidos, productos, clientes, categorias;
\copy categorias(categoria_id,nombre) FROM 'data/categorias.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy productos(producto_id,nombre,precio_actual,categoria_id) FROM 'data/productos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy clientes(cliente_id,nombre,ciudad,fecha_registro) FROM 'data/clientes.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy pedidos(pedido_id,cliente_id,fecha_pedido,estado) FROM 'data/pedidos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy detalle_pedido(detalle_id,pedido_id,producto_id,cantidad,precio_unitario) FROM 'data/detalle_pedido.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
COMMIT;
