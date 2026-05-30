# Ampliación realista de datos — Nortemec Industrial Analytics

## Objetivo

Esta fase añade nuevas tablas y vistas al proyecto para simular situaciones reales de una empresa industrial.

Hasta ahora el proyecto analizaba datos operativos principales. Con esta ampliación, se incorporan elementos más cercanos a la gestión diaria de una fábrica:

- Objetivos de negocio.
- Costes reales.
- Stock mínimo y reposición.
- Acciones correctivas.
- Mantenimiento preventivo.
- Objetivos comerciales.
- Calendario laboral.

---

## 1. Objetivos mensuales

### Archivo SQL

```text
06_add_business_targets.sql
```

### Tabla creada

```text
objetivos_mensuales
```

### Vista limpia creada

```text
vw_objetivos_mensuales
```

### Objetivo del bloque

Permitir el análisis **real vs objetivo** por área de negocio.

### Áreas incluidas

```text
Ventas
Producción
Calidad
Compras
Mantenimiento
```

### Campos principales

```text
fecha_mes
area
objetivo_facturacion
objetivo_margen_pct
objetivo_scrap_pct
objetivo_entregas_tarde_pct
objetivo_coste_no_calidad
objetivo_horas_parada
```

### Preguntas que permite responder

- ¿Estamos por encima o por debajo del objetivo mensual?
- ¿El margen real cumple el objetivo?
- ¿El scrap real supera el objetivo?
- ¿Las entregas tarde están dentro del límite?
- ¿El coste de no calidad supera lo previsto?
- ¿Las horas de parada superan el objetivo?

---

## 2. Coste real vs coste estimado

### Archivo SQL

```text
07_add_real_costs.sql
```

### Tabla creada

```text
costes_reales_of
```

### Vista limpia creada

```text
vw_costes_reales_of
```

### Objetivo del bloque

Comparar el coste estimado de las órdenes de fabricación con el coste real final.

### Campos principales

```text
num_of
pedido_id
producto_id
fecha_cierre
coste_estimado
coste_real
horas_estimadas
horas_reales
desviacion_coste
desviacion_coste_pct
desviacion_horas
desviacion_horas_pct
motivo_desviacion
criticidad_desviacion_coste
criticidad_desviacion_horas
```

### Preguntas que permite responder

- ¿Qué órdenes tuvieron sobrecoste?
- ¿Qué productos acumulan más desviación?
- ¿Qué familias concentran más sobrecoste?
- ¿Qué motivos explican las desviaciones?
- ¿Qué órdenes fueron rentables en presupuesto pero no en realidad?

---

## 3. Stock mínimo y stock actual

### Archivo SQL

```text
08_add_stock_control.sql
```

### Tabla creada

```text
stock_materiales
```

### Vista limpia creada

```text
vw_stock_materiales
```

### Objetivo del bloque

Crear una capa de control de stock para detectar riesgo de rotura, necesidad de reposición y cobertura insuficiente.

### Campos principales

```text
material_id
fecha_stock
stock_actual
stock_minimo
punto_reorden
lead_time_proveedor
consumo_medio_diario
dias_cobertura
estado_riesgo_stock
criticidad_stock
valor_stock_actual
valor_necesario_reponer
```

### Preguntas que permite responder

- ¿Qué materiales están por debajo del mínimo?
- ¿Qué materiales deben reponerse?
- ¿Qué materiales tienen cobertura insuficiente?
- ¿Cuál es el valor económico necesario para reponer?
- ¿Qué proveedores o tipos de material concentran más riesgo?

---

## 4. Acciones correctivas de calidad

### Archivo SQL

```text
09_add_quality_corrective_actions.sql
```

### Tabla creada

```text
acciones_correctivas_calidad
```

### Vista limpia creada

```text
vw_acciones_correctivas_calidad
```

### Objetivo del bloque

No limitar el análisis de calidad a detectar incidencias, sino también analizar si se están cerrando y si las acciones son efectivas.

### Campos principales

```text
incidencia_id
fecha_apertura
accion_correctiva
fecha_cierre
responsable_accion
estado_accion
efectividad_accion
coste_accion
dias_cierre
estado_plazo_cierre
```

### Preguntas que permite responder

- ¿Cuántas acciones correctivas están abiertas?
- ¿Cuántas acciones se cierran tarde?
- ¿Qué acciones no han sido efectivas?
- ¿Qué responsables acumulan más acciones abiertas?
- ¿Qué coste tienen las acciones correctivas?

---

## 5. Mantenimiento preventivo

### Archivo SQL

```text
10_add_preventive_maintenance.sql
```

### Tabla creada

```text
mantenimiento_preventivo
```

### Vista limpia creada

```text
vw_mantenimiento_preventivo
```

### Objetivo del bloque

Medir si el mantenimiento preventivo se cumple y relacionarlo con el análisis de averías y paradas.

### Campos principales

```text
maquina
tipo_mantenimiento
preventivo_correctivo
fecha_mantenimiento_programado
fecha_mantenimiento_real
cumplimiento_preventivo
tecnico_responsable
coste_mantenimiento
horas_intervencion
estado_plazo_preventivo
```

### Preguntas que permite responder

- ¿Qué preventivos se realizaron en plazo?
- ¿Qué máquinas tienen más incumplimientos?
- ¿Qué coste tiene el preventivo?
- ¿Qué preventivos no se realizaron?
- ¿Las máquinas fallan porque no se hace preventivo?

---

## 6. Objetivos comerciales por cliente

### Archivo SQL

```text
11_add_customer_targets.sql
```

### Tabla creada

```text
objetivos_clientes
```

### Vista limpia creada

```text
vw_objetivos_clientes
```

### Objetivo del bloque

Enriquecer el análisis comercial con objetivo, potencial, riesgo y tipo de contrato por cliente.

### Campos principales

```text
cliente_id
fecha_revision
objetivo_cliente
potencial_cliente
gap_potencial_objetivo
gap_potencial_objetivo_pct
riesgo_cliente
tipo_contrato
responsable_comercial
prioridad_comercial
recomendacion_comercial
```

### Preguntas que permite responder

- ¿Qué clientes tienen mayor potencial?
- ¿Qué clientes tienen riesgo comercial alto?
- ¿Qué clientes combinan alto potencial y alto riesgo?
- ¿Qué clientes deben priorizarse?
- ¿Qué tipo de contrato genera mejores oportunidades?

---

## 7. Calendario laboral industrial

### Archivo SQL

```text
12_add_working_calendar.sql
```

### Tabla creada

```text
calendario_laboral
```

### Vista limpia creada

```text
vw_calendario_laboral
```

### Objetivo del bloque

Añadir contexto industrial al calendario para analizar producción, entregas y mantenimiento teniendo en cuenta días laborables, festivos, turnos y semanas de producción.

### Campos principales

```text
fecha
anio
mes
dia_semana
nombre_dia
es_laborable
es_festivo
tipo_dia
turno
semana_produccion
dias_habiles_mes
```

### Preguntas que permite responder

- ¿Cuántos días productivos tiene cada mes?
- ¿Qué meses tienen menos días hábiles?
- ¿Cómo afectan festivos y fines de semana a entregas o producción?
- ¿Qué semanas de producción concentran actividad?
- ¿Qué impacto tiene el calendario laboral en la operación?

---

## Resultado de la fase

Esta ampliación convierte el proyecto en una solución más realista y completa.

El proyecto ya no analiza solo operaciones, sino también:

- Objetivos.
- Desviaciones.
- Riesgos.
- Cumplimiento.
- Potencial comercial.
- Contexto laboral.

Esto permite construir informes Power BI más cercanos a los que una empresa industrial utilizaría para tomar decisiones.
