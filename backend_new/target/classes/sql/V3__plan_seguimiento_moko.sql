-- Plan de seguimiento de Moko (tablas + datos base)

CREATE TABLE IF NOT EXISTS plan_seguimiento_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    detalle TEXT,
    orden INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS productos_seg_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    detalle TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS items_tareas_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    id_prod_seg_moko BIGINT,
    dosis VARCHAR(50),
    id_plan_seg_moko BIGINT NOT NULL,
    orden INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100),
    FOREIGN KEY (id_prod_seg_moko) REFERENCES productos_seg_moko(id) ON DELETE SET NULL,
    FOREIGN KEY (id_plan_seg_moko) REFERENCES plan_seguimiento_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ejecucion_plan_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    foco_id BIGINT NOT NULL,
    id_plan_seg_moko BIGINT NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_inicio DATETIME,
    fecha_completado DATETIME,
    observaciones TEXT,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100),
    FOREIGN KEY (foco_id) REFERENCES registro_moko(id) ON DELETE CASCADE,
    FOREIGN KEY (id_plan_seg_moko) REFERENCES plan_seguimiento_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ejecucion_tareas_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    ejecucion_plan_id BIGINT NOT NULL,
    id_item_tarea BIGINT NOT NULL,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_completado DATETIME,
    observaciones TEXT,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion DATETIME,
    usuario_creacion VARCHAR(100),
    usuario_modificacion VARCHAR(100),
    FOREIGN KEY (ejecucion_plan_id) REFERENCES ejecucion_plan_moko(id) ON DELETE CASCADE,
    FOREIGN KEY (id_item_tarea) REFERENCES items_tareas_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_items_plan ON items_tareas_moko(id_plan_seg_moko);
CREATE INDEX idx_items_producto ON items_tareas_moko(id_prod_seg_moko);
CREATE INDEX idx_ejecucion_foco ON ejecucion_plan_moko(foco_id);
CREATE INDEX idx_ejecucion_plan ON ejecucion_plan_moko(id_plan_seg_moko);
CREATE INDEX idx_ejecucion_tareas_plan ON ejecucion_tareas_moko(ejecucion_plan_id);

-- Fases base (evitar duplicados)
INSERT INTO plan_seguimiento_moko (nombre, detalle, orden, fecha_creacion)
SELECT 'LABORES EN FOCOS',
       'Eliminación segura de plantas infectadas y reducción rápida del patógeno en el suelo.',
       1, NOW()
WHERE NOT EXISTS (SELECT 1 FROM plan_seguimiento_moko WHERE orden = 1);

INSERT INTO plan_seguimiento_moko (nombre, detalle, orden, fecha_creacion)
SELECT 'VACÍO BIOLÓGICO',
       'Periodo para disminuir la presencia del Moko y reforzar la desinfección del área.',
       2, NOW()
WHERE NOT EXISTS (SELECT 1 FROM plan_seguimiento_moko WHERE orden = 2);

INSERT INTO plan_seguimiento_moko (nombre, detalle, orden, fecha_creacion)
SELECT 'ACTIVACIÓN SAR',
       'Fortalecimiento de la defensa natural de las plantas sanas mediante bioestimulantes.',
       3, NOW()
WHERE NOT EXISTS (SELECT 1 FROM plan_seguimiento_moko WHERE orden = 3);

INSERT INTO plan_seguimiento_moko (nombre, detalle, orden, fecha_creacion)
SELECT 'SUELOS SUPRESIVOS',
       'Recuperación del suelo con microorganismos benéficos que reducen el riesgo de reinfección.',
       4, NOW()
WHERE NOT EXISTS (SELECT 1 FROM plan_seguimiento_moko WHERE orden = 4);

-- Productos base
INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'GLIFOSATO', 'Herbicida sistémico para inyección', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'GLIFOSATO');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'DEGRADEX', 'Producto para aceleración de descomposición', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'DEGRADEX');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'SAFERSOIL', 'Producto para tratamiento de suelo', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'SAFERSOIL');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'YODOSAFER', 'Desinfectante yodado', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'YODOSAFER');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'CUPROSPOR', 'Fungicida cúprico', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'CUPROSPOR');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'ARMORUX', 'Bioestimulante para activación SAR', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'ARMORUX');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'AMINOALEXIN', 'Inductor de resistencia', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'AMINOALEXIN');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'SINERJET CU', 'Cobre sinérgico', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'SINERJET CU');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'GOLDEN CROP', 'Microorganismos benéficos', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'GOLDEN CROP');

INSERT INTO productos_seg_moko (nombre, detalle, fecha_creacion)
SELECT 'SAFERBACTER', 'Bacterias benéficas para suelo', NOW()
WHERE NOT EXISTS (SELECT 1 FROM productos_seg_moko WHERE nombre = 'SAFERBACTER');

-- Tareas base por fase
INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'INYECCIÓN CON GLIFOSATO',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'GLIFOSATO' LIMIT 1),
       '50CC/UNIDAD BIOLÓGICA',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 1 LIMIT 1),
       1
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 1 LIMIT 1)
      AND orden = 1
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'ACELERACIÓN DE DESCOMPOSICIÓN DEGRADEX + SAFERSOIL',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'DEGRADEX' LIMIT 1),
       '2 LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 1 LIMIT 1),
       2
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 1 LIMIT 1)
      AND orden = 2
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'APLICACIÓN SAFERSOIL',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERSOIL' LIMIT 1),
       '200 GR',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 1 LIMIT 1),
       3
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 1 LIMIT 1)
      AND orden = 3
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'PRIMER VACÍO - YODOSAFER',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'YODOSAFER' LIMIT 1),
       '3 LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1),
       1
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1)
      AND orden = 1
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'PRIMER VACÍO - CUPROSPOR',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'CUPROSPOR' LIMIT 1),
       '3 LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1),
       2
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1)
      AND orden = 2
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'SEGUNDO VACÍO - YODOSAFER',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'YODOSAFER' LIMIT 1),
       '3 LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1),
       3
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1)
      AND orden = 3
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'SEGUNDO VACÍO - CUPROSPOR',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'CUPROSPOR' LIMIT 1),
       '3 LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1),
       4
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1)
      AND orden = 4
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'TERCER VACÍO - YODOSAFER',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'YODOSAFER' LIMIT 1),
       '3 LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1),
       5
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1)
      AND orden = 5
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'TERCER VACÍO - CUPROSPOR',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'CUPROSPOR' LIMIT 1),
       '3 LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1),
       6
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 2 LIMIT 1)
      AND orden = 6
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'CICLO 1 - ARMORUX',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'ARMORUX' LIMIT 1),
       '1 L',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1),
       1
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1)
      AND orden = 1
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'CICLO 1 - AMINOALEXIN',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'AMINOALEXIN' LIMIT 1),
       '0.5',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1),
       2
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1)
      AND orden = 2
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'CICLO 2 - SINERJET CU',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'SINERJET CU' LIMIT 1),
       '0.5',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1),
       3
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1)
      AND orden = 3
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'CICLO 2 - AMINOALEXIN',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'AMINOALEXIN' LIMIT 1),
       '0.5',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1),
       4
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1)
      AND orden = 4
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'CICLO 3 - ARMORUX',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'ARMORUX' LIMIT 1),
       '1 L',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1),
       5
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1)
      AND orden = 5
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'CICLO 3 - AMINOALEXIN',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'AMINOALEXIN' LIMIT 1),
       '0.5',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1),
       6
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 3 LIMIT 1)
      AND orden = 6
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'PRIMER CICLO - APLICACIÓN DE CHOQUE',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'GOLDEN CROP' LIMIT 1),
       '3LT',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1),
       1
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1)
      AND orden = 1
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'PRIMER CICLO - SAFERBACTER',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERBACTER' LIMIT 1),
       '250 GR',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1),
       2
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1)
      AND orden = 2
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'SEGUNDO CICLO - SAFERBACTER',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERBACTER' LIMIT 1),
       '250 GR',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1),
       3
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1)
      AND orden = 3
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'TERCER CICLO - SAFERSOIL',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERSOIL' LIMIT 1),
       '250 GR',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1),
       4
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1)
      AND orden = 4
);

INSERT INTO items_tareas_moko (nombre, id_prod_seg_moko, dosis, id_plan_seg_moko, orden)
SELECT 'CUARTO CICLO - SAFERBACTER',
       (SELECT id FROM productos_seg_moko WHERE nombre = 'SAFERBACTER' LIMIT 1),
       '250 GR',
       (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1),
       5
WHERE NOT EXISTS (
    SELECT 1 FROM items_tareas_moko
    WHERE id_plan_seg_moko = (SELECT id FROM plan_seguimiento_moko WHERE orden = 4 LIMIT 1)
      AND orden = 5
);
