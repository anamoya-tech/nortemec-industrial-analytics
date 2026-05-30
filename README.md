# nortemec-industrial-analytics
Proyecto end-to-end de analítica industrial con PostgreSQL, limpieza SQL, modelado de datos y dashboards en Power BI.
-----------------------------------------------
# Nortemec Industrial Analytics — Actualización del proyecto

## Descripción breve

**Nortemec Industrial Analytics** es un proyecto de analítica industrial construido con PostgreSQL, SQL y Power BI.  
El objetivo es simular un entorno real de una empresa industrial para analizar ventas, rentabilidad, producción, calidad, compras, almacén y mantenimiento.

En esta actualización se ha ampliado el proyecto con nuevos datos y un modelo Power BI más realista.

---

## Qué se ha añadido

Se han incorporado nuevas tablas y vistas para enriquecer el análisis:

```text
OBJETIVOS_MENSUALES
COSTES_REALES_OF
STOCK_MATERIALES
ACCIONES_CORRECTIVAS_CALIDAD
MANTENIMIENTO_PREVENTIVO
OBJETIVOS_CLIENTES
CALENDARIO_LABORAL
```

Estas tablas permiten analizar:

- Real vs objetivo.
- Coste real vs coste estimado.
- Riesgo de rotura de stock.
- Acciones correctivas de calidad.
- Cumplimiento de mantenimiento preventivo.
- Potencial y riesgo comercial de clientes.
- Impacto del calendario laboral en la operación.

---

## Modelo Power BI

El modelo Power BI se ha ampliado siguiendo una regla clara:

> Las tablas principales de hechos se conectan a calendario.  
> Las tablas auxiliares se conectan a dimensiones o tablas padre para evitar rutas ambiguas.

Relaciones principales:

```text
CALENDARIO → VENTAS
CALENDARIO → PRODUCCION
CALENDARIO → CALIDAD
CALENDARIO → COMPRAS
CALENDARIO → ALMACEN
CALENDARIO → MANTENIMIENTO
CALENDARIO → OBJETIVOS_MENSUALES
CALENDARIO → CALENDARIO_LABORAL

CLIENTES → VENTAS
CLIENTES → OBJETIVOS_CLIENTES

PRODUCTOS → VENTAS
PRODUCTOS → PRODUCCION
PRODUCTOS → COSTES_REALES_OF

MATERIALES → COMPRAS
MATERIALES → ALMACEN
MATERIALES → STOCK_MATERIALES

CALIDAD → ACCIONES_CORRECTIVAS_CALIDAD

Dim_Maquinas → PRODUCCION
Dim_Maquinas → MANTENIMIENTO
Dim_Maquinas → MANTENIMIENTO_PREVENTIVO
```

---

## Informe Power BI

Se ha comenzado el primer informe especializado:

```text
Informe 1 — Rentabilidad y margen
```

### Página 1 — Resumen Ejecutivo de Rentabilidad

Pregunta principal:

> ¿Está Nortemec vendiendo con margen suficiente?

La página incluye:

- KPIs de facturación, margen, pérdida y pedidos problemáticos.
- KPI de `% Margen` con semáforo visual.
- Evolución mensual de facturación y margen.
- Top productos con pérdida estimada.
- Top clientes con pérdida estimada.
- Filtros por fecha, familia, cliente y sector.

---

## Estado del proyecto

```text
Fase SQL: completada
Fase de ampliación de datos: completada
Fase de modelado Power BI: completada
Informe 1 — Página 1: 90% completada
```

---

## Próximos pasos

- Finalizar la Página 1 con ajustes visuales menores.
- Crear la Página 2 — Productos.
- Analizar margen por producto, familia y sobrecostes reales.
- Seguir creando medidas DAX solo cuando sean necesarias para cada visual.
