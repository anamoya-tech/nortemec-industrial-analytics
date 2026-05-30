# Changelog — Nortemec Industrial Analytics

## Actualización: ampliación realista + modelo Power BI + página 1

### Añadido

- Nueva tabla `objetivos_mensuales`.
- Nueva vista `vw_objetivos_mensuales`.
- Consultas de validación real vs objetivo por área.
- Nueva tabla `costes_reales_of`.
- Nueva vista `vw_costes_reales_of`.
- Nuevas métricas de desviación de coste y horas.
- Nueva tabla `stock_materiales`.
- Nueva vista `vw_stock_materiales`.
- Nuevos flags de riesgo de stock.
- Nueva tabla `acciones_correctivas_calidad`.
- Nueva vista `vw_acciones_correctivas_calidad`.
- Nuevos campos de estado, efectividad y cierre de acciones.
- Nueva tabla `mantenimiento_preventivo`.
- Nueva vista `vw_mantenimiento_preventivo`.
- Nuevos flags de preventivo realizado, retrasado o incumplido.
- Nueva tabla `objetivos_clientes`.
- Nueva vista `vw_objetivos_clientes`.
- Nuevos campos de potencial, riesgo, contrato y prioridad comercial.
- Nueva tabla `calendario_laboral`.
- Nueva vista `vw_calendario_laboral`.
- Nuevos campos de día laborable, festivo, turno y semana de producción.
- Modelo Power BI ampliado con nuevas tablas.
- Página 1 del informe de rentabilidad y margen.

---

### Cambiado

- Se amplió el modelo Power BI para incluir nuevas tablas auxiliares.
- Se decidió mantener `CALENDARIO` conectado solo a hechos principales.
- Se evitó conectar tablas auxiliares a calendario cuando generaban rutas ambiguas.
- Se sustituyó el gráfico circular de clientes por barras horizontales en la Página 1.
- Se sustituyó la tabla/matriz inicial de la Página 1 por visuales más ejecutivos.
- Se añadió un KPI de `% Margen` con fondo semáforo.
- Se definió una paleta visual corporativa para Nortemec.

---

### Decisiones de modelado

- `COSTES_REALES_OF` se conecta únicamente con `PRODUCTOS`.
- `COSTES_REALES_OF` no se conecta con `CALENDARIO`.
- `COSTES_REALES_OF` no se conecta con `PRODUCCION`.
- `Dim_Ordenes` queda oculta y sin uso por ahora.
- `STOCK_MATERIALES` se conecta únicamente con `MATERIALES`.
- `ACCIONES_CORRECTIVAS_CALIDAD` se conecta con `CALIDAD`.
- `MANTENIMIENTO_PREVENTIVO` se conecta con `Dim_Maquinas`.
- `OBJETIVOS_CLIENTES` se conecta con `CLIENTES`.
- `CALENDARIO_LABORAL` se conecta con `CALENDARIO`.

---

### Problemas resueltos

- Rutas ambiguas entre tablas auxiliares y calendario.
- Relación problemática entre costes reales, producción y calendario.
- Duplicidades o relaciones no recomendadas en tablas de detalle.
- Exceso de carga visual en la primera página del informe.
- Gráfico circular poco útil para comparar clientes con pérdidas similares.

---

### Estado actual

```text
Base de datos PostgreSQL: completada
Vistas limpias SQL: completadas
Ampliación realista de datos: completada
Modelo Power BI ampliado: completado
Informe 1 — Página 1: 90% completada
```

---

### Próximos pasos

- Finalizar ajustes visuales menores de la Página 1.
- Crear Página 2 — Productos.
- Incorporar análisis de costes reales por producto y familia.
- Crear medidas DAX únicamente cuando sean necesarias para cada visual.
- Continuar documentando cada avance en Markdown.
