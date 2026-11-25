# Propuesta de dashboard Power BI

Estado: pendiente de implementación.

Conectar Power BI Desktop a PostgreSQL e importar `vw_ventas`. La vista contiene una fila por producto de un pedido completado. Crear las siguientes medidas DAX (ajustar separadores según la configuración regional):

```dax
Ingresos = SUM(vw_ventas[ingresos])
Pedidos = DISTINCTCOUNT(vw_ventas[pedido_id])
Ticket promedio = DIVIDE([Ingresos], [Pedidos])
Clientes compradores = DISTINCTCOUNT(vw_ventas[cliente_id])
Unidades = SUM(vw_ventas[cantidad])
```

Crear una tabla calendario y relacionarla con `vw_ventas[fecha_pedido]` (uno a muchos). Usar fechas del calendario en los filtros y ordenar mes por su número.

## Página 1: Resumen comercial

- Tarjetas: ingresos, pedidos, ticket promedio y clientes compradores.
- Línea de ingresos mensuales.
- Barras de ingresos por categoría y top 10 de productos.
- Segmentadores: fecha, categoría y ciudad.

## Página 2: Clientes

- Compradores por ciudad y gasto por cliente.
- Recurrencia: utilizar conteo distinto de pedidos por cliente.
- Para clientes sin compras e inactividad, incorporar la tabla clientes y la lógica SQL correspondiente; la vista de ventas por sí sola no contiene clientes sin compras.

## Publicación

Guardar el PBIX sin credenciales, comprobar los KPI globales contra el README, añadir capturas del dashboard y actualizar el estado del proyecto cuando esté implementado. Los pedidos bajo filtros de producto cuentan pedidos que contienen el producto seleccionado; el ticket filtrado refleja solo los ingresos seleccionados.
