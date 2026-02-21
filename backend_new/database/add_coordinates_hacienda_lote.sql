-- ============================================
-- AGREGAR COORDENADAS A HACIENDA Y LOTE
-- Para mostrar en mapa del cliente
-- ============================================

-- Agregar coordenadas a hacienda
ALTER TABLE hacienda 
ADD COLUMN latitud DOUBLE NULL,
ADD COLUMN longitud DOUBLE NULL;

-- Agregar coordenadas a lote
ALTER TABLE lote 
ADD COLUMN latitud DOUBLE NULL,
ADD COLUMN longitud DOUBLE NULL;

-- Índices geoespaciales para búsqueda eficiente
CREATE INDEX idx_hacienda_coords ON hacienda (latitud, longitud);
CREATE INDEX idx_lote_coords ON lote (latitud, longitud);

-- Vista para obtener evaluaciones con coordenadas por cliente
CREATE OR REPLACE VIEW vista_evaluaciones_cliente AS
SELECT 
    'SIGATOKA' as tipo_evaluacion,
    se.id as evaluacion_id,
    se.cliente_id,
    se.hacienda as hacienda_nombre,
    sl.lote_codigo as lote_codigo,
    se.fecha,
    l.latitud,
    l.longitud,
    h.nombre as hacienda_ref,
    se.evaluador
FROM sigatoka_evaluacion se
LEFT JOIN sigatoka_lote sl ON sl.evaluacion_id = se.id
LEFT JOIN lote l ON l.codigo = sl.lote_codigo
LEFT JOIN hacienda h ON l.hacienda_id = h.id
WHERE l.latitud IS NOT NULL AND l.longitud IS NOT NULL

UNION ALL

SELECT 
    'MOKO' as tipo_evaluacion,
    rm.id as evaluacion_id,
    rm.cliente_id,
    h.nombre as hacienda_nombre,
    rm.lote as lote_codigo,
    rm.fecha_deteccion as fecha,
    l.latitud,
    l.longitud,
    h.nombre as hacienda_ref,
    'N/A' as evaluador
FROM registro_moko rm
LEFT JOIN lote l ON l.codigo = rm.lote
LEFT JOIN hacienda h ON l.hacienda_id = h.id
WHERE l.latitud IS NOT NULL AND l.longitud IS NOT NULL

UNION ALL

SELECT 
    'AUDITORIA' as tipo_evaluacion,
    a.id as evaluacion_id,
    c.id as cliente_id,
    a.hacienda as hacienda_nombre,
    a.cultivo as lote_codigo,
    a.fecha,
    h.latitud,
    h.longitud,
    h.nombre as hacienda_ref,
    'N/A' as evaluador
FROM audits a
LEFT JOIN clients c ON a.client_id = c.id
LEFT JOIN hacienda h ON h.nombre = a.hacienda AND h.cliente_id = c.id
WHERE h.latitud IS NOT NULL AND h.longitud IS NOT NULL;
