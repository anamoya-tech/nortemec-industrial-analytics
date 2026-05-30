# Actualización del proyecto — Nortemec Industrial Analytics

## Estado de la actualización

Esta actualización amplía el proyecto **Nortemec Industrial Analytics** para convertirlo en una solución más cercana a un entorno real de empresa industrial.

El proyecto deja de ser únicamente un análisis operativo basado en ventas, producción, calidad, compras, almacén y mantenimiento, y pasa a incluir elementos más propios de una compañía industrial real:

- Objetivos mensuales de negocio.
- Costes reales frente a costes estimados.
- Control de stock y riesgo de rotura.
- Acciones correctivas de calidad.
- Mantenimiento preventivo.
- Objetivos comerciales por cliente.
- Calendario laboral industrial.
- Modelo Power BI ampliado.
- Primera página del informe de rentabilidad y margen.

---

## Objetivo de la actualización

El objetivo principal ha sido aumentar el realismo del proyecto para que pueda responder preguntas de negocio más completas, como:

- ¿Estamos cumpliendo los objetivos mensuales?
- ¿Qué productos generan más pérdida?
- ¿Qué clientes concentran más margen negativo?
- ¿Qué órdenes tienen sobrecoste real?
- ¿Qué materiales tienen riesgo de rotura de stock?
- ¿Las acciones correctivas de calidad se cierran y son efectivas?
- ¿Se cumple el mantenimiento preventivo?
- ¿Qué clientes tienen mayor potencial o riesgo comercial?
- ¿Cómo afectan los días laborables al análisis operativo?

---

## Nuevos bloques añadidos

Se han añadido siete bloques nuevos de datos al proyecto:

| Bloque | Archivo SQL | Objetivo |
|---|---|---|
| Objetivos mensuales | `06_add_business_targets.sql` | Comparar real vs objetivo por área |
| Costes reales | `07_add_real_costs.sql` | Analizar coste real vs coste estimado |
| Stock | `08_add_stock_control.sql` | Detectar riesgo de rotura y reposición |
| Acciones correctivas | `09_add_quality_corrective_actions.sql` | Medir cierre y efectividad de acciones |
| Mantenimiento preventivo | `10_add_preventive_maintenance.sql` | Analizar cumplimiento preventivo |
| Objetivos clientes | `11_add_customer_targets.sql` | Añadir potencial, riesgo y contrato por cliente |
| Calendario laboral | `12_add_working_calendar.sql` | Enriquecer el calendario con lógica industrial |

---

## Nuevas tablas incorporadas

```text
objetivos_mensuales
costes_reales_of
stock_materiales
acciones_correctivas_calidad
mantenimiento_preventivo
objetivos_clientes
calendario_laboral
```

---

## Nuevas vistas limpias incorporadas

```text
vw_objetivos_mensuales
vw_costes_reales_of
vw_stock_materiales
vw_acciones_correctivas_calidad
vw_mantenimiento_preventivo
vw_objetivos_clientes
vw_calendario_laboral
```

---

## Impacto en el proyecto

Con esta ampliación, el proyecto gana profundidad en tres niveles:

### 1. Nivel estratégico

Permite comparar los resultados reales contra objetivos de dirección:

- Facturación.
- Margen.
- Scrap.
- Entregas tarde.
- Coste de no calidad.
- Horas de parada.

### 2. Nivel operativo

Permite analizar procesos internos con más detalle:

- Sobrecostes de fabricación.
- Riesgos de stock.
- Acciones correctivas.
- Cumplimiento preventivo.
- Calendario laboral.

### 3. Nivel comercial

Permite enriquecer el análisis de clientes:

- Objetivo comercial.
- Potencial.
- Riesgo.
- Tipo de contrato.
- Prioridad comercial.

---

## Estado actual del proyecto

| Fase | Estado |
|---|---|
| Base de datos PostgreSQL | Completada |
| Limpieza SQL | Completada |
| Consultas SQL de análisis | Completada |
| Ampliación realista de datos | Completada |
| Modelo Power BI ampliado | Completado |
| Página 1 del informe de rentabilidad | 90% completada |
| Medidas DAX ampliadas | Se crearán según necesidad |
| Resto de páginas Power BI | Pendiente |

---

## Próximo paso recomendado

El siguiente paso será continuar con el **Informe 1 — Rentabilidad y margen**, desarrollando la página:

```text
02 Productos
```

Esta página debe profundizar en:

- Margen por producto.
- Margen por familia.
- Productos con pérdida.
- Costes reales vs costes estimados.
- Sobrecostes por producto.
- Motivos de desviación.
