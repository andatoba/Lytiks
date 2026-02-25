-- Script para verificar y diagnosticar el seguimiento de ubicación
-- Ejecutar en MySQL

USE lytiks_data;

-- 1. VERIFICAR SI LA TABLA EXISTE
SHOW TABLES LIKE 'location_tracking';
-- Si retorna una fila, la tabla existe
-- Si retorna "Empty set", la tabla NO existe (ejecutar paso 2)

-- 2. CREAR LA TABLA SI NO EXISTE
CREATE TABLE IF NOT EXISTS location_tracking (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    user_name VARCHAR(255),
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    accuracy DOUBLE,
    matrix_latitude DOUBLE,
    matrix_longitude DOUBLE,
    timestamp DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_user_timestamp (user_id, timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Seguimiento GPS de técnicos (cada 5 segundos, 8AM-6PM)';

-- 3. VERIFICAR ESTRUCTURA DE LA TABLA
DESCRIBE location_tracking;

-- 4. CONTAR TOTAL DE REGISTROS
SELECT COUNT(*) as total_registros FROM location_tracking;

-- 5. VER ÚLTIMOS 10 REGISTROS (CUALQUIER FECHA)
SELECT 
    id,
    user_name,
    latitude,
    longitude,
    timestamp,
    created_at
FROM location_tracking
ORDER BY timestamp DESC
LIMIT 10;

-- 6. VER REGISTROS DE HOY
SELECT 
    id,
    user_name,
    latitude,
    longitude,
    timestamp,
    TIMESTAMPDIFF(SECOND, 
        LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp), 
        timestamp
    ) AS segundos_desde_anterior
FROM location_tracking
WHERE DATE(timestamp) = CURDATE()
ORDER BY timestamp DESC
LIMIT 20;

-- 7. VER REGISTROS POR USUARIO (CUALQUIER FECHA)
SELECT 
    user_id,
    user_name,
    COUNT(*) as total_registros,
    MIN(timestamp) as primera_captura,
    MAX(timestamp) as ultima_captura,
    MIN(DATE(timestamp)) as primera_fecha,
    MAX(DATE(timestamp)) as ultima_fecha
FROM location_tracking
GROUP BY user_id, user_name
ORDER BY ultima_captura DESC;

-- 8. VER DISTRIBUCIÓN POR HORA (ÚLTIMOS 7 DÍAS)
SELECT 
    DATE(timestamp) as fecha,
    HOUR(timestamp) as hora,
    COUNT(*) as capturas
FROM location_tracking
WHERE timestamp >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(timestamp), HOUR(timestamp)
ORDER BY fecha DESC, hora;

-- 9. VERIFICAR REGISTROS DE LA ÚLTIMA HORA
SELECT 
    id,
    user_name,
    latitude,
    longitude,
    timestamp,
    TIMESTAMPDIFF(MINUTE, timestamp, NOW()) as minutos_atras
FROM location_tracking
WHERE timestamp >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
ORDER BY timestamp DESC;

-- 10. INSERTAR UN REGISTRO DE PRUEBA (para verificar que la tabla funciona)
-- Descomentar y ejecutar si quieres probar:
/*
INSERT INTO location_tracking (
    user_id, 
    user_name, 
    latitude, 
    longitude, 
    accuracy, 
    timestamp
) VALUES (
    'test_user', 
    'Usuario de Prueba', 
    -0.9320, 
    -79.6540, 
    10.0, 
    NOW()
);
*/

-- 11. VER EL REGISTRO DE PRUEBA
-- SELECT * FROM location_tracking WHERE user_id = 'test_user';

-- 12. ELIMINAR REGISTRO DE PRUEBA
-- DELETE FROM location_tracking WHERE user_id = 'test_user';
