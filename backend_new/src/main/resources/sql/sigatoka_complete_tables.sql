-- ============================================
-- SISTEMA DE EVALUACIÓN DE SIGATOKA
-- Base de datos completa con cálculos automáticos
-- ============================================

-- Tabla principal de evaluación
CREATE TABLE IF NOT EXISTS sigatoka_evaluacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    hacienda VARCHAR(255) NOT NULL,
    fecha_muestreo DATE NOT NULL,
    semana_epidemiologica INT NOT NULL,
    periodo VARCHAR(50) NOT NULL,
    evaluador VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    estado VARCHAR(50) DEFAULT 'ACTIVO',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de muestras individuales
CREATE TABLE IF NOT EXISTS sigatoka_muestra (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL,
    numero_muestra INT NOT NULL,
    lote VARCHAR(100),
    
    -- Grados de infección por hoja
    grado_3era_hoja VARCHAR(10),  -- ej: 2a, 3c, etc.
    grado_4ta_hoja VARCHAR(10),
    grado_5ta_hoja VARCHAR(10),
    
    -- Total de hojas por nivel
    total_hojas_3era INT DEFAULT 0,
    total_hojas_4ta INT DEFAULT 0,
    total_hojas_5ta INT DEFAULT 0,
    total_hojas_general INT DEFAULT 0,
    
    -- Variables Stover Semana 0
    hvle_semana_0 DECIMAL(10,2) DEFAULT 0,
    hvlq_semana_0 DECIMAL(10,2) DEFAULT 0,
    hvlq5_semana_0 DECIMAL(10,2) DEFAULT 0,
    th_semana_0 DECIMAL(10,2) DEFAULT 0,
    
    -- Variables Stover Semana 10
    hvle_semana_10 DECIMAL(10,2) DEFAULT 0,
    hvlq_semana_10 DECIMAL(10,2) DEFAULT 0,
    hvlq5_semana_10 DECIMAL(10,2) DEFAULT 0,
    th_semana_10 DECIMAL(10,2) DEFAULT 0,
    
    -- Campos calculados por muestra (para 3era, 4ta, 5ta hoja)
    plantas_muestreadas_3era INT DEFAULT 0,
    plantas_con_lesiones_3era INT DEFAULT 0,
    total_lesiones_3era INT DEFAULT 0,
    plantas_3er_estadio_3era INT DEFAULT 0,
    total_letras_3era INT DEFAULT 0,
    
    plantas_muestreadas_4ta INT DEFAULT 0,
    plantas_con_lesiones_4ta INT DEFAULT 0,
    total_lesiones_4ta INT DEFAULT 0,
    plantas_3er_estadio_4ta INT DEFAULT 0,
    total_letras_4ta INT DEFAULT 0,
    
    plantas_muestreadas_5ta INT DEFAULT 0,
    plantas_con_lesiones_5ta INT DEFAULT 0,
    total_lesiones_5ta INT DEFAULT 0,
    plantas_3er_estadio_5ta INT DEFAULT 0,
    total_letras_5ta INT DEFAULT 0,
    
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE,
    UNIQUE KEY unique_muestra (evaluacion_id, numero_muestra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de resumen general por evaluación (calculado)
CREATE TABLE IF NOT EXISTS sigatoka_resumen (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    
    -- Resumen 3era Hoja
    total_plantas_3era INT DEFAULT 0,
    total_plantas_lesiones_3era INT DEFAULT 0,
    total_lesiones_3era INT DEFAULT 0,
    total_plantas_3er_estadio_3era INT DEFAULT 0,
    total_letras_3era INT DEFAULT 0,
    
    -- Resumen 4ta Hoja
    total_plantas_4ta INT DEFAULT 0,
    total_plantas_lesiones_4ta INT DEFAULT 0,
    total_lesiones_4ta INT DEFAULT 0,
    total_plantas_3er_estadio_4ta INT DEFAULT 0,
    total_letras_4ta INT DEFAULT 0,
    
    -- Resumen 5ta Hoja
    total_plantas_5ta INT DEFAULT 0,
    total_plantas_lesiones_5ta INT DEFAULT 0,
    total_lesiones_5ta INT DEFAULT 0,
    total_plantas_3er_estadio_5ta INT DEFAULT 0,
    total_letras_5ta INT DEFAULT 0,
    
    -- Totales de hojas funcionales
    total_hojas_funcionales INT DEFAULT 0,
    
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de indicadores calculados (f, g, h, i, j, k)
CREATE TABLE IF NOT EXISTS sigatoka_indicadores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    
    -- Indicadores 3era Hoja
    promedio_lesiones_planta_3era DECIMAL(10,2) DEFAULT 0,  -- f = c/a
    porcentaje_plantas_3er_estadio_3era DECIMAL(10,2) DEFAULT 0,  -- g = (d/b)*100
    porcentaje_plantas_lesiones_3era DECIMAL(10,2) DEFAULT 0,  -- h = (b/a)*100
    total_hojas_funcionales_3era INT DEFAULT 0,  -- i
    promedio_hojas_utiles_3era DECIMAL(10,2) DEFAULT 0,  -- j = i/a
    promedio_letras_3era DECIMAL(10,2) DEFAULT 0,  -- k = e/a
    
    -- Indicadores 4ta Hoja
    promedio_lesiones_planta_4ta DECIMAL(10,2) DEFAULT 0,
    porcentaje_plantas_3er_estadio_4ta DECIMAL(10,2) DEFAULT 0,
    porcentaje_plantas_lesiones_4ta DECIMAL(10,2) DEFAULT 0,
    total_hojas_funcionales_4ta INT DEFAULT 0,
    promedio_hojas_utiles_4ta DECIMAL(10,2) DEFAULT 0,
    promedio_letras_4ta DECIMAL(10,2) DEFAULT 0,
    
    -- Indicadores 5ta Hoja
    promedio_lesiones_planta_5ta DECIMAL(10,2) DEFAULT 0,
    porcentaje_plantas_3er_estadio_5ta DECIMAL(10,2) DEFAULT 0,
    porcentaje_plantas_lesiones_5ta DECIMAL(10,2) DEFAULT 0,
    total_hojas_funcionales_5ta INT DEFAULT 0,
    promedio_hojas_utiles_5ta DECIMAL(10,2) DEFAULT 0,
    promedio_letras_5ta DECIMAL(10,2) DEFAULT 0,
    
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de estado evolutivo e interpretación
CREATE TABLE IF NOT EXISTS sigatoka_estado_evolutivo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    
    -- Estado Evolutivo por hoja (EE = f * factor * k)
    estado_evolutivo_3era DECIMAL(10,2) DEFAULT 0,  -- f * 120 * k
    estado_evolutivo_4ta DECIMAL(10,2) DEFAULT 0,   -- f * 100 * k
    estado_evolutivo_5ta DECIMAL(10,2) DEFAULT 0,   -- f * 80 * k
    
    -- Nivel interpretado (BAJO, MODERADO, ALTO)
    nivel_3era VARCHAR(20),
    nivel_4ta VARCHAR(20),
    nivel_5ta VARCHAR(20),
    
    -- Interpretación general
    interpretacion_general TEXT,
    nivel_general VARCHAR(20),
    
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de promedios Stover reales
CREATE TABLE IF NOT EXISTS sigatoka_stover_promedio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    
    -- Promedios Semana 0
    promedio_hvle_semana_0 DECIMAL(10,2) DEFAULT 0,
    promedio_hvlq_semana_0 DECIMAL(10,2) DEFAULT 0,
    promedio_hvlq5_semana_0 DECIMAL(10,2) DEFAULT 0,
    promedio_th_semana_0 DECIMAL(10,2) DEFAULT 0,
    
    -- Promedios Semana 10
    promedio_hvle_semana_10 DECIMAL(10,2) DEFAULT 0,
    promedio_hvlq_semana_10 DECIMAL(10,2) DEFAULT 0,
    promedio_hvlq5_semana_10 DECIMAL(10,2) DEFAULT 0,
    promedio_th_semana_10 DECIMAL(10,2) DEFAULT 0,
    
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices para optimización
CREATE INDEX idx_evaluacion_fecha ON sigatoka_evaluacion(fecha_muestreo);
CREATE INDEX idx_evaluacion_cliente ON sigatoka_evaluacion(cliente_id);
CREATE INDEX idx_muestra_evaluacion ON sigatoka_muestra(evaluacion_id);
CREATE INDEX idx_muestra_lote ON sigatoka_muestra(lote);
