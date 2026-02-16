-- ============================================
-- NUEVAS TABLAS PARA HACIENDA, LOTE Y LOGO
-- ============================================

-- Tabla de configuración de logo
CREATE TABLE IF NOT EXISTS configuracion_logo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ruta_logo VARCHAR(500) NOT NULL,
    logo_base64 LONGTEXT,
    tipo_mime VARCHAR(100),
    activo TINYINT(1) DEFAULT 1,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_logo_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de haciendas
CREATE TABLE IF NOT EXISTS hacienda (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    detalle TEXT,
    ubicacion VARCHAR(500),
    hectareas DOUBLE,
    cliente_id BIGINT NOT NULL,
    estado VARCHAR(50) DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(255),
    usuario_actualizacion VARCHAR(255),
    INDEX idx_hacienda_cliente (cliente_id),
    INDEX idx_hacienda_nombre (nombre),
    INDEX idx_hacienda_estado (estado),
    CONSTRAINT fk_hacienda_cliente FOREIGN KEY (cliente_id) REFERENCES clients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de lotes
CREATE TABLE IF NOT EXISTS lote (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    codigo VARCHAR(100) NOT NULL,
    detalle TEXT,
    hectareas DOUBLE,
    variedad VARCHAR(100),
    edad VARCHAR(50),
    hacienda_id BIGINT NOT NULL,
    estado VARCHAR(50) DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(255),
    usuario_actualizacion VARCHAR(255),
    INDEX idx_lote_hacienda (hacienda_id),
    INDEX idx_lote_codigo (codigo),
    INDEX idx_lote_nombre (nombre),
    INDEX idx_lote_estado (estado),
    CONSTRAINT fk_lote_hacienda FOREIGN KEY (hacienda_id) REFERENCES hacienda(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Actualizar tabla sigatoka_evaluacion para incluir referencias a hacienda y lote
ALTER TABLE sigatoka_evaluacion 
ADD COLUMN hacienda_id BIGINT NULL AFTER cliente_id,
ADD COLUMN lote_id BIGINT NULL AFTER hacienda_id,
ADD INDEX idx_sigatoka_hacienda (hacienda_id),
ADD INDEX idx_sigatoka_lote (lote_id),
ADD CONSTRAINT fk_sigatoka_hacienda FOREIGN KEY (hacienda_id) REFERENCES hacienda(id) ON DELETE SET NULL,
ADD CONSTRAINT fk_sigatoka_lote FOREIGN KEY (lote_id) REFERENCES lote(id) ON DELETE SET NULL;

-- Insertar logo por defecto
INSERT INTO configuracion_logo (nombre, ruta_logo, activo, descripcion)
VALUES ('Logo Principal Lytiks', 'assets/images/logo2.png', 1, 'Logo principal de la aplicación Lytiks')
ON DUPLICATE KEY UPDATE activo = 1;

-- Datos de ejemplo para haciendas (migrar desde clients.finca_nombre)
INSERT INTO hacienda (nombre, detalle, cliente_id, estado)
SELECT DISTINCT 
    COALESCE(finca_nombre, CONCAT('Hacienda - ', nombre)) as nombre,
    CONCAT('Hectáreas: ', COALESCE(finca_hectareas, 0), ' - Cultivos: ', COALESCE(cultivos_principales, 'N/A')) as detalle,
    id as cliente_id,
    estado
FROM clients
WHERE finca_nombre IS NOT NULL OR id IS NOT NULL
ON DUPLICATE KEY UPDATE nombre = nombre;
