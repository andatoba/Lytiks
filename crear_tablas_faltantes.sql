-- ============================================
-- TABLAS FALTANTES PARA LYTIKS
-- Ejecutar en base de datos: lytiks_db
-- ============================================

USE lytiks_db;

-- 1. TABLA: audit_categoria
CREATE TABLE IF NOT EXISTS audit_categoria (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    orden INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_audit_categoria_codigo (codigo),
    INDEX idx_audit_categoria_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. TABLA: audit_criterio
CREATE TABLE IF NOT EXISTS audit_criterio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    categoria_id BIGINT NOT NULL,
    nombre TEXT NOT NULL,
    puntuacion_maxima INT NOT NULL DEFAULT 100,
    orden INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_audit_criterio_categoria (categoria_id),
    INDEX idx_audit_criterio_activo (activo),
    CONSTRAINT fk_criterio_categoria FOREIGN KEY (categoria_id) 
        REFERENCES audit_categoria(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. TABLA: hacienda
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

-- 4. TABLA: lote
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
    INDEX idx_lote_estado (estado),
    UNIQUE KEY unique_lote_hacienda (hacienda_id, codigo),
    CONSTRAINT fk_lote_hacienda FOREIGN KEY (hacienda_id) REFERENCES hacienda(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. TABLA: configuracion_logo
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

-- ============================================
-- DATOS INICIALES
-- ============================================

-- Insertar categorías de auditoría
INSERT INTO audit_categoria (codigo, nombre, descripcion, orden) VALUES
('ENFUNDE', 'ENFUNDE', 'Evaluación de enfunde de racimos', 1),
('SELECCION', 'SELECCIÓN', 'Evaluación de selección de hijos', 2),
('COSECHA', 'COSECHA', 'Evaluación de cosecha', 3),
('DESHOJE_FITOSANITARIO', 'DESHOJE FITOSANITARIO', 'Evaluación de deshoje fitosanitario', 4),
('DESHOJE_NORMAL', 'DESHOJE NORMAL', 'Evaluación de deshoje normal', 5),
('DESVIO_HIJOS', 'DESVIO DE HIJOS', 'Evaluación de desvío de hijos', 6),
('APUNTALAMIENTO_ZUNCHO', 'APUNTALAMIENTO CON ZUNCHO', 'Evaluación de apuntalamiento con zuncho', 7),
('APUNTALAMIENTO_PUNTAL', 'APUNTALAMIENTO CON PUNTAL', 'Evaluación de apuntalamiento con puntal', 8),
('MANEJO_AGUAS_RIEGO', 'MANEJO DE AGUAS (RIEGO)', 'Evaluación de manejo de aguas - riego', 9),
('MANEJO_AGUAS_DRENAJE', 'MANEJO DE AGUAS (DRENAJE)', 'Evaluación de manejo de aguas - drenaje', 10)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para ENFUNDE
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(1, 'ATRASO DE LABOR E MAL IDENTIFICACION', 20, 1),
(1, 'RETOLDEO', 20, 2),
(1, 'CIRUGIA, SE ENCUENTRAN MELLIZOS', 20, 3),
(1, 'FALTA DE PROTECTORES Y/O MAL COLOCADO', 20, 4),
(1, 'SACUDIR BRACTEAS 2DA SUBIDA Y 3RA SUBIDA AL RACIMO', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para SELECCION
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(2, 'NO REALIZA DESFLORE', 20, 1),
(2, 'MAL ALINEADOS HIJOS', 20, 2),
(2, 'FALTA DE DISTRIBUCION DE EDADES', 20, 3),
(2, 'NO CONSIDERA LOS CRITERIOS DE SELECCIÓN', 20, 4),
(2, 'NO IDENTIFICA LAS PLANTAS A SELECCIONAR', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para COSECHA
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(3, 'PLANTA MAL CALIBRADA', 20, 1),
(3, 'NO CONSIDERA NORMA TECNICA DE COSECHA', 20, 2),
(3, 'ESTACION DE MANOS NO FUNCIONAL', 20, 3),
(3, 'CAMION Y CABLE VIA MAL UBICADO', 20, 4),
(3, 'FRUTA NO SE PROTEGE DE LOS RAYOS DEL SOL', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para DESHOJE FITOSANITARIO
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(4, 'MACHETE EN MAL ESTADO', 20, 1),
(4, 'NO DESINFECTA HERRAMIENTA', 20, 2),
(4, 'EPOCA DE CORTE INADECUADO', 20, 3),
(4, 'MALA ACTIVIDAD DE CORTE', 20, 4),
(4, 'NO SE CONSIDERA EL TRAZADO DEL CORTE', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para DESHOJE NORMAL
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(5, 'CORTE ANTES DE TIEMPO', 20, 1),
(5, 'HOJA TOTALMENTE SECA', 20, 2),
(5, 'NO SE DESINFECTA HERRAMIENTA', 20, 3),
(6, 'EPOCA DE CORTE INADECUADO', 20, 4),
(5, 'LAS HOJAS NO CUMPLEN CRITERIO DE CORTE', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para DESVIO DE HIJOS
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(6, 'NO DESINFECTA HERRAMIENTA', 20, 1),
(6, 'EPOCA DE CORTE INADECUADO', 20, 2),
(6, 'FALTA DE DISTRIBUCION DE EDADES', 20, 3),
(6, 'PLANTAS CON EXCESO DE HIJOS', 20, 4),
(6, 'NO HAY PLANEACION DE LA LABOR', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para APUNTALAMIENTO CON ZUNCHO
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(7, 'FALTA DE TENSION', 20, 1),
(7, 'MALA UBICACION DEL ZUNCHO EN LA PLANTA', 20, 2),
(7, 'ZUNCHO DEMASIADO ALTO O DEMASIADO BAJO', 20, 3),
(7, 'MATERIAL EN MAL ESTADO', 20, 4),
(7, 'NO SE REALIZA LA LABOR A TIEMPO', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para APUNTALAMIENTO CON PUNTAL
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(8, 'FALTA DE TENSION', 20, 1),
(8, 'MALA UBICACION DEL PUNTAL', 20, 2),
(8, 'MATERIAL EN MAL ESTADO', 20, 3),
(8, 'AMARRE INADECUADO', 20, 4),
(8, 'NO SE REALIZA LA LABOR A TIEMPO', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para MANEJO DE AGUAS (RIEGO)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(9, 'GOTEROS OBSTRUIDOS O DEFECTUOSOS', 20, 1),
(9, 'FUGAS EN TUBERIAS', 20, 2),
(9, 'PRESION INADECUADA', 20, 3),
(9, 'HORARIO DE RIEGO INADECUADO', 20, 4),
(9, 'NO SE REGISTRA LA ACTIVIDAD', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Insertar criterios para MANEJO DE AGUAS (DRENAJE)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(10, 'CANALES OBSTRUIDOS', 20, 1),
(10, 'PENDIENTE INADECUADA', 20, 2),
(10, 'FALTA DE MANTENIMIENTO', 20, 3),
(10, 'ENCHARCAMIENTOS FRECUENTES', 20, 4),
(10, 'NO SE REGISTRA LA ACTIVIDAD', 20, 5)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 'Tablas creadas exitosamente' as status;
SELECT COUNT(*) as total_categorias FROM audit_categoria;
SELECT COUNT(*) as total_criterios FROM audit_criterio;

SHOW TABLES LIKE '%audit%';
SHOW TABLES LIKE '%hacienda%';
SHOW TABLES LIKE '%lote%';
SHOW TABLES LIKE '%logo%';
