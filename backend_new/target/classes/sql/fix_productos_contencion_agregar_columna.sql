-- ========================================
-- FIX: Agregar columna id_producto a productos_contencion
-- ========================================
-- Error actual: Unknown column 'p1_0.id_producto' in 'field list'
-- Solución: Modificar tabla existente para agregar columna faltante
-- ========================================

USE lytiks_db;

-- ========================================
-- PASO 1: Verificar estructura actual
-- ========================================
DESCRIBE productos_contencion;

-- ========================================
-- PASO 2: Crear tabla 'producto' si no existe
-- ========================================
CREATE TABLE IF NOT EXISTS producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    detalle TEXT,
    cantidad INT,
    peso_kg DOUBLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ========================================
-- PASO 3: Agregar columna id_producto a productos_contencion
-- ========================================
-- Verificar si la columna ya existe antes de agregarla
SET @column_exists = (
    SELECT COUNT(*) 
    FROM information_schema.columns 
    WHERE table_schema = 'lytiks_db' 
    AND table_name = 'productos_contencion' 
    AND column_name = 'id_producto'
);

-- Solo agregar si no existe
ALTER TABLE productos_contencion 
ADD COLUMN IF NOT EXISTS id_producto INT AFTER id;

-- ========================================
-- PASO 4: Eliminar columna 'nombre' si existe (no debería estar aquí)
-- ========================================
-- En productos_contencion, el nombre viene de la tabla producto
SET @nombre_existe = (
    SELECT COUNT(*) 
    FROM information_schema.columns 
    WHERE table_schema = 'lytiks_db' 
    AND table_name = 'productos_contencion' 
    AND column_name = 'nombre'
);

-- Si existe la columna nombre, la eliminamos
ALTER TABLE productos_contencion 
DROP COLUMN IF EXISTS nombre;

-- ========================================
-- PASO 5: Agregar Foreign Key si no existe
-- ========================================
-- Verificar si ya existe la constraint
SET @fk_exists = (
    SELECT COUNT(*) 
    FROM information_schema.table_constraints 
    WHERE table_schema = 'lytiks_db' 
    AND table_name = 'productos_contencion' 
    AND constraint_type = 'FOREIGN KEY'
    AND constraint_name = 'fk_productos_contencion_producto'
);

-- Agregar constraint si no existe
SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE productos_contencion ADD CONSTRAINT fk_productos_contencion_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON DELETE CASCADE',
    'SELECT "FK ya existe" AS mensaje'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ========================================
-- PASO 6: Limpiar datos existentes e insertar correctamente
-- ========================================
-- Limpiar datos anteriores (porque no tenían id_producto)
DELETE FROM productos_contencion;

-- Insertar productos base en tabla 'producto'
INSERT INTO producto (nombre, detalle, cantidad, peso_kg) VALUES
('Golden Crop', 'Producto para contención MOKO', 1, 1.0),
('Previotik Crop', 'Producto biológico para contención', 1, 6.6),
('Saferbacter', 'Bacteria beneficiosa para control', 1, 0.25),
('Safersoil Trichoderma', 'Hongo antagonista para biocontrol', 1, 0.25)
ON DUPLICATE KEY UPDATE 
    detalle = VALUES(detalle),
    cantidad = VALUES(cantidad),
    peso_kg = VALUES(peso_kg);

-- Insertar productos de contención con relación correcta
INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '1L',
    '1L/400L/agua/ha',
    'https://example.com/productos/golden-crop'
FROM producto p 
WHERE p.nombre = 'Golden Crop';

INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '6.6kg',
    '6.6kg/ha (con fertilizante)',
    'https://example.com/productos/previotik-crop'
FROM producto p 
WHERE p.nombre = 'Previotik Crop';

INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '250g',
    '250g/400L/agua/ha',
    'https://example.com/productos/saferbacter'
FROM producto p 
WHERE p.nombre = 'Saferbacter';

INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '250g',
    '250g/400L/agua/ha',
    'https://example.com/productos/safersoil-trichoderma'
FROM producto p 
WHERE p.nombre = 'Safersoil Trichoderma';

-- ========================================
-- PASO 7: Verificar estructura corregida
-- ========================================
DESCRIBE productos_contencion;

-- ========================================
-- PASO 8: Verificar datos insertados
-- ========================================
SELECT 
    pc.id,
    p.id_producto,
    p.nombre,
    pc.presentacion,
    pc.dosis_sugerida
FROM productos_contencion pc
INNER JOIN producto p ON pc.id_producto = p.id_producto
ORDER BY pc.id;

-- ========================================
-- RESUMEN FINAL
-- ========================================
SELECT '✅ FIX COMPLETADO' AS Estado;
SELECT 
    'Productos base' AS tabla,
    COUNT(*) AS total 
FROM producto
UNION ALL
SELECT 
    'Productos contención' AS tabla,
    COUNT(*) AS total 
FROM productos_contencion;
