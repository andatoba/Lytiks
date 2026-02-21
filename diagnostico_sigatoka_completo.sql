-- ============================================
-- DIAGNÓSTICO COMPLETO - SIGATOKA
-- ============================================

USE lytiks_db;

-- ============================================
-- PASO 1: Verificar que las tablas existen
-- ============================================
SHOW TABLES LIKE 'sigatoka%';

-- ============================================
-- PASO 2: Verificar estructura de cada tabla
-- ============================================

-- Tabla de evaluaciones (encabezado)
SHOW CREATE TABLE sigatoka_evaluacion\G

-- Tabla de lotes
SHOW CREATE TABLE sigatoka_lote\G

-- Tabla de muestras completas
SHOW CREATE TABLE sigatoka_muestra\G

-- Tabla de resumen
SHOW CREATE TABLE sigatoka_resumen\G

-- ============================================
-- PASO 3: Contar registros en cada tabla
-- ============================================

SELECT 'sigatoka_evaluacion' AS tabla, COUNT(*) AS total FROM sigatoka_evaluacion
UNION ALL
SELECT 'sigatoka_lote' AS tabla, COUNT(*) AS total FROM sigatoka_lote
UNION ALL
SELECT 'sigatoka_muestra' AS tabla, COUNT(*) AS total FROM sigatoka_muestra
UNION ALL
SELECT 'sigatoka_resumen' AS tabla, COUNT(*) AS total FROM sigatoka_resumen;

-- ============================================
-- PASO 4: Ver las evaluaciones que SÍ existen
-- ============================================

SELECT 
    id,
    cliente_id,
    hacienda,
    fecha,
    semana_epidemiologica,
    periodo,
    evaluador,
    created_at
FROM sigatoka_evaluacion
ORDER BY id DESC
LIMIT 10;

-- ============================================
-- PASO 5: Verificar relaciones entre tablas
-- ============================================

SELECT 
    e.id AS evaluacion_id,
    e.hacienda,
    e.fecha,
    COUNT(DISTINCT l.id) AS total_lotes,
    COUNT(m.id) AS total_muestras,
    COUNT(r.id) AS tiene_resumen
FROM sigatoka_evaluacion e
LEFT JOIN sigatoka_lote l ON e.id = l.evaluacion_id
LEFT JOIN sigatoka_muestra m ON l.id = m.lote_id
LEFT JOIN sigatoka_resumen r ON e.id = r.evaluacion_id
GROUP BY e.id, e.hacienda, e.fecha
ORDER BY e.id DESC;

-- ============================================
-- DIAGNÓSTICO ESPERADO:
-- ============================================
-- 
-- Si ves:
-- - sigatoka_evaluacion: 8 registros (HAY EVALUACIONES CREADAS)
-- - sigatoka_lote: 0 registros (NO HAY LOTES)
-- - sigatoka_muestra: 0 registros (NO HAY MUESTRAS)
-- - sigatoka_resumen: 0 registros (NO HAY RESUMEN)
--
-- CAUSA: Las evaluaciones se crearon pero NO se completó el proceso
--        de agregar muestras. El flujo se detuvo en el paso 1.
--
-- SOLUCIÓN: Crear una nueva evaluación y AGREGAR MUESTRAS:
--   1. Abrir app Flutter
--   2. Ir a pantalla Sigatoka
--   3. Crear evaluación (esto ya funciona)
--   4. **IMPORTANTE**: Agregar al menos 5 muestras con el botón "Agregar Muestra"
--   5. Presionar "Calcular y Ver Reporte"
--
-- Después de esto, las tablas tendrán datos.
-- ============================================
