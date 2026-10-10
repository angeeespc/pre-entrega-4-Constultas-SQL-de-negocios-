-- ==============================================================================
-- Entregable M4: Consultas SQL de negocio (Extrayendo métricas con SQL)
-- Base de Datos: Ventas_Tech_DB
-- ==============================================================================

-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
SELECT 
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(id_venta) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM 
    ventas
GROUP BY 
    EXTRACT(MONTH FROM fecha_venta);

-- Consulta 2 — Ranking de productos
-- Top 5 de id_producto por total facturado, mostrando unidades vendidas y total.
SELECT 
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM 
    ventas
GROUP BY 
    id_producto
ORDER BY 
    total_generado DESC
LIMIT 5;

-- Consulta 3 — Clientes recurrentes
-- id_cliente que hayan realizado más de un pedido, mostrando cantidad de pedidos y total gastado.
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM 
    ventas
GROUP BY 
    id_cliente
HAVING 
    COUNT(*) > 1;

-- Consulta 4 — Meses por encima/por debajo del promedio
-- Total facturado por mes y categorización respecto al promedio mensual general.
WITH VentasPorMes AS (
    SELECT 
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM 
        ventas
    GROUP BY 
        EXTRACT(MONTH FROM fecha_venta)
),
PromedioGeneral AS (
    SELECT 
        AVG(total_facturado) AS promedio
    FROM 
        VentasPorMes
)
SELECT 
    v.mes,
    v.total_facturado,
    CASE 
        WHEN v.total_facturado > p.promedio THEN 'Por encima'
        WHEN v.total_facturado < p.promedio THEN 'Por debajo'
        ELSE 'Igual al promedio' 
    END AS rendimiento_vs_promedio
FROM 
    VentasPorMes v
CROSS JOIN 
    PromedioGeneral p;

-- ==============================================================================
-- BLOQUE DE CIERRE: Hallazgos concretos
-- ==============================================================================
-- 1. Concentración de ingresos: El producto 1 (Laptop Pro 15) domina absolutamente 
--    las ventas. Generó $3,600 en facturación, lo que representa más de la mitad 
--    de los ingresos totales registrados ($6,444) con apenas 3 unidades vendidas.
-- 2. Recurrencia perfecta: Todos los clientes registrados en la tabla de ventas 
--    (del 1 al 5) tienen exactamente 2 pedidos realizados, lo que demuestra una 
--    recurrencia del 100% en esta muestra.
-- 3. Concentración temporal: Toda la facturación y la actividad de pedidos registrada 
--    hasta el momento se concentra en un único mes (marzo/mes 3), generando 10 pedidos 
--    con un ticket promedio de $644.40 por transacción.