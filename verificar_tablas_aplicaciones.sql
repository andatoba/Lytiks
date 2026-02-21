-- ========================================
-- VERIFICAR TABLAS DE APLICACIONES
-- ========================================
USE lytiks_db;

-- ========================================
-- 1. Ver si existe la tabla aplicaciones
-- ========================================
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Tabla aplicaciones EXISTE'
        ELSE '❌ Tabla aplicaciones NO EXISTE'
    END AS estado_tabla
FROM information_schema.tables 
WHERE table_schema = 'lytiks_db' 
AND table_name = 'aplicaciones';

-- ========================================
-- 2. Ver estructura de la tabla aplicaciones
-- ========================================
DESCRIBE aplicaciones;

-- ========================================
-- 3. Ver todas las columnas de aplicaciones
-- ========================================
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    CHARACTER_MAXIMUM_LENGTH
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'lytiks_db' 
AND TABLE_NAME = 'aplicaciones'
ORDER BY ORDINAL_POSITION;

-- ========================================
-- 4. Verificar foreign keys
-- ========================================
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'lytiks_db'
AND (TABLE_NAME = 'aplicaciones' OR TABLE_NAME = 'seguimiento_aplicaciones')
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ========================================
-- 5. Ver estructura de seguimiento_aplicaciones
-- ========================================
DESCRIBE seguimiento_aplicaciones;

-- ========================================
-- 6. Ver datos de aplicaciones (si hay)
-- ========================================
SELECT * FROM aplicaciones LIMIT 5;

-- ========================================
-- 7. Contar registros
-- ========================================
SELECT 
    'Aplicaciones' AS tabla, COUNT(*) AS total FROM aplicaciones
UNION ALL
SELECT 
    'Seguimiento' AS tabla, COUNT(*) AS total FROM seguimiento_aplicaciones;
