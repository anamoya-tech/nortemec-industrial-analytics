# Modelado Power BI ampliado — Nortemec Industrial Analytics

## Objetivo del modelado

El objetivo de esta fase ha sido construir un modelo Power BI estable, escalable y cercano a un entorno real de empresa industrial.

El modelo parte de las vistas limpias creadas en PostgreSQL y se ha ampliado con nuevas tablas de negocio para aportar más realismo al proyecto.

```text
PostgreSQL
   ↓
Vistas limpias SQL
   ↓
Power BI
   ↓
Modelo analítico industrial
```

---

## Tablas principales del modelo

### Tablas de hechos principales

```text
VENTAS
PRODUCCION
CALIDAD
COMPRAS
ALMACEN
MANTENIMIENTO
```

Estas tablas representan la actividad operativa principal de la empresa y son las que mantienen relación directa con `CALENDARIO`.

---

### Tablas de dimensiones principales

```text
CLIENTES
PRODUCTOS
PROVEEDORES
MATERIALES
Dim_Maquinas
Dim_Operarios
CALENDARIO
CALENDARIO_LABORAL
```

Estas tablas permiten segmentar, filtrar y enriquecer el análisis.

---

### Tablas nuevas añadidas

```text
OBJETIVOS_MENSUALES
COSTES_REALES_OF
STOCK_MATERIALES
ACCIONES_CORRECTIVAS_CALIDAD
MANTENIMIENTO_PREVENTIVO
OBJETIVOS_CLIENTES
CALENDARIO_LABORAL
```

---

## Relaciones activas con calendario

Se mantuvieron activas las relaciones entre `CALENDARIO` y las tablas principales de hechos:

```text
ALMACEN[fecha]                    → CALENDARIO[Date]
CALIDAD[fecha]                    → CALENDARIO[Date]
COMPRAS[fecha_pedido]             → CALENDARIO[Date]
MANTENIMIENTO[fecha_inicio]       → CALENDARIO[Date]
OBJETIVOS_MENSUALES[fecha_mes]    → CALENDARIO[Date]
PRODUCCION[fecha]                 → CALENDARIO[Date]
VENTAS[fecha_pedido]              → CALENDARIO[Date]
CALENDARIO_LABORAL[fecha]         → CALENDARIO[Date]
```

Estas relaciones permiten analizar la operación por fecha, mes, trimestre y año.

---

## Relaciones por área

### Ventas

```text
VENTAS[cliente_id]    → CLIENTES[cliente_id]
VENTAS[producto_id]   → PRODUCTOS[producto_id]
VENTAS[fecha_pedido]  → CALENDARIO[Date]
```

Permite analizar:

- Facturación por cliente.
- Facturación por producto.
- Margen por cliente.
- Margen por producto.
- Pedidos retrasados.
- Clientes con bajo margen.
- Productos con margen negativo.

---

### Producción

```text
PRODUCCION[fecha]                   → CALENDARIO[Date]
PRODUCCION[producto_id]             → PRODUCTOS[producto_id]
PRODUCCION[codigo_maquina_limpio]   → Dim_Maquinas[codigo_maquina_limpio]
PRODUCCION[operario_limpio]         → Dim_Operarios[nombre_operario_limpio]
```

Permite analizar:

- Producción por fecha.
- Producción por producto.
- Producción por máquina.
- Producción por operario.
- Scrap.
- Rechazo.
- Paradas.
- Órdenes retrasadas.

---

### Compras

```text
COMPRAS[fecha_pedido]  → CALENDARIO[Date]
COMPRAS[material_id]   → MATERIALES[material_id]
COMPRAS[proveedor_id]  → PROVEEDORES[proveedor_id]
```

Permite analizar:

- Compras por proveedor.
- Compras por material.
- Entregas tarde.
- Incidencias de proveedor.
- Compras con precio alto.

---

### Almacén

```text
ALMACEN[fecha]        → CALENDARIO[Date]
ALMACEN[material_id]  → MATERIALES[material_id]
```

Permite analizar:

- Movimientos de almacén.
- Materiales sin trazabilidad.
- Valor de movimientos.
- Entradas y salidas.

---

### Mantenimiento

```text
MANTENIMIENTO[fecha_inicio]           → CALENDARIO[Date]
MANTENIMIENTO[codigo_maquina_limpio]  → Dim_Maquinas[codigo_maquina_limpio]
```

Permite analizar:

- Averías por fecha.
- Averías por máquina.
- Coste de mantenimiento.
- Horas de parada.
- Paradas largas.
- Averías abiertas.

---

## Relaciones de tablas auxiliares

### Costes reales

```text
COSTES_REALES_OF[producto_id] → PRODUCTOS[producto_id]
```

Decisión tomada:

```text
COSTES_REALES_OF no se relaciona con CALENDARIO.
COSTES_REALES_OF no se relaciona con PRODUCCION.
Dim_Ordenes queda oculta y sin uso por ahora.
```

Motivo:

Power BI generaba rutas ambiguas al intentar conectar costes reales con calendario y producción.

Modelo final elegido:

```text
PRODUCTOS → COSTES_REALES_OF
```

---

### Stock

```text
STOCK_MATERIALES[material_id] → MATERIALES[material_id]
```

Decisión tomada:

```text
STOCK_MATERIALES no se relaciona con CALENDARIO.
```

Motivo:

`STOCK_MATERIALES` funciona como una foto de stock actual o snapshot. Conectarla a calendario generaba rutas ambiguas con `ALMACEN`.

Modelo final elegido:

```text
MATERIALES → STOCK_MATERIALES
```

---

### Acciones correctivas de calidad

```text
CALIDAD[incidencia_id] → ACCIONES_CORRECTIVAS_CALIDAD[incidencia_id]
```

Decisión tomada:

```text
ACCIONES_CORRECTIVAS_CALIDAD no se relaciona directamente con CALENDARIO.
```

Motivo:

Ya existe relación activa:

```text
CALIDAD → CALENDARIO
```

Si acciones correctivas también se conectaba a calendario, Power BI detectaba una ruta ambigua.

Modelo final elegido:

```text
CALENDARIO → CALIDAD → ACCIONES_CORRECTIVAS_CALIDAD
```

---

### Mantenimiento preventivo

```text
MANTENIMIENTO_PREVENTIVO[codigo_maquina_limpio] → Dim_Maquinas[codigo_maquina_limpio]
```

Decisión tomada:

```text
MANTENIMIENTO_PREVENTIVO no se relaciona con CALENDARIO.
```

Modelo final elegido:

```text
Dim_Maquinas → MANTENIMIENTO_PREVENTIVO
```

---

### Objetivos comerciales de clientes

```text
CLIENTES[cliente_id] → OBJETIVOS_CLIENTES[cliente_id]
```

Decisión tomada:

```text
OBJETIVOS_CLIENTES no se relaciona con CALENDARIO.
```

Motivo:

`OBJETIVOS_CLIENTES` es una tabla de atributos comerciales del cliente. No representa una transacción diaria, sino una foto de objetivo, potencial y riesgo comercial.

Modelo final elegido:

```text
CLIENTES → OBJETIVOS_CLIENTES
```

---

## Problemas encontrados

### 1. Rutas ambiguas con calendario

Al añadir nuevas tablas, Power BI detectó rutas ambiguas.

Ejemplo:

```text
ALMACEN → CALENDARIO
ALMACEN → MATERIALES → STOCK_MATERIALES → CALENDARIO
```

Solución:

```text
Solo las tablas principales de hechos se conectan activamente a CALENDARIO.
Las tablas auxiliares se conectan a sus dimensiones o tablas padre.
```

---

### 2. COSTES_REALES_OF no debía conectarse a calendario

Al intentar conectar `COSTES_REALES_OF` con `CALENDARIO`, se generaban rutas ambiguas con `PRODUCCION`.

Solución:

```text
COSTES_REALES_OF queda sin relación activa con CALENDARIO.
Se conecta únicamente con PRODUCTOS.
```

---

### 3. Dim_Ordenes no funcionó correctamente

Se creó `Dim_Ordenes` para intentar unir `PRODUCCION` y `COSTES_REALES_OF`, pero generaba ambigüedad.

Solución:

```text
Dim_Ordenes queda oculta y sin uso en esta versión.
No se fuerza la relación entre PRODUCCION y COSTES_REALES_OF.
```

---

## Regla de modelado aplicada

```text
1. CALENDARIO se conecta solo con hechos principales.
2. Las tablas auxiliares se conectan a dimensiones o tablas padre.
3. Todas las relaciones deben tener dirección de filtro única.
4. No se fuerzan relaciones muchos a muchos.
5. Si una relación crea ambigüedad, se elimina o se deja inactiva.
6. Se prioriza un modelo estable y explicable.
```

---

## Modelo final resumido

```text
CALENDARIO
   ├── VENTAS
   ├── PRODUCCION
   ├── CALIDAD
   ├── COMPRAS
   ├── ALMACEN
   ├── MANTENIMIENTO
   ├── OBJETIVOS_MENSUALES
   └── CALENDARIO_LABORAL

CLIENTES
   ├── VENTAS
   └── OBJETIVOS_CLIENTES

PRODUCTOS
   ├── VENTAS
   ├── PRODUCCION
   └── COSTES_REALES_OF

MATERIALES
   ├── COMPRAS
   ├── ALMACEN
   └── STOCK_MATERIALES

PROVEEDORES
   └── COMPRAS

CALIDAD
   └── ACCIONES_CORRECTIVAS_CALIDAD

Dim_Maquinas
   ├── PRODUCCION
   ├── MANTENIMIENTO
   └── MANTENIMIENTO_PREVENTIVO

Dim_Operarios
   └── PRODUCCION
```

---

## Estado final

```text
Fase 4 — Modelo Power BI ampliado: COMPLETADA
```

El modelo queda preparado para seguir construyendo informes Power BI especializados.
