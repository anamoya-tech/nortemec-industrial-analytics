## Controles críticos tras la limpieza SQL

Después de crear la capa limpia mediante vistas SQL, se ejecutó un control final para identificar registros que siguen requiriendo revisión de negocio.

| Control | Registros |
|---|---:|
| calidad_sin_causa_raiz | 896 |
| ventas_sin_producto | 187 |
| mantenimiento_averia_abierta | 548 |
| almacen_sin_material | 190 |
| compras_entrega_tarde | 2585 |
| ventas_margen_negativo | 322 |
| produccion_con_scrap | 4329 |
| produccion_sin_of | 336 |

### Interpretación

La limpieza SQL no elimina los problemas reales del negocio, sino que los deja visibles y medibles.

Los controles más relevantes son:

- **896 incidencias de calidad sin causa raíz**, lo que impide identificar correctamente el origen de los defectos.
- **548 averías abiertas**, que afectan al cálculo de disponibilidad, horas de parada y coste real de mantenimiento.
- **322 líneas de venta con margen negativo**, que pueden indicar errores de precio, costes mal estimados o ventas no rentables.
- **2585 compras entregadas tarde**, lo que sugiere problemas de cumplimiento de proveedores o planificación de aprovisionamiento.
- **4329 partes de producción con scrap**, indicador clave para analizar mermas, eficiencia y coste industrial.
- **336 partes de producción sin orden de fabricación**, lo que dificulta conectar producción con producto, pedido, coste y rentabilidad.
- **190 movimientos de almacén sin material**, que afectan a la trazabilidad del inventario.
- **187 líneas de venta sin producto**, que limitan el análisis de facturación, margen y rentabilidad por producto.

### Conclusión

La capa limpia permite transformar una base operativa sucia en una estructura analítica preparada para responder preguntas de negocio.

En lugar de ocultar los errores, el modelo crea flags que permiten analizarlos:

- `flag_sin_causa_raiz`
- `flag_margen_negativo`
- `flag_averia_abierta`
- `flag_entrega_tarde`
- `flag_tiene_scrap`
- `flag_sin_of`
- `flag_sin_material`
- `flag_sin_producto`

Esto convierte los problemas de calidad del dato en indicadores accionables para el dashboard de Power BI.
-- ============================================================
-- 05_analysis_queries.sql
-- Proyecto: Nortemec Industrial Analytics
-- Fase 3: Consultas de análisis de negocio
-- Objetivo: Obtener insights accionables desde las vistas limpias
-- ============================================================


-- ============================================================
-- 1. RESUMEN EJECUTIVO GENERAL
-- ============================================================

-- 1.1 KPIs generales del negocio

SELECT
    (SELECT ROUND(SUM(importe_linea_limpio)::numeric, 2) FROM vw_ventas_limpias) AS facturacion_total,
    (SELECT ROUND(SUM(coste_estimado)::numeric, 2) FROM vw_ventas_limpias) AS coste_total_estimado,
    (SELECT ROUND(SUM(margen_estimado_limpio)::numeric, 2) FROM vw_ventas_limpias) AS margen_total,
    (SELECT ROUND((SUM(margen_estimado_limpio) / NULLIF(SUM(importe_linea_limpio), 0) * 100)::numeric, 2) FROM vw_ventas_limpias) AS margen_pct,
    (SELECT ROUND(SUM(kg_scrap_limpio)::numeric, 2) FROM vw_produccion_limpia) AS kg_scrap_total,
    (SELECT ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) FROM vw_calidad_limpia) AS coste_no_calidad_total,
    (SELECT ROUND(SUM(coste_mantenimiento_estimado)::numeric, 2) FROM vw_mantenimiento_limpio) AS coste_mantenimiento_total,
    (SELECT ROUND(SUM(horas_parada)::numeric, 2) FROM vw_mantenimiento_limpio) AS horas_parada_total;


-- 1.2 Volumen de registros por área limpia

SELECT 'ventas' AS area, COUNT(*) AS registros FROM vw_ventas_limpias
UNION ALL
SELECT 'produccion', COUNT(*) FROM vw_produccion_limpia
UNION ALL
SELECT 'calidad', COUNT(*) FROM vw_calidad_limpia
UNION ALL
SELECT 'compras', COUNT(*) FROM vw_compras_limpias
UNION ALL
SELECT 'almacen', COUNT(*) FROM vw_almacen_limpio
UNION ALL
SELECT 'mantenimiento', COUNT(*) FROM vw_mantenimiento_limpio
ORDER BY area;


-- ============================================================
-- 2. ANÁLISIS DE VENTAS Y RENTABILIDAD
-- ============================================================

-- 2.1 Ventas, coste y margen por familia de producto

SELECT
    familia_producto,
    COUNT(*) AS num_lineas,
    ROUND(SUM(importe_linea_limpio)::numeric, 2) AS facturacion,
    ROUND(SUM(coste_estimado)::numeric, 2) AS coste_estimado,
    ROUND(SUM(margen_estimado_limpio)::numeric, 2) AS margen,
    ROUND(
        (SUM(margen_estimado_limpio) / NULLIF(SUM(importe_linea_limpio), 0) * 100)::numeric,
        2
    ) AS margen_pct
FROM vw_ventas_limpias
GROUP BY familia_producto
ORDER BY facturacion DESC;


-- 2.2 Top 20 productos por facturación

SELECT
    cod_producto_limpio,
    producto_limpio,
    familia_producto,
    COUNT(*) AS num_lineas,
    ROUND(SUM(cantidad)::numeric, 2) AS unidades_vendidas,
    ROUND(SUM(importe_linea_limpio)::numeric, 2) AS facturacion,
    ROUND(SUM(margen_estimado_limpio)::numeric, 2) AS margen,
    ROUND(
        (SUM(margen_estimado_limpio) / NULLIF(SUM(importe_linea_limpio), 0) * 100)::numeric,
        2
    ) AS margen_pct
FROM vw_ventas_limpias
GROUP BY
    cod_producto_limpio,
    producto_limpio,
    familia_producto
ORDER BY facturacion DESC
LIMIT 20;


-- 2.3 Productos con margen negativo

SELECT
    cod_producto_limpio,
    producto_limpio,
    familia_producto,
    COUNT(*) AS lineas_con_margen_negativo,
    ROUND(SUM(importe_linea_limpio)::numeric, 2) AS facturacion_afectada,
    ROUND(SUM(margen_estimado_limpio)::numeric, 2) AS perdida_estimanda
FROM vw_ventas_limpias
WHERE flag_margen_negativo = TRUE
GROUP BY
    cod_producto_limpio,
    producto_limpio,
    familia_producto
ORDER BY perdida_estimanda ASC
LIMIT 30;


-- 2.4 Clientes con mayor facturación

SELECT
    cod_cliente_limpio,
    nombre_cliente_limpio,
    sector_cliente,
    provincia_cliente,
    COUNT(*) AS num_lineas,
    ROUND(SUM(importe_linea_limpio)::numeric, 2) AS facturacion,
    ROUND(SUM(margen_estimado_limpio)::numeric, 2) AS margen,
    ROUND(
        (SUM(margen_estimado_limpio) / NULLIF(SUM(importe_linea_limpio), 0) * 100)::numeric,
        2
    ) AS margen_pct
FROM vw_ventas_limpias
GROUP BY
    cod_cliente_limpio,
    nombre_cliente_limpio,
    sector_cliente,
    provincia_cliente
ORDER BY facturacion DESC
LIMIT 20;


-- 2.5 Clientes con bajo margen

SELECT
    cod_cliente_limpio,
    nombre_cliente_limpio,
    sector_cliente,
    COUNT(*) AS num_lineas,
    ROUND(SUM(importe_linea_limpio)::numeric, 2) AS facturacion,
    ROUND(SUM(margen_estimado_limpio)::numeric, 2) AS margen,
    ROUND(
        (SUM(margen_estimado_limpio) / NULLIF(SUM(importe_linea_limpio), 0) * 100)::numeric,
        2
    ) AS margen_pct
FROM vw_ventas_limpias
WHERE importe_linea_limpio IS NOT NULL
GROUP BY
    cod_cliente_limpio,
    nombre_cliente_limpio,
    sector_cliente
HAVING SUM(importe_linea_limpio) > 0
ORDER BY margen_pct ASC
LIMIT 20;


-- 2.6 Pedidos entregados tarde

SELECT
    num_pedido_limpio,
    nombre_cliente_limpio,
    fecha_pedido,
    fecha_entrega_prevista,
    fecha_entrega_real,
    dias_retraso,
    estado_pedido_limpio,
    ROUND(SUM(importe_linea_limpio)::numeric, 2) AS facturacion_pedido
FROM vw_ventas_limpias
WHERE flag_entrega_tarde = TRUE
GROUP BY
    num_pedido_limpio,
    nombre_cliente_limpio,
    fecha_pedido,
    fecha_entrega_prevista,
    fecha_entrega_real,
    dias_retraso,
    estado_pedido_limpio
ORDER BY dias_retraso DESC
LIMIT 30;


-- ============================================================
-- 3. ANÁLISIS DE PRODUCCIÓN
-- ============================================================

-- 3.1 Producción por máquina

SELECT
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio,
    centro_trabajo_limpio,
    COUNT(*) AS num_partes,
    ROUND(SUM(horas_trabajadas)::numeric, 2) AS horas_totales,
    ROUND(SUM(unidades_ok)::numeric, 2) AS unidades_ok,
    ROUND(SUM(unidades_nok_limpias)::numeric, 2) AS unidades_nok,
    ROUND(SUM(unidades_totales)::numeric, 2) AS unidades_totales,
    ROUND(SUM(kg_consumidos)::numeric, 2) AS kg_consumidos,
    ROUND(SUM(kg_scrap_limpio)::numeric, 2) AS kg_scrap,
    ROUND(
        (SUM(kg_scrap_limpio) / NULLIF(SUM(kg_consumidos), 0) * 100)::numeric,
        2
    ) AS pct_scrap
FROM vw_produccion_limpia
GROUP BY
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio,
    centro_trabajo_limpio
ORDER BY pct_scrap DESC;


-- 3.2 Producción por turno

SELECT
    turno_limpio,
    COUNT(*) AS num_partes,
    ROUND(SUM(horas_trabajadas)::numeric, 2) AS horas_totales,
    ROUND(SUM(unidades_ok)::numeric, 2) AS unidades_ok,
    ROUND(SUM(unidades_nok_limpias)::numeric, 2) AS unidades_nok,
    ROUND(
        (SUM(unidades_nok_limpias) / NULLIF(SUM(unidades_totales), 0) * 100)::numeric,
        2
    ) AS pct_rechazo
FROM vw_produccion_limpia
GROUP BY turno_limpio
ORDER BY pct_rechazo DESC;


-- 3.3 Máquinas con más paradas

SELECT
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio,
    COUNT(*) FILTER (WHERE flag_tiene_parada = TRUE) AS partes_con_parada,
    ROUND(SUM(parada_horas_limpio)::numeric, 2) AS horas_parada_total,
    ROUND(AVG(parada_horas_limpio)::numeric, 2) AS horas_parada_media
FROM vw_produccion_limpia
GROUP BY
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio
ORDER BY horas_parada_total DESC
LIMIT 20;


-- 3.4 Motivos de parada más frecuentes

SELECT
    motivo_parada_limpio,
    COUNT(*) AS num_partes,
    ROUND(SUM(parada_horas_limpio)::numeric, 2) AS horas_parada_total,
    ROUND(AVG(parada_horas_limpio)::numeric, 2) AS horas_parada_media
FROM vw_produccion_limpia
WHERE flag_tiene_parada = TRUE
GROUP BY motivo_parada_limpio
ORDER BY horas_parada_total DESC;


-- 3.5 Órdenes de fabricación retrasadas

SELECT
    num_of_limpio,
    producto_limpio,
    familia_producto,
    fecha_fin_prevista,
    fecha_fin_real,
    dias_retraso_of,
    cantidad_planificada,
    cantidad_fabricada,
    estado_of_limpio
FROM vw_produccion_limpia
WHERE flag_of_retrasada = TRUE
ORDER BY dias_retraso_of DESC
LIMIT 30;


-- ============================================================
-- 4. ANÁLISIS DE SCRAP Y MERMAS
-- ============================================================

-- 4.1 Scrap por máquina

SELECT
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio,
    ROUND(SUM(kg_consumidos)::numeric, 2) AS kg_consumidos,
    ROUND(SUM(kg_scrap_limpio)::numeric, 2) AS kg_scrap,
    ROUND(
        (SUM(kg_scrap_limpio) / NULLIF(SUM(kg_consumidos), 0) * 100)::numeric,
        2
    ) AS pct_scrap
FROM vw_produccion_limpia
GROUP BY
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio
ORDER BY pct_scrap DESC
LIMIT 20;


-- 4.2 Scrap por motivo

SELECT
    motivo_scrap_limpio,
    COUNT(*) AS num_partes,
    ROUND(SUM(kg_scrap_limpio)::numeric, 2) AS kg_scrap_total,
    ROUND(AVG(kg_scrap_limpio)::numeric, 2) AS kg_scrap_medio
FROM vw_produccion_limpia
WHERE flag_tiene_scrap = TRUE
GROUP BY motivo_scrap_limpio
ORDER BY kg_scrap_total DESC;


-- 4.3 Scrap por familia de producto

SELECT
    familia_producto,
    ROUND(SUM(kg_consumidos)::numeric, 2) AS kg_consumidos,
    ROUND(SUM(kg_scrap_limpio)::numeric, 2) AS kg_scrap,
    ROUND(
        (SUM(kg_scrap_limpio) / NULLIF(SUM(kg_consumidos), 0) * 100)::numeric,
        2
    ) AS pct_scrap
FROM vw_produccion_limpia
GROUP BY familia_producto
ORDER BY pct_scrap DESC;


-- 4.4 Rechazo por máquina

SELECT
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    ROUND(SUM(unidades_ok)::numeric, 2) AS unidades_ok,
    ROUND(SUM(unidades_nok_limpias)::numeric, 2) AS unidades_nok,
    ROUND(SUM(unidades_totales)::numeric, 2) AS unidades_totales,
    ROUND(
        (SUM(unidades_nok_limpias) / NULLIF(SUM(unidades_totales), 0) * 100)::numeric,
        2
    ) AS pct_rechazo
FROM vw_produccion_limpia
GROUP BY
    codigo_maquina_limpio,
    nombre_maquina_limpio
ORDER BY pct_rechazo DESC
LIMIT 20;


-- ============================================================
-- 5. ANÁLISIS DE CALIDAD
-- ============================================================

-- 5.1 Coste de no calidad por tipo de incidencia

SELECT
    tipo_incidencia_limpio,
    COUNT(*) AS num_incidencias,
    ROUND(SUM(unidades_afectadas)::numeric, 2) AS unidades_afectadas,
    ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) AS coste_no_calidad,
    ROUND(AVG(coste_no_calidad_estimado)::numeric, 2) AS coste_medio_incidencia
FROM vw_calidad_limpia
GROUP BY tipo_incidencia_limpio
ORDER BY coste_no_calidad DESC;


-- 5.2 Coste de no calidad por causa raíz

SELECT
    causa_raiz_limpia,
    COUNT(*) AS num_incidencias,
    ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) AS coste_no_calidad,
    ROUND(AVG(coste_no_calidad_estimado)::numeric, 2) AS coste_medio
FROM vw_calidad_limpia
GROUP BY causa_raiz_limpia
ORDER BY coste_no_calidad DESC;


-- 5.3 Incidencias sin causa raíz

SELECT
    COUNT(*) AS incidencias_sin_causa_raiz,
    ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) AS coste_asociado
FROM vw_calidad_limpia
WHERE flag_sin_causa_raiz = TRUE;


-- 5.4 Incidencias abiertas por gravedad

SELECT
    gravedad_limpia,
    COUNT(*) AS incidencias_abiertas,
    ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) AS coste_abierto
FROM vw_calidad_limpia
WHERE flag_incidencia_abierta = TRUE
GROUP BY gravedad_limpia
ORDER BY coste_abierto DESC;


-- 5.5 Clientes con más incidencias de calidad

SELECT
    cliente_limpio,
    COUNT(*) AS num_incidencias,
    ROUND(SUM(unidades_afectadas)::numeric, 2) AS unidades_afectadas,
    ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) AS coste_no_calidad
FROM vw_calidad_limpia
GROUP BY cliente_limpio
ORDER BY coste_no_calidad DESC
LIMIT 20;


-- 5.6 Máquinas asociadas a más incidencias

SELECT
    maquina_limpia,
    COUNT(*) AS num_incidencias,
    ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) AS coste_no_calidad
FROM vw_calidad_limpia
GROUP BY maquina_limpia
ORDER BY coste_no_calidad DESC
LIMIT 20;


-- ============================================================
-- 6. ANÁLISIS DE COMPRAS Y PROVEEDORES
-- ============================================================

-- 6.1 Compras por proveedor

SELECT
    nombre_proveedor_limpio,
    criticidad_proveedor,
    COUNT(*) AS num_lineas,
    ROUND(SUM(importe_total_limpio)::numeric, 2) AS coste_total_compra,
    COUNT(*) FILTER (WHERE flag_entrega_tarde = TRUE) AS entregas_tarde,
    COUNT(*) FILTER (WHERE flag_incidencia_calidad = TRUE) AS incidencias_calidad,
    ROUND(
        (
            COUNT(*) FILTER (WHERE flag_entrega_tarde = TRUE)::numeric
            / NULLIF(COUNT(*), 0)
            * 100
        ),
        2
    ) AS pct_entregas_tarde
FROM vw_compras_limpias
GROUP BY nombre_proveedor_limpio, criticidad_proveedor
ORDER BY coste_total_compra DESC
LIMIT 30;


-- 6.2 Proveedores con más retrasos

SELECT
    nombre_proveedor_limpio,
    COUNT(*) AS num_lineas,
    COUNT(*) FILTER (WHERE flag_entrega_tarde = TRUE) AS entregas_tarde,
    ROUND(AVG(dias_retraso_compra)::numeric, 2) AS retraso_medio_dias,
    MAX(dias_retraso_compra) AS retraso_maximo_dias
FROM vw_compras_limpias
GROUP BY nombre_proveedor_limpio
HAVING COUNT(*) FILTER (WHERE flag_entrega_tarde = TRUE) > 0
ORDER BY entregas_tarde DESC, retraso_medio_dias DESC
LIMIT 20;


-- 6.3 Proveedores con incidencias de calidad

SELECT
    nombre_proveedor_limpio,
    criticidad_proveedor,
    COUNT(*) AS num_lineas,
    COUNT(*) FILTER (WHERE flag_incidencia_calidad = TRUE) AS incidencias_calidad,
    ROUND(
        (
            COUNT(*) FILTER (WHERE flag_incidencia_calidad = TRUE)::numeric
            / NULLIF(COUNT(*), 0)
            * 100
        ),
        2
    ) AS pct_incidencias_calidad
FROM vw_compras_limpias
GROUP BY nombre_proveedor_limpio, criticidad_proveedor
ORDER BY pct_incidencias_calidad DESC
LIMIT 20;


-- 6.4 Materiales más comprados

SELECT
    cod_material_limpio,
    material_limpio,
    tipo_material_limpio,
    ROUND(SUM(cantidad_pedida)::numeric, 2) AS cantidad_pedida_total,
    ROUND(SUM(cantidad_recibida)::numeric, 2) AS cantidad_recibida_total,
    ROUND(SUM(importe_total_limpio)::numeric, 2) AS coste_total_compra
FROM vw_compras_limpias
GROUP BY
    cod_material_limpio,
    material_limpio,
    tipo_material_limpio
ORDER BY coste_total_compra DESC
LIMIT 30;


-- 6.5 Compras con precio alto frente a estándar

SELECT
    nombre_proveedor_limpio,
    material_limpio,
    precio_unitario,
    coste_estandar_material,
    diferencia_precio_vs_estandar,
    pct_variacion_precio_vs_estandar,
    importe_total_limpio
FROM vw_compras_limpias
WHERE flag_precio_alto_vs_estandar = TRUE
ORDER BY pct_variacion_precio_vs_estandar DESC
LIMIT 30;


-- ============================================================
-- 7. ANÁLISIS DE ALMACÉN
-- ============================================================

-- 7.1 Movimientos por tipo

SELECT
    tipo_movimiento_limpio,
    grupo_movimiento,
    COUNT(*) AS num_movimientos,
    ROUND(SUM(cantidad)::numeric, 2) AS cantidad_total,
    ROUND(SUM(valor_movimiento_estimado)::numeric, 2) AS valor_estimado_total
FROM vw_almacen_limpio
GROUP BY tipo_movimiento_limpio, grupo_movimiento
ORDER BY valor_estimado_total DESC;


-- 7.2 Valor de movimientos por material

SELECT
    cod_material_limpio,
    material_limpio,
    tipo_material_limpio,
    COUNT(*) AS num_movimientos,
    ROUND(SUM(cantidad)::numeric, 2) AS cantidad_total,
    ROUND(SUM(valor_movimiento_estimado)::numeric, 2) AS valor_estimado_total
FROM vw_almacen_limpio
GROUP BY
    cod_material_limpio,
    material_limpio,
    tipo_material_limpio
ORDER BY valor_estimado_total DESC
LIMIT 30;


-- 7.3 Movimientos altos

SELECT
    movimiento_id,
    fecha,
    material_limpio,
    tipo_movimiento_limpio,
    almacen_limpio,
    cantidad,
    unidad_movimiento_limpia,
    valor_movimiento_estimado,
    motivo_limpio
FROM vw_almacen_limpio
WHERE flag_movimiento_alto = TRUE
ORDER BY cantidad DESC
LIMIT 30;


-- 7.4 Movimientos sin material

SELECT
    COUNT(*) AS movimientos_sin_material
FROM vw_almacen_limpio
WHERE flag_sin_material = TRUE;


-- ============================================================
-- 8. ANÁLISIS DE MANTENIMIENTO
-- ============================================================

-- 8.1 Coste de mantenimiento por máquina

SELECT
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio,
    COUNT(*) AS num_averias,
    ROUND(SUM(coste_mantenimiento_estimado)::numeric, 2) AS coste_mantenimiento,
    ROUND(SUM(coste_parada_estimado)::numeric, 2) AS coste_parada,
    ROUND(SUM(horas_parada)::numeric, 2) AS horas_parada_total,
    ROUND(AVG(horas_parada)::numeric, 2) AS horas_parada_media,
    COUNT(*) FILTER (WHERE flag_averia_abierta = TRUE) AS averias_abiertas,
    COUNT(*) FILTER (WHERE flag_parada_larga = TRUE) AS paradas_largas
FROM vw_mantenimiento_limpio
GROUP BY
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio
ORDER BY coste_mantenimiento DESC;


-- 8.2 Tipos de avería más costosos

SELECT
    tipo_averia_limpio,
    COUNT(*) AS num_averias,
    ROUND(SUM(coste_mantenimiento_estimado)::numeric, 2) AS coste_mantenimiento,
    ROUND(SUM(horas_parada)::numeric, 2) AS horas_parada_total,
    ROUND(AVG(horas_parada)::numeric, 2) AS horas_parada_media
FROM vw_mantenimiento_limpio
GROUP BY tipo_averia_limpio
ORDER BY coste_mantenimiento DESC;


-- 8.3 Averías abiertas

SELECT
    averia_id,
    fecha_inicio,
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_averia_limpio,
    tecnico_limpio,
    coste_mantenimiento_estimado,
    estado_averia_limpio
FROM vw_mantenimiento_limpio
WHERE flag_averia_abierta = TRUE
ORDER BY fecha_inicio DESC NULLS LAST
LIMIT 50;


-- 8.4 Paradas largas

SELECT
    averia_id,
    fecha_inicio,
    fecha_fin,
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_averia_limpio,
    horas_parada,
    coste_parada_estimado
FROM vw_mantenimiento_limpio
WHERE flag_parada_larga = TRUE
ORDER BY horas_parada DESC
LIMIT 30;


-- ============================================================
-- 9. IMPACTO ECONÓMICO DE PÉRDIDAS
-- ============================================================

-- 9.1 Pérdidas estimadas por área

SELECT
    'Margen negativo en ventas' AS concepto,
    ROUND(ABS(SUM(margen_estimado_limpio))::numeric, 2) AS impacto_estimado
FROM vw_ventas_limpias
WHERE flag_margen_negativo = TRUE

UNION ALL

SELECT
    'Coste de no calidad',
    ROUND(SUM(coste_no_calidad_estimado)::numeric, 2)
FROM vw_calidad_limpia

UNION ALL

SELECT
    'Coste mantenimiento',
    ROUND(SUM(coste_mantenimiento_estimado)::numeric, 2)
FROM vw_mantenimiento_limpio

UNION ALL

SELECT
    'Coste estimado de paradas',
    ROUND(SUM(coste_parada_estimado)::numeric, 2)
FROM vw_mantenimiento_limpio

ORDER BY impacto_estimado DESC;


-- 9.2 Máquinas críticas combinando producción, calidad y mantenimiento

WITH produccion AS (
    SELECT
        codigo_maquina_limpio,
        ROUND(SUM(kg_scrap_limpio)::numeric, 2) AS kg_scrap,
        ROUND(SUM(parada_horas_limpio)::numeric, 2) AS horas_parada_produccion
    FROM vw_produccion_limpia
    GROUP BY codigo_maquina_limpio
),

calidad AS (
    SELECT
        maquina_limpia AS codigo_maquina_limpio,
        COUNT(*) AS num_incidencias,
        ROUND(SUM(coste_no_calidad_estimado)::numeric, 2) AS coste_no_calidad
    FROM vw_calidad_limpia
    GROUP BY maquina_limpia
),

mantenimiento AS (
    SELECT
        codigo_maquina_limpio,
        COUNT(*) AS num_averias,
        ROUND(SUM(coste_mantenimiento_estimado)::numeric, 2) AS coste_mantenimiento,
        ROUND(SUM(coste_parada_estimado)::numeric, 2) AS coste_parada
    FROM vw_mantenimiento_limpio
    GROUP BY codigo_maquina_limpio
)

SELECT
    COALESCE(p.codigo_maquina_limpio, c.codigo_maquina_limpio, m.codigo_maquina_limpio) AS codigo_maquina_limpio,
    COALESCE(p.kg_scrap, 0) AS kg_scrap,
    COALESCE(p.horas_parada_produccion, 0) AS horas_parada_produccion,
    COALESCE(c.num_incidencias, 0) AS num_incidencias_calidad,
    COALESCE(c.coste_no_calidad, 0) AS coste_no_calidad,
    COALESCE(m.num_averias, 0) AS num_averias,
    COALESCE(m.coste_mantenimiento, 0) AS coste_mantenimiento,
    COALESCE(m.coste_parada, 0) AS coste_parada,
    ROUND(
        (
            COALESCE(c.coste_no_calidad, 0)
            + COALESCE(m.coste_mantenimiento, 0)
            + COALESCE(m.coste_parada, 0)
        )::numeric,
        2
    ) AS impacto_economico_estimado
FROM produccion p
FULL JOIN calidad c
    ON p.codigo_maquina_limpio = c.codigo_maquina_limpio
FULL JOIN mantenimiento m
    ON COALESCE(p.codigo_maquina_limpio, c.codigo_maquina_limpio) = m.codigo_maquina_limpio
ORDER BY impacto_economico_estimado DESC
LIMIT 30;


-- ============================================================
-- 10. CONTROLES DE CALIDAD DE LAS VISTAS
-- ============================================================

-- 10.1 Conteo final por vista

SELECT 'vw_ventas_limpias' AS vista, COUNT(*) AS filas FROM vw_ventas_limpias
UNION ALL
SELECT 'vw_produccion_limpia', COUNT(*) FROM vw_produccion_limpia
UNION ALL
SELECT 'vw_calidad_limpia', COUNT(*) FROM vw_calidad_limpia
UNION ALL
SELECT 'vw_compras_limpias', COUNT(*) FROM vw_compras_limpias
UNION ALL
SELECT 'vw_almacen_limpio', COUNT(*) FROM vw_almacen_limpio
UNION ALL
SELECT 'vw_mantenimiento_limpio', COUNT(*) FROM vw_mantenimiento_limpio
ORDER BY vista;


-- 10.2 Registros críticos pendientes de revisión

SELECT 'ventas_sin_producto' AS control, COUNT(*) AS registros
FROM vw_ventas_limpias
WHERE flag_sin_producto = TRUE

UNION ALL

SELECT 'ventas_margen_negativo', COUNT(*)
FROM vw_ventas_limpias
WHERE flag_margen_negativo = TRUE

UNION ALL

SELECT 'produccion_sin_of', COUNT(*)
FROM vw_produccion_limpia
WHERE flag_sin_of = TRUE

UNION ALL

SELECT 'produccion_con_scrap', COUNT(*)
FROM vw_produccion_limpia
WHERE flag_tiene_scrap = TRUE

UNION ALL

SELECT 'calidad_sin_causa_raiz', COUNT(*)
FROM vw_calidad_limpia
WHERE flag_sin_causa_raiz = TRUE

UNION ALL

SELECT 'compras_entrega_tarde', COUNT(*)
FROM vw_compras_limpias
WHERE flag_entrega_tarde = TRUE

UNION ALL

SELECT 'almacen_sin_material', COUNT(*)
FROM vw_almacen_limpio
WHERE flag_sin_material = TRUE

UNION ALL

SELECT 'mantenimiento_averia_abierta', COUNT(*)
FROM vw_mantenimiento_limpio
WHERE flag_averia_abierta = TRUE;
