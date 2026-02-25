-- Trayecto de ubicaciones para auditorias de campo

ALTER TABLE audits ADD COLUMN IF NOT EXISTS trayecto_ubicaciones TEXT;
