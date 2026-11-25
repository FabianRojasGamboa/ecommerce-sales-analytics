
-- =====================================================
-- E-COMMERCE SALES & CUSTOMER ANALYTICS
-- 02. DATA VALIDATION
-- =====================================================

-- 01. Cantidad de registros por tabla
SELECT 'categorias' AS tabla, COUNT(*) AS registros
FROM categorias
UNION ALL
SELECT 'productos', COUNT(*) FROM productos
UNION ALL
SELECT 'clientes', COUNT(*) FROM clientes
UNION ALL
SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL
SELECT 'detalle_pedido', COUNT(*) FROM detalle_pedido;


-- 02. Verificar productos sin categoría válida
SELECT COUNT(*) AS productos_sin_categoria
FROM productos p
LEFT JOIN categorias c
    ON p.categoria_id = c.categoria_id
WHERE c.categoria_id IS NULL;


-- 03. Verificar pedidos sin cliente válido
SELECT COUNT(*) AS pedidos_sin_cliente
FROM pedidos p
LEFT JOIN clientes c
    ON p.cliente_id = c.cliente_id
WHERE c.cliente_id IS NULL;


-- 04. Verificar detalles sin pedido o producto válido
SELECT COUNT(*) AS detalles_invalidos
FROM detalle_pedido d
LEFT JOIN pedidos p
    ON d.pedido_id = p.pedido_id
LEFT JOIN productos pr
    ON d.producto_id = pr.producto_id
WHERE p.pedido_id IS NULL
   OR pr.producto_id IS NULL;


-- 05. Verificar cantidades y precios inválidos
SELECT COUNT(*) AS registros_invalidos
FROM detalle_pedido
WHERE cantidad <= 0
   OR precio_unitario < 0
   OR cantidad IS NULL
   OR precio_unitario IS NULL;


-- 06. Distribución de pedidos por estado
SELECT
    estado,
    COUNT(*) AS total_pedidos
FROM pedidos
GROUP BY estado
ORDER BY total_pedidos DESC;


-- 07. Verificar pedidos anteriores al registro del cliente
SELECT COUNT(*) AS pedidos_anteriores_al_registro
FROM pedidos p
INNER JOIN clientes c
    ON p.cliente_id = c.cliente_id
WHERE p.fecha_pedido < c.fecha_registro;

-- 08. Pedidos sin detalle (esperado: 0)
SELECT COUNT(*) AS pedidos_sin_detalle
FROM pedidos p
WHERE NOT EXISTS (SELECT 1 FROM detalle_pedido d WHERE d.pedido_id = p.pedido_id);

-- 09. Productos repetidos en un pedido (esperado: ninguna fila)
SELECT pedido_id, producto_id, COUNT(*) AS repeticiones
FROM detalle_pedido
GROUP BY pedido_id, producto_id
HAVING COUNT(*) > 1;
