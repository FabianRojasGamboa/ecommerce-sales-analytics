-- Grano: una fila por línea de pedido completado.
CREATE OR REPLACE VIEW vw_ventas AS
SELECT d.detalle_id, p.pedido_id, p.fecha_pedido, p.cliente_id,
       c.ciudad, d.producto_id, pr.nombre AS producto,
       cat.categoria_id, cat.nombre AS categoria,
       d.cantidad, d.precio_unitario,
       d.cantidad * d.precio_unitario AS ingresos
FROM detalle_pedido d
JOIN pedidos p ON p.pedido_id = d.pedido_id
JOIN clientes c ON c.cliente_id = p.cliente_id
JOIN productos pr ON pr.producto_id = d.producto_id
JOIN categorias cat ON cat.categoria_id = pr.categoria_id
WHERE p.estado = 'completado';
