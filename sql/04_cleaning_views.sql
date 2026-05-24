# 04_cleaning_views.sql

## Objetivo

Este script crea la capa limpia de la base de datos **nortemec_operaciones** sin modificar las tablas brutas originales.

La finalidad de este archivo es transformar tablas operativas con datos sucios en vistas SQL limpias y preparadas para análisis, modelado y conexión con Power BI.

El archivo forma parte de la **Fase 2 — Limpieza y normalización SQL** del proyecto **Nortemec Industrial Analytics**.

Fuente del script trabajado: `04_cleaning_views.sql.txt`. :contentReference[oaicite:0]{index=0}

---

## Enfoque de limpieza

La limpieza se realiza mediante vistas SQL usando:

- `CREATE OR REPLACE VIEW`
- `TRIM()`
- `UPPER()`
- `LOWER()`
- `INITCAP()`
- `COALESCE()`
- `NULLIF()`
- `CASE WHEN`
- flags booleanos de control
- normalización de nombres, códigos, estados y categorías
- joins contra vistas maestras limpias
- deduplicación con `DISTINCT ON` en vistas con riesgo de duplicar filas

La filosofía del script es:

```text
Tablas brutas sucias → Vistas limpias SQL → Modelo Power BI

1. Vistas limpias maestras
1.1 vw_clientes_limpios

Vista creada a partir de la tabla bruta:

clientes
Limpiezas aplicadas
Generación de código artificial para clientes sin código.
Limpieza de nombre y razón social.
Normalización de CIF.
Normalización de provincia.
Normalización de país.
Normalización de sector.
Normalización de tipo de cliente.
Normalización del estado del cliente.
Limpieza de email y teléfono.
Creación de flags de calidad.
Campos destacados
cod_cliente_limpio
nombre_cliente_limpio
razon_social_limpia
cif_limpio
provincia_limpia
pais_limpio
sector_limpio
tipo_cliente_limpio
estado_cliente_limpio
flag_cliente_activo
flag_codigo_generado
flag_nombre_vacio
Ejemplos de normalización
España / ESP / Spain → España
Bizkaia / Vizcaya → Bizkaia
Automoción / Automocion / Auxiliar automoción → Automoción
SI / Sí / S / Activo / ACT → Activo
NO / Baja → Baja
1.2 vw_productos_limpios

Vista creada a partir de la tabla bruta:

productos
Limpiezas aplicadas
Generación de código artificial para productos sin código.
Normalización de descripciones de producto.
Normalización de familias.
Normalización de material base.
Normalización de unidad de medida.
Normalización de estado de producto.
Identificación de productos sin coste estándar.
Identificación de productos sin precio teórico.
Campos destacados
cod_producto_limpio
descripcion_limpia
familia_limpia
material_base_limpio
unidad_medida_limpia
estado_producto_limpio
flag_producto_activo
flag_codigo_generado
flag_sin_coste_estandar
flag_sin_precio_teorico
Ejemplos de normalización
Placa perforada 8mm / Placa perf. 8 mm / PLACA PERFORADA 8 MM → Placa perforada 8 mm
Eje mecanizado 40mm / Eje mec. Ø40 → Eje mecanizado 40 mm
Inox 304 / Acero inoxidable 304 → Acero inoxidable 304
UD / unidad / pcs / pieza → ud
ACT / activo / Activo → Activo
1.3 vw_maquinas_limpias

Vista creada a partir de la tabla bruta:

maquinas
Limpiezas aplicadas
Generación de código artificial para máquinas sin código.
Normalización de códigos de máquina.
Normalización de nombres.
Normalización de tipo de máquina.
Normalización de centro de trabajo.
Normalización de fabricante.
Normalización de estado.
Identificación de máquinas sin coste hora.
Campos destacados
codigo_maquina_limpio
nombre_maquina_limpio
tipo_maquina_limpio
centro_trabajo_limpio
fabricante_limpio
estado_maquina_limpio
flag_maquina_activa
flag_codigo_generado
flag_sin_coste_hora
Ejemplos de normalización
CNC-01 / CNC 1 / cnc_01 → CNC-01
LAS-02 / Laser-2 → LAS-02
CNC_04 → CNC-04
ACT / Activa / activo → Activa
1.4 vw_operarios_limpios

Vista creada a partir de la tabla bruta:

operarios
Limpiezas aplicadas
Generación de código artificial para operarios sin código.
Normalización de nombres abreviados.
Normalización de categorías.
Normalización de equipos.
Normalización de turnos.
Normalización de estado de operario.
Campos destacados
codigo_operario_limpio
nombre_operario_limpio
categoria_limpia
equipo_limpio
turno_habitual_limpio
estado_operario_limpio
flag_operario_activo
flag_codigo_generado
Ejemplos de normalización
L. Gomez / Luis G. → Luis Gómez
A. Perez → Ana Pérez
C. Ruiz → Carlos Ruiz
M / Mañana → Mañana
T / Tarde → Tarde
N / Noche → Noche
1.5 vw_proveedores_limpios

Vista creada a partir de la tabla bruta:

proveedores
Limpiezas aplicadas
Generación de código artificial para proveedores sin código.
Normalización de nombres de proveedor.
Normalización de CIF.
Normalización de provincia y país.
Normalización de tipo de material.
Normalización de criticidad.
Normalización de estado.
Limpieza de email y teléfono.
Campos destacados
cod_proveedor_limpio
nombre_proveedor_limpio
cif_limpio
provincia_limpia
pais_limpio
tipo_material_limpio
criticidad_limpia
estado_proveedor_limpio
flag_proveedor_activo
flag_codigo_generado
Ejemplos de normalización
ACEROS NORTE SL / Aceros Norte → Aceros Norte S.L.
ALUMINIOS IBERIA S.A. → Aluminios Iberia
Trat. Cantabria → Tratamientos Cantabria
Critico / Crítico / Alta → Alta
1.6 vw_materiales_limpios

Vista creada a partir de la tabla bruta:

materiales
Limpiezas aplicadas
Generación de código artificial para materiales sin código.
Normalización de descripción.
Normalización de tipo de material.
Normalización de calidad.
Normalización de unidad de medida.
Normalización de proveedor habitual.
Normalización de estado.
Identificación de materiales sin coste estándar.
Campos destacados
cod_material_limpio
descripcion_limpia
tipo_material_limpio
calidad_material_limpia
unidad_medida_limpia
proveedor_habitual_limpio
estado_material_limpio
flag_material_activo
flag_codigo_generado
flag_sin_coste_estandar
Ejemplos de normalización
kg / KG / kilos → kg
ud / UD / unidad → ud
m / metro → m
L / litros → l
Inox / Acero inoxidable → Acero inoxidable
AISI 304 / 304 → AISI 304
2. Vistas limpias transaccionales
2.1 vw_ventas_limpias

Vista creada a partir de:

lineas_pedido_venta
pedidos_venta
vw_clientes_limpios
vw_productos_limpios
Objetivo

Preparar una vista de ventas lista para análisis de facturación, costes, márgenes y retrasos de entrega.

Limpiezas y transformaciones
Limpieza de número de pedido.
Unión con cliente limpio.
Unión con producto limpio.
Normalización de estado de pedido.
Normalización de comercial.
Normalización de forma de pago.
Normalización de prioridad.
Recalculo de importe de línea.
Recalculo de margen estimado.
Cálculo de porcentaje de margen.
Cálculo de días de retraso.
Creación de flags de calidad.
Campos destacados
num_pedido_limpio
nombre_cliente_limpio
producto_limpio
familia_producto
importe_linea_limpio
coste_estimado
margen_estimado_limpio
margen_pct_limpio
estado_pedido_limpio
comercial_limpio
forma_pago_limpia
prioridad_limpia
dias_retraso
flag_entrega_tarde
flag_sin_cliente
flag_sin_producto
flag_margen_negativo
Validación esperada
SELECT COUNT(*) AS total_ventas_limpias
FROM vw_ventas_limpias;

Resultado esperado:

5000
2.2 vw_produccion_limpia

Vista creada a partir de:

partes_produccion
ordenes_fabricacion
vw_productos_limpios
vw_maquinas_limpias
vw_operarios_limpios
Objetivo

Preparar una vista de producción para analizar horas, unidades, scrap, rechazo, paradas y órdenes de fabricación.

Problema detectado y corrección aplicada

En una primera versión, la vista devolvía:

8834 filas

cuando debía devolver aproximadamente:

5000 filas

La causa fue la duplicación de registros al cruzar contra máquinas y operarios normalizados, ya que códigos como:

CNC-01
CNC 1
cnc_01

se convertían todos en:

CNC-01

Para corregirlo se usaron CTEs con DISTINCT ON:

maquinas_unicas
operarios_unicos
ordenes_unicas

Esto evita duplicaciones en los joins.

Limpiezas y transformaciones
Normalización de número de orden de fabricación.
Unión con órdenes de fabricación.
Unión con producto limpio.
Unión con máquina limpia deduplicada.
Unión con operario limpio deduplicado.
Normalización de turno.
Normalización de motivo de scrap.
Normalización de motivo de parada.
Cálculo de unidades totales.
Cálculo de porcentaje de scrap.
Cálculo de porcentaje de rechazo.
Cálculo de horas de parada.
Cálculo de coste teórico de horas.
Identificación de órdenes retrasadas.
Creación de flags de calidad.
Campos destacados
num_of_limpio
producto_limpio
familia_producto
codigo_maquina_limpio
nombre_maquina_limpio
tipo_maquina_limpio
operario_limpio
turno_limpio
horas_trabajadas
unidades_ok
unidades_nok_limpias
unidades_totales
kg_consumidos
kg_scrap_limpio
pct_scrap
pct_rechazo
motivo_scrap_limpio
parada_horas_limpio
motivo_parada_limpio
dias_retraso_of
flag_of_retrasada
flag_tiene_parada
flag_tiene_scrap
flag_tiene_rechazo
coste_teorico_horas
Validación esperada
SELECT COUNT(*) AS total_produccion_limpia
FROM vw_produccion_limpia;

Resultado esperado:

5000
2.3 vw_calidad_limpia

Vista creada a partir de:

incidencias_calidad
Objetivo

Preparar una vista de calidad para analizar defectos, gravedad, causa raíz, reprocesos y coste de no calidad.

Limpiezas y transformaciones
Normalización de número de OF.
Normalización de cliente.
Normalización de producto.
Normalización de máquina.
Normalización de proveedor.
Normalización de tipo de incidencia.
Normalización de gravedad.
Normalización de reproceso.
Normalización de causa raíz.
Normalización de estado.
Normalización de responsable.
Creación de flags de calidad.
Campos destacados
num_of_limpio
cliente_limpio
producto_limpio
maquina_limpia
proveedor_limpio
tipo_incidencia_limpio
gravedad_limpia
unidades_afectadas
coste_no_calidad_estimado
requiere_reproceso_limpio
causa_raiz_limpia
estado_incidencia_limpio
responsable_limpio
flag_sin_causa_raiz
flag_requiere_reproceso
flag_incidencia_abierta
flag_gravedad_alta
flag_coste_alto
Validación esperada
SELECT COUNT(*) AS total_calidad_limpia
FROM vw_calidad_limpia;

Resultado esperado:

2600
2.4 vw_compras_limpias

Vista creada a partir de:

lineas_pedido_compra
pedidos_compra
vw_proveedores_limpios
vw_materiales_limpios
Objetivo

Preparar una vista de compras para analizar proveedores, materiales, costes, retrasos, cantidades recibidas e incidencias de calidad.

Limpiezas y transformaciones
Limpieza de número de pedido de compra.
Unión con proveedor limpio.
Unión con material limpio.
Normalización de unidad de compra.
Recalculo de importe total.
Cálculo de diferencia entre cantidad pedida y recibida.
Cálculo de variación de precio frente a coste estándar.
Normalización de incidencia de calidad.
Normalización de estado del pedido.
Normalización de comprador.
Cálculo de días de retraso.
Creación de flags.
Campos destacados
num_pedido_compra_limpio
nombre_proveedor_limpio
criticidad_proveedor
material_limpio
tipo_material_limpio
cantidad_pedida
cantidad_recibida
diferencia_cantidad
precio_unitario
importe_total_limpio
diferencia_precio_vs_estandar
pct_variacion_precio_vs_estandar
incidencia_calidad_limpia
estado_pedido_compra_limpio
comprador_limpio
dias_retraso_compra
flag_entrega_tarde
flag_recibido_menos
flag_incidencia_calidad
flag_precio_alto_vs_estandar
Validación esperada
SELECT COUNT(*) AS total_compras_limpias
FROM vw_compras_limpias;

Resultado esperado:

4500
2.5 vw_almacen_limpio

Vista creada a partir de:

movimientos_almacen
vw_materiales_limpios
Objetivo

Preparar una vista de almacén para analizar entradas, salidas, consumos, ajustes, regularizaciones y valor estimado de movimientos.

Limpiezas y transformaciones
Unión con material limpio.
Normalización de tipo de movimiento.
Creación de grupo de movimiento.
Normalización de unidad de movimiento.
Cálculo de valor estimado de movimiento.
Normalización de almacén.
Limpieza de número de OF.
Limpieza de pedido de compra.
Normalización de motivo.
Normalización de usuario.
Creación de flags.
Campos destacados
movimiento_id
fecha
material_limpio
tipo_material_limpio
tipo_movimiento_limpio
grupo_movimiento
cantidad
unidad_movimiento_limpia
valor_movimiento_estimado
almacen_limpio
num_of_limpio
pedido_compra_limpio
motivo_limpio
usuario_limpio
flag_sin_material
flag_sin_tipo_movimiento
flag_sin_cantidad
flag_movimiento_alto
Validación esperada
SELECT COUNT(*) AS total_almacen_limpio
FROM vw_almacen_limpio;

Resultado esperado:

5000
2.6 vw_mantenimiento_limpio

Vista creada a partir de:

averias_mantenimiento
vw_maquinas_limpias
Objetivo

Preparar una vista de mantenimiento para analizar averías, costes, horas de parada, técnicos, máquinas críticas y averías abiertas.

Limpiezas y transformaciones
Deduplicación de máquinas con DISTINCT ON.
Normalización de código de máquina.
Unión con máquina limpia.
Normalización de tipo de avería.
Normalización de técnico.
Normalización de parada de producción.
Cálculo de horas de parada.
Cálculo de minutos de parada.
Cálculo de coste estimado de parada.
Normalización de estado de avería.
Creación de flags.
Campos destacados
averia_id
fecha_inicio
fecha_fin
codigo_maquina_limpio
nombre_maquina_limpio
tipo_maquina_limpio
centro_trabajo_limpio
tipo_averia_limpio
tecnico_limpio
parada_produccion_limpia
coste_mantenimiento_estimado
horas_parada
minutos_parada
coste_parada_estimado
estado_averia_limpio
flag_averia_abierta
flag_parada_produccion
flag_parada_larga
flag_coste_mantenimiento_alto
Validación esperada
SELECT COUNT(*) AS total_mantenimiento_limpio
FROM vw_mantenimiento_limpio;

Resultado esperado:

2600
3. Vistas creadas en el archivo

El archivo 04_cleaning_views.sql crea las siguientes vistas:

vw_clientes_limpios
vw_productos_limpios
vw_maquinas_limpias
vw_operarios_limpios
vw_proveedores_limpios
vw_materiales_limpios
vw_ventas_limpias
vw_produccion_limpia
vw_calidad_limpia
vw_compras_limpias
vw_almacen_limpio
vw_mantenimiento_limpio
4. Validación general de vistas

Para comprobar que las vistas se han creado correctamente:

SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

Resultado esperado:

vw_almacen_limpio
vw_calidad_limpia
vw_clientes_limpios
vw_compras_limpias
vw_mantenimiento_limpio
vw_maquinas_limpias
vw_materiales_limpios
vw_operarios_limpios
vw_produccion_limpia
vw_productos_limpios
vw_proveedores_limpios
vw_ventas_limpias
5. Validación de filas esperadas
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

Resultado esperado:

vw_almacen_limpio          5000
vw_calidad_limpia          2600
vw_compras_limpias         4500
vw_mantenimiento_limpio    2600
vw_produccion_limpia       5000
vw_ventas_limpias          5000
6. Consultas de validación de negocio
6.1 Ventas por familia de producto
SELECT
    familia_producto,
    COUNT(*) AS num_lineas,
    SUM(importe_linea_limpio) AS facturacion,
    SUM(coste_estimado) AS coste,
    SUM(margen_estimado_limpio) AS margen,
    ROUND(
        (SUM(margen_estimado_limpio) / NULLIF(SUM(importe_linea_limpio), 0) * 100)::numeric,
        2
    ) AS margen_pct
FROM vw_ventas_limpias
GROUP BY familia_producto
ORDER BY facturacion DESC;
6.2 Producción por máquina
SELECT
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio,
    COUNT(*) AS num_partes,
    SUM(horas_trabajadas) AS horas_totales,
    SUM(unidades_ok) AS unidades_ok,
    SUM(unidades_nok_limpias) AS unidades_nok,
    SUM(kg_consumidos) AS kg_consumidos,
    SUM(kg_scrap_limpio) AS kg_scrap,
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
6.3 Calidad por tipo de incidencia
SELECT
    tipo_incidencia_limpio,
    gravedad_limpia,
    COUNT(*) AS num_incidencias,
    SUM(unidades_afectadas) AS unidades_afectadas,
    SUM(coste_no_calidad_estimado) AS coste_no_calidad,
    ROUND(AVG(coste_no_calidad_estimado)::numeric, 2) AS coste_medio
FROM vw_calidad_limpia
GROUP BY tipo_incidencia_limpio, gravedad_limpia
ORDER BY coste_no_calidad DESC
LIMIT 20;
6.4 Compras por proveedor
SELECT
    nombre_proveedor_limpio,
    criticidad_proveedor,
    COUNT(*) AS num_lineas,
    SUM(importe_total_limpio) AS coste_total_compra,
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
LIMIT 20;
6.5 Movimientos de almacén
SELECT
    tipo_movimiento_limpio,
    grupo_movimiento,
    COUNT(*) AS num_movimientos,
    SUM(cantidad) AS cantidad_total,
    SUM(valor_movimiento_estimado) AS valor_estimado_total
FROM vw_almacen_limpio
GROUP BY tipo_movimiento_limpio, grupo_movimiento
ORDER BY valor_estimado_total DESC;
6.6 Mantenimiento por máquina
SELECT
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio,
    COUNT(*) AS num_averias,
    SUM(coste_mantenimiento_estimado) AS coste_mantenimiento,
    SUM(coste_parada_estimado) AS coste_parada,
    ROUND(AVG(horas_parada)::numeric, 2) AS horas_parada_media,
    SUM(horas_parada) AS horas_parada_total,
    COUNT(*) FILTER (WHERE flag_averia_abierta = TRUE) AS averias_abiertas,
    COUNT(*) FILTER (WHERE flag_parada_larga = TRUE) AS paradas_largas
FROM vw_mantenimiento_limpio
GROUP BY
    codigo_maquina_limpio,
    nombre_maquina_limpio,
    tipo_maquina_limpio
ORDER BY coste_mantenimiento DESC
LIMIT 20;
7. Resultado de la Fase 2

Con este archivo queda creada una capa SQL limpia sobre la base operativa bruta.

La arquitectura queda así:

Tablas brutas PostgreSQL
        ↓
04_cleaning_views.sql
        ↓
Vistas limpias SQL
