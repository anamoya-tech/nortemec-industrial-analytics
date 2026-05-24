# Fase 5 — Medidas DAX

En esta fase se crearon las medidas DAX necesarias para convertir el modelo de Power BI en un dashboard analítico con KPIs industriales.

El objetivo fue construir indicadores para analizar rentabilidad, producción, calidad, compras, almacén y mantenimiento.

---

## Tabla de medidas

Se creó una tabla específica llamada:

```text
MEDIDAS
```

Esta tabla se utiliza para centralizar todas las medidas DAX del modelo y mantener el panel de campos más ordenado.

---

## 1. Medidas de ventas y rentabilidad

Se crearon medidas para analizar la rentabilidad comercial de Nortemec.

### Facturación total

```DAX
Facturación total =
SUM ( VENTAS[importe_linea_limpio] )
```

### Coste estimado total

```DAX
Coste estimado total =
SUM ( VENTAS[coste_estimado] )
```

### Margen estimado

```DAX
Margen estimado =
SUM ( VENTAS[margen_estimado_limpio] )
```

### % Margen

```DAX
% Margen =
DIVIDE (
    [Margen estimado],
    [Facturación total]
)
```

### Unidades vendidas

```DAX
Unidades vendidas =
SUM ( VENTAS[cantidad] )
```

### Pedidos

```DAX
Pedidos =
DISTINCTCOUNT ( VENTAS[pedido_id] )
```

### Pedidos retrasados

```DAX
Pedidos retrasados =
CALCULATE (
    DISTINCTCOUNT ( VENTAS[pedido_id] ),
    VENTAS[flag_entrega_tarde] = TRUE()
)
```

### % Pedidos retrasados

```DAX
% Pedidos retrasados =
DIVIDE (
    [Pedidos retrasados],
    [Pedidos]
)
```

### Líneas con margen negativo

```DAX
Líneas con margen negativo =
CALCULATE (
    COUNTROWS ( VENTAS ),
    VENTAS[flag_margen_negativo] = TRUE()
)
```

### Pérdida por margen negativo

```DAX
Pérdida por margen negativo =
CALCULATE (
    ABS ( SUM ( VENTAS[margen_estimado_limpio] ) ),
    VENTAS[flag_margen_negativo] = TRUE()
)
```

Estas medidas permiten responder preguntas como:

* ¿Cuánto factura la empresa?
* ¿Cuál es el margen estimado?
* ¿Qué porcentaje de margen tiene el negocio?
* ¿Cuántos pedidos se entregan tarde?
* ¿Qué líneas de venta generan pérdidas?

---

## 2. Medidas de producción

Se crearon KPIs para analizar rendimiento productivo, rechazo, scrap y paradas.

### Unidades fabricadas

```DAX
Unidades fabricadas =
SUM ( PRODUCCION[unidades_ok] )
```

### Unidades rechazadas

```DAX
Unidades rechazadas =
SUM ( PRODUCCION[unidades_nok_limpias] )
```

### Unidades totales produccion

```DAX
Unidades totales produccion =
SUM ( PRODUCCION[unidades_totales] )
```

### % Rechazo

```DAX
% Rechazo =
DIVIDE (
    [Unidades rechazadas],
    [Unidades totales produccion]
)
```

### Horas trabajadas

```DAX
Horas trabajadas =
SUM ( PRODUCCION[horas_trabajadas] )
```

### Kg consumidos

```DAX
Kg consumidos =
SUM ( PRODUCCION[kg_consumidos] )
```

### Kg scrap

```DAX
Kg scrap =
SUM ( PRODUCCION[kg_scrap_limpio] )
```

### % Scrap

```DAX
% Scrap =
DIVIDE (
    [Kg scrap],
    [Kg consumidos]
)
```

### Partes produccion

```DAX
Partes produccion =
COUNTROWS ( PRODUCCION )
```

### Partes con scrap

```DAX
Partes con scrap =
CALCULATE (
    COUNTROWS ( PRODUCCION ),
    PRODUCCION[flag_tiene_scrap] = TRUE()
)
```

### % Partes con scrap

```DAX
% Partes con scrap =
DIVIDE (
    [Partes con scrap],
    [Partes produccion]
)
```

### Partes con parada

```DAX
Partes con parada =
CALCULATE (
    COUNTROWS ( PRODUCCION ),
    PRODUCCION[flag_tiene_parada] = TRUE()
)
```

### % Partes con parada

```DAX
% Partes con parada =
DIVIDE (
    [Partes con parada],
    [Partes produccion]
)
```

### Horas parada produccion

```DAX
Horas parada produccion =
SUM ( PRODUCCION[parada_horas_limpio] )
```

### Coste teorico horas

```DAX
Coste teorico horas =
SUM ( PRODUCCION[coste_teorico_horas] )
```

### Ordenes fabricacion

```DAX
Ordenes fabricacion =
DISTINCTCOUNT ( PRODUCCION[num_of_limpio] )
```

### Ordenes retrasadas

```DAX
Ordenes retrasadas =
CALCULATE (
    DISTINCTCOUNT ( PRODUCCION[num_of_limpio] ),
    PRODUCCION[flag_of_retrasada] = TRUE()
)
```

### % Ordenes retrasadas

```DAX
% Ordenes retrasadas =
DIVIDE (
    [Ordenes retrasadas],
    [Ordenes fabricacion]
)
```

Estas medidas permiten analizar:

* Volumen de producción.
* Unidades rechazadas.
* Porcentaje de rechazo.
* Material consumido.
* Kg de scrap.
* Porcentaje de scrap.
* Partes con parada.
* Órdenes de fabricación retrasadas.

---

## 3. Medidas de calidad

Se crearon medidas para evaluar incidencias, reprocesos y coste de no calidad.

### Incidencias calidad

```DAX
Incidencias calidad =
COUNTROWS ( CALIDAD )
```

### Coste no calidad

```DAX
Coste no calidad =
SUM ( CALIDAD[coste_no_calidad_estimado] )
```

### Unidades afectadas calidad

```DAX
Unidades afectadas calidad =
SUM ( CALIDAD[unidades_afectadas] )
```

### Coste medio incidencia

```DAX
Coste medio incidencia =
DIVIDE (
    [Coste no calidad],
    [Incidencias calidad]
)
```

### Incidencias sin causa raiz

```DAX
Incidencias sin causa raiz =
CALCULATE (
    COUNTROWS ( CALIDAD ),
    CALIDAD[flag_sin_causa_raiz] = TRUE()
)
```

### % Incidencias sin causa raiz

```DAX
% Incidencias sin causa raiz =
DIVIDE (
    [Incidencias sin causa raiz],
    [Incidencias calidad]
)
```

### Incidencias abiertas

```DAX
Incidencias abiertas =
CALCULATE (
    COUNTROWS ( CALIDAD ),
    CALIDAD[flag_incidencia_abierta] = TRUE()
)
```

### % Incidencias abiertas

```DAX
% Incidencias abiertas =
DIVIDE (
    [Incidencias abiertas],
    [Incidencias calidad]
)
```

### Incidencias con reproceso

```DAX
Incidencias con reproceso =
CALCULATE (
    COUNTROWS ( CALIDAD ),
    CALIDAD[flag_requiere_reproceso] = TRUE()
)
```

### % Incidencias con reproceso

```DAX
% Incidencias con reproceso =
DIVIDE (
    [Incidencias con reproceso],
    [Incidencias calidad]
)
```

### Incidencias gravedad alta

```DAX
Incidencias gravedad alta =
CALCULATE (
    COUNTROWS ( CALIDAD ),
    CALIDAD[flag_gravedad_alta] = TRUE()
)
```

### Coste no calidad alto

```DAX
Coste no calidad alto =
CALCULATE (
    [Coste no calidad],
    CALIDAD[flag_coste_alto] = TRUE()
)
```

Estas medidas ayudan a responder:

* ¿Cuántas incidencias de calidad existen?
* ¿Cuánto cuesta la no calidad?
* ¿Qué porcentaje de incidencias no tiene causa raíz?
* ¿Cuántas incidencias siguen abiertas?
* ¿Qué parte de la calidad requiere reproceso?

---

## 4. Medidas de compras y proveedores

Se crearon medidas para analizar gasto, cumplimiento de entregas e incidencias de proveedor.

### Compras totales

```DAX
Compras totales =
SUM ( COMPRAS[importe_total_limpio] )
```

### Cantidad pedida

```DAX
Cantidad pedida =
SUM ( COMPRAS[cantidad_pedida] )
```

### Cantidad recibida

```DAX
Cantidad recibida =
SUM ( COMPRAS[cantidad_recibida] )
```

### Diferencia cantidad compra

```DAX
Diferencia cantidad compra =
SUM ( COMPRAS[diferencia_cantidad] )
```

### Lineas compra

```DAX
Lineas compra =
COUNTROWS ( COMPRAS )
```

### Entregas tarde

```DAX
Entregas tarde =
CALCULATE (
    COUNTROWS ( COMPRAS ),
    COMPRAS[flag_entrega_tarde] = TRUE()
)
```

### % Entregas tarde

```DAX
% Entregas tarde =
DIVIDE (
    [Entregas tarde],
    [Lineas compra]
)
```

### Incidencias calidad proveedor

```DAX
Incidencias calidad proveedor =
CALCULATE (
    COUNTROWS ( COMPRAS ),
    COMPRAS[flag_incidencia_calidad] = TRUE()
)
```

### % Incidencias proveedor

```DAX
% Incidencias proveedor =
DIVIDE (
    [Incidencias calidad proveedor],
    [Lineas compra]
)
```

### Compras con precio alto

```DAX
Compras con precio alto =
CALCULATE (
    COUNTROWS ( COMPRAS ),
    COMPRAS[flag_precio_alto_vs_estandar] = TRUE()
)
```

### % Compras con precio alto

```DAX
% Compras con precio alto =
DIVIDE (
    [Compras con precio alto],
    [Lineas compra]
)
```

Estas medidas permiten detectar:

* Proveedores con retrasos.
* Materiales con mayor gasto.
* Diferencias entre cantidad pedida y recibida.
* Incidencias de calidad asociadas a proveedor.
* Compras con precio superior al coste estándar.

---

## 5. Medidas de almacén

Se crearon medidas para controlar movimientos, valor estimado y problemas de trazabilidad.

### Movimientos almacen

```DAX
Movimientos almacen =
COUNTROWS ( ALMACEN )
```

### Valor movimientos almacen

```DAX
Valor movimientos almacen =
SUM ( ALMACEN[valor_movimiento_estimado] )
```

### Cantidad movimientos almacen

```DAX
Cantidad movimientos almacen =
SUM ( ALMACEN[cantidad] )
```

### Movimientos sin material

```DAX
Movimientos sin material =
CALCULATE (
    COUNTROWS ( ALMACEN ),
    ALMACEN[flag_sin_material] = TRUE()
)
```

### % Movimientos sin material

```DAX
% Movimientos sin material =
DIVIDE (
    [Movimientos sin material],
    [Movimientos almacen]
)
```

### Movimientos altos

```DAX
Movimientos altos =
CALCULATE (
    COUNTROWS ( ALMACEN ),
    ALMACEN[flag_movimiento_alto] = TRUE()
)
```

### % Movimientos altos

```DAX
% Movimientos altos =
DIVIDE (
    [Movimientos altos],
    [Movimientos almacen]
)
```

Estas medidas permiten analizar:

* Volumen de movimientos de almacén.
* Valor estimado de entradas y salidas.
* Movimientos sin material asociado.
* Movimientos de cantidad elevada.

---

## 6. Medidas de mantenimiento

Se crearon KPIs para evaluar averías, paradas y coste de mantenimiento.

### Averias

```DAX
Averias =
COUNTROWS ( MANTENIMIENTO )
```

### Coste mantenimiento

```DAX
Coste mantenimiento =
SUM ( MANTENIMIENTO[coste_mantenimiento_estimado] )
```

### Horas parada

```DAX
Horas parada =
SUM ( MANTENIMIENTO[horas_parada] )
```

### Coste parada

```DAX
Coste parada =
SUM ( MANTENIMIENTO[coste_parada_estimado] )
```

### Averias abiertas

```DAX
Averias abiertas =
CALCULATE (
    COUNTROWS ( MANTENIMIENTO ),
    MANTENIMIENTO[flag_averia_abierta] = TRUE()
)
```

### % Averias abiertas

```DAX
% Averias abiertas =
DIVIDE (
    [Averias abiertas],
    [Averias]
)
```

### Paradas largas

```DAX
Paradas largas =
CALCULATE (
    COUNTROWS ( MANTENIMIENTO ),
    MANTENIMIENTO[flag_parada_larga] = TRUE()
)
```

### % Paradas largas

```DAX
% Paradas largas =
DIVIDE (
    [Paradas largas],
    [Averias]
)
```

### Coste medio averia

```DAX
Coste medio averia =
DIVIDE (
    [Coste mantenimiento],
    [Averias]
)
```

### Horas parada media

```DAX
Horas parada media =
DIVIDE (
    [Horas parada],
    [Averias]
)
```

### Coste mantenimiento alto

```DAX
Coste mantenimiento alto =
CALCULATE (
    [Coste mantenimiento],
    MANTENIMIENTO[flag_coste_mantenimiento_alto] = TRUE()
)
```

Estas medidas permiten responder:

* ¿Cuántas averías se registran?
* ¿Cuánto cuesta el mantenimiento?
* ¿Cuántas horas de parada hay?
* ¿Qué porcentaje de averías sigue abierto?
* ¿Qué averías generan paradas largas?
* ¿Cuál es el coste medio por avería?

---

## 7. Medidas de impacto económico

Se crearon medidas avanzadas para cuantificar pérdidas y priorizar decisiones.

### Coste total de perdidas

```DAX
Coste total de perdidas =
[Pérdida por margen negativo]
    + [Coste no calidad]
    + [Coste mantenimiento]
    + [Coste parada]
```

### Impacto scrap no calidad mantenimiento

```DAX
Impacto scrap no calidad mantenimiento =
[Coste no calidad]
    + [Coste mantenimiento]
    + [Coste parada]
```

### Impacto operativo total

```DAX
Impacto operativo total =
[Pérdida por margen negativo]
    + [Coste no calidad]
    + [Coste mantenimiento]
    + [Coste parada]
    + [Coste teorico horas]
```

Estas medidas combinan diferentes áreas de pérdida:

* Margen negativo.
* Coste de no calidad.
* Coste de mantenimiento.
* Coste de parada.
* Coste teórico de horas.

El objetivo es ofrecer una visión global del impacto económico de los problemas operativos.

---

## 8. Medidas de ranking

Se crearon rankings para identificar elementos críticos.

### Ranking clientes rentables

```DAX
Ranking clientes rentables =
RANKX (
    ALL ( CLIENTES[nombre_cliente_limpio] ),
    [Margen estimado],
    ,
    DESC,
    Dense
)
```

### Ranking productos margen negativo

```DAX
Ranking productos margen negativo =
RANKX (
    ALL ( PRODUCTOS[descripcion_limpia] ),
    [Pérdida por margen negativo],
    ,
    DESC,
    Dense
)
```

### Ranking maquinas criticas

```DAX
Ranking maquinas criticas =
RANKX (
    ALL ( Dim_Maquinas[codigo_maquina_limpio] ),
    [Coste mantenimiento] + [Coste parada] + [Kg scrap],
    ,
    DESC,
    Dense
)
```

### Ranking proveedores criticos

```DAX
Ranking proveedores criticos =
RANKX (
    ALL ( PROVEEDORES[nombre_proveedor_limpio] ),
    [Entregas tarde] + [Incidencias calidad proveedor],
    ,
    DESC,
    Dense
)
```

Estos rankings permiten priorizar:

* Clientes más rentables.
* Productos con mayor pérdida.
* Máquinas críticas.
* Proveedores problemáticos.

---

## Ajustes realizados durante la creación de medidas

Durante la creación de medidas se detectó un problema de sintaxis con nombres de tablas que contenían acentos, como:

```text
PRODUCCIÓN
ALMACÉN
```

Para evitar errores en DAX, se renombraron las tablas como:

```text
PRODUCCION
ALMACEN
```

Después de este cambio, las medidas se crearon correctamente usando los nuevos nombres de tabla.

---

## Formato aplicado a las medidas

Se aplicaron formatos adecuados según el tipo de indicador:

| Tipo de medida                                                           | Formato        |
| ------------------------------------------------------------------------ | -------------- |
| Facturación, costes, margen e impacto económico                          | Moneda €       |
| Porcentajes de margen, rechazo, scrap, entregas tarde y averías abiertas | Porcentaje     |
| Unidades, pedidos, incidencias y averías                                 | Número entero  |
| Horas y cantidades                                                       | Número decimal |

---

## Resultado de la fase

Con esta fase, el modelo de Power BI ya cuenta con una capa de medidas DAX preparada para construir el dashboard.

Estado:

```text
Fase 5 — Medidas DAX: COMPLETADA
```

El siguiente paso será diseñar las páginas del informe Power BI y construir visualizaciones orientadas a responder la pregunta central del proyecto:

```text
¿Dónde está perdiendo rentabilidad Nortemec dentro de su proceso industrial?
```
