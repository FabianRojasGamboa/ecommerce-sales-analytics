-- ============================================
-- E-COMMERCE SALES & CUSTOMER ANALYTICS
-- Análisis de ventas
-- ============================================

-- 01. Ingresos totales de pedidos completados
SELECT
    SUM(b.cantidad * b.precio_unitario) AS ingresos_totales
FROM pedidos a
INNER JOIN detalle_pedido b
    ON a.pedido_id = b.pedido_id
WHERE a.estado = 'completado';

-- 02. Ingresos mensuales
SELECT
    DATE_TRUNC('month', a.fecha_pedido) AS mes,
    SUM(b.cantidad * b.precio_unitario) AS ingresos_totales
FROM pedidos a
INNER JOIN detalle_pedido b
    ON a.pedido_id = b.pedido_id
WHERE a.estado = 'completado'
GROUP BY mes
ORDER BY mes ASC;

-- 03.   Top 10 productos con mayores ingresos

SELECT
    c.nombre AS producto,
    SUM(b.cantidad) AS unidades_vendidas,
    SUM(b.cantidad * b.precio_unitario) AS ingresos_generados
FROM pedidos a
INNER JOIN detalle_pedido b
    ON a.pedido_id = b.pedido_id
INNER JOIN productos c
    ON b.producto_id = c.producto_id
WHERE a.estado = 'completado'
GROUP BY c.producto_id, c.nombre
ORDER BY ingresos_generados DESC
LIMIT 10;

-- 04.   Ingresos por categoría de productos

SELECT
    d.nombre AS categoria,
    SUM(b.cantidad) AS unidades_vendidas,
    SUM(b.cantidad * b.precio_unitario) AS ingresos_totales
FROM pedidos a
INNER JOIN detalle_pedido b
    ON a.pedido_id = b.pedido_id
INNER JOIN productos c
    ON b.producto_id = c.producto_id
INNER JOIN categorias d
    ON c.categoria_id = d.categoria_id
WHERE a.estado = 'completado'
GROUP BY d.nombre
ORDER BY ingresos_totales DESC;

-- 05. Clientes con mayor gasto

SELECT
    a.cliente_id,
    a.nombre AS cliente,
    COUNT(DISTINCT b.pedido_id) AS pedidos_completados,
    SUM(c.cantidad * c.precio_unitario) AS gasto_total

FROM clientes a
INNER JOIN pedidos b
    ON a.cliente_id = b.cliente_id
INNER JOIN detalle_pedido c
    ON b.pedido_id = c.pedido_id
WHERE b.estado = 'completado'
GROUP BY a.cliente_id, a.nombre
ORDER BY gasto_total DESC
LIMIT 10;

-- 06. Ticket promedio por pedido
WITH total_por_pedido AS (
    SELECT
        a.pedido_id,
        SUM(b.cantidad * b.precio_unitario) AS gasto_total
    FROM pedidos a
    INNER JOIN detalle_pedido b
        ON a.pedido_id = b.pedido_id
    WHERE a.estado = 'completado'
    GROUP BY a.pedido_id
)
SELECT
    ROUND(AVG(gasto_total), 2) AS ticket_promedio
FROM total_por_pedido;

-- 07. Clientes recurrentes

SELECT
    b.cliente_id,
    b.nombre AS cliente,
    COUNT(a.pedido_id) AS pedidos_completados
FROM pedidos a
INNER JOIN clientes b
    ON a.cliente_id = b.cliente_id
WHERE a.estado = 'completado'
GROUP BY b.cliente_id
HAVING COUNT(a.pedido_id) >= 2
ORDER BY pedidos_completados DESC;

-- 08. Crecimiento mensual de ingresos

WITH ingresos_mensuales AS(
    SELECT
        DATE_TRUNC('month', a.fecha_pedido) AS mes,
        SUM(b.cantidad * b.precio_unitario) AS ingresos_mensuales

    FROM pedidos a
    INNER JOIN detalle_pedido b
        ON a.pedido_id = b.pedido_id
    WHERE a.estado = 'completado'
    GROUP BY mes
),
comparacion_mensual AS(
    SELECT
        mes,
        ingresos_mensuales,
        LAG(ingresos_mensuales) OVER(ORDER BY mes) AS ingresos_mes_anterior
    FROM ingresos_mensuales
)
SELECT
    TO_CHAR(mes, 'YYYY-MM') AS mes,
    ingresos_mensuales,
    ingresos_mes_anterior,
    ROUND(((ingresos_mensuales-ingresos_mes_anterior)/NULLIF(ingresos_mes_anterior, 0))*100,2) AS crecimiento_pct
FROM comparacion_mensual
ORDER BY mes;

-- 09. Ranking de productos por categoría

WITH ingresos_por_producto AS(
    SELECT
        d.categoria_id,
        d.nombre AS categoria,
        c.producto_id,
        c.nombre AS producto,
        SUM(b.cantidad * b.precio_unitario) AS ingresos_generados
    FROM pedidos a
    INNER JOIN detalle_pedido b
        ON a.pedido_id = b.pedido_id
    INNER JOIN productos c
        ON  b.producto_id = c.producto_id
    INNER JOIN categorias d
        ON c.categoria_id = d.categoria_id
    WHERE a.estado = 'completado'
    GROUP BY d.categoria_id, d.nombre, c.producto_id, c.nombre
),
ranking_productos AS(
    SELECT
        categoria,
        producto,
        ingresos_generados,
        DENSE_RANK() OVER (
            PARTITION BY categoria_id
            ORDER BY ingresos_generados DESC
        ) AS ranking
    FROM ingresos_por_producto
)

SELECT
    categoria,
    producto,
    ingresos_generados,
    ranking
FROM ranking_productos
WHERE ranking <= 3
ORDER BY categoria, ranking ASC
;

-- 10. Clientes sin compras completadas o con última compra hace más de seis meses
-- Fecha de referencia: último pedido del conjunto de datos.

SELECT
    a.cliente_id,
    a.nombre AS cliente,
    MAX(b.fecha_pedido) AS ultima_compra
FROM clientes a
LEFT JOIN pedidos b
    ON a.cliente_id = b.cliente_id
    AND b.estado = 'completado'
GROUP BY a.cliente_id
HAVING MAX(b.fecha_pedido) < (SELECT MAX(fecha_pedido) - INTERVAL '6 months' FROM pedidos)
    OR MAX(b.fecha_pedido) IS NULL
ORDER BY ultima_compra DESC NULLS LAST
;
