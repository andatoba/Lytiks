-- ============================================
-- DIAGNÓSTICO SIGATOKA - NOMBRES CORRECTOS
-- ============================================

USE lytiks_db;

-- ============================================
-- CONTEO DE REGISTROS (nombres correctos)
-- ============================================

SELECT 'sigatoka_evaluacion' AS tabla, COUNT(*) AS total FROM sigatoka_evaluacion
UNION ALL
SELECT 'sigatoka_lote' AS tabla, COUNT(*) AS total FROM sigatoka_lote
UNION ALL
SELECT 'sigatoka_muestra' AS tabla, COUNT(*) AS total FROM sigatoka_muestra
UNION ALL
SELECT 'sigatoka_resumen' AS tabla, COUNT(*) AS total FROM sigatoka_resumen
UNION ALL
SELECT 'sigatoka_indicadores' AS tabla, COUNT(*) AS total FROM sigatoka_indicadores
UNION ALL
SELECT 'sigatoka_estado_evolutivo' AS tabla, COUNT(*) AS total FROM sigatoka_estado_evolutivo
UNION ALL
SELECT 'sigatoka_stover_promedio' AS tabla, COUNT(*) AS total FROM sigatoka_stover_promedio;

-- ============================================
-- VERIFICAR RELACIONES
-- ============================================

SELECT 
    e.id AS evaluacion_id,
    e.hacienda,
    e.fecha,
    COUNT(DISTINCT l.id) AS total_lotes,
    COUNT(m.id) AS total_muestras,
    CASE WHEN r.id IS NOT NULL THEN 'SI' ELSE 'NO' END AS tiene_resumen
FROM sigatoka_evaluacion e
LEFT JOIN sigatoka_lote l ON e.id = l.evaluacion_id
LEFT JOIN sigatoka_muestra m ON l.id = m.lote_id
LEFT JOIN sigatoka_resumen r ON e.id = r.evaluacion_id
GROUP BY e.id, e.hacienda, e.fecha, r.id
ORDER BY e.id DESC;

-- ============================================
-- VER ESTRUCTURA DE TABLAS
-- ============================================

DESCRIBE sigatoka_lote;
DESCRIBE sigatoka_muestra;

-- ============================================
-- VERIFICAR SI HAY DATOS EN LOTES Y MUESTRAS
-- ============================================

SELECT 'LOTES' AS tipo, id, evaluacion_id, lote_codigo FROM sigatoka_lote LIMIT 10;
SELECT 'MUESTRAS' AS tipo, id, lote_id, muestra_num, plantas_con_lesiones FROM sigatoka_muestra LIMIT 10;
