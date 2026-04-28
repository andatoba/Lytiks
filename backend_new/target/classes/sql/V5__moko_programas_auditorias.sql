CREATE TABLE IF NOT EXISTS configuraciones_aplicacion (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    foco_id BIGINT NOT NULL,
    fase_id BIGINT NOT NULL,
    tarea_id BIGINT NOT NULL,
    nombre_tarea VARCHAR(500) NOT NULL,
    fecha_programada DATETIME NOT NULL,
    frecuencia INT NOT NULL,
    repeticiones INT NOT NULL,
    recordatorio VARCHAR(100) NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_completado DATETIME NULL,
    observaciones LONGTEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_configuracion_aplicacion (foco_id, fase_id, tarea_id),
    KEY idx_configuracion_aplicacion_foco (foco_id),
    KEY idx_configuracion_aplicacion_foco_fase (foco_id, fase_id),
    KEY idx_configuracion_aplicacion_pendientes (foco_id, completado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS moko_contencion_auditoria (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    foco_id BIGINT NOT NULL,
    numero_foco INT NULL,
    cliente_id BIGINT NULL,
    observaciones_generales LONGTEXT NULL,
    recomendaciones LONGTEXT NULL,
    payload_json LONGTEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_moko_contencion_auditoria_foco (foco_id),
    CONSTRAINT fk_moko_contencion_auditoria_foco
        FOREIGN KEY (foco_id) REFERENCES registro_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS moko_preventivo_auditoria (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    foco_id BIGINT NOT NULL,
    numero_foco INT NULL,
    fecha_inicio_plan DATETIME NULL,
    payload_json LONGTEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_moko_preventivo_auditoria_foco (foco_id),
    CONSTRAINT fk_moko_preventivo_auditoria_foco
        FOREIGN KEY (foco_id) REFERENCES registro_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
