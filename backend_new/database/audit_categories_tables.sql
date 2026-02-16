-- Tabla de categorías de auditoría
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

-- Tabla de criterios de evaluación por categoría
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

-- Insertar categorías existentes
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
('MANEJO_AGUAS_DRENAJE', 'MANEJO DE AGUAS (DRENAJE)', 'Evaluación de manejo de aguas - drenaje', 10);

-- Insertar criterios para ENFUNDE (categoria_id = 1)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(1, 'ATRASO DE LABOR E MAL IDENTIFICACION', 20, 1),
(1, 'RETOLDEO', 20, 2),
(1, 'CIRUGIA, SE ENCUENTRAN MELLIZOS', 20, 3),
(1, 'FALTA DE PROTECTORES Y/O MAL COLOCADO', 20, 4),
(1, 'SACUDIR BRACTEAS 2DA SUBIDA Y 3RA SUBIDA AL RACIMO', 20, 5);

-- Insertar criterios para SELECCION (categoria_id = 2)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(2, 'MALA DISTRIBUCION Y/O DEJA PLANTAS SIN SELECTAR', 20, 1),
(2, 'MALA SELECCION DE HIJOS', 20, 2),
(2, 'DOBLE EN EXCESO', 20, 3),
(2, 'MAL CANCELADOS', 20, 4),
(2, 'NO GENERA DOBLES PERIFERICOS', 20, 5);

-- Insertar criterios para COSECHA (categoria_id = 3)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(3, 'FFE + FFI (6.01% a 7.99%)', 10, 1),
(3, 'FFE + FFI (8 a 9%)', 15, 2),
(3, 'FFE+FFI (>=9.01%)', 20, 3),
(3, 'NO SE LLEVA PARCELA DE CALIBRACION', 15, 4),
(3, 'LIBRO DE AR (LLEVA REGISTRO DIARIO DE LOTES COSECHADOS)', 20, 5);

-- Insertar criterios para DESHOJE FITOSANITARIO (categoria_id = 4)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(4, 'TEJIDO NECROTICO SIN CORTAR', 40, 1),
(4, 'ELIMINAN TEJIDO VERDE Y/O CON ESTRIAS', 30, 2),
(4, 'LA LONGITUD DE LA PALANCA NO ES LA CORRECTA', 30, 3);

-- Insertar criterios para DESHOJE NORMAL (categoria_id = 5)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(5, 'HOJA TOCANDO RACIMO Y/O HOJA PUENTE SIN CORTAR', 25, 1),
(5, 'ELIMINA HOJAS VERDES', 25, 2),
(5, 'DEJA HOJA BAJERA', 25, 3),
(5, 'DEJAN CODOS', 25, 4);

-- Insertar criterios para DESVIO DE HIJOS (categoria_id = 6)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(6, 'SIN DESVIAR', 50, 1),
(6, 'HIJOS MALTRATADOS', 50, 2);

-- Insertar criterios para APUNTALAMIENTO CON ZUNCHO (categoria_id = 7)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(7, 'ZUNCHO FLOJO Y/O MAL ANGULO MAL COLOCADO', 25, 1),
(7, 'MATAS CAIDAS MAYOR A 3% DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE', 25, 2),
(7, 'UTILIZA ESTAQUILLA PARA MEJORAR ANGULO DENTRO DE LA PLANTACION Y CABLE VIA', 25, 3),
(7, 'AMARRE EN HIJOS Y/O EN PLANTAS CON RACIMOS +9 SEM', 25, 4);

-- Insertar criterios para APUNTALAMIENTO CON PUNTAL (categoria_id = 8)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(8, 'PUNTAL FLOJO Y/O MAL ANGULO', 20, 1),
(8, 'MATAS CAIDAS MAYOR A 3% DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE', 20, 2),
(8, 'UN PUNTAL', 20, 3),
(8, 'PUNTAL ROZANDO RACIMO Y/O DAÑA PARTE BASAL DE LA HOJA', 20, 4),
(8, 'PUNTAL PODRIDO', 20, 5);

-- Insertar criterios para MANEJO DE AGUAS (RIEGO) (categoria_id = 9)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(9, 'SATURACION DE AREA SIN CAPACIDAD DE CAMPO', 20, 1),
(9, 'CUMPLIMIENTO DE TURNOS DE RIEGO', 20, 2),
(9, 'SE OBSERVAN TRIANGULO SECOS', 15, 3),
(9, 'SE OBSERVAN FUGAS', 15, 4),
(9, 'FALTA DE ASPERSORES', 15, 5),
(9, 'Lotes con frecuencia mayor a 5 días / mala planificación de cosecha', 15, 6),
(9, 'PRESION INADECUADA (ALTA O BAJA)', 15, 7);

-- Insertar criterios para MANEJO DE AGUAS (DRENAJE) (categoria_id = 10)
INSERT INTO audit_criterio (categoria_id, nombre, puntuacion_maxima, orden) VALUES
(10, 'AGUAS RETENIDAS', 35, 1),
(10, 'CANALES SUCIOS', 35, 2),
(10, 'ENCHARCAMIENTO POR FALTA DE DRENAJE', 30, 3);
