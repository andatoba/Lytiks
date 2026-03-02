-- Script para consultar la tabla productos_contencion
-- Ejecutar en MySQL

USE lytiks_db;

-- 1. VER ESTRUCTURA DE LA TABLA
DESCRIBE productos_contencion;

-- 2. VER TODOS LOS PRODUCTOS
SELECT * FROM productos_contencion;

-- 3. VER PRODUCTOS CON FORMATO (sin URL para mejor lectura)
SELECT 
    id,
    nombre,
    presentacion,
    dosis_sugerida,
    created_at,
    updated_at
FROM productos_contencion 
ORDER BY id;

-- 4. CONTAR PRODUCTOS
SELECT COUNT(*) as total_productos FROM productos_contencion;

-- 5. BUSCAR PRODUCTO POR NOMBRE (ejemplo)
-- SELECT * FROM productos_contencion WHERE nombre LIKE '%Golden%';

-- 6. VER SOLO NOMBRES Y PRESENTACIONES
SELECT id, nombre, presentacion FROM productos_contencion ORDER BY nombre;
