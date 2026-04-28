-- ============================================
-- TABLA: Conteo de Literales por Evaluación
-- ============================================
-- Almacena el conteo de cada estadio (letra a-j)
-- para cada tipo de hoja en una evaluación
-- ============================================

USE lytiks_db;

CREATE TABLE IF NOT EXISTS sigatoka_conteo_literales (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    
    -- Conteos para 3era Hoja
    literal_a_3era INT DEFAULT 0,
    literal_b_3era INT DEFAULT 0,
    literal_c_3era INT DEFAULT 0,
    literal_d_3era INT DEFAULT 0,
    literal_e_3era INT DEFAULT 0,
    literal_f_3era INT DEFAULT 0,
    literal_g_3era INT DEFAULT 0,
    literal_h_3era INT DEFAULT 0,
    literal_i_3era INT DEFAULT 0,
    literal_j_3era INT DEFAULT 0,
    
    -- Conteos para 4ta Hoja
    literal_a_4ta INT DEFAULT 0,
    literal_b_4ta INT DEFAULT 0,
    literal_c_4ta INT DEFAULT 0,
    literal_d_4ta INT DEFAULT 0,
    literal_e_4ta INT DEFAULT 0,
    literal_f_4ta INT DEFAULT 0,
    literal_g_4ta INT DEFAULT 0,
    literal_h_4ta INT DEFAULT 0,
    literal_i_4ta INT DEFAULT 0,
    literal_j_4ta INT DEFAULT 0,
    
    -- Conteos para 5ta Hoja
    literal_a_5ta INT DEFAULT 0,
    literal_b_5ta INT DEFAULT 0,
    literal_c_5ta INT DEFAULT 0,
    literal_d_5ta INT DEFAULT 0,
    literal_e_5ta INT DEFAULT 0,
    literal_f_5ta INT DEFAULT 0,
    literal_g_5ta INT DEFAULT 0,
    literal_h_5ta INT DEFAULT 0,
    literal_i_5ta INT DEFAULT 0,
    literal_j_5ta INT DEFAULT 0,
    
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Crear índice para búsquedas rápidas
CREATE INDEX idx_conteo_evaluacion ON sigatoka_conteo_literales(evaluacion_id);

-- ============================================
-- FUNCIÓN AUXILIAR: Contar literales
-- ============================================

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS calcular_conteo_literales(IN eval_id BIGINT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE letra CHAR(1);
    DECLARE tipo_hoja VARCHAR(10);
    
    -- Variables para conteos
    DECLARE cnt_a3 INT DEFAULT 0;
    DECLARE cnt_b3 INT DEFAULT 0;
    DECLARE cnt_c3 INT DEFAULT 0;
    DECLARE cnt_d3 INT DEFAULT 0;
    DECLARE cnt_e3 INT DEFAULT 0;
    DECLARE cnt_f3 INT DEFAULT 0;
    DECLARE cnt_g3 INT DEFAULT 0;
    DECLARE cnt_h3 INT DEFAULT 0;
    DECLARE cnt_i3 INT DEFAULT 0;
    DECLARE cnt_j3 INT DEFAULT 0;
    
    DECLARE cnt_a4 INT DEFAULT 0;
    DECLARE cnt_b4 INT DEFAULT 0;
    DECLARE cnt_c4 INT DEFAULT 0;
    DECLARE cnt_d4 INT DEFAULT 0;
    DECLARE cnt_e4 INT DEFAULT 0;
    DECLARE cnt_f4 INT DEFAULT 0;
    DECLARE cnt_g4 INT DEFAULT 0;
    DECLARE cnt_h4 INT DEFAULT 0;
    DECLARE cnt_i4 INT DEFAULT 0;
    DECLARE cnt_j4 INT DEFAULT 0;
    
    DECLARE cnt_a5 INT DEFAULT 0;
    DECLARE cnt_b5 INT DEFAULT 0;
    DECLARE cnt_c5 INT DEFAULT 0;
    DECLARE cnt_d5 INT DEFAULT 0;
    DECLARE cnt_e5 INT DEFAULT 0;
    DECLARE cnt_f5 INT DEFAULT 0;
    DECLARE cnt_g5 INT DEFAULT 0;
    DECLARE cnt_h5 INT DEFAULT 0;
    DECLARE cnt_i5 INT DEFAULT 0;
    DECLARE cnt_j5 INT DEFAULT 0;
    
    -- Contar literales de 3era hoja
    SELECT 
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'a' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'b' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'c' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'd' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'e' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'f' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'g' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'h' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'i' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_3era, -1) = 'j' THEN 1 ELSE 0 END)
    INTO cnt_a3, cnt_b3, cnt_c3, cnt_d3, cnt_e3, cnt_f3, cnt_g3, cnt_h3, cnt_i3, cnt_j3
    FROM sigatoka_muestra m
    JOIN sigatoka_lote l ON m.lote_id = l.id
    WHERE l.evaluacion_id = eval_id AND hoja_3era IS NOT NULL;
    
    -- Contar literales de 4ta hoja
    SELECT 
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'a' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'b' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'c' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'd' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'e' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'f' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'g' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'h' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'i' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_4ta, -1) = 'j' THEN 1 ELSE 0 END)
    INTO cnt_a4, cnt_b4, cnt_c4, cnt_d4, cnt_e4, cnt_f4, cnt_g4, cnt_h4, cnt_i4, cnt_j4
    FROM sigatoka_muestra m
    JOIN sigatoka_lote l ON m.lote_id = l.id
    WHERE l.evaluacion_id = eval_id AND hoja_4ta IS NOT NULL;
    
    -- Contar literales de 5ta hoja
    SELECT 
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'a' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'b' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'c' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'd' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'e' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'f' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'g' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'h' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'i' THEN 1 ELSE 0 END),
        SUM(CASE WHEN SUBSTRING(hoja_5ta, -1) = 'j' THEN 1 ELSE 0 END)
    INTO cnt_a5, cnt_b5, cnt_c5, cnt_d5, cnt_e5, cnt_f5, cnt_g5, cnt_h5, cnt_i5, cnt_j5
    FROM sigatoka_muestra m
    JOIN sigatoka_lote l ON m.lote_id = l.id
    WHERE l.evaluacion_id = eval_id AND hoja_5ta IS NOT NULL;
    
    -- Insertar o actualizar
    INSERT INTO sigatoka_conteo_literales (
        evaluacion_id,
        literal_a_3era, literal_b_3era, literal_c_3era, literal_d_3era, literal_e_3era,
        literal_f_3era, literal_g_3era, literal_h_3era, literal_i_3era, literal_j_3era,
        literal_a_4ta, literal_b_4ta, literal_c_4ta, literal_d_4ta, literal_e_4ta,
        literal_f_4ta, literal_g_4ta, literal_h_4ta, literal_i_4ta, literal_j_4ta,
        literal_a_5ta, literal_b_5ta, literal_c_5ta, literal_d_5ta, literal_e_5ta,
        literal_f_5ta, literal_g_5ta, literal_h_5ta, literal_i_5ta, literal_j_5ta
    ) VALUES (
        eval_id,
        cnt_a3, cnt_b3, cnt_c3, cnt_d3, cnt_e3, cnt_f3, cnt_g3, cnt_h3, cnt_i3, cnt_j3,
        cnt_a4, cnt_b4, cnt_c4, cnt_d4, cnt_e4, cnt_f4, cnt_g4, cnt_h4, cnt_i4, cnt_j4,
        cnt_a5, cnt_b5, cnt_c5, cnt_d5, cnt_e5, cnt_f5, cnt_g5, cnt_h5, cnt_i5, cnt_j5
    ) ON DUPLICATE KEY UPDATE
        literal_a_3era = cnt_a3, literal_b_3era = cnt_b3, literal_c_3era = cnt_c3, 
        literal_d_3era = cnt_d3, literal_e_3era = cnt_e3, literal_f_3era = cnt_f3,
        literal_g_3era = cnt_g3, literal_h_3era = cnt_h3, literal_i_3era = cnt_i3, 
        literal_j_3era = cnt_j3,
        literal_a_4ta = cnt_a4, literal_b_4ta = cnt_b4, literal_c_4ta = cnt_c4,
        literal_d_4ta = cnt_d4, literal_e_4ta = cnt_e4, literal_f_4ta = cnt_f4,
        literal_g_4ta = cnt_g4, literal_h_4ta = cnt_h4, literal_i_4ta = cnt_i4,
        literal_j_4ta = cnt_j4,
        literal_a_5ta = cnt_a5, literal_b_5ta = cnt_b5, literal_c_5ta = cnt_c5,
        literal_d_5ta = cnt_d5, literal_e_5ta = cnt_e5, literal_f_5ta = cnt_f5,
        literal_g_5ta = cnt_g5, literal_h_5ta = cnt_h5, literal_i_5ta = cnt_i5,
        literal_j_5ta = cnt_j5;
        
END$$

DELIMITER ;

-- ============================================
-- SCRIPT COMPLETADO
-- ============================================
