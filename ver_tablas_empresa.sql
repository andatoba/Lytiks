-- Script para ver la estructura de las tablas is_empresa e is_empresa_roles
-- Ejecutar en MySQL

USE lytiks_db;

-- 1. VER ESTRUCTURA DE is_empresa
DESCRIBE is_empresa;

-- 2. VER ESTRUCTURA DE is_empresa_roles
DESCRIBE is_empresa_roles;

-- 3. VER CONTENIDO DE is_empresa
SELECT * FROM is_empresa;

-- 4. VER CONTENIDO DE is_empresa_roles
SELECT * FROM is_empresa_roles;

-- 5. VER FOREIGN KEYS DE is_empresa
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'is_empresa'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 6. VER FOREIGN KEYS DE is_empresa_roles
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'is_empresa_roles'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 7. VER ÍNDICES DE is_empresa
SHOW INDEXES FROM is_empresa;

-- 8. VER ÍNDICES DE is_empresa_roles
SHOW INDEXES FROM is_empresa_roles;

-- 9. VER INFORMACIÓN COMPLETA DE is_empresa
SHOW CREATE TABLE is_empresa;

-- 10. VER INFORMACIÓN COMPLETA DE is_empresa_roles
SHOW CREATE TABLE is_empresa_roles;
