-- Tabla para el seguimiento de focos de Moko
CREATE TABLE seguimiento_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    foco_id BIGINT NOT NULL,
    numero_foco INT NOT NULL,
    semana_inicio INT,
    plantas_afectadas INT NOT NULL,
    plantas_inyectadas INT NOT NULL,
    control_vectores BOOLEAN NOT NULL DEFAULT FALSE,
    cuarentena_activa BOOLEAN NOT NULL DEFAULT FALSE,
    unica_entrada_habilitada BOOLEAN NOT NULL DEFAULT FALSE,
    eliminacion_maleza_hospedera BOOLEAN NOT NULL DEFAULT FALSE,
    control_picudo_aplicado BOOLEAN NOT NULL DEFAULT FALSE,
    inspeccion_plantas_vecinas BOOLEAN NOT NULL DEFAULT FALSE,
    corte_riego BOOLEAN NOT NULL DEFAULT FALSE,
    pediluvio_activo BOOLEAN NOT NULL DEFAULT FALSE,
    ppm_solucion_desinfectante INT,
    fecha_seguimiento DATETIME NOT NULL,
    fecha_creacion DATETIME NOT NULL,
    
    -- Índices para mejorar consultas
    INDEX idx_foco_id (foco_id),
    INDEX idx_numero_foco (numero_foco),
    INDEX idx_fecha_seguimiento (fecha_seguimiento),
    INDEX idx_semana_inicio (semana_inicio),
    INDEX idx_pediluvio_activo (pediluvio_activo),
    INDEX idx_cuarentena_activa (cuarentena_activa),
    
    -- Relación con la tabla registro_moko
    FOREIGN KEY (foco_id) REFERENCES registro_moko(id) ON DELETE CASCADE
);

-- Comentarios para documentar la tabla
ALTER TABLE seguimiento_moko COMMENT = 'Tabla para registrar el seguimiento de focos de Moko con medidas de control implementadas';

-- Comentarios en columnas
ALTER TABLE seguimiento_moko 
    MODIFY COLUMN foco_id BIGINT NOT NULL COMMENT 'ID del foco en registro_moko',
    MODIFY COLUMN numero_foco INT NOT NULL COMMENT 'Número secuencial del foco',
    MODIFY COLUMN semana_inicio INT COMMENT 'Semana del año cuando se detectó el foco',
    MODIFY COLUMN plantas_afectadas INT NOT NULL COMMENT 'Número actual de plantas afectadas',
    MODIFY COLUMN plantas_inyectadas INT NOT NULL COMMENT 'Número de plantas que han sido inyectadas',
    MODIFY COLUMN control_vectores BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si se ha implementado control de vectores',
    MODIFY COLUMN cuarentena_activa BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si la cuarentena está activa',
    MODIFY COLUMN unica_entrada_habilitada BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si solo hay una entrada habilitada',
    MODIFY COLUMN eliminacion_maleza_hospedera BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si se ha eliminado maleza hospedera',
    MODIFY COLUMN control_picudo_aplicado BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si se ha aplicado control de picudo',
    MODIFY COLUMN inspeccion_plantas_vecinas BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si se han inspeccionado plantas vecinas',
    MODIFY COLUMN corte_riego BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si se ha cortado el riego',
    MODIFY COLUMN pediluvio_activo BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Si el pediluvio está activo',
    MODIFY COLUMN ppm_solucion_desinfectante INT COMMENT 'Concentración PPM de la solución desinfectante',
    MODIFY COLUMN fecha_seguimiento DATETIME NOT NULL COMMENT 'Fecha y hora del seguimiento',
    MODIFY COLUMN fecha_creacion DATETIME NOT NULL COMMENT 'Fecha y hora de creación del registro';

-- Insertar algunos datos de ejemplo para pruebas (opcional)
-- Nota: Asegúrate de que existan registros en registro_moko antes de ejecutar estos inserts

/*
INSERT INTO seguimiento_moko (
    foco_id, 
    numero_foco, 
    semana_inicio, 
    plantas_afectadas, 
    plantas_inyectadas,
    control_vectores,
    cuarentena_activa,
    unica_entrada_habilitada,
    eliminacion_maleza_hospedera,
    control_picudo_aplicado,
    inspeccion_plantas_vecinas,
    corte_riego,
    pediluvio_activo,
    ppm_solucion_desinfectante,
    fecha_seguimiento,
    fecha_creacion
) VALUES 
(1, 1, 45, 15, 10, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 200, NOW(), NOW()),
(2, 2, 46, 8, 5, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, 150, NOW(), NOW()),
(3, 3, 47, 20, 18, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, 250, NOW(), NOW());
*/