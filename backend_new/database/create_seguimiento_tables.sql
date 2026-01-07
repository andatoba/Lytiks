-- Script para crear tablas de seguimiento de aplicaciones
-- Ejecutar este script en la base de datos MySQL

-- Tabla para aplicaciones (ya existe, pero agregar campos si faltan)
CREATE TABLE IF NOT EXISTS aplicaciones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    producto_nombre VARCHAR(255),
    plan VARCHAR(255) DEFAULT 'Moko',
    lote VARCHAR(255),
    area_hectareas DECIMAL(10,2),
    dosis VARCHAR(255),
    fecha_inicio DATETIME,
    frecuencia_dias INT DEFAULT 7,
    repeticiones INT DEFAULT 4,
    recordatorio_hora VARCHAR(10) DEFAULT '08:00',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla para seguimiento de aplicaciones
CREATE TABLE IF NOT EXISTS seguimiento_aplicaciones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    aplicacion_id BIGINT NOT NULL,
    numero_aplicacion INT NOT NULL,
    fecha_programada DATETIME NOT NULL,
    fecha_aplicada DATETIME NULL,
    estado VARCHAR(50) DEFAULT 'programada', -- completada, programada, proxima, vencida
    dosis_aplicada VARCHAR(255),
    lote VARCHAR(255),
    observaciones TEXT,
    foto_evidencia VARCHAR(500),
    recordatorio_activo BOOLEAN DEFAULT TRUE,
    hora_recordatorio VARCHAR(10) DEFAULT '08:00',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (aplicacion_id) REFERENCES aplicaciones(id) ON DELETE CASCADE,
    INDEX idx_aplicacion_estado (aplicacion_id, estado),
    INDEX idx_fecha_programada (fecha_programada)
);

-- Verificar que las tablas fueron creadas
SHOW TABLES LIKE '%aplicacion%';
SHOW TABLES LIKE '%seguimiento%';

-- Mostrar estructura de las tablas
DESCRIBE aplicaciones;
DESCRIBE seguimiento_aplicaciones;