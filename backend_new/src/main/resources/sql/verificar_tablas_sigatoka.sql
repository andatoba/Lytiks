-- ========================================
-- VERIFICAR ESTRUCTURA DE TABLAS SIGATOKA
-- ========================================
USE lytiks_db;

-- ========================================
-- Ver todas las tablas relacionadas con Sigatoka
-- ========================================
SHOW TABLES LIKE 'sigatoka%';

-- ========================================
-- Ver estructura de cada tabla
-- ========================================
DESCRIBE sigatoka_evaluacion;
DESCRIBE sigatoka_lote;
DESCRIBE sigatoka_muestra;
DESCRIBE sigatoka_resumen;
DESCRIBE sigatoka_indicadores;
DESCRIBE sigatoka_estado_evolutivo;
DESCRIBE sigatoka_stover_promedio;

-- ========================================
-- Verificar relaciones (Foreign Keys)
-- ========================================
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'lytiks_db'
AND (TABLE_NAME LIKE 'sigatoka%')
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- ========================================
-- Verificar si hay evaluaciones creadas
-- ========================================
SELECT COUNT(*) AS total_evaluaciones FROM sigatoka_evaluacion;
SELECT * FROM sigatoka_evaluacion LIMIT 5;

-- ========================================
-- Verificar columnas esperadas por el backend
-- ========================================
-- Ver si existe la columna cliente_id en sigatoka_evaluacion
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'lytiks_db' 
AND TABLE_NAME = 'sigatoka_evaluacion'
ORDER BY ORDINAL_POSITION;
