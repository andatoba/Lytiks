CREATE TABLE IF NOT EXISTS moko_capacitacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    hacienda_id BIGINT NULL,
    lote_id BIGINT NULL,
    hacienda VARCHAR(255) NULL,
    lote VARCHAR(255) NOT NULL,
    tema VARCHAR(255) NOT NULL,
    descripcion TEXT NULL,
    participantes INT NULL,
    fotos_json LONGTEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_moko_capacitacion_cliente (cliente_id),
    KEY idx_moko_capacitacion_lote (lote)
);
