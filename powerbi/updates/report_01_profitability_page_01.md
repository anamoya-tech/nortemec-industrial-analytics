# Informe 1 — Rentabilidad y margen

## Página 1 — Resumen Ejecutivo de Rentabilidad

## Pregunta de negocio

> ¿Está Nortemec vendiendo con margen suficiente?

El objetivo de esta primera página es ofrecer una visión ejecutiva rápida sobre la rentabilidad general de la empresa, detectando si existe margen positivo, cuánto se está perdiendo por margen negativo y dónde se concentran los principales problemas.

---

## Enfoque de la página

Se decidió que la primera página no debía estar sobrecargada con tablas o matrices detalladas.

Por eso se planteó como una página de **resumen ejecutivo**, centrada en:

- KPIs principales.
- Evolución mensual.
- Productos con mayor pérdida.
- Clientes con mayor pérdida.
- Lectura rápida para dirección.

Las tablas y matrices de detalle se reservarán para páginas posteriores del informe.

---

## Estructura final de la página

```text
Menú lateral
Cabecera superior con logo
Filtros principales
Tarjetas KPI
Gráfico principal de evolución
Gráficos inferiores de diagnóstico
```

---

## Menú lateral

Se creó un menú lateral en color azul corporativo para navegar entre las secciones del informe.

Páginas incluidas:

```text
01 Resumen
02 Productos
03 Clientes
04 Pedidos
05 Objetivos
06 Alertas
```

También se integró el logo blanco de **NORTEMEC** en la parte superior derecha del dashboard, manteniendo una estética industrial y profesional.

---

## Paleta visual utilizada

Se eligió una identidad visual acorde a una empresa industrial B2B:

```text
Azul acero:        #1F3A5F
Fondo claro:       #F4F6F8
Tarjetas:          #FFFFFF
Texto principal:   #2F3437
Azul gráfico:      #4A90E2
Rojo crítico:      #C62828
Naranja riesgo:    #EF6C00
Amarillo aviso:    #FFD54F
Verde correcto:    #2E7D32
```

El diseño busca transmitir:

```text
industria
precisión
seriedad
claridad ejecutiva
alertas visuales
```

---

## Filtros añadidos

En la parte superior se añadieron filtros para permitir analizar la rentabilidad desde distintos enfoques:

```text
Fecha
Familia
Cliente
Sector
```

Estos filtros permiten que la página responda de forma dinámica según el periodo, la familia de producto, el cliente o el sector seleccionado.

---

## KPIs principales

Se añadieron cinco tarjetas KPI:

```text
Facturación total
Margen estimado
% Margen
Pérdida margen negativo
Pedidos problemáticos
```

Estos KPIs responden rápidamente a:

```text
¿Cuánto vendemos?
¿Cuánto margen generamos?
¿Qué rentabilidad tenemos?
¿Cuánto estamos perdiendo?
¿Cuántos pedidos presentan problemas?
```

---

## Tarjeta semáforo de % Margen

Se decidió que la tarjeta de **% Margen** cambiara el color de fondo en función del nivel de rentabilidad.

### Medida DAX utilizada

```DAX
Color fondo % margen =
SWITCH (
    TRUE(),
    [% Margen] < 0, "#C62828",
    [% Margen] < 0.10, "#EF6C00",
    [% Margen] < 0.20, "#FFD54F",
    [% Margen] >= 0.20, "#2E7D32",
    "#7A8691"
)
```

### Interpretación

```text
< 0 %        rojo      pérdida
0 % - 10 %   naranja   margen bajo
10 % - 20 %  amarillo  margen medio
>= 20 %      verde     margen sano
```

Con el margen actual alrededor del **18,66 %**, la tarjeta aparece en amarillo, indicando que la rentabilidad es positiva pero mejorable.

---

## Gráfico principal

Se añadió un gráfico combinado para mostrar la evolución mensual:

```text
Evolución mensual de facturación y margen
```

Visual utilizado:

```text
Columnas + línea
```

Campos:

```text
Columnas: Facturación total
Línea: % Margen
Eje: Año-Mes / jerarquía temporal
```

Este gráfico permite detectar si la empresa está aumentando facturación, perdiendo margen o manteniendo una rentabilidad estable en el tiempo.

---

## Drill temporal

Se planteó el uso de una jerarquía temporal para poder analizar la evolución en distintos niveles:

```text
Año
Año-Trimestre
Año-Mes
Día
```

Esto permite navegar desde una visión general anual hasta un detalle más granular usando las opciones de drill down de Power BI.

---

## Gráficos inferiores

Inicialmente se había planteado usar una tabla y una matriz, pero se decidió simplificar la página.

Se sustituyeron por dos gráficos de barras horizontales:

```text
Top productos con pérdida estimada
Top clientes con pérdida estimada
```

Esta decisión mejora la lectura visual y permite identificar rápidamente los principales focos de pérdida.

---

## Top productos con pérdida estimada

Visual utilizado:

```text
Gráfico de barras horizontal
```

Objetivo:

```text
Detectar qué productos concentran mayor pérdida por margen negativo.
```

Campos utilizados:

```text
Producto
Pérdida por margen negativo
```

---

## Top clientes con pérdida estimada

Visual utilizado:

```text
Gráfico de barras horizontal
```

Objetivo:

```text
Detectar qué clientes concentran mayor pérdida estimada.
```

Campos utilizados:

```text
Cliente
Pérdida por margen negativo
```

Se cambió desde un gráfico circular inicial porque las barras permiten comparar mejor clientes con valores similares.

---

## Decisiones tomadas

### 1. Página ejecutiva, no operativa

Se decidió que la Página 1 no incluyera tablas ni matrices detalladas.

Motivo:

```text
La primera página debe explicar la situación en pocos segundos.
El detalle se analizará en páginas específicas.
```

---

### 2. Sustituir tabla y matriz por gráficos visuales

Se eliminó la idea inicial de incluir:

```text
Tabla de clientes con menor margen
Matriz por familia de producto
```

Estas se trasladarán a páginas posteriores:

```text
Tabla clientes → Página 3 Clientes
Matriz productos/familias → Página 2 Productos
```

---

### 3. Cambiar gráfico circular por barras

Se sustituyó el gráfico circular de clientes por barras horizontales.

Motivo:

```text
El gráfico circular no comparaba bien valores parecidos.
Las barras permiten ver rápidamente qué clientes generan más pérdida.
```

---

### 4. Usar semáforo en el KPI de margen

Se integró el semáforo directamente en la tarjeta de `% Margen`.

Motivo:

```text
Ahorra espacio.
Refuerza la lectura ejecutiva.
Permite interpretar la rentabilidad de un vistazo.
```

---

### 5. Mantener una estética corporativa industrial

Se usaron colores sobrios, tarjetas claras y menú azul acero para que el informe parezca propio de una empresa industrial real.

---

## Estado actual de la Página 1

La página está prácticamente terminada.

```text
Página 1 — 90 % completada
```

Pendientes menores:

```text
Quitar página duplicada del menú si no se usa.
Corregir tildes en títulos.
Alinear perfectamente las tarjetas KPI.
Añadir insight ejecutivo manual o dinámico.
Revisar formato final de moneda y unidades.
```

---

## Insight ejecutivo sugerido

```text
Insight ejecutivo: Nortemec mantiene un margen positivo del 18,66 %, aunque 1.105 pedidos presentan riesgo comercial por margen negativo o retraso. Las pérdidas se concentran principalmente en un grupo reducido de productos y clientes, por lo que conviene revisar precios, costes estimados y condiciones comerciales.
```

Más adelante este insight puede convertirse en una medida DAX dinámica.

---

## Resultado conseguido

La Página 1 ya cumple su función como resumen ejecutivo:

- Muestra la rentabilidad global.
- Indica el estado del margen mediante semáforo.
- Permite filtrar por fecha, familia, cliente y sector.
- Muestra la evolución mensual.
- Identifica productos y clientes con mayor pérdida.
- Evita sobrecargar con tablas de detalle.

La página responde correctamente a la pregunta:

> ¿Está Nortemec vendiendo con margen suficiente?

Y prepara el camino para investigar más a fondo en las siguientes páginas del informe.
