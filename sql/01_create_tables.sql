# 01_create_tables.sql

## Objetivo

Este script crea las tablas operativas de la base de datos **nortemec_operaciones**.

La estructura simula una base de datos industrial realista, con tablas procedentes de áreas como ventas, producción, compras, calidad, almacén y mantenimiento.

A diferencia de un modelo analítico limpio tipo `dim` / `fact`, estas tablas representan una capa operativa inicial, similar a la que podría existir en un ERP industrial o en procesos internos heredados.

---

## Tablas incluidas

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

---

## Script SQL

```sql
CREATE TABLE clientes (
    cliente_id INTEGER PRIMARY KEY,
    cod_cliente VARCHAR(20),
    nombre VARCHAR(150),
    razon_social VARCHAR(150),
    cif VARCHAR(20),
    provincia VARCHAR(80),
    pais VARCHAR(80),
    sector VARCHAR(100),
    tipo_cliente VARCHAR(50),
    fecha_alta DATE,
    activo VARCHAR(10),
    email_contacto VARCHAR(120),
    telefono VARCHAR(30),
    observaciones TEXT
);

CREATE TABLE productos (
    producto_id INTEGER PRIMARY KEY,
    cod_producto VARCHAR(30),
    descripcion VARCHAR(200),
    familia VARCHAR(100),
    material_base VARCHAR(80),
    peso_kg NUMERIC(10,3),
    unidad_medida VARCHAR(20),
    coste_estandar NUMERIC(12,2),
    precio_teorico NUMERIC(12,2),
    estado VARCHAR(30),
    fecha_creacion DATE,
    plano_tecnico VARCHAR(80)
);

CREATE TABLE maquinas (
    maquina_id INTEGER PRIMARY KEY,
    codigo_maquina VARCHAR(30),
    nombre_maquina VARCHAR(100),
    tipo VARCHAR(80),
    centro_trabajo VARCHAR(80),
    fabricante VARCHAR(100),
    anio_instalacion INTEGER,
    coste_hora NUMERIC(12,2),
    estado VARCHAR(30),
    observaciones TEXT
);

CREATE TABLE operarios (
    operario_id INTEGER PRIMARY KEY,
    codigo_operario VARCHAR(30),
    nombre VARCHAR(120),
    categoria VARCHAR(80),
    equipo VARCHAR(50),
    turno_habitual VARCHAR(30),
    fecha_alta DATE,
    activo VARCHAR(20),
    observaciones TEXT
);

CREATE TABLE proveedores (
    proveedor_id INTEGER PRIMARY KEY,
    cod_proveedor VARCHAR(30),
    nombre VARCHAR(150),
    cif VARCHAR(20),
    provincia VARCHAR(80),
    pais VARCHAR(80),
    tipo_material VARCHAR(100),
    criticidad VARCHAR(30),
    activo VARCHAR(20),
    email VARCHAR(120),
    telefono VARCHAR(30),
    observaciones TEXT
);

CREATE TABLE materiales (
    material_id INTEGER PRIMARY KEY,
    cod_material VARCHAR(30),
    descripcion VARCHAR(150),
    tipo_material VARCHAR(80),
    calidad_material VARCHAR(80),
    unidad_medida VARCHAR(20),
    coste_estandar NUMERIC(12,2),
    proveedor_habitual VARCHAR(150),
    activo VARCHAR(20)
);

CREATE TABLE pedidos_venta (
    pedido_id INTEGER PRIMARY KEY,
    num_pedido VARCHAR(30),
    cliente_id INTEGER,
    fecha_pedido DATE,
    fecha_entrega_prevista DATE,
    fecha_entrega_real DATE,
    estado VARCHAR(50),
    comercial VARCHAR(100),
    forma_pago VARCHAR(80),
    prioridad VARCHAR(30),
    observaciones TEXT
);

CREATE TABLE lineas_pedido_venta (
    linea_id INTEGER PRIMARY KEY,
    pedido_id INTEGER,
    producto_id INTEGER,
    cantidad NUMERIC(12,2),
    precio_unitario NUMERIC(12,2),
    descuento_pct NUMERIC(5,2),
    importe_linea NUMERIC(12,2),
    coste_estimado NUMERIC(12,2),
    margen_estimado NUMERIC(12,2),
    observaciones TEXT
);

CREATE TABLE ordenes_fabricacion (
    of_id INTEGER PRIMARY KEY,
    num_of VARCHAR(30),
    pedido_id INTEGER,
    producto_id INTEGER,
    fecha_lanzamiento DATE,
    fecha_inicio DATE,
    fecha_fin_prevista DATE,
    fecha_fin_real DATE,
    cantidad_planificada NUMERIC(12,2),
    cantidad_fabricada NUMERIC(12,2),
    estado VARCHAR(50),
    responsable VARCHAR(100),
    prioridad VARCHAR(30),
    observaciones TEXT
);

CREATE TABLE partes_produccion (
    parte_id INTEGER PRIMARY KEY,
    fecha DATE,
    num_of VARCHAR(30),
    maquina VARCHAR(80),
    operario VARCHAR(100),
    turno VARCHAR(30),
    horas_trabajadas NUMERIC(10,2),
    unidades_ok NUMERIC(12,2),
    unidades_nok NUMERIC(12,2),
    kg_consumidos NUMERIC(12,2),
    kg_scrap NUMERIC(12,2),
    motivo_scrap VARCHAR(150),
    parada_minutos NUMERIC(10,2),
    motivo_parada VARCHAR(150),
    observaciones TEXT
);

CREATE TABLE incidencias_calidad (
    incidencia_id INTEGER PRIMARY KEY,
    fecha DATE,
    num_of VARCHAR(30),
    pedido_id INTEGER,
    cliente VARCHAR(150),
    producto VARCHAR(150),
    maquina VARCHAR(80),
    proveedor VARCHAR(150),
    tipo_incidencia VARCHAR(100),
    descripcion TEXT,
    gravedad VARCHAR(30),
    unidades_afectadas NUMERIC(12,2),
    coste_estimado NUMERIC(12,2),
    requiere_reproceso VARCHAR(10),
    causa_raiz VARCHAR(150),
    estado VARCHAR(50),
    responsable VARCHAR(100)
);

CREATE TABLE pedidos_compra (
    pedido_compra_id INTEGER PRIMARY KEY,
    num_pedido_compra VARCHAR(30),
    proveedor_id INTEGER,
    fecha_pedido DATE,
    fecha_prevista DATE,
    fecha_recepcion DATE,
    estado VARCHAR(50),
    comprador VARCHAR(100),
    observaciones TEXT
);

CREATE TABLE lineas_pedido_compra (
    linea_compra_id INTEGER PRIMARY KEY,
    pedido_compra_id INTEGER,
    material_id INTEGER,
    cantidad_pedida NUMERIC(12,2),
    cantidad_recibida NUMERIC(12,2),
    unidad VARCHAR(20),
    precio_unitario NUMERIC(12,2),
    importe_total NUMERIC(12,2),
    incidencia_calidad VARCHAR(10),
    observaciones TEXT
);

CREATE TABLE movimientos_almacen (
    movimiento_id INTEGER PRIMARY KEY,
    fecha DATE,
    material_id INTEGER,
    tipo_movimiento VARCHAR(50),
    cantidad NUMERIC(12,2),
    unidad VARCHAR(20),
    almacen VARCHAR(80),
    num_of VARCHAR(30),
    pedido_compra VARCHAR(30),
    motivo VARCHAR(150),
    usuario VARCHAR(100),
    observaciones TEXT
);

CREATE TABLE averias_mantenimiento (
    averia_id INTEGER PRIMARY KEY,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    maquina VARCHAR(80),
    tipo_averia VARCHAR(100),
    descripcion TEXT,
    tecnico VARCHAR(100),
    parada_produccion VARCHAR(10),
    coste_estimado NUMERIC(12,2),
    estado VARCHAR(50),
    observaciones TEXT
);
```

---

## Comprobación posterior

Después de ejecutar este script, se puede comprobar que las tablas han sido creadas correctamente con:

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

## Siguiente paso

Después de crear las tablas, ejecutar el archivo:

```text
02_insert_dirty_data.sql
```

Este archivo cargará datos sucios y realistas en las tablas operativas.

