-- ============================================
-- SCRIPT: Agregar Lotes y Muestras a Evaluaciones Existentes
-- ============================================
-- Este script agrega datos de prueba a las 8 evaluaciones
-- que ya existen pero no tienen lotes ni muestras
-- ============================================

USE lytiks_db;

-- ============================================
-- EVALUACIÓN 1: Angie Tobar (2026-01-30)
-- ============================================

-- Crear 2 lotes para evaluación 1
INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(1, 'AT-LOTE-001', -0.2345, -78.5432),
(1, 'AT-LOTE-002', -0.2350, -78.5440);

-- Obtener IDs de lotes (asumiendo que son los primeros)
SET @lote1_eval1 = LAST_INSERT_ID();
SET @lote2_eval1 = @lote1_eval1 + 1;

-- Agregar 5 muestras al lote 1 de evaluación 1
INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta, 
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval1, 1, '1a', '2b', '3a', 8, 7, 6, 10, 25, 5, 15, 12.5, 10.2, 8.5, 30.5),
(@lote1_eval1, 2, '1b', '2a', '2c', 9, 8, 7, 12, 30, 6, 18, 13.0, 11.0, 9.0, 32.0),
(@lote1_eval1, 3, '2a', '2b', '3b', 7, 6, 5, 8, 20, 4, 12, 11.5, 9.5, 7.5, 28.5),
(@lote2_eval1, 4, '1c', '2c', '3a', 8, 7, 6, 11, 28, 5, 16, 12.8, 10.5, 8.8, 31.2),
(@lote2_eval1, 5, '2b', '3a', '3c', 9, 8, 7, 13, 32, 7, 19, 13.5, 11.5, 9.5, 33.0);

-- ============================================
-- EVALUACIÓN 2: Angie Tobar (2026-01-30)
-- ============================================

INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(2, 'AT-LOTE-003', -0.2355, -78.5445),
(2, 'AT-LOTE-004', -0.2360, -78.5450);

SET @lote1_eval2 = LAST_INSERT_ID();
SET @lote2_eval2 = @lote1_eval2 + 1;

INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta,
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval2, 1, '1a', '2a', '2b', 8, 7, 6, 9, 22, 4, 14, 12.0, 9.8, 8.0, 29.5),
(@lote1_eval2, 2, '1b', '2b', '3a', 9, 8, 7, 11, 27, 5, 16, 12.8, 10.5, 8.8, 31.5),
(@lote1_eval2, 3, '2a', '2c', '3b', 7, 6, 5, 10, 24, 5, 15, 11.8, 9.8, 7.8, 29.0),
(@lote2_eval2, 4, '1c', '2a', '3a', 8, 7, 6, 12, 29, 6, 17, 13.0, 10.8, 9.0, 32.0),
(@lote2_eval2, 5, '2b', '3a', '3c', 9, 8, 7, 14, 33, 7, 20, 13.8, 11.8, 9.8, 34.0);

-- ============================================
-- EVALUACIÓN 3: la fortuna (2026-02-06)
-- ============================================

INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(3, 'LF-LOTE-001', -0.3345, -78.6432),
(3, 'LF-LOTE-002', -0.3350, -78.6440);

SET @lote1_eval3 = LAST_INSERT_ID();
SET @lote2_eval3 = @lote1_eval3 + 1;

INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta,
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval3, 1, '1a', '2b', '3a', 8, 7, 6, 11, 26, 5, 16, 12.5, 10.2, 8.5, 30.8),
(@lote1_eval3, 2, '1b', '2a', '2c', 9, 8, 7, 13, 31, 6, 19, 13.2, 11.0, 9.2, 32.5),
(@lote1_eval3, 3, '2a', '2b', '3b', 7, 6, 5, 9, 23, 4, 13, 11.8, 9.5, 7.8, 28.8),
(@lote2_eval3, 4, '1c', '2c', '3a', 8, 7, 6, 12, 28, 6, 17, 13.0, 10.5, 9.0, 31.8),
(@lote2_eval3, 5, '2b', '3a', '3c', 9, 8, 7, 14, 34, 7, 21, 13.8, 11.8, 9.8, 34.5);

-- ============================================
-- EVALUACIÓN 4: la fortuna (2026-02-05)
-- ============================================

INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(4, 'LF-LOTE-003', -0.3355, -78.6445),
(4, 'LF-LOTE-004', -0.3360, -78.6450);

SET @lote1_eval4 = LAST_INSERT_ID();
SET @lote2_eval4 = @lote1_eval4 + 1;

INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta,
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval4, 1, '1a', '2a', '2b', 8, 7, 6, 10, 24, 5, 15, 12.2, 10.0, 8.2, 30.0),
(@lote1_eval4, 2, '1b', '2b', '3a', 9, 8, 7, 12, 28, 6, 17, 13.0, 10.8, 9.0, 32.0),
(@lote1_eval4, 3, '2a', '2c', '3b', 7, 6, 5, 11, 25, 5, 16, 12.0, 9.8, 8.0, 29.5),
(@lote2_eval4, 4, '1c', '2a', '3a', 8, 7, 6, 13, 30, 6, 18, 13.2, 11.0, 9.2, 32.5),
(@lote2_eval4, 5, '2b', '3a', '3c', 9, 8, 7, 15, 35, 8, 22, 14.0, 12.0, 10.0, 35.0);

-- ============================================
-- EVALUACIÓN 5: la fortuna (2026-02-06)
-- ============================================

INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(5, 'LF-LOTE-005', -0.3365, -78.6455);

SET @lote1_eval5 = LAST_INSERT_ID();

INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta,
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval5, 1, '1a', '2b', '3a', 8, 7, 6, 9, 21, 4, 13, 11.8, 9.6, 7.8, 29.0),
(@lote1_eval5, 2, '1b', '2a', '2c', 9, 8, 7, 10, 25, 5, 15, 12.5, 10.2, 8.5, 30.5),
(@lote1_eval5, 3, '2a', '2b', '3b', 7, 6, 5, 8, 19, 3, 11, 11.0, 9.0, 7.0, 27.0),
(@lote1_eval5, 4, '1c', '2c', '3a', 8, 7, 6, 11, 26, 5, 16, 12.8, 10.5, 8.8, 31.2),
(@lote1_eval5, 5, '2b', '3a', '3c', 9, 8, 7, 12, 29, 6, 18, 13.2, 11.0, 9.2, 32.5);

-- ============================================
-- EVALUACIÓN 6: la fortuna (2026-02-14)
-- ============================================

INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(6, 'LF-LOTE-006', -0.3370, -78.6460);

SET @lote1_eval6 = LAST_INSERT_ID();

INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta,
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval6, 1, '1a', '2a', '2b', 8, 7, 6, 10, 23, 4, 14, 12.0, 9.8, 8.0, 29.5),
(@lote1_eval6, 2, '1b', '2b', '3a', 9, 8, 7, 11, 26, 5, 16, 12.8, 10.5, 8.8, 31.0),
(@lote1_eval6, 3, '2a', '2c', '3b', 7, 6, 5, 9, 22, 4, 13, 11.5, 9.5, 7.5, 28.5),
(@lote1_eval6, 4, '1c', '2a', '3a', 8, 7, 6, 12, 27, 5, 17, 13.0, 10.8, 9.0, 32.0),
(@lote1_eval6, 5, '2b', '3a', '3c', 9, 8, 7, 13, 31, 6, 19, 13.5, 11.5, 9.5, 33.5);

-- ============================================
-- EVALUACIÓN 7: la fortuna (2026-02-21)
-- ============================================

INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(7, 'LF-LOTE-007', -0.3375, -78.6465);

SET @lote1_eval7 = LAST_INSERT_ID();

INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta,
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval7, 1, '1a', '2b', '3a', 8, 7, 6, 11, 25, 5, 15, 12.5, 10.2, 8.5, 30.5),
(@lote1_eval7, 2, '1b', '2a', '2c', 9, 8, 7, 12, 28, 6, 17, 13.0, 10.8, 9.0, 32.0),
(@lote1_eval7, 3, '2a', '2b', '3b', 7, 6, 5, 10, 24, 5, 15, 11.8, 9.8, 7.8, 29.0),
(@lote1_eval7, 4, '1c', '2c', '3a', 8, 7, 6, 13, 30, 6, 18, 13.2, 11.0, 9.2, 32.5),
(@lote1_eval7, 5, '2b', '3a', '3c', 9, 8, 7, 14, 32, 7, 20, 13.8, 11.8, 9.8, 34.0);

-- ============================================
-- EVALUACIÓN 8: la fortuna (2026-02-21)
-- ============================================

INSERT INTO sigatoka_lote (evaluacion_id, lote_codigo, latitud, longitud)
VALUES 
(8, 'LF-LOTE-008', -0.3380, -78.6470),
(8, 'LF-LOTE-009', -0.3385, -78.6475);

SET @lote1_eval8 = LAST_INSERT_ID();
SET @lote2_eval8 = @lote1_eval8 + 1;

INSERT INTO sigatoka_muestra 
(lote_id, muestra_num, hoja_3era, hoja_4ta, hoja_5ta,
 total_hojas_3era, total_hojas_4ta, total_hojas_5ta,
 plantas_con_lesiones, total_lesiones, plantas_3er_estadio, total_letras,
 h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w)
VALUES
(@lote1_eval8, 1, '1a', '2a', '2b', 8, 7, 6, 10, 24, 5, 15, 12.2, 10.0, 8.2, 30.0),
(@lote1_eval8, 2, '1b', '2b', '3a', 9, 8, 7, 11, 27, 5, 16, 12.8, 10.5, 8.8, 31.5),
(@lote1_eval8, 3, '2a', '2c', '3b', 7, 6, 5, 9, 22, 4, 14, 11.5, 9.5, 7.5, 28.5),
(@lote2_eval8, 4, '1c', '2a', '3a', 8, 7, 6, 12, 29, 6, 17, 13.0, 10.8, 9.0, 32.0),
(@lote2_eval8, 5, '2b', '3a', '3c', 9, 8, 7, 13, 31, 6, 19, 13.5, 11.5, 9.5, 33.5);

-- ============================================
-- VERIFICAR DATOS INSERTADOS
-- ============================================

SELECT 'RESUMEN DE INSERCIONES' AS resultado;

SELECT 
    'sigatoka_lote' AS tabla, 
    COUNT(*) AS registros_insertados 
FROM sigatoka_lote;

SELECT 
    'sigatoka_muestra' AS tabla, 
    COUNT(*) AS registros_insertados 
FROM sigatoka_muestra;

-- Ver resumen por evaluación
SELECT 
    e.id AS evaluacion_id,
    e.hacienda,
    e.fecha,
    COUNT(DISTINCT l.id) AS total_lotes,
    COUNT(m.id) AS total_muestras
FROM sigatoka_evaluacion e
LEFT JOIN sigatoka_lote l ON e.id = l.evaluacion_id
LEFT JOIN sigatoka_muestra m ON l.id = m.lote_id
GROUP BY e.id, e.hacienda, e.fecha
ORDER BY e.id;

-- ============================================
-- SCRIPT COMPLETADO
-- ============================================
-- 
-- ✅ Se agregaron:
--    - 13 lotes (distribuidos en las 8 evaluaciones)
--    - 40 muestras (5 muestras por evaluación)
--
-- ✅ Todas las evaluaciones ahora tienen:
--    - Al menos 1 lote
--    - 5 muestras para análisis
--    - Datos realistas de campos de banano
--
-- 🔄 Próximo paso opcional:
--    Ejecutar el cálculo de resumen/indicadores desde la app
--    o manualmente con el endpoint POST /api/sigatoka/{id}/calcular-todo
-- ============================================
