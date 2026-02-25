-- Tabla para el seguimiento de ubicación de técnicos
-- Ejecutar en la base de datos lytiks_data

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
COMMENT='Tabla para almacenar el seguimiento de ubicación de técnicos cada 5 minutos durante horario laboral (8AM-4PM)';

-- Consultas útiles para verificación:

-- Ver todas las ubicaciones de hoy
-- SELECT * FROM location_tracking 
-- WHERE DATE(timestamp) = CURDATE() 
-- ORDER BY timestamp DESC;

-- Ver ubicaciones de un usuario específico hoy
-- SELECT * FROM location_tracking 
-- WHERE user_id = 'ID_USUARIO' 
-- AND DATE(timestamp) = CURDATE() 
-- ORDER BY timestamp DESC;

-- Ver ubicaciones en horario laboral (8AM-4PM)
-- SELECT * FROM location_tracking 
-- WHERE HOUR(timestamp) >= 8 AND HOUR(timestamp) < 16 
-- ORDER BY timestamp DESC;

-- Estadísticas por usuario
-- SELECT 
--     user_id, 
--     user_name, 
--     COUNT(*) as total_registros,
--     MIN(timestamp) as primer_registro,
--     MAX(timestamp) as ultimo_registro
-- FROM location_tracking 
-- GROUP BY user_id, user_name;

-- Limpiar registros antiguos (más de 90 días)
-- DELETE FROM location_tracking 
-- WHERE timestamp < DATE_SUB(NOW(), INTERVAL 90 DAY);
