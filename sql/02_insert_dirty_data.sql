# 02_insert_dirty_data.sql

## Objetivo

Este script carga datos sucios y realistas en las tablas operativas de la base de datos **nortemec_operaciones**.

La carga simula un entorno industrial real, con datos procedentes de ventas, producción, compras, calidad, almacén y mantenimiento.

Los datos incluyen intencionadamente problemas habituales de calidad del dato:

* Códigos nulos.
* Nombres duplicados o escritos de forma diferente.
* Estados mal normalizados.
* Fechas incompletas.
* Campos vacíos.
* Registros sin relaciones completas.
* Incidencias sin causa raíz.
* Averías sin fecha de cierre.
* Máquinas, operarios, proveedores y materiales escritos con variaciones.

---

## Nota importante

Este script usa `TRUNCATE TABLE` antes de insertar datos.

Si se ejecuta de nuevo, eliminará los datos actuales de las tablas y los volverá a generar.

---

## 1. Carga de datos en `clientes`

```sql
TRUNCATE TABLE clientes;

INSERT INTO clientes (
    cliente_id,
    cod_cliente,
    nombre,
    razon_social,
    cif,
    provincia,
    pais,
    sector,
    tipo_cliente,
    fecha_alta,
    activo,
    email_contacto,
    telefono,
    observaciones
)
SELECT
    gs AS cliente_id,

    CASE
        WHEN random() < 0.04 THEN NULL
        WHEN random() < 0.18 THEN 'C-' || LPAD(gs::text, 4, '0')
        ELSE 'CL' || LPAD(gs::text, 4, '0')
    END AS cod_cliente,

    CASE
        WHEN gs % 37 = 0 THEN 'TALLERES NORTE SA'
        WHEN gs % 41 = 0 THEN 'Talleres Norte S.A.'
        WHEN gs % 53 = 0 THEN 'Talleres Norte SA'
        WHEN gs % 67 = 0 THEN 'TALLERES NORT S.A.'
        ELSE 
            (ARRAY[
                'AgroMecánica Ruiz',
                'Indusmetal Norte',
                'Mecanizados Costa',
                'Ebro Componentes',
                'Cantabria Motion',
                'Metalúrgica del Norte',
                'TecnoPart Solutions',
                'HidraMachines',
                'Ferroval Industrial',
                'Nortequip',
                'Mecalux Industrial',
                'Forjas del Ebro',
                'Componentes Atlántico',
                'Soldaduras Técnicas Norte',
                'Automoción Rivera'
            ])[floor(random()*15)::int + 1] || ' ' || gs
    END AS nombre,

    CASE
        WHEN random() < 0.15 THEN NULL
        ELSE 'Razón social cliente ' || gs
    END AS razon_social,

    CASE
        WHEN random() < 0.10 THEN NULL
        ELSE 'B' || LPAD((10000000 + gs)::text, 8, '0')
    END AS cif,

    CASE
        WHEN random() < 0.06 THEN NULL
        ELSE 
            (ARRAY[
                'Cantabria',
                'CANTABRIA',
                'Bizkaia',
                'Vizcaya',
                'Burgos',
                'Asturias',
                'Madrid',
                'Navarra',
                'La Rioja',
                'Gipuzkoa',
                'Valladolid',
                'Palencia',
                'León',
                'Barcelona',
                'Valencia'
            ])[floor(random()*15)::int + 1]
    END AS provincia,

    (ARRAY[
        'España',
        'ESP',
        'Spain',
        'Portugal',
        'Francia',
        ''
    ])[floor(random()*6)::int + 1] AS pais,

    CASE
        WHEN random() < 0.09 THEN NULL
        ELSE 
            (ARRAY[
                'Automoción',
                'Automocion',
                'Maquinaria agrícola',
                'Agrícola',
                'Bienes de equipo',
                'Energía',
                'Industrial',
                'Mantenimiento industrial',
                'Metal',
                'Auxiliar automoción',
                ''
            ])[floor(random()*11)::int + 1]
    END AS sector,

    (ARRAY[
        'A',
        'B',
        'C',
        'Estratégico',
        'Estrategico',
        'Nuevo',
        'Recurrente',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS tipo_cliente,

    DATE '2015-01-01' + floor(random()*3650)::int AS fecha_alta,

    (ARRAY[
        'SI',
        'Sí',
        'S',
        'Activo',
        'ACT',
        'NO',
        'Baja',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS activo,

    CASE
        WHEN random() < 0.12 THEN NULL
        ELSE 'compras' || gs || '@cliente-industrial.com'
    END AS email_contacto,

    CASE
        WHEN random() < 0.10 THEN NULL
        ELSE '+34 6' || LPAD((floor(random()*99999999)::int)::text, 8, '0')
    END AS telefono,

    CASE
        WHEN random() < 0.70 THEN NULL
        WHEN random() < 0.50 THEN 'Cliente importado desde ERP antiguo'
        ELSE 'Datos pendientes de validar por administración'
    END AS observaciones

FROM generate_series(1, 2600) gs;
```

---

## 2. Carga de datos en `productos`

```sql
TRUNCATE TABLE productos;

INSERT INTO productos (
    producto_id,
    cod_producto,
    descripcion,
    familia,
    material_base,
    peso_kg,
    unidad_medida,
    coste_estandar,
    precio_teorico,
    estado,
    fecha_creacion,
    plano_tecnico
)
SELECT
    gs AS producto_id,

    CASE
        WHEN random() < 0.04 THEN NULL
        WHEN random() < 0.15 THEN 'P' || LPAD(gs::text, 5, '0')
        WHEN random() < 0.25 THEN 'PROD-' || LPAD(gs::text, 4, '0')
        ELSE 'P-' || LPAD(gs::text, 5, '0')
    END AS cod_producto,

    CASE
        WHEN gs % 43 = 0 THEN 'Placa perforada 8mm'
        WHEN gs % 47 = 0 THEN 'Placa perf. 8 mm'
        WHEN gs % 59 = 0 THEN 'PLACA PERFORADA 8 MM'
        WHEN gs % 61 = 0 THEN 'Eje mecanizado 40mm'
        WHEN gs % 67 = 0 THEN 'Eje mec. Ø40'
        ELSE
            (ARRAY[
                'Placa soporte mecanizada',
                'Base de ensamblaje',
                'Tapa mecanizada',
                'Brida industrial',
                'Eje mecanizado',
                'Casquillo calibrado',
                'Separador metálico',
                'Soporte soldado lateral',
                'Bastidor pequeño',
                'Refuerzo de maquinaria',
                'Guía metálica',
                'Panel técnico perforado',
                'Chapa plegada',
                'Anclaje estructural',
                'Pieza especial bajo plano'
            ])[floor(random()*15)::int + 1] || ' ' || gs
    END AS descripcion,

    CASE
        WHEN random() < 0.08 THEN NULL
        ELSE
            (ARRAY[
                'Placas mecanizadas',
                'Placas perforadas',
                'Placa Perforada',
                'Ejes',
                'Ejes y casquillos',
                'Casquillos',
                'Soportes soldados',
                'Soportes',
                'Componentes perforados',
                'Bridas industriales',
                'Chapa',
                '',
                'Otros'
            ])[floor(random()*13)::int + 1]
    END AS familia,

    CASE
        WHEN random() < 0.07 THEN NULL
        ELSE
            (ARRAY[
                'Acero S275',
                'acero s275',
                'ACERO S275',
                'Acero C45',
                'Inox 304',
                'Acero inoxidable 304',
                'Aluminio 6082',
                'aluminio',
                'Chapa galvanizada',
                ''
            ])[floor(random()*10)::int + 1]
    END AS material_base,

    CASE
        WHEN random() < 0.09 THEN NULL
        ELSE ROUND((0.25 + random()*45)::numeric, 3)
    END AS peso_kg,

    (ARRAY[
        'ud',
        'UD',
        'unidad',
        'pcs',
        'pieza',
        '',
        NULL
    ])[floor(random()*7)::int + 1] AS unidad_medida,

    CASE
        WHEN random() < 0.11 THEN NULL
        ELSE ROUND((3 + random()*180)::numeric, 2)
    END AS coste_estandar,

    CASE
        WHEN random() < 0.13 THEN NULL
        ELSE ROUND((8 + random()*260)::numeric, 2)
    END AS precio_teorico,

    (ARRAY[
        'Activo',
        'ACT',
        'activo',
        'Baja',
        'Descatalogado',
        'NO USAR',
        '',
        NULL
    ])[floor(random()*8)::int + 1] AS estado,

    DATE '2016-01-01' + floor(random()*3000)::int AS fecha_creacion,

    CASE
        WHEN random() < 0.16 THEN NULL
        WHEN random() < 0.30 THEN ''
        ELSE 'PL-' || LPAD(gs::text, 5, '0') || '.pdf'
    END AS plano_tecnico

FROM generate_series(1, 2600) gs;
```

---

## 3. Carga de datos en `maquinas`

```sql
TRUNCATE TABLE maquinas;

INSERT INTO maquinas (
    maquina_id,
    codigo_maquina,
    nombre_maquina,
    tipo,
    centro_trabajo,
    fabricante,
    anio_instalacion,
    coste_hora,
    estado,
    observaciones
)
VALUES
(1,  'CNC-01',  'Centro CNC Mazak 01',              'CNC',        'Mecanizado',   'Mazak',     2016, 58.00, 'Activa', NULL),
(2,  'CNC 1',   'Mazak 1',                           'cnc',        'mecanizado',   'MAZAK',     2016, NULL,  'ACT', 'Misma máquina que CNC-01, código duplicado en ERP antiguo'),
(3,  'CNC-02',  'Centro CNC Mazak 02',              'CNC',        'Mecanizado',   'Mazak',     2018, 61.50, 'Activa', NULL),
(4,  'CNC-03',  'Centro mecanizado vertical 03',    'CNC',        'Mecanizado',   'DMG Mori',  2020, 66.00, 'Activa', NULL),
(5,  'CNC_04',  'Centro CNC vertical 04',           'cnc',        'Mecanizado',   'Fanuc',     2015, 54.75, 'activo', NULL),
(6,  'TOR-01',  'Torno CNC 01',                     'Torno',      'Mecanizado',   'Mazak',     2014, 49.00, 'Activa', NULL),
(7,  'TOR 02',  'Torno CNC 2',                      'torno cnc',  'mecanizado',   'DMG Mori',  2017, 52.40, 'ACT', NULL),
(8,  'TOR-03',  'Torno automático 03',              'Torno',      'Mecanizado',   'Fanuc',     2019, NULL,  'Activa', 'Coste hora pendiente de actualizar'),
(9,  'FRE-01',  'Fresadora industrial 01',          'Fresadora',  'Mecanizado',   'Haas',      2013, 45.00, 'Activa', NULL),
(10, 'FRE-02',  'Fresadora CNC 02',                 'Fresadora',  'mecanizado',   'Haas',      2018, 48.50, 'ACT', NULL),
(11, 'FRE 03',  'Fresadora universal 3',            'fresadora',  'Mecanizado',   NULL,        2010, 39.00, 'Baja', 'Máquina antigua con datos históricos'),
(12, 'LAS-01',  'Corte Láser Trumpf 01',            'Láser',      'Corte',        'Trumpf',    2019, 72.50, 'Activa', NULL),
(13, 'LAS-02',  'Corte Láser Trumpf 2',             'Laser',      'corte laser',  'TRUMPF',    2021, 78.00, 'Activa', NULL),
(14, 'Laser-2', 'Laser Trumpf II',                  'laser',      'Corte',        'Trumpf',    2021, NULL,  'ACT', 'Misma máquina que LAS-02 registrada por mantenimiento'),
(15, 'LAS-03',  'Corte láser fibra 03',             'Láser',      'Corte',        'Bystronic', 2022, 81.25, 'Activa', NULL),
(16, 'PRE-01',  'Prensa hidráulica 01',             'Prensa',     'Prensado',     'Amada',     2012, 42.00, 'Activa', NULL),
(17, 'PRE 02',  'Prensa hidráulica 2',              'prensa',     'prensado',     'Amada',     2016, 44.00, 'ACT', NULL),
(18, 'PLE-01',  'Plegadora CNC 01',                 'Plegadora',  'Plegado',      'Amada',     2018, 46.50, 'Activa', NULL),
(19, 'PLE_02',  'Plegadora cnc 02',                 'plegadora',  'plegado',      'Bystronic', 2020, NULL,  'activo', 'Coste hora no informado'),
(20, 'SOLD-01', 'Puesto Soldadura 1',               'Soldadura',  'Soldadura',    'Kuka',      2017, 43.00, 'Activa', NULL),
(21, 'SOLD 02', 'Puesto soldadura manual 02',       'soldadura',  'soldadura',    NULL,        2011, 35.00, 'ACT', NULL),
(22, 'ROB-SOL1','Celda robotizada soldadura 1',     'Soldadura',  'Soldadura',    'Kuka',      2021, 69.00, 'Activa', NULL),
(23, 'TAL-01',  'Taladro industrial 01',            'Taladro',    'Taladrado',    NULL,        2009, 28.00, 'Activa', NULL),
(24, 'TAL 02',  'Taladro columna 02',               'taladro',    'taladrado',    NULL,        2008, NULL,  'Baja', 'Equipo antiguo usado solo en pedidos especiales'),
(25, 'SIE-01',  'Sierra automática 01',             'Sierra',     'Corte',        'Kasto',     2015, 31.50, 'Activa', NULL),
(26, 'SIE 02',  'Sierra cinta 02',                  'sierra',     'corte',        'Kasto',     2012, 29.75, 'ACT', NULL),
(27, 'VER-01',  'Puesto verificación dimensional',  'Verificación','Calidad',      'Mitutoyo',  2020, 38.00, 'Activa', NULL),
(28, 'VER 02',  'Control calidad tridimensional',   'verificacion','calidad',      'Mitutoyo',  2022, 55.00, 'Activa', NULL),
(29, 'LAV-01',  'Lavadora industrial piezas',       'Lavado',     'Acabado',      NULL,        2016, 24.00, 'Activa', NULL),
(30, 'EMB-01',  'Puesto embalaje final',            'Embalaje',   'Expediciones', NULL,        2014, 22.00, 'Activa', NULL),
(31, NULL,      'Máquina sin código histórico',     'CNC',        'Mecanizado',   NULL,        2007, NULL,  '', 'Registro incompleto importado del ERP antiguo'),
(32, 'MANT-XX', 'Equipo pendiente clasificar',      '',           '',             '',          NULL, NULL,  NULL, 'Registro pendiente de depuración');
```

---

## 4. Carga de datos en `operarios`

```sql
TRUNCATE TABLE operarios;

INSERT INTO operarios (
    operario_id,
    codigo_operario,
    nombre,
    categoria,
    equipo,
    turno_habitual,
    fecha_alta,
    activo,
    observaciones
)
SELECT
    gs AS operario_id,

    CASE
        WHEN random() < 0.04 THEN NULL
        WHEN random() < 0.12 THEN 'OP-' || LPAD(gs::text, 3, '0')
        ELSE 'OP' || LPAD(gs::text, 3, '0')
    END AS codigo_operario,

    CASE
        WHEN gs = 1 THEN 'Luis Gómez'
        WHEN gs = 2 THEN 'L. Gomez'
        WHEN gs = 3 THEN 'Luis G.'
        WHEN gs = 4 THEN 'Ana Pérez'
        WHEN gs = 5 THEN 'A. Perez'
        WHEN gs = 6 THEN 'Carlos Ruiz'
        WHEN gs = 7 THEN 'C. Ruiz'
        ELSE
            (ARRAY[
                'Javier Martín',
                'Marta López',
                'Sergio Fernández',
                'Laura García',
                'David Sánchez',
                'Paula Rodríguez',
                'Miguel Torres',
                'Elena Díaz',
                'Raúl Herrera',
                'Nuria Castro',
                'Iván Ortega',
                'Carmen Gil',
                'Daniel Vega',
                'Lucía Romero',
                'Alberto Molina',
                'Sara Navarro',
                'Hugo León',
                'Cristina Peña',
                'Óscar Prieto',
                'Beatriz Santos'
            ])[floor(random()*20)::int + 1] || ' ' || gs
    END AS nombre,

    CASE
        WHEN random() < 0.06 THEN NULL
        ELSE
            (ARRAY[
                'Operario CNC',
                'operario cnc',
                'Tornero',
                'Fresador',
                'Soldador',
                'soldador',
                'Técnico calidad',
                'Verificador',
                'Mantenimiento',
                'Mozo almacén',
                'almacen',
                'Responsable turno',
                ''
            ])[floor(random()*13)::int + 1]
    END AS categoria,

    CASE
        WHEN random() < 0.05 THEN NULL
        ELSE
            (ARRAY[
                'Equipo A',
                'equipo a',
                'Equipo B',
                'Equipo C',
                'Mecanizado',
                'Soldadura',
                'Calidad',
                'Almacén',
                ''
            ])[floor(random()*9)::int + 1]
    END AS equipo,

    (ARRAY[
        'Mañana',
        'M',
        'Tarde',
        'T',
        'Noche',
        'N',
        'Rotativo',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS turno_habitual,

    CASE
        WHEN random() < 0.05 THEN NULL
        ELSE DATE '2010-01-01' + floor(random()*5200)::int
    END AS fecha_alta,

    (ARRAY[
        'SI',
        'Sí',
        'S',
        'Activo',
        'ACT',
        'NO',
        'Baja',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS activo,

    CASE
        WHEN random() < 0.75 THEN NULL
        WHEN random() < 0.50 THEN 'Nombre duplicado o abreviado en partes antiguos'
        ELSE 'Registro importado desde RRHH'
    END AS observaciones

FROM generate_series(1, 120) gs;
```

---

## 5. Carga de datos en `proveedores`

```sql
TRUNCATE TABLE proveedores;

INSERT INTO proveedores (
    proveedor_id,
    cod_proveedor,
    nombre,
    cif,
    provincia,
    pais,
    tipo_material,
    criticidad,
    activo,
    email,
    telefono,
    observaciones
)
SELECT
    gs AS proveedor_id,

    CASE
        WHEN random() < 0.05 THEN NULL
        WHEN random() < 0.18 THEN 'P-' || LPAD(gs::text, 4, '0')
        ELSE 'PR' || LPAD(gs::text, 4, '0')
    END AS cod_proveedor,

    CASE
        WHEN gs = 1 THEN 'Aceros Norte S.L.'
        WHEN gs = 2 THEN 'ACEROS NORTE SL'
        WHEN gs = 3 THEN 'Aceros Norte'
        WHEN gs = 4 THEN 'Aluminios Iberia'
        WHEN gs = 5 THEN 'ALUMINIOS IBERIA S.A.'
        WHEN gs = 6 THEN 'Tratamientos Cantabria'
        WHEN gs = 7 THEN 'Trat. Cantabria'
        ELSE
            (ARRAY[
                'Suministros Industriales Norte',
                'FerroCantábrica',
                'MetalSupply Iberia',
                'Tornillería del Ebro',
                'Aceros Atlántico',
                'Logística Industrial Ruiz',
                'Herramientas Técnicas S.L.',
                'Químicos de Superficie',
                'Embalajes del Norte',
                'Componentes Mecánicos Vega',
                'Fundiciones Castilla',
                'Almacenes Metalúrgicos',
                'Recubrimientos Técnicos',
                'Rodamientos Norte',
                'Corte y Chapa Industrial'
            ])[floor(random()*15)::int + 1] || ' ' || gs
    END AS nombre,

    CASE
        WHEN random() < 0.12 THEN NULL
        ELSE 'B' || LPAD((20000000 + gs)::text, 8, '0')
    END AS cif,

    CASE
        WHEN random() < 0.07 THEN NULL
        ELSE
            (ARRAY[
                'Cantabria',
                'CANTABRIA',
                'Bizkaia',
                'Vizcaya',
                'Burgos',
                'Asturias',
                'Madrid',
                'Navarra',
                'La Rioja',
                'Gipuzkoa',
                'Barcelona',
                'Valencia',
                'Zaragoza',
                ''
            ])[floor(random()*14)::int + 1]
    END AS provincia,

    (ARRAY[
        'España',
        'ESP',
        'Spain',
        'Portugal',
        'Francia',
        '',
        NULL
    ])[floor(random()*7)::int + 1] AS pais,

    CASE
        WHEN random() < 0.08 THEN NULL
        ELSE
            (ARRAY[
                'Acero',
                'acero',
                'Aluminio',
                'aluminio',
                'Inox',
                'Tornillería',
                'tornilleria',
                'Tratamiento superficial',
                'Pintura',
                'Embalaje',
                'Herramientas',
                'Transporte',
                ''
            ])[floor(random()*13)::int + 1]
    END AS tipo_material,

    (ARRAY[
        'Alta',
        'alta',
        'Media',
        'media',
        'Baja',
        'Crítico',
        'Critico',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS criticidad,

    (ARRAY[
        'SI',
        'Sí',
        'S',
        'Activo',
        'ACT',
        'NO',
        'Baja',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS activo,

    CASE
        WHEN random() < 0.15 THEN NULL
        ELSE 'compras' || gs || '@proveedor-industrial.com'
    END AS email,

    CASE
        WHEN random() < 0.12 THEN NULL
        ELSE '+34 9' || LPAD((floor(random()*99999999)::int)::text, 8, '0')
    END AS telefono,

    CASE
        WHEN random() < 0.75 THEN NULL
        WHEN random() < 0.50 THEN 'Proveedor duplicado pendiente de revisión'
        ELSE 'Datos importados desde compras'
    END AS observaciones

FROM generate_series(1, 150) gs;
```

---

## 6. Carga de datos en `materiales`

```sql
TRUNCATE TABLE materiales;

INSERT INTO materiales (
    material_id,
    cod_material,
    descripcion,
    tipo_material,
    calidad_material,
    unidad_medida,
    coste_estandar,
    proveedor_habitual,
    activo
)
SELECT
    gs AS material_id,

    CASE
        WHEN random() < 0.04 THEN NULL
        WHEN random() < 0.18 THEN 'M' || LPAD(gs::text, 4, '0')
        ELSE 'MAT-' || LPAD(gs::text, 4, '0')
    END AS cod_material,

    CASE
        WHEN gs = 1 THEN 'Acero S275'
        WHEN gs = 2 THEN 'acero s275'
        WHEN gs = 3 THEN 'ACERO S275'
        WHEN gs = 4 THEN 'Aluminio 6082'
        WHEN gs = 5 THEN 'ALUMINIO 6082'
        WHEN gs = 6 THEN 'Inox 304'
        WHEN gs = 7 THEN 'Acero inoxidable 304'
        ELSE
            (ARRAY[
                'Chapa acero laminada',
                'Barra calibrada',
                'Tubo estructural',
                'Pletina acero',
                'Redondo acero',
                'Perfil aluminio',
                'Chapa galvanizada',
                'Tornillo DIN 912',
                'Tuerca hexagonal',
                'Arandela plana',
                'Disco corte',
                'Broca metal',
                'Aceite refrigerante',
                'Pintura imprimación',
                'Caja embalaje',
                'Film retráctil',
                'Palet madera',
                'Electrodo soldadura',
                'Gas soldadura',
                'Granalla limpieza'
            ])[floor(random()*20)::int + 1] || ' ' || gs
    END AS descripcion,

    CASE
        WHEN random() < 0.07 THEN NULL
        ELSE
            (ARRAY[
                'Acero',
                'acero',
                'Aluminio',
                'aluminio',
                'Inox',
                'Acero inoxidable',
                'Tornillería',
                'tornilleria',
                'Consumible',
                'consumibles',
                'Embalaje',
                'Herramienta',
                'Químico',
                'Pintura',
                ''
            ])[floor(random()*15)::int + 1]
    END AS tipo_material,

    CASE
        WHEN random() < 0.12 THEN NULL
        ELSE
            (ARRAY[
                'S275',
                's275',
                'C45',
                'c45',
                '304',
                'AISI 304',
                '6082',
                'T6',
                'Galvanizado',
                'DIN',
                'N/A',
                ''
            ])[floor(random()*12)::int + 1]
    END AS calidad_material,

    (ARRAY[
        'kg',
        'KG',
        'kilos',
        'ud',
        'UD',
        'unidad',
        'm',
        'metro',
        'litros',
        'L',
        '',
        NULL
    ])[floor(random()*12)::int + 1] AS unidad_medida,

    CASE
        WHEN random() < 0.11 THEN NULL
        ELSE ROUND((0.15 + random()*95)::numeric, 2)
    END AS coste_estandar,

    CASE
        WHEN random() < 0.18 THEN NULL
        ELSE
            (ARRAY[
                'Aceros Norte S.L.',
                'ACEROS NORTE SL',
                'Aceros Norte',
                'Aluminios Iberia',
                'ALUMINIOS IBERIA S.A.',
                'Suministros Industriales Norte',
                'FerroCantábrica',
                'Tornillería del Ebro',
                'Herramientas Técnicas S.L.',
                'Embalajes del Norte',
                ''
            ])[floor(random()*11)::int + 1]
    END AS proveedor_habitual,

    (ARRAY[
        'SI',
        'Sí',
        'S',
        'Activo',
        'ACT',
        'NO',
        'Baja',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS activo

FROM generate_series(1, 420) gs;
```

---

## 7. Carga de datos en `pedidos_venta`

```sql
TRUNCATE TABLE pedidos_venta;

INSERT INTO pedidos_venta (
    pedido_id,
    num_pedido,
    cliente_id,
    fecha_pedido,
    fecha_entrega_prevista,
    fecha_entrega_real,
    estado,
    comercial,
    forma_pago,
    prioridad,
    observaciones
)
SELECT
    gs AS pedido_id,

    CASE
        WHEN random() < 0.04 THEN NULL
        WHEN random() < 0.20 THEN 'PV' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || LPAD(gs::text, 5, '0')
        WHEN random() < 0.35 THEN 'PV-' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || '-' || LPAD(gs::text, 5, '0')
        ELSE 'PED-' || LPAD(gs::text, 6, '0')
    END AS num_pedido,

    CASE
        WHEN random() < 0.035 THEN NULL
        ELSE floor(1 + random()*2600)::int
    END AS cliente_id,

    DATE '2023-01-01' + floor(random()*720)::int AS fecha_pedido,

    CASE
        WHEN random() < 0.08 THEN NULL
        ELSE DATE '2023-01-01' + floor(random()*720)::int + floor(7 + random()*35)::int
    END AS fecha_entrega_prevista,

    CASE
        WHEN random() < 0.22 THEN NULL
        ELSE DATE '2023-01-01' + floor(random()*720)::int + floor(10 + random()*45)::int
    END AS fecha_entrega_real,

    (ARRAY[
        'Entregado',
        'entregado',
        'Cerrado',
        'cerrado',
        'Pendiente',
        'En curso',
        'EN CURSO',
        'Cancelado',
        'cancelado',
        '',
        NULL
    ])[floor(random()*11)::int + 1] AS estado,

    (ARRAY[
        'Marta Alonso',
        'M. Alonso',
        'Carlos Vega',
        'C. Vega',
        'Lucía Herrero',
        'L. Herrero',
        'Javier Peña',
        'J. Peña',
        '',
        NULL
    ])[floor(random()*10)::int + 1] AS comercial,

    (ARRAY[
        'Transferencia',
        'transferencia',
        '30 días',
        '30 dias',
        '60 días',
        '60 dias',
        'Confirming',
        'Contado',
        '',
        NULL
    ])[floor(random()*10)::int + 1] AS forma_pago,

    (ARRAY[
        'Normal',
        'normal',
        'Alta',
        'alta',
        'Urgente',
        'URG',
        'Baja',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS prioridad,

    CASE
        WHEN random() < 0.78 THEN NULL
        WHEN random() < 0.50 THEN 'Pedido importado desde ERP antiguo'
        ELSE 'Fecha de entrega pendiente de validar'
    END AS observaciones

FROM generate_series(1, 3200) gs;
```

---

## 8. Carga de datos en `lineas_pedido_venta`

```sql
TRUNCATE TABLE lineas_pedido_venta;

WITH base AS (
    SELECT
        gs AS linea_id,

        CASE
            WHEN random() < 0.025 THEN NULL
            ELSE floor(1 + random()*3200)::int
        END AS pedido_id,

        CASE
            WHEN random() < 0.035 THEN NULL
            ELSE floor(1 + random()*2600)::int
        END AS producto_id,

        CASE
            WHEN random() < 0.025 THEN NULL
            ELSE ROUND((1 + random()*450)::numeric, 2)
        END AS cantidad,

        CASE
            WHEN random() < 0.035 THEN NULL
            ELSE ROUND((6 + random()*240)::numeric, 2)
        END AS precio_unitario,

        CASE
            WHEN random() < 0.18 THEN NULL
            ELSE ROUND((random()*15)::numeric, 2)
        END AS descuento_pct,

        random() AS r_importe_nulo,
        random() AS r_coste_nulo,
        random() AS r_margen_nulo,
        random() AS r_coste_ratio,
        random() AS r_observacion

    FROM generate_series(1, 5000) gs
),

calc AS (
    SELECT
        linea_id,
        pedido_id,
        producto_id,
        cantidad,
        precio_unitario,
        descuento_pct,

        CASE
            WHEN cantidad IS NULL OR precio_unitario IS NULL OR r_importe_nulo < 0.10 THEN NULL
            ELSE ROUND(
                (
                    cantidad 
                    * precio_unitario 
                    * (1 - COALESCE(descuento_pct, 0) / 100)
                )::numeric,
                2
            )
        END AS importe_linea,

        r_coste_nulo,
        r_margen_nulo,
        r_coste_ratio,
        r_observacion

    FROM base
),

calc2 AS (
    SELECT
        linea_id,
        pedido_id,
        producto_id,
        cantidad,
        precio_unitario,
        descuento_pct,
        importe_linea,

        CASE
            WHEN importe_linea IS NULL OR r_coste_nulo < 0.12 THEN NULL
            ELSE ROUND(
                (
                    importe_linea *
                    CASE
                        WHEN r_coste_ratio < 0.08 
                            THEN (1.05 + random()*0.25)::numeric
                        ELSE (0.55 + random()*0.35)::numeric
                    END
                )::numeric,
                2
            )
        END AS coste_estimado,

        r_margen_nulo,
        r_observacion

    FROM calc
)

INSERT INTO lineas_pedido_venta (
    linea_id,
    pedido_id,
    producto_id,
    cantidad,
    precio_unitario,
    descuento_pct,
    importe_linea,
    coste_estimado,
    margen_estimado,
    observaciones
)
SELECT
    linea_id,
    pedido_id,
    producto_id,
    cantidad,
    precio_unitario,
    descuento_pct,
    importe_linea,
    coste_estimado,

    CASE
        WHEN importe_linea IS NULL OR coste_estimado IS NULL OR r_margen_nulo < 0.08 THEN NULL
        ELSE ROUND((importe_linea - coste_estimado)::numeric, 2)
    END AS margen_estimado,

    CASE
        WHEN r_observacion < 0.76 THEN NULL
        WHEN r_observacion < 0.88 THEN 'Importe pendiente de validar'
        ELSE 'Coste estimado cargado manualmente'
    END AS observaciones

FROM calc2;
```

---

## 9. Carga de datos en `ordenes_fabricacion`

```sql
TRUNCATE TABLE ordenes_fabricacion;

WITH base AS (
    SELECT
        gs AS of_id,

        CASE
            WHEN random() < 0.03 THEN NULL
            WHEN random() < 0.20 THEN 'OF' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || LPAD(gs::text, 5, '0')
            WHEN random() < 0.35 THEN 'OF-' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || '-' || LPAD(gs::text, 5, '0')
            ELSE 'OF-' || LPAD(gs::text, 6, '0')
        END AS num_of,

        CASE
            WHEN random() < 0.14 THEN NULL
            ELSE floor(1 + random()*3200)::int
        END AS pedido_id,

        CASE
            WHEN random() < 0.04 THEN NULL
            ELSE floor(1 + random()*2600)::int
        END AS producto_id,

        DATE '2023-01-01' + floor(random()*720)::int AS fecha_lanzamiento,

        random() AS r_inicio_nulo,
        random() AS r_fin_real_nulo,
        random() AS r_cant_fab_nula,
        random() AS r_observacion
    FROM generate_series(1, 4200) gs
),

calc AS (
    SELECT
        of_id,
        num_of,
        pedido_id,
        producto_id,
        fecha_lanzamiento,

        CASE
            WHEN r_inicio_nulo < 0.07 THEN NULL
            ELSE fecha_lanzamiento + floor(random()*7)::int
        END AS fecha_inicio,

        fecha_lanzamiento + floor(8 + random()*28)::int AS fecha_fin_prevista,

        r_fin_real_nulo,
        r_cant_fab_nula,
        r_observacion,

        ROUND((5 + random()*500)::numeric, 2) AS cantidad_planificada

    FROM base
),

calc2 AS (
    SELECT
        of_id,
        num_of,
        pedido_id,
        producto_id,
        fecha_lanzamiento,
        fecha_inicio,
        fecha_fin_prevista,

        CASE
            WHEN r_fin_real_nulo < 0.20 THEN NULL
            ELSE fecha_fin_prevista + floor(-3 + random()*12)::int
        END AS fecha_fin_real,

        cantidad_planificada,

        CASE
            WHEN r_cant_fab_nula < 0.10 THEN NULL
            ELSE ROUND((cantidad_planificada * (0.85 + random()*0.25))::numeric, 2)
        END AS cantidad_fabricada,

        r_observacion

    FROM calc
)

INSERT INTO ordenes_fabricacion (
    of_id,
    num_of,
    pedido_id,
    producto_id,
    fecha_lanzamiento,
    fecha_inicio,
    fecha_fin_prevista,
    fecha_fin_real,
    cantidad_planificada,
    cantidad_fabricada,
    estado,
    responsable,
    prioridad,
    observaciones
)
SELECT
    of_id,
    num_of,
    pedido_id,
    producto_id,
    fecha_lanzamiento,
    fecha_inicio,
    fecha_fin_prevista,
    fecha_fin_real,
    cantidad_planificada,
    cantidad_fabricada,

    CASE
        WHEN fecha_fin_real IS NULL THEN
            (ARRAY['Lanzada', 'En curso', 'EN CURSO', 'Pendiente', '', NULL])[floor(random()*6)::int + 1]
        ELSE
            (ARRAY['Cerrada', 'cerrada', 'Finalizada', 'finalizada', 'CERRADO'])[floor(random()*5)::int + 1]
    END AS estado,

    (ARRAY[
        'Raúl Herrera',
        'R. Herrera',
        'Marta López',
        'M. Lopez',
        'Carlos Ruiz',
        'C. Ruiz',
        'Ana Pérez',
        'A. Perez',
        '',
        NULL
    ])[floor(random()*10)::int + 1] AS responsable,

    (ARRAY[
        'Normal',
        'normal',
        'Alta',
        'alta',
        'Urgente',
        'URG',
        'Baja',
        '',
        NULL
    ])[floor(random()*9)::int + 1] AS prioridad,

    CASE
        WHEN r_observacion < 0.78 THEN NULL
        WHEN r_observacion < 0.88 THEN 'OF creada manualmente por planificación'
        ELSE 'Cantidad fabricada pendiente de validar'
    END AS observaciones

FROM calc2;
```

---

## 10. Carga de datos en `partes_produccion`

```sql
TRUNCATE TABLE partes_produccion;

WITH base AS (
    SELECT
        gs AS parte_id,

        CASE
            WHEN random() < 0.04 THEN NULL
            ELSE DATE '2023-01-01' + floor(random()*720)::int
        END AS fecha,

        CASE
            WHEN random() < 0.07 THEN NULL
            WHEN random() < 0.22 THEN 'OF' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || LPAD((floor(1 + random()*4200)::int)::text, 5, '0')
            WHEN random() < 0.40 THEN 'OF-' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || '-' || LPAD((floor(1 + random()*4200)::int)::text, 5, '0')
            ELSE 'OF-' || LPAD((floor(1 + random()*4200)::int)::text, 6, '0')
        END AS num_of,

        (ARRAY[
            'CNC-01', 'CNC 1', 'cnc_01', 'CNC-02', 'CNC-03', 'CNC_04',
            'TOR-01', 'TOR 02', 'TOR-03', 'FRE-01', 'FRE-02', 'FRE 03',
            'LAS-01', 'LAS-02', 'Laser-2', 'LAS-03', 'PRE-01', 'PRE 02',
            'PLE-01', 'PLE_02', 'SOLD-01', 'SOLD 02', 'ROB-SOL1', 'TAL-01',
            'TAL 02', 'SIE-01', 'SIE 02', 'VER-01', 'VER 02', 'LAV-01',
            'EMB-01', '', NULL
        ])[floor(random()*33)::int + 1] AS maquina,

        (ARRAY[
            'Luis Gómez', 'L. Gomez', 'Luis G.', 'Ana Pérez', 'A. Perez',
            'Carlos Ruiz', 'C. Ruiz', 'Javier Martín', 'Marta López',
            'Sergio Fernández', 'Laura García', 'David Sánchez', 'Paula Rodríguez',
            'Miguel Torres', 'Elena Díaz', 'Raúl Herrera', 'Nuria Castro', '', NULL
        ])[floor(random()*19)::int + 1] AS operario,

        (ARRAY[
            'Mañana', 'M', 'mañana', 'Tarde', 'T', 'tarde', 'Noche', 'N',
            'Rotativo', '', NULL
        ])[floor(random()*11)::int + 1] AS turno,

        random() AS r_horas_nulas,
        random() AS r_unidades_nok_nulas,
        random() AS r_consumo_nulo,
        random() AS r_scrap_nulo,
        random() AS r_parada_nula,
        random() AS r_observacion

    FROM generate_series(1, 5000) gs
),

calc AS (
    SELECT
        parte_id,
        fecha,
        num_of,
        maquina,
        operario,
        turno,

        CASE
            WHEN r_horas_nulas < 0.06 THEN NULL
            ELSE ROUND((0.25 + random()*9.5)::numeric, 2)
        END AS horas_trabajadas,

        ROUND((1 + random()*250)::numeric, 2) AS unidades_ok,

        CASE
            WHEN r_unidades_nok_nulas < 0.14 THEN NULL
            ELSE ROUND((random()*18)::numeric, 2)
        END AS unidades_nok,

        CASE
            WHEN r_consumo_nulo < 0.08 THEN NULL
            ELSE ROUND((5 + random()*900)::numeric, 2)
        END AS kg_consumidos,

        CASE
            WHEN r_scrap_nulo < 0.13 THEN NULL
            ELSE ROUND((random()*55)::numeric, 2)
        END AS kg_scrap,

        CASE
            WHEN r_scrap_nulo < 0.35 THEN NULL
            ELSE
                (ARRAY[
                    'Rebaba', 'rebabas', 'Exceso rebaba', 'Error corte',
                    'error de corte', 'Taladro desplazado', 'Material defectuoso',
                    'Ajuste herramienta', 'Golpe pieza', 'Soldadura incorrecta', '', NULL
                ])[floor(random()*12)::int + 1]
        END AS motivo_scrap,

        CASE
            WHEN r_parada_nula < 0.20 THEN NULL
            ELSE ROUND((random()*180)::numeric, 2)
        END AS parada_minutos,

        CASE
            WHEN r_parada_nula < 0.45 THEN NULL
            ELSE
                (ARRAY[
                    'Cambio herramienta', 'cambio herramienta', 'Avería máquina',
                    'averia maquina', 'Falta material', 'Espera calidad',
                    'Ajuste programa', 'Limpieza', 'Sin operario', '', NULL
                ])[floor(random()*11)::int + 1]
        END AS motivo_parada,

        CASE
            WHEN r_observacion < 0.80 THEN NULL
            WHEN r_observacion < 0.90 THEN 'Parte cargado manualmente'
            ELSE 'Dato pendiente de validar por encargado'
        END AS observaciones

    FROM base
)

INSERT INTO partes_produccion (
    parte_id,
    fecha,
    num_of,
    maquina,
    operario,
    turno,
    horas_trabajadas,
    unidades_ok,
    unidades_nok,
    kg_consumidos,
    kg_scrap,
    motivo_scrap,
    parada_minutos,
    motivo_parada,
    observaciones
)
SELECT
    parte_id,
    fecha,
    num_of,
    maquina,
    operario,
    turno,
    horas_trabajadas,
    unidades_ok,
    unidades_nok,
    kg_consumidos,
    kg_scrap,
    motivo_scrap,
    parada_minutos,
    motivo_parada,
    observaciones
FROM calc;
```

---

## 11. Carga de datos en `incidencias_calidad`

```sql
TRUNCATE TABLE incidencias_calidad;

WITH base AS (
    SELECT
        gs AS incidencia_id,

        CASE
            WHEN random() < 0.05 THEN NULL
            ELSE DATE '2023-01-01' + floor(random()*720)::int
        END AS fecha,

        CASE
            WHEN random() < 0.10 THEN NULL
            WHEN random() < 0.28 THEN 'OF' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || LPAD((floor(1 + random()*4200)::int)::text, 5, '0')
            WHEN random() < 0.45 THEN 'OF-' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || '-' || LPAD((floor(1 + random()*4200)::int)::text, 5, '0')
            ELSE 'OF-' || LPAD((floor(1 + random()*4200)::int)::text, 6, '0')
        END AS num_of,

        CASE
            WHEN random() < 0.18 THEN NULL
            ELSE floor(1 + random()*3200)::int
        END AS pedido_id,

        (ARRAY[
            'Talleres Norte S.A.', 'TALLERES NORTE SA', 'Talleres Norte',
            'AgroMecánica Ruiz', 'Agromecanica Ruiz', 'Indusmetal Norte',
            'Metalúrgica del Norte', 'Mecanizados Costa', 'Cantabria Motion', '', NULL
        ])[floor(random()*11)::int + 1] AS cliente,

        (ARRAY[
            'Placa perforada 8mm', 'Placa perf. 8 mm', 'PLACA PERFORADA 8 MM',
            'Eje mecanizado 40mm', 'Eje mec. Ø40', 'Soporte soldado lateral',
            'Brida industrial', 'Casquillo calibrado', 'Guía metálica', '', NULL
        ])[floor(random()*11)::int + 1] AS producto,

        (ARRAY[
            'CNC-01', 'CNC 1', 'cnc_01', 'CNC-02', 'LAS-02', 'Laser-2',
            'SOLD-01', 'SOLD 02', 'TOR-01', 'FRE-01', '', NULL
        ])[floor(random()*12)::int + 1] AS maquina,

        (ARRAY[
            'Aceros Norte S.L.', 'ACEROS NORTE SL', 'Aceros Norte',
            'Aluminios Iberia', 'ALUMINIOS IBERIA S.A.', 'Tratamientos Cantabria',
            'Trat. Cantabria', '', NULL
        ])[floor(random()*9)::int + 1] AS proveedor,

        (ARRAY[
            'Rebaba', 'rebabas', 'Exceso rebaba', 'Taladro desplazado',
            'Error corte', 'error de corte', 'Soldadura defectuosa', 'soldadura',
            'Material defectuoso', 'Dimensión fuera tolerancia', 'Fuera tolerancia',
            'Golpe pieza', '', NULL
        ])[floor(random()*14)::int + 1] AS tipo_incidencia,

        CASE
            WHEN random() < 0.20 THEN NULL
            ELSE
                (ARRAY[
                    'Defecto detectado en inspección final',
                    'Incidencia comunicada por producción',
                    'Reclamación de cliente tras entrega',
                    'Material rechazado en recepción',
                    'Pieza requiere reproceso',
                    'No conformidad interna',
                    ''
                ])[floor(random()*7)::int + 1]
        END AS descripcion,

        (ARRAY[
            'Baja', 'baja', 'Media', 'media', 'Alta', 'ALTA', 'Crítica',
            'Critica', '', NULL
        ])[floor(random()*10)::int + 1] AS gravedad,

        CASE
            WHEN random() < 0.10 THEN NULL
            ELSE ROUND((1 + random()*80)::numeric, 2)
        END AS unidades_afectadas,

        CASE
            WHEN random() < 0.16 THEN NULL
            ELSE ROUND((50 + random()*3500)::numeric, 2)
        END AS coste_estimado,

        (ARRAY[
            'SI', 'Sí', 'S', 'NO', 'No', 'N', '', NULL
        ])[floor(random()*8)::int + 1] AS requiere_reproceso,

        CASE
            WHEN random() < 0.28 THEN NULL
            ELSE
                (ARRAY[
                    'Ajuste herramienta', 'ajuste herramienta', 'Error operario',
                    'error humano', 'Material defectuoso', 'Proveedor',
                    'Programa CNC incorrecto', 'Falta mantenimiento',
                    'Parámetro soldadura', 'No determinada', ''
                ])[floor(random()*11)::int + 1]
        END AS causa_raiz,

        (ARRAY[
            'Abierta', 'abierta', 'En análisis', 'en analisis', 'Cerrada',
            'cerrada', 'Pendiente proveedor', '', NULL
        ])[floor(random()*9)::int + 1] AS estado,

        (ARRAY[
            'Laura García', 'L. Garcia', 'Técnico Calidad', 'Tecnico calidad',
            'Raúl Herrera', 'R. Herrera', '', NULL
        ])[floor(random()*8)::int + 1] AS responsable

    FROM generate_series(1, 2600) gs
)

INSERT INTO incidencias_calidad (
    incidencia_id,
    fecha,
    num_of,
    pedido_id,
    cliente,
    producto,
    maquina,
    proveedor,
    tipo_incidencia,
    descripcion,
    gravedad,
    unidades_afectadas,
    coste_estimado,
    requiere_reproceso,
    causa_raiz,
    estado,
    responsable
)
SELECT
    incidencia_id,
    fecha,
    num_of,
    pedido_id,
    cliente,
    producto,
    maquina,
    proveedor,
    tipo_incidencia,
    descripcion,
    gravedad,
    unidades_afectadas,
    coste_estimado,
    requiere_reproceso,
    causa_raiz,
    estado,
    responsable
FROM base;
```

---

## 12. Carga de datos en `pedidos_compra`

```sql
TRUNCATE TABLE pedidos_compra;

WITH base AS (
    SELECT
        gs AS pedido_compra_id,

        CASE
            WHEN random() < 0.04 THEN NULL
            WHEN random() < 0.22 THEN 'PC' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || LPAD(gs::text, 5, '0')
            WHEN random() < 0.40 THEN 'PC-' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || '-' || LPAD(gs::text, 5, '0')
            ELSE 'COMP-' || LPAD(gs::text, 6, '0')
        END AS num_pedido_compra,

        CASE
            WHEN random() < 0.035 THEN NULL
            ELSE floor(1 + random()*150)::int
        END AS proveedor_id,

        CASE
            WHEN random() < 0.03 THEN NULL
            ELSE DATE '2023-01-01' + floor(random()*720)::int
        END AS fecha_pedido,

        random() AS r_prevista_nula,
        random() AS r_recepcion_nula,
        random() AS r_observacion
    FROM generate_series(1, 2800) gs
),

calc AS (
    SELECT
        pedido_compra_id,
        num_pedido_compra,
        proveedor_id,
        fecha_pedido,

        CASE
            WHEN fecha_pedido IS NULL OR r_prevista_nula < 0.08 THEN NULL
            ELSE fecha_pedido + floor(3 + random()*25)::int
        END AS fecha_prevista,

        r_recepcion_nula,
        r_observacion

    FROM base
),

calc2 AS (
    SELECT
        pedido_compra_id,
        num_pedido_compra,
        proveedor_id,
        fecha_pedido,
        fecha_prevista,

        CASE
            WHEN fecha_prevista IS NULL OR r_recepcion_nula < 0.18 THEN NULL
            ELSE fecha_prevista + floor(-2 + random()*14)::int
        END AS fecha_recepcion,

        r_observacion

    FROM calc
)

INSERT INTO pedidos_compra (
    pedido_compra_id,
    num_pedido_compra,
    proveedor_id,
    fecha_pedido,
    fecha_prevista,
    fecha_recepcion,
    estado,
    comprador,
    observaciones
)
SELECT
    pedido_compra_id,
    num_pedido_compra,
    proveedor_id,
    fecha_pedido,
    fecha_prevista,
    fecha_recepcion,

    CASE
        WHEN fecha_recepcion IS NULL THEN
            (ARRAY['Pendiente', 'pendiente', 'En curso', 'EN CURSO', 'Reclamado', '', NULL])[floor(random()*7)::int + 1]
        ELSE
            (ARRAY['Recibido', 'recibido', 'Cerrado', 'cerrado', 'Finalizado'])[floor(random()*5)::int + 1]
    END AS estado,

    (ARRAY[
        'Nuria Castro', 'N. Castro', 'Javier Peña', 'J. Peña',
        'Compras', 'Dpto. Compras', '', NULL
    ])[floor(random()*8)::int + 1] AS comprador,

    CASE
        WHEN r_observacion < 0.78 THEN NULL
        WHEN r_observacion < 0.88 THEN 'Pedido importado desde Excel de compras'
        ELSE 'Fecha de recepción pendiente de validar'
    END AS observaciones

FROM calc2;
```

---

## 13. Carga de datos en `lineas_pedido_compra`

```sql
TRUNCATE TABLE lineas_pedido_compra;

WITH base AS (
    SELECT
        gs AS linea_compra_id,

        CASE
            WHEN random() < 0.025 THEN NULL
            ELSE floor(1 + random()*2800)::int
        END AS pedido_compra_id,

        CASE
            WHEN random() < 0.035 THEN NULL
            ELSE floor(1 + random()*420)::int
        END AS material_id,

        CASE
            WHEN random() < 0.025 THEN NULL
            ELSE ROUND((5 + random()*2500)::numeric, 2)
        END AS cantidad_pedida,

        random() AS r_recibida_nula,
        random() AS r_precio_nulo,
        random() AS r_importe_nulo,
        random() AS r_calidad,
        random() AS r_observacion
    FROM generate_series(1, 4500) gs
),

calc AS (
    SELECT
        linea_compra_id,
        pedido_compra_id,
        material_id,
        cantidad_pedida,

        CASE
            WHEN cantidad_pedida IS NULL OR r_recibida_nula < 0.07 THEN NULL
            ELSE ROUND((cantidad_pedida * (0.85 + random()*0.20))::numeric, 2)
        END AS cantidad_recibida,

        (ARRAY[
            'kg', 'KG', 'kilos', 'ud', 'UD', 'unidad',
            'm', 'metro', 'litros', 'L', '', NULL
        ])[floor(random()*12)::int + 1] AS unidad,

        CASE
            WHEN r_precio_nulo < 0.08 THEN NULL
            ELSE ROUND((0.20 + random()*95)::numeric, 2)
        END AS precio_unitario,

        r_importe_nulo,
        r_calidad,
        r_observacion

    FROM base
),

calc2 AS (
    SELECT
        linea_compra_id,
        pedido_compra_id,
        material_id,
        cantidad_pedida,
        cantidad_recibida,
        unidad,
        precio_unitario,

        CASE
            WHEN cantidad_pedida IS NULL OR precio_unitario IS NULL OR r_importe_nulo < 0.10 THEN NULL
            ELSE ROUND((cantidad_pedida * precio_unitario)::numeric, 2)
        END AS importe_total,

        CASE
            WHEN r_calidad < 0.08 THEN 'SI'
            WHEN r_calidad < 0.13 THEN 'Sí'
            WHEN r_calidad < 0.18 THEN 'S'
            WHEN r_calidad < 0.55 THEN 'NO'
            WHEN r_calidad < 0.75 THEN 'No'
            WHEN r_calidad < 0.90 THEN 'N'
            WHEN r_calidad < 0.95 THEN ''
            ELSE NULL
        END AS incidencia_calidad,

        CASE
            WHEN r_observacion < 0.78 THEN NULL
            WHEN r_observacion < 0.88 THEN 'Cantidad recibida pendiente de validar'
            ELSE 'Precio cargado manualmente desde factura'
        END AS observaciones

    FROM calc
)

INSERT INTO lineas_pedido_compra (
    linea_compra_id,
    pedido_compra_id,
    material_id,
    cantidad_pedida,
    cantidad_recibida,
    unidad,
    precio_unitario,
    importe_total,
    incidencia_calidad,
    observaciones
)
SELECT
    linea_compra_id,
    pedido_compra_id,
    material_id,
    cantidad_pedida,
    cantidad_recibida,
    unidad,
    precio_unitario,
    importe_total,
    incidencia_calidad,
    observaciones
FROM calc2;
```

---

## 14. Carga de datos en `movimientos_almacen`

```sql
TRUNCATE TABLE movimientos_almacen;

WITH base AS (
    SELECT
        gs AS movimiento_id,

        CASE
            WHEN random() < 0.04 THEN NULL
            ELSE DATE '2023-01-01' + floor(random()*720)::int
        END AS fecha,

        CASE
            WHEN random() < 0.035 THEN NULL
            ELSE floor(1 + random()*420)::int
        END AS material_id,

        (ARRAY[
            'Entrada', 'entrada', 'ENT', 'Salida', 'salida',
            'Salida producción', 'salida produccion', 'Consumo OF',
            'consumo of', 'Ajuste', 'Regularizacion', 'Regularización',
            'Inventario', '', NULL
        ])[floor(random()*15)::int + 1] AS tipo_movimiento,

        CASE
            WHEN random() < 0.035 THEN NULL
            ELSE ROUND((1 + random()*1800)::numeric, 2)
        END AS cantidad,

        (ARRAY[
            'kg', 'KG', 'kilos', 'ud', 'UD', 'unidad',
            'm', 'metro', 'litros', 'L', '', NULL
        ])[floor(random()*12)::int + 1] AS unidad,

        (ARRAY[
            'Principal', 'principal', 'Almacén Materia Prima', 'Almacen MP',
            'MP', 'Producción', 'produccion', 'Expediciones', 'Calidad', '', NULL
        ])[floor(random()*11)::int + 1] AS almacen,

        CASE
            WHEN random() < 0.28 THEN NULL
            WHEN random() < 0.42 THEN 'OF' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || LPAD((floor(1 + random()*4200)::int)::text, 5, '0')
            WHEN random() < 0.60 THEN 'OF-' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || '-' || LPAD((floor(1 + random()*4200)::int)::text, 5, '0')
            ELSE 'OF-' || LPAD((floor(1 + random()*4200)::int)::text, 6, '0')
        END AS num_of,

        CASE
            WHEN random() < 0.35 THEN NULL
            WHEN random() < 0.50 THEN 'PC' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || LPAD((floor(1 + random()*2800)::int)::text, 5, '0')
            WHEN random() < 0.65 THEN 'PC-' || TO_CHAR(DATE '2023-01-01' + floor(random()*720)::int, 'YY') || '-' || LPAD((floor(1 + random()*2800)::int)::text, 5, '0')
            ELSE 'COMP-' || LPAD((floor(1 + random()*2800)::int)::text, 6, '0')
        END AS pedido_compra,

        CASE
            WHEN random() < 0.18 THEN NULL
            ELSE
                (ARRAY[
                    'Recepción proveedor', 'recepcion proveedor', 'Consumo fabricación',
                    'Consumo fabricacion', 'Ajuste inventario', 'Regularización stock',
                    'regularizacion stock', 'Devolución proveedor', 'Devolucion proveedor',
                    'Material defectuoso', 'Corrección manual', '', NULL
                ])[floor(random()*13)::int + 1]
        END AS motivo,

        (ARRAY[
            'almacen01', 'Almacen01', 'produccion', 'Producción',
            'compras', 'Compras', 'calidad', 'Calidad', '', NULL
        ])[floor(random()*10)::int + 1] AS usuario,

        CASE
            WHEN random() < 0.80 THEN NULL
            WHEN random() < 0.90 THEN 'Movimiento importado desde Excel de almacén'
            ELSE 'Cantidad pendiente de validar'
        END AS observaciones

    FROM generate_series(1, 5000) gs
)

INSERT INTO movimientos_almacen (
    movimiento_id,
    fecha,
    material_id,
    tipo_movimiento,
    cantidad,
    unidad,
    almacen,
    num_of,
    pedido_compra,
    motivo,
    usuario,
    observaciones
)
SELECT
    movimiento_id,
    fecha,
    material_id,
    tipo_movimiento,
    cantidad,
    unidad,
    almacen,
    num_of,
    pedido_compra,
    motivo,
    usuario,
    observaciones
FROM base;
```

---

## 15. Carga de datos en `averias_mantenimiento`

```sql
TRUNCATE TABLE averias_mantenimiento;

WITH base AS (
    SELECT
        gs AS averia_id,

        CASE
            WHEN random() < 0.04 THEN NULL
            ELSE 
                TIMESTAMP '2023-01-01 06:00:00'
                + (floor(random()*720)::int || ' days')::interval
                + (floor(random()*16)::int || ' hours')::interval
                + (floor(random()*60)::int || ' minutes')::interval
        END AS fecha_inicio,

        (ARRAY[
            'CNC-01', 'CNC 1', 'cnc_01', 'CNC-02', 'CNC-03', 'CNC_04',
            'TOR-01', 'TOR 02', 'TOR-03', 'FRE-01', 'FRE-02', 'FRE 03',
            'LAS-01', 'LAS-02', 'Laser-2', 'LAS-03', 'PRE-01', 'PRE 02',
            'PLE-01', 'PLE_02', 'SOLD-01', 'SOLD 02', 'ROB-SOL1',
            'TAL-01', 'TAL 02', 'SIE-01', 'SIE 02', '', NULL
        ])[floor(random()*29)::int + 1] AS maquina,

        (ARRAY[
            'Herramienta', 'herramienta', 'Rotura herramienta', 'Sensor',
            'sensor', 'Eléctrica', 'electrica', 'Mecánica', 'mecanica',
            'Hidráulica', 'hidraulica', 'Neumática', 'neumatica',
            'Software CNC', 'Ajuste programa', 'Fuga aceite',
            'Sobrecalentamiento', '', NULL
        ])[floor(random()*19)::int + 1] AS tipo_averia,

        random() AS r_fecha_fin_nula,
        random() AS r_coste_nulo,
        random() AS r_observacion

    FROM generate_series(1, 2600) gs
),

calc AS (
    SELECT
        averia_id,
        fecha_inicio,

        CASE
            WHEN fecha_inicio IS NULL OR r_fecha_fin_nula < 0.18 THEN NULL
            ELSE 
                fecha_inicio
                + (floor(15 + random()*720)::int || ' minutes')::interval
        END AS fecha_fin,

        maquina,
        tipo_averia,

        CASE
            WHEN random() < 0.18 THEN NULL
            ELSE
                (ARRAY[
                    'Parada detectada durante producción',
                    'Aviso registrado por encargado de turno',
                    'Intervención correctiva de mantenimiento',
                    'Revisión preventiva convertida en correctiva',
                    'Máquina parada a la espera de recambio',
                    'Incidencia repetitiva pendiente de análisis',
                    ''
                ])[floor(random()*7)::int + 1]
        END AS descripcion,

        (ARRAY[
            'Miguel Torres', 'M. Torres', 'David Sánchez', 'D. Sanchez',
            'Técnico externo', 'Tecnico externo', 'Mantenimiento', '', NULL
        ])[floor(random()*9)::int + 1] AS tecnico,

        (ARRAY[
            'SI', 'Sí', 'S', 'NO', 'No', 'N', '', NULL
        ])[floor(random()*8)::int + 1] AS parada_produccion,

        CASE
            WHEN r_coste_nulo < 0.14 THEN NULL
            ELSE ROUND((30 + random()*2200)::numeric, 2)
        END AS coste_estimado,

        r_observacion

    FROM base
)

INSERT INTO averias_mantenimiento (
    averia_id,
    fecha_inicio,
    fecha_fin,
    maquina,
    tipo_averia,
    descripcion,
    tecnico,
    parada_produccion,
    coste_estimado,
    estado,
    observaciones
)
SELECT
    averia_id,
    fecha_inicio,
    fecha_fin,
    maquina,
    tipo_averia,
    descripcion,
    tecnico,
    parada_produccion,
    coste_estimado,

    CASE
        WHEN fecha_fin IS NULL THEN
            (ARRAY['Abierta', 'abierta', 'Pendiente', 'En curso', 'EN CURSO', '', NULL])[floor(random()*7)::int + 1]
        ELSE
            (ARRAY['Cerrada', 'cerrada', 'Resuelta', 'resuelta', 'Finalizada'])[floor(random()*5)::int + 1]
    END AS estado,

    CASE
        WHEN r_observacion < 0.78 THEN NULL
        WHEN r_observacion < 0.88 THEN 'Avería registrada manualmente'
        ELSE 'Fecha fin pendiente de validar'
    END AS observaciones

FROM calc;
```

---

## Siguiente paso

Después de cargar los datos, ejecutar el archivo:

```text
03_validation_queries.sql
```

Este archivo comprobará:

* Tablas existentes.
* Número de registros por tabla.
* Volumen total de la base de datos.
* Problemas de calidad del dato.

