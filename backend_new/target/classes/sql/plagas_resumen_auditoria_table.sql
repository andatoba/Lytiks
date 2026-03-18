CREATE TABLE IF NOT EXISTS plagas_resumen_auditoria (
    id BIGINT NOT NULL AUTO_INCREMENT,
    client_id BIGINT NOT NULL,
    tecnico_id BIGINT NULL,
    fecha DATE NOT NULL,
    lote VARCHAR(255) NOT NULL,
    plaga VARCHAR(255) NOT NULL,
    total_huevo INT NULL,
    total_pequena INT NULL,
    total_mediana INT NULL,
    total_grande INT NULL,
    total_individuos INT NULL,
    porcentaje_danio DECIMAL(8,2) NULL,
    promedio_huevo DECIMAL(8,2) NULL,
    promedio_pequena DECIMAL(8,2) NULL,
    promedio_mediana DECIMAL(8,2) NULL,
    promedio_grande DECIMAL(8,2) NULL,
    promedio_total DECIMAL(8,2) NULL,
    promedio_danio DECIMAL(8,2) NULL,
    porcentaje_huevo DECIMAL(8,2) NULL,
    porcentaje_pequena DECIMAL(8,2) NULL,
    porcentaje_mediana DECIMAL(8,2) NULL,
    porcentaje_grande DECIMAL(8,2) NULL,
    numero_muestras INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_plagas_client_id (client_id),
    KEY idx_plagas_fecha (fecha),
    KEY idx_plagas_tecnico (tecnico_id),
    CONSTRAINT fk_plagas_resumen_client
        FOREIGN KEY (client_id)
        REFERENCES clients (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
