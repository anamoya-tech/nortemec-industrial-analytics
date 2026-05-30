# Data Quality Report — Nortemec Industrial Analytics

## 1. Objetivo del informe

Este documento recoge el análisis de calidad del dato realizado sobre la base de datos **nortemec_operaciones**, creada para el proyecto **Nortemec Industrial Analytics**.

El objetivo del informe es documentar:

* Qué problemas de calidad existen en la base operativa.
* Qué controles SQL se han utilizado para detectarlos.
* Qué impacto tienen esos problemas en el negocio.
* Qué decisiones de limpieza se han aplicado.
* Qué problemas se mantienen como indicadores analizables.
* Qué flags se han creado para preparar el análisis en Power BI.

Este informe forma parte de la documentación del proyecto y complementa los scripts:

```text
03_validation_queries.sql
04_cleaning_views.sql
05_analysis_queries.sql
```

---

## 2. Contexto del dato

Nortemec Precision Components S.L. es una empresa industrial ficticia dedicada a la fabricación de componentes metálicos de precisión.

La empresa genera datos en diferentes áreas:

* Ventas.
* Producción.
* Calidad.
* Compras.
* Almacén.
* Mantenimiento.
* Clientes.
* Productos.
* Proveedores.
* Materiales.
* Máquinas.
* Operarios.

La base de datos simula un entorno industrial realista, donde la información no llega limpia ni perfectamente modelada. Parte de los datos procede de ERP, Excel, partes manuales de producción, registros de calidad y mantenimiento.

Por este motivo, el proyecto no parte de un modelo analítico perfecto, sino de tablas operativas con problemas habituales de calidad del dato.

---

## 3. Tablas analizadas

La base de datos contiene 15 tablas operativas:

```text
clientes
productos
maquinas
operarios
proveedores
materiales
pedidos_venta
lineas_pedido_venta
ordenes_fabricacion
partes_produccion
incidencias_calidad
pedidos_compra
lineas_pedido_compra
movimientos_almacen
averias_mantenimiento
```

Estas tablas cubren las áreas clave del negocio industrial:

| Área                     | Tablas principales                     |
| ------------------------ | -------------------------------------- |
| Clientes                 | clientes                               |
| Productos                | productos                              |
| Ventas                   | pedidos_venta, lineas_pedido_venta     |
| Producción               | ordenes_fabricacion, partes_produccion |
| Calidad                  | incidencias_calidad                    |
| Compras                  | pedidos_compra, lineas_pedido_compra   |
| Almacén                  | movimientos_almacen                    |
| Mantenimiento            | averias_mantenimiento                  |
| Recursos productivos     | maquinas, operarios                    |
| Proveedores y materiales | proveedores, materiales                |

---

## 4. Volumen de datos

La base contiene más de **40.000 registros** distribuidos entre tablas maestras y transaccionales.

| Tabla                 | Registros esperados |
| --------------------- | ------------------: |
| clientes              |                2600 |
| productos             |                2600 |
| maquinas              |                  32 |
| operarios             |                 120 |
| proveedores           |                 150 |
| materiales            |                 420 |
| pedidos_venta         |                3200 |
| lineas_pedido_venta   |                5000 |
| ordenes_fabricacion   |                4200 |
| partes_produccion     |                5000 |
| incidencias_calidad   |                2600 |
| pedidos_compra        |                2800 |
| lineas_pedido_compra  |                4500 |
| movimientos_almacen   |                5000 |
| averias_mantenimiento |                2600 |

Consulta utilizada para validar el número de filas:

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

---

## 5. Problemas iniciales detectados en tablas brutas

Se ejecutó una primera validación sobre las tablas brutas para identificar problemas críticos de integridad y completitud.

Consulta utilizada:

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

| Control                      | Registros |
| ---------------------------- | --------: |
| clientes_sin_codigo          |        98 |
| productos_sin_codigo         |       116 |
| pedidos_venta_sin_cliente    |       114 |
| lineas_venta_sin_producto    |       187 |
| ordenes_sin_producto         |       165 |
| partes_sin_of                |       336 |
| incidencias_sin_causa_raiz   |       896 |
| pedidos_compra_sin_proveedor |        99 |
| lineas_compra_sin_material   |       145 |
| movimientos_sin_material     |       190 |
| averias_sin_fecha_fin        |       548 |

---

## 6. Clasificación de problemas de calidad del dato

Los problemas detectados se pueden agrupar en cinco categorías.

## 6.1 Problemas de completitud

Campos clave que aparecen vacíos o nulos.

Ejemplos:

* Clientes sin código.
* Productos sin código.
* Pedidos sin cliente.
* Líneas de venta sin producto.
* Pedidos de compra sin proveedor.
* Movimientos de almacén sin material.
* Averías sin fecha de fin.

Impacto:

* Dificultan el análisis por cliente, producto, proveedor o material.
* Reducen la trazabilidad.
* Impiden construir relaciones fiables en Power BI.
* Obligan a crear flags de revisión.

---

## 6.2 Problemas de consistencia

Campos con el mismo significado escritos de formas diferentes.

Ejemplos:

```text
España / ESP / Spain
SI / Sí / S / Activo / ACT
NO / Baja
CNC-01 / CNC 1 / cnc_01
LAS-02 / Laser-2
Aceros Norte S.L. / ACEROS NORTE SL / Aceros Norte
Aluminio / ALUMINIO / Aluminio 6082
kg / KG / kilos
ud / UD / unidad
```

Impacto:

* Fragmentan los resultados en los gráficos.
* Generan duplicidades aparentes.
* Dificultan los rankings.
* Provocan errores en segmentadores y filtros.

---

## 6.3 Problemas de integridad relacional

Registros transaccionales que no apuntan correctamente a entidades maestras.

Ejemplos:

* Pedidos de venta sin cliente.
* Líneas de venta sin producto.
* Órdenes de fabricación sin producto.
* Partes de producción sin orden de fabricación.
* Líneas de compra sin material.
* Movimientos de almacén sin material.

Impacto:

* Dificultan el modelo de relaciones.
* Impiden analizar correctamente márgenes, producción o compras por dimensión.
* Requieren mantener registros visibles pero marcados como problemáticos.

---

## 6.4 Problemas de trazabilidad operativa

Registros que existen, pero no permiten reconstruir el proceso completo.

Ejemplos:

* Partes de producción sin orden de fabricación.
* Incidencias sin causa raíz.
* Averías sin fecha de cierre.
* Movimientos de almacén sin material.
* Pedidos de compra sin fecha de recepción.

Impacto:

* Dificultan saber qué producto, máquina, proveedor o cliente originó un problema.
* Impiden calcular correctamente retrasos, paradas o costes.
* Reducen la capacidad de toma de decisiones.

---

## 6.5 Problemas de negocio detectables

No todos los problemas son errores técnicos. Algunos son alertas de negocio.

Ejemplos:

* Ventas con margen negativo.
* Compras entregadas tarde.
* Producción con scrap.
* Averías abiertas.
* Incidencias de calidad sin causa raíz.

Impacto:

* Permiten detectar pérdidas ocultas.
* Ayudan a priorizar acciones correctivas.
* Son indicadores clave para el dashboard.

---

## 7. Limpieza y normalización aplicada

La limpieza no modifica las tablas originales. Se crea una capa limpia mediante vistas SQL.

Archivo principal:

```text
04_cleaning_views.sql
```

Vistas creadas:

```text
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
```

Arquitectura de limpieza:

```text
Tablas brutas PostgreSQL
        ↓
Vistas limpias SQL
        ↓
Consultas de análisis
        ↓
Power BI
```

---

## 8. Decisiones de limpieza aplicadas

## 8.1 Conservación del dato bruto

Las tablas originales no se modifican.

Se mantienen como capa de origen para preservar la trazabilidad.

## 8.2 Creación de códigos artificiales

Cuando una entidad no tiene código, se genera un identificador controlado.

Ejemplos:

```text
SIN_CODIGO_CLIENTE_123
SIN_CODIGO_PRODUCTO_456
SIN_CODIGO_MAQUINA_31
SIN_CODIGO_PROVEEDOR_22
SIN_CODIGO_MATERIAL_88
```

Esto permite que el registro siga siendo visible en análisis sin confundirse con registros válidos.

## 8.3 Normalización de estados

Estados equivalentes se agrupan bajo una única categoría.

Ejemplos:

```text
SI / Sí / S / Activo / ACT → Activo
NO / Baja → Baja
Entregado / Cerrado → Entregado
Recibido / Cerrado / Finalizado → Recibido
Abierta / Pendiente / En curso → Abierta o En curso
```

## 8.4 Normalización de unidades

Unidades equivalentes se consolidan.

```text
kg / KG / kilos → kg
ud / UD / unidad / pieza / pcs → ud
m / metro → m
L / litros → l
```

## 8.5 Normalización de nombres maestros

Se normalizan nombres escritos de forma diferente.

Ejemplos:

```text
Aceros Norte S.L. / ACEROS NORTE SL / Aceros Norte → Aceros Norte S.L.
Aluminios Iberia / ALUMINIOS IBERIA S.A. → Aluminios Iberia
Trat. Cantabria → Tratamientos Cantabria
L. Gomez / Luis G. → Luis Gómez
A. Perez → Ana Pérez
C. Ruiz → Carlos Ruiz
```

## 8.6 Normalización de máquinas

Los códigos de máquina se unifican para evitar fragmentación.

```text
CNC-01 / CNC 1 / cnc_01 → CNC-01
LAS-02 / Laser-2 → LAS-02
CNC_04 → CNC-04
```

## 8.7 Deduplicación en joins

Durante la creación de `vw_produccion_limpia`, se detectó una duplicación de filas.

La vista devolvía:

```text
8834 filas
```

cuando debía devolver aproximadamente:

```text
5000 filas
```

La causa era que varias máquinas y operarios distintos se normalizaban al mismo valor limpio, generando duplicidades en los joins.

Solución aplicada:

```sql
SELECT DISTINCT ON (codigo_maquina_limpio)
```

y creación de CTEs:

```text
maquinas_unicas
operarios_unicos
ordenes_unicas
```

Con esta corrección, la vista de producción queda alineada con los registros originales de partes de producción.

---

## 9. Flags creados para análisis

Las vistas limpias incorporan flags booleanos para identificar problemas sin eliminar registros.

## 9.1 Flags de ventas

```text
flag_sin_cliente
flag_sin_producto
flag_sin_cantidad
flag_sin_precio
flag_sin_coste
flag_margen_negativo
flag_pedido_sin_numero
flag_entrega_tarde
```

## 9.2 Flags de producción

```text
flag_sin_fecha
flag_sin_of
flag_sin_maquina
flag_sin_operario
flag_sin_horas
flag_sin_kg_consumidos
flag_sin_kg_scrap
flag_tiene_parada
flag_tiene_scrap
flag_tiene_rechazo
flag_of_retrasada
```

## 9.3 Flags de calidad

```text
flag_sin_fecha
flag_sin_of
flag_sin_pedido
flag_sin_cliente
flag_sin_producto
flag_sin_maquina
flag_sin_proveedor
flag_sin_causa_raiz
flag_coste_no_informado
flag_requiere_reproceso
flag_incidencia_abierta
flag_gravedad_alta
flag_coste_alto
```

## 9.4 Flags de compras

```text
flag_entrega_tarde
flag_sin_fecha_recepcion
flag_pedido_sin_numero
flag_sin_proveedor
flag_sin_material
flag_sin_cantidad_pedida
flag_sin_cantidad_recibida
flag_sin_precio_unitario
flag_sin_importe_total
flag_recibido_menos
flag_incidencia_calidad
flag_precio_alto_vs_estandar
```

## 9.5 Flags de almacén

```text
flag_sin_fecha
flag_sin_material
flag_sin_tipo_movimiento
flag_sin_cantidad
flag_sin_unidad
flag_sin_almacen
flag_sin_of
flag_sin_pedido_compra
flag_sin_motivo
flag_movimiento_alto
```

## 9.6 Flags de mantenimiento

```text
flag_parada_produccion
flag_averia_abierta
flag_sin_fecha_inicio
flag_sin_fecha_fin
flag_sin_maquina
flag_sin_tipo_averia
flag_sin_tecnico
flag_sin_coste_mantenimiento
flag_coste_mantenimiento_alto
flag_parada_larga
```

---

## 10. Controles críticos tras la limpieza SQL

Después de crear la capa limpia mediante vistas SQL, se ejecutó un control final para identificar registros que siguen requiriendo revisión de negocio.

Consulta utilizada:

```sql
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
```

Resultado obtenido:

| Control                      | Registros |
| ---------------------------- | --------: |
| calidad_sin_causa_raiz       |       896 |
| ventas_sin_producto          |       187 |
| mantenimiento_averia_abierta |       548 |
| almacen_sin_material         |       190 |
| compras_entrega_tarde        |      2585 |
| ventas_margen_negativo       |       322 |
| produccion_con_scrap         |      4329 |
| produccion_sin_of            |       336 |

---

## 11. Interpretación de controles críticos

## 11.1 Calidad sin causa raíz

```text
calidad_sin_causa_raiz: 896 registros
```

Este es uno de los problemas más importantes.

Una incidencia sin causa raíz impide saber por qué se ha producido el defecto.

Impacto en negocio:

* Dificulta reducir defectos repetitivos.
* Impide priorizar acciones correctivas.
* Complica saber si el problema viene de máquina, operario, proveedor, material o proceso.
* Reduce la capacidad del departamento de calidad para prevenir incidencias futuras.

Uso en Power BI:

* KPI de incidencias sin causa raíz.
* Filtro de incidencias pendientes de análisis.
* Ranking de coste asociado a incidencias sin causa raíz.

---

## 11.2 Ventas sin producto

```text
ventas_sin_producto: 187 registros
```

Estas líneas de venta no tienen producto asociado.

Impacto en negocio:

* No se puede analizar la facturación por producto.
* No se puede calcular correctamente la rentabilidad por familia.
* Se pierde trazabilidad entre venta, producción, calidad y margen.
* Puede ocultar productos problemáticos o pedidos mal registrados.

Uso en Power BI:

* KPI de líneas de venta sin producto.
* Filtro de ventas pendientes de revisión.
* Control de calidad del dato comercial.

---

## 11.3 Averías abiertas

```text
mantenimiento_averia_abierta: 548 registros
```

Estas averías no tienen fecha de cierre o siguen en estado abierto, pendiente o en curso.

Impacto en negocio:

* Impiden calcular correctamente el tiempo total de parada.
* Distorsionan indicadores de mantenimiento.
* Pueden ocultar problemas reales de disponibilidad de máquinas.
* Dificultan calcular MTTR y coste real de reparación.

Uso en Power BI:

* KPI de averías abiertas.
* Tabla de averías pendientes.
* Ranking de máquinas con más averías abiertas.

---

## 11.4 Movimientos de almacén sin material

```text
almacen_sin_material: 190 registros
```

Estos movimientos no tienen material asociado.

Impacto en negocio:

* Rompen la trazabilidad de inventario.
* Dificultan analizar entradas, salidas y consumos.
* Impiden calcular correctamente el valor estimado del movimiento.
* Pueden afectar al control de stock.

Uso en Power BI:

* KPI de movimientos sin material.
* Control de trazabilidad de inventario.
* Filtro de registros pendientes de corrección.

---

## 11.5 Compras entregadas tarde

```text
compras_entrega_tarde: 2585 registros
```

Este control no es solo un problema de dato, sino un indicador operativo.

Impacto en negocio:

* Puede provocar retrasos en producción.
* Puede generar compras urgentes.
* Aumenta el riesgo de rotura de stock.
* Permite evaluar el rendimiento de proveedores.

Uso en Power BI:

* KPI de entregas tarde.
* Ranking de proveedores con más retrasos.
* Evolución mensual del cumplimiento de proveedor.

---

## 11.6 Ventas con margen negativo

```text
ventas_margen_negativo: 322 registros
```

Son líneas de venta donde el margen estimado es inferior a cero.

Impacto en negocio:

* Identifica pedidos potencialmente no rentables.
* Puede señalar errores de precio, coste mal estimado o descuentos excesivos.
* Ayuda a ventas y finanzas a revisar condiciones comerciales.
* Puede indicar productos que requieren revisión de tarifa.

Uso en Power BI:

* KPI de líneas con margen negativo.
* Ranking de productos con pérdida.
* Ranking de clientes con margen bajo.
* Análisis de impacto económico por familia.

---

## 11.7 Producción con scrap

```text
produccion_con_scrap: 4329 registros
```

La mayoría de partes de producción presentan algún nivel de scrap.

Impacto en negocio:

* Indica que la merma es un problema relevante.
* Permite analizar qué máquinas, turnos o productos generan más desperdicio.
* Ayuda a priorizar mejoras de proceso.
* Puede conectar con problemas de calidad, mantenimiento o proveedor.

Uso en Power BI:

* KPI de kg de scrap.
* % scrap sobre material consumido.
* Ranking de máquinas con mayor scrap.
* Evolución mensual de la merma.

---

## 11.8 Producción sin orden de fabricación

```text
produccion_sin_of: 336 registros
```

Estos partes de producción no tienen orden de fabricación asociada.

Impacto en negocio:

* Dificulta conectar producción con producto, cliente o pedido.
* Reduce la trazabilidad del coste industrial.
* Complica analizar rentabilidad por producto.
* Puede indicar partes introducidos manualmente o errores en captura de datos.

Uso en Power BI:

* KPI de partes sin OF.
* Control de trazabilidad de producción.
* Filtro de partes pendientes de revisión.

---

## 12. Validación de vistas limpias

Después de crear las vistas limpias, se validó que las vistas transaccionales devolvieran el volumen esperado.

Consulta de validación:

```sql
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
```

Resultado esperado:

| Vista                   | Filas esperadas |
| ----------------------- | --------------: |
| vw_almacen_limpio       |            5000 |
| vw_calidad_limpia       |            2600 |
| vw_compras_limpias      |            4500 |
| vw_mantenimiento_limpio |            2600 |
| vw_produccion_limpia    |            5000 |
| vw_ventas_limpias       |            5000 |

---

## 13. Qué problemas se corrigen y cuáles se mantienen

## 13.1 Problemas corregidos mediante normalización

Se corrigen problemas de formato y consistencia:

* Mayúsculas y minúsculas.
* Espacios sobrantes.
* Códigos con guiones, espacios o barras bajas.
* Estados equivalentes.
* Unidades de medida mezcladas.
* Nombres abreviados.
* Proveedores escritos de forma diferente.
* Países y provincias con variantes.

## 13.2 Problemas no eliminados

No se eliminan registros con problemas críticos.

En lugar de borrar datos, se marcan con flags.

Ejemplos:

* Ventas sin producto.
* Partes sin OF.
* Movimientos sin material.
* Averías abiertas.
* Incidencias sin causa raíz.
* Márgenes negativos.
* Compras tardías.
* Producción con scrap.

Esto es importante porque esos registros contienen información útil para el negocio.

---

## 14. Impacto del enfoque de limpieza

La limpieza SQL permite transformar una base operativa sucia en una capa analítica sin perder trazabilidad.

Ventajas:

* Se conserva el dato original.
* Se crea una capa limpia reutilizable.
* Se documentan las reglas de limpieza.
* Se generan indicadores de calidad del dato.
* Se preparan las vistas para Power BI.
* Se transforman errores operativos en alertas de negocio.

---

## 15. Riesgos y limitaciones

## 15.1 Datos simulados

Los datos han sido generados para simular un entorno industrial realista.

No representan una empresa real ni contienen información confidencial.

## 15.2 Relaciones imperfectas

Algunas relaciones no son perfectas porque el modelo reproduce un entorno operativo con datos manuales y sistemas heredados.

Esto afecta especialmente a:

* Calidad.
* Producción.
* Mantenimiento.
* Almacén.

## 15.3 Métricas estimadas

Algunas métricas se calculan de forma estimada:

* Coste de parada.
* Coste de mantenimiento.
* Margen estimado.
* Coste de no calidad.
* Valor estimado de movimientos de almacén.

Estas métricas son útiles para análisis, pero en un entorno real deberían validarse con finanzas y operaciones.

## 15.4 Campos sin relación perfecta

Algunos campos se relacionan mediante texto normalizado en lugar de claves numéricas.

Ejemplos:

* Máquina en calidad.
* Proveedor en calidad.
* Producto en calidad.
* Operario en producción.

Esto se mantiene porque es habitual en entornos industriales con datos procedentes de Excel o registros manuales.

---

## 16. Recomendaciones de mejora

Si Nortemec quisiera mejorar su calidad de datos, debería priorizar:

## 16.1 Gobierno del dato maestro

* Catálogo único de clientes.
* Catálogo único de productos.
* Catálogo único de proveedores.
* Catálogo único de máquinas.
* Catálogo único de materiales.

## 16.2 Validaciones en origen

* No permitir pedidos sin cliente.
* No permitir líneas sin producto.
* No permitir partes sin OF.
* No permitir movimientos sin material.
* Obligar a cerrar averías con fecha fin.
* Obligar a registrar causa raíz en incidencias cerradas.

## 16.3 Estandarización de nomenclaturas

* Estados cerrados y controlados.
* Unidades de medida normalizadas.
* Códigos únicos de máquina.
* Nombres únicos de proveedor.
* Catálogos desplegables en lugar de texto libre.

## 16.4 Seguimiento periódico de calidad del dato

Crear un dashboard de calidad del dato con KPIs como:

* % registros sin código.
* % pedidos sin cliente.
* % líneas sin producto.
* % incidencias sin causa raíz.
* % averías abiertas.
* % partes sin OF.
* % movimientos sin material.

---

## 17. Conclusión

La base de datos de Nortemec simula un entorno industrial realista, con datos suficientes para construir análisis de negocio pero también con problemas típicos de calidad del dato.

La limpieza realizada no busca ocultar esos problemas. Al contrario, los convierte en indicadores medibles.

Gracias a las vistas limpias, el proyecto consigue:

* Mantener intactas las tablas brutas.
* Crear una capa analítica limpia.
* Normalizar datos clave.
* Corregir duplicidades de análisis.
* Detectar problemas críticos.
* Preparar los datos para Power BI.
* Convertir errores de calidad del dato en oportunidades de mejora operativa.

Este enfoque demuestra una competencia clave de un Data Analyst: no solo limpiar datos, sino entender qué significan esos problemas para el negocio y cómo transformarlos en información accionable.

