# 03_validation_queries.sql

## Objetivo

Este script contiene las consultas de validación utilizadas para comprobar que la base de datos **nortemec_operaciones** se ha creado y cargado correctamente.

Las validaciones comprueban:

* Existencia de tablas.
* Número de filas por tabla.
* Volumen total de registros.
* Problemas básicos de calidad del dato.
* Primeras consultas útiles por área de negocio.

---

## 1. Comprobar tablas existentes

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

Resultado esperado:

```text
averias_mantenimiento
clientes
incidencias_calidad
lineas_pedido_compra
lineas_pedido_venta
maquinas
materiales
movimientos_almacen
operarios
ordenes_fabricacion
partes_produccion
pedidos_compra
pedidos_venta
productos
proveedores
```

---

## 2. Comprobar número de filas por tabla

```sql
SELECT 'clientes' AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL
SELECT 'productos', COUNT(*) FROM productos
UNION ALL
SELECT 'maquinas', COUNT(*) FROM maquinas
UNION ALL
SELECT 'operarios', COUNT(*) FROM operarios
UNION ALL
SELECT 'proveedores', COUNT(*) FROM proveedores
UNION ALL
SELECT 'materiales', COUNT(*) FROM materiales
UNION ALL
SELECT 'pedidos_venta', COUNT(*) FROM pedidos_venta
UNION ALL
SELECT 'lineas_pedido_venta', COUNT(*) FROM lineas_pedido_venta
UNION ALL
SELECT 'ordenes_fabricacion', COUNT(*) FROM ordenes_fabricacion
UNION ALL
SELECT 'partes_produccion', COUNT(*) FROM partes_produccion
UNION ALL
SELECT 'incidencias_calidad', COUNT(*) FROM incidencias_calidad
UNION ALL
SELECT 'pedidos_compra', COUNT(*) FROM pedidos_compra
UNION ALL
SELECT 'lineas_pedido_compra', COUNT(*) FROM lineas_pedido_compra
UNION ALL
SELECT 'movimientos_almacen', COUNT(*) FROM movimientos_almacen
UNION ALL
SELECT 'averias_mantenimiento', COUNT(*) FROM averias_mantenimiento
ORDER BY tabla;
```

Resultado esperado:

```text
averias_mantenimiento      2600
clientes                   2600
incidencias_calidad        2600
lineas_pedido_compra       4500
lineas_pedido_venta        5000
maquinas                   32
materiales                 420
movimientos_almacen        5000
operarios                  120
ordenes_fabricacion        4200
partes_produccion          5000
pedidos_compra             2800
pedidos_venta              3200
productos                  2600
proveedores                150
```

---

## 3. Comprobar volumen total de registros

```sql
SELECT
    (
        (SELECT COUNT(*) FROM clientes) +
        (SELECT COUNT(*) FROM productos) +
        (SELECT COUNT(*) FROM maquinas) +
        (SELECT COUNT(*) FROM operarios) +
        (SELECT COUNT(*) FROM proveedores) +
        (SELECT COUNT(*) FROM materiales) +
        (SELECT COUNT(*) FROM pedidos_venta) +
        (SELECT COUNT(*) FROM lineas_pedido_venta) +
        (SELECT COUNT(*) FROM ordenes_fabricacion) +
        (SELECT COUNT(*) FROM partes_produccion) +
        (SELECT COUNT(*) FROM incidencias_calidad) +
        (SELECT COUNT(*) FROM pedidos_compra) +
        (SELECT COUNT(*) FROM lineas_pedido_compra) +
        (SELECT COUNT(*) FROM movimientos_almacen) +
        (SELECT COUNT(*) FROM averias_mantenimiento)
    ) AS total_registros_base_datos;
```

Resultado esperado:

```text
40822
```

---

## 4. Comprobación general de calidad del dato

```sql
SELECT 'clientes_sin_codigo' AS control, COUNT(*) AS registros
FROM clientes
WHERE cod_cliente IS NULL

UNION ALL

SELECT 'productos_sin_codigo', COUNT(*)
FROM productos
WHERE cod_producto IS NULL

UNION ALL

SELECT 'pedidos_venta_sin_cliente', COUNT(*)
FROM pedidos_venta
WHERE cliente_id IS NULL

UNION ALL

SELECT 'lineas_venta_sin_producto', COUNT(*)
FROM lineas_pedido_venta
WHERE producto_id IS NULL

UNION ALL

SELECT 'ordenes_sin_producto', COUNT(*)
FROM ordenes_fabricacion
WHERE producto_id IS NULL

UNION ALL

SELECT 'partes_sin_of', COUNT(*)
FROM partes_produccion
WHERE num_of IS NULL OR num_of = ''

UNION ALL

SELECT 'incidencias_sin_causa_raiz', COUNT(*)
FROM incidencias_calidad
WHERE causa_raiz IS NULL OR causa_raiz = ''

UNION ALL

SELECT 'pedidos_compra_sin_proveedor', COUNT(*)
FROM pedidos_compra
WHERE proveedor_id IS NULL

UNION ALL

SELECT 'lineas_compra_sin_material', COUNT(*)
FROM lineas_pedido_compra
WHERE material_id IS NULL

UNION ALL

SELECT 'movimientos_sin_material', COUNT(*)
FROM movimientos_almacen
WHERE material_id IS NULL

UNION ALL

SELECT 'averias_sin_fecha_fin', COUNT(*)
FROM averias_mantenimiento
WHERE fecha_fin IS NULL;
```

Resultado obtenido:

```text
clientes_sin_codigo              98
productos_sin_codigo             116
pedidos_venta_sin_cliente        114
lineas_venta_sin_producto        187
ordenes_sin_producto             165
partes_sin_of                    336
incidencias_sin_causa_raiz       896
pedidos_compra_sin_proveedor      99
lineas_compra_sin_material       145
movimientos_sin_material         190
averias_sin_fecha_fin            548
```

---

## 5. Validaciones por tabla

### 5.1 Clientes sin código

```sql
SELECT COUNT(*) AS clientes_sin_codigo
FROM clientes
WHERE cod_cliente IS NULL;
```

### 5.2 Provincias de clientes sin normalizar

```sql
SELECT provincia, COUNT(*) AS total
FROM clientes
GROUP BY provincia
ORDER BY total DESC;
```

### 5.3 Estados de clientes mezclados

```sql
SELECT activo, COUNT(*) AS total
FROM clientes
GROUP BY activo
ORDER BY total DESC;
```

### 5.4 Países de clientes mal normalizados

```sql
SELECT pais, COUNT(*) AS total
FROM clientes
GROUP BY pais
ORDER BY total DESC;
```

### 5.5 Posibles clientes duplicados

```sql
SELECT nombre, COUNT(*) AS veces
FROM clientes
GROUP BY nombre
HAVING COUNT(*) > 1
ORDER BY veces DESC;
```

---

### 5.6 Productos sin código

```sql
SELECT COUNT(*) AS productos_sin_codigo
FROM productos
WHERE cod_producto IS NULL;
```

### 5.7 Familias de producto mal normalizadas

```sql
SELECT familia, COUNT(*) AS total
FROM productos
GROUP BY familia
ORDER BY total DESC;
```

### 5.8 Materiales base escritos de forma diferente

```sql
SELECT material_base, COUNT(*) AS total
FROM productos
GROUP BY material_base
ORDER BY total DESC;
```

### 5.9 Estados de producto mezclados

```sql
SELECT estado, COUNT(*) AS total
FROM productos
GROUP BY estado
ORDER BY total DESC;
```

### 5.10 Productos sin coste estándar

```sql
SELECT COUNT(*) AS productos_sin_coste
FROM productos
WHERE coste_estandar IS NULL;
```

---

### 5.11 Tipos de máquina mezclados

```sql
SELECT tipo, COUNT(*) AS total
FROM maquinas
GROUP BY tipo
ORDER BY total DESC;
```

### 5.12 Centros de trabajo mezclados

```sql
SELECT centro_trabajo, COUNT(*) AS total
FROM maquinas
GROUP BY centro_trabajo
ORDER BY total DESC;
```

### 5.13 Máquinas sin coste hora

```sql
SELECT COUNT(*) AS maquinas_sin_coste_hora
FROM maquinas
WHERE coste_hora IS NULL;
```

### 5.14 Estados de máquina mezclados

```sql
SELECT estado, COUNT(*) AS total
FROM maquinas
GROUP BY estado
ORDER BY total DESC;
```

---

### 5.15 Categorías de operarios mezcladas

```sql
SELECT categoria, COUNT(*) AS total
FROM operarios
GROUP BY categoria
ORDER BY total DESC;
```

### 5.16 Turnos de operarios mezclados

```sql
SELECT turno_habitual, COUNT(*) AS total
FROM operarios
GROUP BY turno_habitual
ORDER BY total DESC;
```

### 5.17 Estados de operarios mezclados

```sql
SELECT activo, COUNT(*) AS total
FROM operarios
GROUP BY activo
ORDER BY total DESC;
```

### 5.18 Operarios sin código

```sql
SELECT COUNT(*) AS operarios_sin_codigo
FROM operarios
WHERE codigo_operario IS NULL;
```

---

### 5.19 Proveedores sin código

```sql
SELECT COUNT(*) AS proveedores_sin_codigo
FROM proveedores
WHERE cod_proveedor IS NULL;
```

### 5.20 Países de proveedores mezclados

```sql
SELECT pais, COUNT(*) AS total
FROM proveedores
GROUP BY pais
ORDER BY total DESC;
```

### 5.21 Tipos de material de proveedor mezclados

```sql
SELECT tipo_material, COUNT(*) AS total
FROM proveedores
GROUP BY tipo_material
ORDER BY total DESC;
```

### 5.22 Criticidad de proveedor mezclada

```sql
SELECT criticidad, COUNT(*) AS total
FROM proveedores
GROUP BY criticidad
ORDER BY total DESC;
```

### 5.23 Estados de proveedores mezclados

```sql
SELECT activo, COUNT(*) AS total
FROM proveedores
GROUP BY activo
ORDER BY total DESC;
```

---

### 5.24 Materiales sin código

```sql
SELECT COUNT(*) AS materiales_sin_codigo
FROM materiales
WHERE cod_material IS NULL;
```

### 5.25 Tipos de material mezclados

```sql
SELECT tipo_material, COUNT(*) AS total
FROM materiales
GROUP BY tipo_material
ORDER BY total DESC;
```

### 5.26 Unidades de medida de materiales mezcladas

```sql
SELECT unidad_medida, COUNT(*) AS total
FROM materiales
GROUP BY unidad_medida
ORDER BY total DESC;
```

### 5.27 Materiales sin coste estándar

```sql
SELECT COUNT(*) AS materiales_sin_coste
FROM materiales
WHERE coste_estandar IS NULL;
```

### 5.28 Proveedores habituales mal normalizados

```sql
SELECT proveedor_habitual, COUNT(*) AS total
FROM materiales
GROUP BY proveedor_habitual
ORDER BY total DESC;
```

---

## 6. Primeras consultas de negocio

### 6.1 Ventas por producto

```sql
SELECT
    producto_id,
    COUNT(*) AS num_lineas,
    SUM(cantidad) AS unidades_vendidas,
    SUM(importe_linea) AS facturacion_estimada,
    SUM(coste_estimado) AS coste_estimado_total,
    SUM(margen_estimado) AS margen_estimado_total
FROM lineas_pedido_venta
GROUP BY producto_id
ORDER BY facturacion_estimada DESC
LIMIT 20;
```

---

### 6.2 Comprobación de margen recalculado

```sql
SELECT
    linea_id,
    cantidad,
    precio_unitario,
    descuento_pct,
    importe_linea,
    coste_estimado,
    margen_estimado,
    ROUND((importe_linea - coste_estimado)::numeric, 2) AS margen_recalculado
FROM lineas_pedido_venta
WHERE importe_linea IS NOT NULL
  AND coste_estimado IS NOT NULL
  AND margen_estimado IS NOT NULL
LIMIT 20;
```

---

### 6.3 Órdenes de fabricación con retraso

```sql
SELECT COUNT(*) AS ordenes_con_retraso
FROM ordenes_fabricacion
WHERE fecha_fin_real > fecha_fin_prevista;
```

---

### 6.4 Producción por máquina

```sql
SELECT
    maquina,
    COUNT(*) AS num_partes,
    SUM(horas_trabajadas) AS horas_totales,
    SUM(unidades_ok) AS unidades_ok,
    SUM(unidades_nok) AS unidades_nok,
    SUM(kg_consumidos) AS kg_consumidos,
    SUM(kg_scrap) AS kg_scrap,
    ROUND(
        (SUM(kg_scrap) / NULLIF(SUM(kg_consumidos), 0) * 100)::numeric,
        2
    ) AS pct_scrap
FROM partes_produccion
GROUP BY maquina
ORDER BY pct_scrap DESC
LIMIT 20;
```

---

### 6.5 Coste de no calidad por tipo de incidencia

```sql
SELECT
    tipo_incidencia,
    COUNT(*) AS num_incidencias,
    SUM(unidades_afectadas) AS unidades_afectadas,
    SUM(coste_estimado) AS coste_no_calidad_estimado,
    ROUND(AVG(coste_estimado)::numeric, 2) AS coste_medio_incidencia
FROM incidencias_calidad
GROUP BY tipo_incidencia
ORDER BY coste_no_calidad_estimado DESC
LIMIT 20;
```

---

### 6.6 Rendimiento de proveedores por retraso

```sql
SELECT
    proveedor_id,
    COUNT(*) AS total_pedidos,
    COUNT(*) FILTER (WHERE fecha_recepcion > fecha_prevista) AS pedidos_tarde,
    ROUND(
        (
            COUNT(*) FILTER (WHERE fecha_recepcion > fecha_prevista)::numeric
            / NULLIF(COUNT(*) FILTER (WHERE fecha_prevista IS NOT NULL), 0)
            * 100
        ),
        2
    ) AS pct_pedidos_tarde
FROM pedidos_compra
GROUP BY proveedor_id
ORDER BY pct_pedidos_tarde DESC
LIMIT 20;
```

---

### 6.7 Compras por material

```sql
SELECT
    material_id,
    COUNT(*) AS num_lineas,
    SUM(cantidad_pedida) AS cantidad_pedida_total,
    SUM(cantidad_recibida) AS cantidad_recibida_total,
    SUM(importe_total) AS coste_total_compra,
    ROUND(AVG(precio_unitario)::numeric, 2) AS precio_unitario_medio
FROM lineas_pedido_compra
GROUP BY material_id
ORDER BY coste_total_compra DESC
LIMIT 20;
```

---

### 6.8 Movimientos de almacén por material y tipo

```sql
SELECT
    material_id,
    tipo_movimiento,
    COUNT(*) AS num_movimientos,
    SUM(cantidad) AS cantidad_total
FROM movimientos_almacen
WHERE cantidad IS NOT NULL
GROUP BY material_id, tipo_movimiento
ORDER BY cantidad_total DESC
LIMIT 30;
```

---

### 6.9 Resumen por tipo de movimiento de almacén

```sql
SELECT
    tipo_movimiento,
    COUNT(*) AS num_movimientos,
    SUM(cantidad) AS cantidad_total
FROM movimientos_almacen
WHERE cantidad IS NOT NULL
GROUP BY tipo_movimiento
ORDER BY cantidad_total DESC;
```

---

### 6.10 Mantenimiento por máquina

```sql
SELECT
    maquina,
    COUNT(*) AS num_averias,
    SUM(coste_estimado) AS coste_total_mantenimiento,
    ROUND(AVG(coste_estimado)::numeric, 2) AS coste_medio_averia,
    ROUND(
        SUM(EXTRACT(EPOCH FROM (fecha_fin - fecha_inicio)) / 3600)::numeric,
        2
    ) AS horas_parada_estimadas
FROM averias_mantenimiento
WHERE fecha_inicio IS NOT NULL
  AND fecha_fin IS NOT NULL
GROUP BY maquina
ORDER BY coste_total_mantenimiento DESC
LIMIT 20;
```

---

## 7. Interpretación de los controles principales

Los controles finales muestran que la base de datos contiene problemas realistas de calidad del dato.

Los más relevantes son:

```text
incidencias_sin_causa_raiz       896
averias_sin_fecha_fin            548
partes_sin_of                    336
lineas_venta_sin_producto        187
movimientos_sin_material         190
```

Estos problemas son intencionados y permiten construir una fase posterior de limpieza, normalización y modelado para Power BI.

---

## Siguiente paso

Después de validar la base de datos, ejecutar el archivo:

```text
04_cleaning_views.sql
```

Este archivo creará vistas limpias para preparar los datos para análisis y visualización.

