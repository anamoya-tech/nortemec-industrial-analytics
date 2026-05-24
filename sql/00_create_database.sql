# 00_create_database.sql

## Objetivo

Este script crea la base de datos principal del proyecto **Nortemec Industrial Analytics**.

La base de datos se llama:

```sql
nortemec_operaciones
```

Esta base almacenará las tablas operativas de la empresa ficticia **Nortemec Precision Components S.L.**, simulando un entorno industrial real con datos procedentes de:

* Clientes
* Productos
* Ventas
* Producción
* Calidad
* Compras
* Almacén
* Mantenimiento

---

## Script SQL

```sql
CREATE DATABASE nortemec_operaciones;
```

---

## Cómo ejecutarlo en pgAdmin 4

1. Abrir **pgAdmin 4**.
2. Conectarse al servidor PostgreSQL.
3. Seleccionar la base de datos por defecto:

```text
postgres
```

4. Abrir **Query Tool**.
5. Pegar y ejecutar:

```sql
CREATE DATABASE nortemec_operaciones;
```

6. Hacer clic derecho en **Databases**.
7. Seleccionar **Refresh**.
8. Comprobar que aparece la base de datos:

```text
nortemec_operaciones
```

---

## Comprobación

Para comprobar que la base de datos se ha creado correctamente:

```sql
SELECT datname
FROM pg_database
WHERE datname = 'nortemec_operaciones';
```

Resultado esperado:

```text
nortemec_operaciones
```

---

## Nota importante

Este script debe ejecutarse desde una base de datos existente, normalmente `postgres`.

No debe ejecutarse conectado a `nortemec_operaciones`, porque esa base de datos todavía no existe antes de lanzar este script.

---

## Siguiente paso

Después de crear la base de datos, conectarse a:

```text
nortemec_operaciones
```

y ejecutar el siguiente archivo:

```text
01_create_tables.sql
```
