-- =====================================================
-- TABLAS PARA PLAN DE SEGUIMIENTO DE MOKO
-- =====================================================

-- Tabla: plan_seguimiento_moko (Fases/Etapas del protocolo)
CREATE TABLE IF NOT EXISTS plan_seguimiento_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    detalle TEXT,
    orden INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    -- Campos de auditoría
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: productos_seg_moko (Productos utilizados en el protocolo)
CREATE TABLE IF NOT EXISTS productos_seg_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    detalle TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    -- Campos de auditoría
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: items_tareas_moko (Tareas/Actividades de cada fase)
CREATE TABLE IF NOT EXISTS items_tareas_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    id_prod_seg_moko BIGINT,
    dosis VARCHAR(50),
    id_plan_seg_moko BIGINT NOT NULL,
    orden INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    -- Campos de auditoría
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100),
    -- Foreign Keys
    FOREIGN KEY (id_prod_seg_moko) REFERENCES productos_seg_moko(id) ON DELETE SET NULL,
    FOREIGN KEY (id_plan_seg_moko) REFERENCES plan_seguimiento_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: ejecucion_plan_moko (Registro de ejecución por foco)
CREATE TABLE IF NOT EXISTS ejecucion_plan_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    foco_id BIGINT NOT NULL,
    id_plan_seg_moko BIGINT NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_inicio DATETIME,
    fecha_completado DATETIME,
    observaciones TEXT,
    -- Campos de auditoría
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100),
    -- Foreign Keys
    FOREIGN KEY (foco_id) REFERENCES registro_moko(id) ON DELETE CASCADE,
    FOREIGN KEY (id_plan_seg_moko) REFERENCES plan_seguimiento_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: ejecucion_tareas_moko (Registro de tareas completadas)
CREATE TABLE IF NOT EXISTS ejecucion_tareas_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    ejecucion_plan_id BIGINT NOT NULL,
    id_item_tarea BIGINT NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_completado DATETIME,
    observaciones TEXT,
    -- Campos de auditoría
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100),
    -- Foreign Keys
    FOREIGN KEY (ejecucion_plan_id) REFERENCES ejecucion_plan_moko(id) ON DELETE CASCADE,
    FOREIGN KEY (id_item_tarea) REFERENCES items_tareas_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para mejorar consultas
CREATE INDEX idx_items_plan ON items_tareas_moko(id_plan_seg_moko);
CREATE INDEX idx_items_producto ON items_tareas_moko(id_prod_seg_moko);
CREATE INDEX idx_ejecucion_foco ON ejecucion_plan_moko(foco_id);
CREATE INDEX idx_ejecucion_plan ON ejecucion_plan_moko(id_plan_seg_moko);
CREATE INDEX idx_ejecucion_tareas_plan ON ejecucion_tareas_moko(ejecucion_plan_id);

-- =====================================================
-- DATOS INICIALES - FASES DEL PROTOCOLO
-- =====================================================

INSERT INTO plan_seguimiento_moko (nombre, detalle, orden, fecha_creacion) VALUES
('LABORES EN FOCOS', 'Eliminación segura de plantas infectadas y reducción rápida del patógeno en el suelo.', 1, NOW()),
('VACÍO BIOLÓGICO', 'Periodo para disminuir la presencia del Moko y reforzar la desinfección del área.', 2, NOW()),
('ACTIVACIÓN SAR', 'Fortalecimiento de la defensa natural de las plantas sanas mediante bioestimulantes.', 3, NOW()),
('SUELOS SUPRESIVOS', 'Recuperación del suelo con microorganismos benéficos que reducen el riesgo de reinfección.', 4, NOW());

-- =====================================================
-- DATOS INICIALES - PRODUCTOS DEL PROTOCOLO
-- =====================================================

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion) VALUES
('GLIFOSATO', 'Herbicida sistémico para inyección', NOW()),
('DEGRADEX', 'Producto para aceleración de descomposición', NOW()),
('SAFERSOIL', 'Producto para tratamiento de suelo', NOW()),
('YODOSAFER', 'Desinfectante yodado', NOW()),
('CUPROSPOR', 'Fungicida cúprico', NOW()),
('ARMORUX', 'Bioestimulante para activación SAR', NOW()),
('AMINOALEXIN', 'Inductor de resistencia', NOW()),
('SINERJET CU', 'Cobre sinérgico', NOW()),
('GOLDEN CROP', 'Microorganismos benéficos', NOW()),
('SAFERBACTER', 'Bacterias benéficas para suelo', NOW());

-- =====================================================
-- DATOS INICIALES - TAREAS POR FASE
-- =====================================================

-- FASE 1: LABORES EN FOCOS
INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden) VALUES
('INYECCIÓN CON GLIFOSATO', (SELECT id FROM productos_seg_moko WHERE nombre = 'GLIFOSATO'), '50CC/UNIDAD BIOLÓGICA', (SELECT id FROM plan_seguimiento_moko WHERE orden = 1), 1),
('ACELERACIÓN DE DESCOMPOSICIÓN DEGRADEX + SAFERSOIL', (SELECT id FROM productos_seg_moko WHERE nombre = 'DEGRADEX'), '2 LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 1), 2),
('APLICACIÓN SAFERSOIL', (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERSOIL'), '200 GR', (SELECT id FROM plan_seguimiento_moko WHERE orden = 1), 3);

-- FASE 2: VACÍO BIOLÓGICO
INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden) VALUES
('PRIMER VACÍO - YODOSAFER', (SELECT id FROM productos_seg_moko WHERE nombre = 'YODOSAFER'), '3 LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 2), 1),
('PRIMER VACÍO - CUPROSPOR', (SELECT id FROM productos_seg_moko WHERE nombre = 'CUPROSPOR'), '3 LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 2), 2),
('SEGUNDO VACÍO - YODOSAFER', (SELECT id FROM productos_seg_moko WHERE nombre = 'YODOSAFER'), '3 LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 2), 3),
('SEGUNDO VACÍO - CUPROSPOR', (SELECT id FROM productos_seg_moko WHERE nombre = 'CUPROSPOR'), '3 LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 2), 4),
('TERCER VACÍO - YODOSAFER', (SELECT id FROM productos_seg_moko WHERE nombre = 'YODOSAFER'), '3 LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 2), 5),
('TERCER VACÍO - CUPROSPOR', (SELECT id FROM productos_seg_moko WHERE nombre = 'CUPROSPOR'), '3 LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 2), 6);

-- FASE 3: ACTIVACIÓN SAR
INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden) VALUES
('CICLO 1 - ARMORUX', (SELECT id FROM productos_seg_moko WHERE nombre = 'ARMORUX'), '1 L', (SELECT id FROM plan_seguimiento_moko WHERE orden = 3), 1),
('CICLO 1 - AMINOALEXIN', (SELECT id FROM productos_seg_moko WHERE nombre = 'AMINOALEXIN'), '0.5', (SELECT id FROM plan_seguimiento_moko WHERE orden = 3), 2),
('CICLO 2 - SINERJET CU', (SELECT id FROM productos_seg_moko WHERE nombre = 'SINERJET CU'), '0.5', (SELECT id FROM plan_seguimiento_moko WHERE orden = 3), 3),
('CICLO 2 - AMINOALEXIN', (SELECT id FROM productos_seg_moko WHERE nombre = 'AMINOALEXIN'), '0.5', (SELECT id FROM plan_seguimiento_moko WHERE orden = 3), 4),
('CICLO 3 - ARMORUX', (SELECT id FROM productos_seg_moko WHERE nombre = 'ARMORUX'), '1 L', (SELECT id FROM plan_seguimiento_moko WHERE orden = 3), 5),
('CICLO 3 - AMINOALEXIN', (SELECT id FROM productos_seg_moko WHERE nombre = 'AMINOALEXIN'), '0.5', (SELECT id FROM plan_seguimiento_moko WHERE orden = 3), 6);

-- FASE 4: SUELOS SUPRESIVOS
INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden) VALUES
('PRIMER CICLO - APLICACIÓN DE CHOQUE', (SELECT id FROM productos_seg_moko WHERE nombre = 'GOLDEN CROP'), '3LT', (SELECT id FROM plan_seguimiento_moko WHERE orden = 4), 1),
('PRIMER CICLO - SAFERBACTER', (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERBACTER'), '250 GR', (SELECT id FROM plan_seguimiento_moko WHERE orden = 4), 2),
('SEGUNDO CICLO - SAFERBACTER', (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERBACTER'), '250 GR', (SELECT id FROM plan_seguimiento_moko WHERE orden = 4), 3),
('TERCER CICLO - SAFERSOIL', (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERSOIL'), '250 GR', (SELECT id FROM plan_seguimiento_moko WHERE orden = 4), 4),
('CUARTO CICLO - SAFERBACTER', (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERBACTER'), '250 GR', (SELECT id FROM plan_seguimiento_moko WHERE orden = 4), 5);
