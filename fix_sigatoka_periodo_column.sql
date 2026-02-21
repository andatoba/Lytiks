-- ========================================
-- FIX: Ampliar columna 'periodo' en sigatoka_evaluacion
-- ========================================
-- Error: Data too long for column 'periodo' at row 1
-- Solución: Ampliar tamaño de la columna periodo
-- ========================================

USE lytiks_db;

-- ========================================
-- Ver estructura actual
-- ========================================
DESCRIBE sigatoka_evaluacion;

-- ========================================
-- Ver el tamaño actual de la columna periodo
-- ========================================
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    COLUMN_TYPE
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'lytiks_db' 
AND TABLE_NAME = 'sigatoka_evaluacion'
AND COLUMN_NAME = 'periodo';

-- ========================================
-- Ampliar columna 'periodo' de VARCHAR(10) a VARCHAR(100)
-- ========================================
ALTER TABLE sigatoka_evaluacion 
MODIFY COLUMN periodo VARCHAR(100);

-- ========================================
-- Verificar el cambio
-- ========================================
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    COLUMN_TYPE
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'lytiks_db' 
AND TABLE_NAME = 'sigatoka_evaluacion'
AND COLUMN_NAME = 'periodo';

-- ========================================
-- Ver estructura actualizada
-- ========================================
DESCRIBE sigatoka_evaluacion;

SELECT '✅ Columna periodo ampliada correctamente' AS resultado;
