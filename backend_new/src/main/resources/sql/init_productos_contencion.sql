-- Script para inicializar productos de contención MOKO según especificaciones
-- Ejecutar este script en la base de datos MySQL

-- Crear tabla si no existe
CREATE TABLE IF NOT EXISTS productos_contencion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    presentacion VARCHAR(255),
    dosis_sugerida VARCHAR(500),
    url VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Limpiar productos existentes
DELETE FROM productos_contencion;

-- Insertar productos según especificaciones
INSERT INTO productos_contencion (nombre, presentacion, dosis_sugerida, url) VALUES
('Golden Crop', '1L', '1L/400L/agua/ha', 'https://example.com/productos/golden-crop'),
('Previotik Crop', '6.6kg', '6.6kg/ha (con fertilizante)', 'https://example.com/productos/previotik-crop'),
('Saferbacter', '250g', '250g/400L/agua/ha', 'https://example.com/productos/saferbacter'),
('Safersoil Trichoderma', '250g', '250g/400L/agua/ha', 'https://example.com/productos/safersoil-trichoderma');

-- Verificar inserción
SELECT id, nombre, presentacion, dosis_sugerida FROM productos_contencion ORDER BY id;