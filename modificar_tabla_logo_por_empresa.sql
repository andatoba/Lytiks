-- Script para modificar configuracion_logo y relacionarla con is_empresa
-- Ejecutar en MySQL

USE lytiks_db;

-- 1. VER ESTRUCTURA ACTUAL DE configuracion_logo
DESCRIBE configuracion_logo;

-- 2. AGREGAR COLUMNA id_empresa
ALTER TABLE configuracion_logo 
ADD COLUMN id_empresa INT UNSIGNED NULL AFTER id;

-- 3. AGREGAR FOREIGN KEY hacia is_empresa
ALTER TABLE configuracion_logo
ADD CONSTRAINT fk_logo_empresa 
FOREIGN KEY (id_empresa) REFERENCES is_empresa(id_empresa)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 4. AGREGAR ÍNDICE para mejorar búsquedas
CREATE INDEX idx_empresa_activo ON configuracion_logo(id_empresa, activo);

-- 5. NOTA: MySQL no soporta DROP INDEX IF EXISTS ni CREATE INDEX con WHERE
-- Si existe un índice idx_activo y necesitas eliminarlo:
-- DROP INDEX idx_activo ON configuracion_logo;

-- 6. NOTA: En MySQL no usamos UNIQUE INDEX con WHERE
-- En su lugar, la lógica de "un solo logo activo por empresa" se maneja en la aplicación
CREATE INDEX idx_empresa_activo2 ON configuracion_logo(id_empresa, activo);

-- 7. VER NUEVA ESTRUCTURA
DESCRIBE configuracion_logo;

-- 8. VERIFICAR FOREIGN KEYS
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'configuracion_logo'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 9. EJEMPLO: Insertar logos para empresas
-- Logo para ULOG (id_empresa = 1)
INSERT INTO configuracion_logo (id_empresa, nombre, ruta_logo, activo, descripcion) 
VALUES (1, 'Logo ULOG', 'https://ejemplo.com/logos/ulog.png', true, 'Logo oficial de ULOG');

-- Logo para La Favorita (id_empresa = 2)
INSERT INTO configuracion_logo (id_empresa, nombre, ruta_logo, activo, descripcion) 
VALUES (2, 'Logo La Favorita', 'https://ejemplo.com/logos/favorita.png', true, 'Logo oficial de La Favorita');

-- 10. CONSULTAR logos por empresa
SELECT 
    cl.id,
    cl.id_empresa,
    e.nomb_comercial,
    cl.nombre as nombre_logo,
    cl.activo,
    cl.fecha_creacion
FROM configuracion_logo cl
INNER JOIN is_empresa e ON cl.id_empresa = e.id_empresa
ORDER BY e.nomb_comercial;

-- 11. OBTENER LOGO ACTIVO DE UNA EMPRESA ESPECÍFICA
SELECT * FROM configuracion_logo 
WHERE id_empresa = 1 AND activo = true;

-- 12. CAMBIAR LOGO ACTIVO DE UNA EMPRESA
-- Primero desactivar todos los logos de esa empresa
UPDATE configuracion_logo SET activo = false WHERE id_empresa = 1;
-- Luego activar el nuevo logo
UPDATE configuracion_logo SET activo = true WHERE id_empresa = 1 AND id = 1;
