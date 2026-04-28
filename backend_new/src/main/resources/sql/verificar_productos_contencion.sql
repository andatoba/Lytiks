-- ========================================
-- SCRIPT DE VERIFICACIÓN: Productos de Contención
-- ========================================

USE lytiks_db;

-- 1. VERIFICAR SI EXISTE LA TABLA 'producto'
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Tabla producto EXISTE'
        ELSE '❌ Tabla producto NO EXISTE'
    END AS estado_tabla_producto
FROM information_schema.tables 
WHERE table_schema = 'lytiks_db' 
AND table_name = 'producto';

-- 2. VERIFICAR SI EXISTE LA TABLA 'productos_contencion'
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Tabla productos_contencion EXISTE'
        ELSE '❌ Tabla productos_contencion NO EXISTE'
    END AS estado_tabla_productos_contencion
FROM information_schema.tables 
WHERE table_schema = 'lytiks_db' 
AND table_name = 'productos_contencion';

-- 3. VER ESTRUCTURA DE LA TABLA 'producto' (si existe)
DESCRIBE producto;

-- 4. VER ESTRUCTURA DE LA TABLA 'productos_contencion' (si existe)
DESCRIBE productos_contencion;

-- 5. VER DATOS EN LA TABLA 'producto' (si existe)
SELECT * FROM producto;

-- 6. VER DATOS EN LA TABLA 'productos_contencion' (si existe)
SELECT * FROM productos_contencion;

-- 7. VERIFICAR RELACIONES (FOREIGN KEYS)
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'lytiks_db'
AND TABLE_NAME = 'productos_contencion'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 8. CONTAR REGISTROS
SELECT 
    (SELECT COUNT(*) FROM producto) AS total_productos,
    (SELECT COUNT(*) FROM productos_contencion) AS total_productos_contencion;
