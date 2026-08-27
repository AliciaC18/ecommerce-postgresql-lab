# 🛒 Sistema de Control de Inventarios y Ventas (E-Commerce)

Un modelo de base de datos relacional desarrollado en **PostgreSQL 16** diseñado para gestionar usuarios, catálogo de productos, órdenes de compra y control automático de stock mediante disparadores (*triggers*).

---

## 🚀 Características Principales

- **Diseño Relacional Normalizado:** Modelado de entidades con llaves primarias, llaves foráneas y restricciones de integridad (`CHECK`, `UNIQUE`, `NOT NULL`).
- **Automatización de Inventario:** Implementación de funciones y *triggers* en PL/pgSQL que descuentan automáticamente el stock de productos tras registrar un detalle de pedido.
- **Capa de Análisis y Reportes:** Creación de **Vistas (`VIEW`)** y consultas complejas (`JOIN`, `GROUP BY`, `COALESCE`, `WITH / CTEs`) para consolidados de ventas por cliente.
- **Transaccionalidad (ACID):** Control estricto de transacciones mediante `BEGIN`, `COMMIT` y `ROLLBACK` para evitar incoherencias en datos.

---

## 🛠️ Tecnologías Utilizadas

- **Base de Datos:** PostgreSQL 16
- **Cliente / GUI:** pgAdmin 4 / DBeaver
- **Lenguaje:** SQL, PL/pgSQL

---

## 📊 Modelo Entidad-Relación (Estructura de Tablas)

El modelo está compuesto por 4 tablas principales:

1. `clientes`: Almacena información básica de los usuarios registrados.
2. `productos`: Catálogo general con precios y existencias (`stock`).
3. `pedidos`: Cabecera de las órdenes asociadas a un cliente.
4. `detalle_pedidos`: Ítems asociados a cada pedido con cantidad y precio pagado.

---

## ⚡ Automatización en Acción (Triggers)

El script incluye una función que mantiene actualizado el inventario en tiempo real:

```sql
CREATE OR REPLACE FUNCTION actualizar_stock_producto()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE producto_id = NEW.producto_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## 📈 Consultas de Negocio Destacadas

### 1. Reporte Consolidado de Ventas por Cliente (Vista)
Muestra el gasto total por usuario, incluyendo clientes inactivos ($0.00) mediante `LEFT JOIN` y `COALESCE`:

```sql
SELECT * FROM vista_reporte_ventas;
```

### 2. Análisis de Clientes VIP (CTE / Subconsulta)
Identifica usuarios cuyo consumo superó el promedio general de ventas de la plataforma.

---

## 📦 Instrucciones de Ejecución

1. Clonar este repositorio:
   ```bash
   git clone [https://github.com/TU_USUARIO/ecommerce-postgresql-lab.git](https://github.com/TU_USUARIO/ecommerce-postgresql-lab.git)
   ```
2. Abrir **pgAdmin 4** o tu cliente SQL preferido.
3. Crear una base de datos limpia:
   ```sql
   CREATE DATABASE laboratorio_db;
   ```
4. Abrir la herramienta de consulta (*Query Tool*), cargar el archivo `sql/01_schema_and_data.sql` y ejecutar.

---

## ✍️ Autora

- **Carmen Capote** - *TSU en Informática & Desarrolladora SQL / PostgreSQL*
- 📩 [Correo electrónico](mailto:carali1922@gmail.com)
