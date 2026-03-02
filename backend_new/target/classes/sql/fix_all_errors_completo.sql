-- ========================================
-- FIX COMPLETO: Todos los errores encontrados
-- ========================================
-- Este script corrige:
-- 1. Tabla productos_contencion - falta columna id_producto
-- 2. Tabla sigatoka_evaluacion - columna periodo muy pequeña
-- ========================================

USE lytiks_db;

-- ========================================
-- PARTE 1: FIX PRODUCTOS_CONTENCION
-- ========================================

-- Eliminar columna 'nombre' si existe
ALTER TABLE productos_contencion DROP COLUMN IF EXISTS nombre;

-- Agregar columna id_producto si no existe
ALTER TABLE productos_contencion 
ADD COLUMN IF NOT EXISTS id_producto INT AFTER id;

-- Verificar estructura
DESCRIBE productos_contencion;

-- ========================================
-- PARTE 2: FIX SIGATOKA_EVALUACION - COLUMNA PERIODO
-- ========================================

-- Ampliar columna 'periodo'
ALTER TABLE sigatoka_evaluacion 
MODIFY COLUMN periodo VARCHAR(100);

-- Verificar cambio
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'lytiks_db' 
AND TABLE_NAME = 'sigatoka_evaluacion'
AND COLUMN_NAME = 'periodo';

-- ========================================
-- RESUMEN FINAL
-- ========================================
SELECT '✅ FIXES APLICADOS CORRECTAMENTE' AS estado;

SELECT 'productos_contencion' AS tabla, 
       COLUMN_NAME, 
       COLUMN_TYPE 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'lytiks_db' 
AND TABLE_NAME = 'productos_contencion'
AND COLUMN_NAME IN ('id_producto', 'nombre')
UNION ALL
SELECT 'sigatoka_evaluacion' AS tabla, 
       COLUMN_NAME, 
       COLUMN_TYPE 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'lytiks_db' 
AND TABLE_NAME = 'sigatoka_evaluacion'
AND COLUMN_NAME = 'periodo';
