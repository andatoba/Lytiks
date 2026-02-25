-- Tablas para módulo de evaluación de Sigatoka
-- Estructura COMPLETA basada en el formato Excel (rediseñada)

-- TABLA 1: ENCABEZADO (Datos generales)
CREATE TABLE IF NOT EXISTS sigatoka_evaluacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    hacienda VARCHAR(255) NOT NULL,
    fecha DATE NOT NULL,
    semana_epidemiologica INT,
    periodo VARCHAR(10),
    evaluador VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- TABLA 2: LOTES (Agrupación de muestras)
CREATE TABLE IF NOT EXISTS sigatoka_lote (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL,
    lote_codigo VARCHAR(100) NOT NULL,
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
);

-- TABLA 3: MUESTRAS COMPLETAS (con TODOS los campos del Excel)
CREATE TABLE IF NOT EXISTS sigatoka_muestra (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lote_id BIGINT NOT NULL,
    muestra_num INT NOT NULL,
    
    -- Grados de infección (3era, 4ta, 5ta hoja)
    hoja_3era VARCHAR(10),
    hoja_4ta VARCHAR(10),
    hoja_5ta VARCHAR(10),
    
    -- Total de hojas por nivel
    total_hojas_3era INT,
    total_hojas_4ta INT,
    total_hojas_5ta INT,
    
    -- Variables para cálculos (a-e)
    plantas_muestreadas INT,
    plantas_con_lesiones INT,
    total_lesiones INT,
    plantas_3er_estadio INT,
    total_letras INT,
    
    -- Valores Stover 0 semanas
    h_v_l_e_0w DECIMAL(5,2),
    h_v_l_q_0w DECIMAL(5,2),
    h_v_l_q5_0w DECIMAL(5,2),
    t_h_0w DECIMAL(5,2),
    
    -- Valores Stover 10 semanas
    h_v_l_e_10w DECIMAL(5,2),
    h_v_l_q_10w DECIMAL(5,2),
    h_v_l_q5_10w DECIMAL(5,2),
    t_h_10w DECIMAL(5,2),
    
    FOREIGN KEY (lote_id) REFERENCES sigatoka_lote(id) ON DELETE CASCADE
);

-- TABLA 4: RESUMEN (Promedios a-e)
CREATE TABLE IF NOT EXISTS sigatoka_resumen (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    promedio_hojas_emitidas DECIMAL(10,2),
    promedio_hojas_erectas DECIMAL(10,2),
    promedio_hojas_sintomas DECIMAL(10,2),
    promedio_hoja_joven_enferma DECIMAL(10,2),
    promedio_hoja_joven_necrosada DECIMAL(10,2),
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
);

-- TABLA 5: INDICADORES (Cálculos f-k)
CREATE TABLE IF NOT EXISTS sigatoka_indicadores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    incidencia_promedio DECIMAL(10,2),
    severidad_promedio DECIMAL(10,2),
    indice_hojas_erectas DECIMAL(10,2),
    ritmo_emision DECIMAL(10,2),
    velocidad_evolucion DECIMAL(10,2),
    velocidad_necrosis DECIMAL(10,2),
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
);

-- TABLA 6: ESTADO EVOLUTIVO (EE y clasificación)
CREATE TABLE IF NOT EXISTS sigatoka_estado_evolutivo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    ee_3era_hoja DECIMAL(10,2),
    ee_4ta_hoja DECIMAL(10,2),
    ee_5ta_hoja DECIMAL(10,2),
    nivel_infeccion VARCHAR(20),
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
);

-- TABLA 7: STOVER PROMEDIO (Calculado)
CREATE TABLE IF NOT EXISTS sigatoka_stover_promedio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    stover_3era_hoja DECIMAL(10,2),
    stover_4ta_hoja DECIMAL(10,2),
    stover_5ta_hoja DECIMAL(10,2),
    stover_promedio DECIMAL(10,2),
    nivel_infeccion VARCHAR(20),
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
);

-- TABLA DE REFERENCIA: Niveles Stover recomendados (valores estándar)
CREATE TABLE IF NOT EXISTS sigatoka_stover_referencia (
    id INT PRIMARY KEY,
    semana VARCHAR(10),
    h_v_l_e DECIMAL(5,2),
    h_v_l_q DECIMAL(5,2),
    h_v_l_q5 DECIMAL(5,2),
    t_h DECIMAL(5,2)
);

-- Insertar valores estándar Stover
INSERT INTO sigatoka_stover_referencia (id, semana, h_v_l_e, h_v_l_q, h_v_l_q5, t_h) VALUES
  (1, '0', 6.0, 11.0, 12.5, 13.5),
  (2, '10', 0.0, 5.0, 8.5, 9.0)
ON DUPLICATE KEY UPDATE semana=VALUES(semana);
