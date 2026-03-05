-- ========================================
-- SCRIPT CORRECTO: Crear Tablas de Productos de Contención
-- Este script es compatible con las entidades Java del backend
-- ========================================

USE lytiks_db;

-- ========================================
-- PASO 1: Crear tabla 'producto' (si no existe)
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
-- PASO 2: Crear tabla 'productos_contencion' con relación a 'producto'
-- ========================================
CREATE TABLE IF NOT EXISTS productos_contencion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    presentacion VARCHAR(255),
    dosis_sugerida VARCHAR(500),
    url VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON DELETE CASCADE
);

-- ========================================
-- PASO 3: Limpiar datos existentes (opcional)
-- ========================================
-- DELETE FROM productos_contencion;
-- DELETE FROM producto;

-- ========================================
-- PASO 4: Insertar productos base en tabla 'producto'
-- ========================================
INSERT INTO producto (nombre, detalle, cantidad, peso_kg) VALUES
('Golden Crop', 'Producto para contención MOKO', 1, 1.0),
('Previotik Crop', 'Producto biológico para contención', 1, 6.6),
('Saferbacter', 'Bacteria beneficiosa para control', 1, 0.25),
('Safersoil Trichoderma', 'Hongo antagonista para biocontrol', 1, 0.25)
ON DUPLICATE KEY UPDATE 
    detalle = VALUES(detalle),
    cantidad = VALUES(cantidad),
    peso_kg = VALUES(peso_kg);

-- ========================================
-- PASO 5: Insertar datos en 'productos_contencion'
-- ========================================
INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '1L',
    '1L/400L/agua/ha',
    'https://example.com/productos/golden-crop'
FROM producto p 
WHERE p.nombre = 'Golden Crop'
ON DUPLICATE KEY UPDATE 
    presentacion = VALUES(presentacion),
    dosis_sugerida = VALUES(dosis_sugerida);

INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '6.6kg',
    '6.6kg/ha (con fertilizante)',
    'https://example.com/productos/previotik-crop'
FROM producto p 
WHERE p.nombre = 'Previotik Crop'
ON DUPLICATE KEY UPDATE 
    presentacion = VALUES(presentacion),
    dosis_sugerida = VALUES(dosis_sugerida);

INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '250g',
    '250g/400L/agua/ha',
    'https://example.com/productos/saferbacter'
FROM producto p 
WHERE p.nombre = 'Saferbacter'
ON DUPLICATE KEY UPDATE 
    presentacion = VALUES(presentacion),
    dosis_sugerida = VALUES(dosis_sugerida);

INSERT INTO productos_contencion (id_producto, presentacion, dosis_sugerida, url)
SELECT 
    p.id_producto,
    '250g',
    '250g/400L/agua/ha',
    'https://example.com/productos/safersoil-trichoderma'
FROM producto p 
WHERE p.nombre = 'Safersoil Trichoderma'
ON DUPLICATE KEY UPDATE 
    presentacion = VALUES(presentacion),
    dosis_sugerida = VALUES(dosis_sugerida);

-- ========================================
-- PASO 6: Verificar la inserción
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
-- RESUMEN
-- ========================================
SELECT 
    'Productos base' AS tabla,
    COUNT(*) AS total 
FROM producto
UNION ALL
SELECT 
    'Productos contención' AS tabla,
    COUNT(*) AS total 
FROM productos_contencion;
