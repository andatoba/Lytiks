-- Script SQL para crear la tabla configuraciones_aplicacion en MySQL
-- Ejecutar este script en la base de datos de Lytiks

CREATE TABLE IF NOT EXISTS configuraciones_aplicacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    foco_id BIGINT NOT NULL,
    fase_id BIGINT NOT NULL,
    tarea_id BIGINT NOT NULL,
    nombre_tarea VARCHAR(500) NOT NULL,
    fecha_programada DATETIME NOT NULL,
    frecuencia INT NOT NULL COMMENT 'Frecuencia en días',
    repeticiones INT NOT NULL,
    recordatorio VARCHAR(50) NOT NULL,
    completado TINYINT(1) NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL,
    fecha_completado DATETIME NULL,
    observaciones TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_foco_id (foco_id),
    INDEX idx_fase_id (fase_id),
    INDEX idx_tarea_id (tarea_id),
    INDEX idx_fecha_programada (fecha_programada),
    INDEX idx_completado (completado),
    UNIQUE KEY uk_foco_fase_tarea (foco_id, fase_id, tarea_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comentarios de la tabla
ALTER TABLE configuraciones_aplicacion 
    COMMENT = 'Configuraciones de aplicación de tareas en planes de seguimiento Moko';
