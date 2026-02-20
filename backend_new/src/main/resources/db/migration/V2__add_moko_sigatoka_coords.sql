-- Add lote coordinates for Moko and Sigatoka

ALTER TABLE registro_moko ADD COLUMN IF NOT EXISTS lote_latitud DOUBLE;
ALTER TABLE registro_moko ADD COLUMN IF NOT EXISTS lote_longitud DOUBLE;

ALTER TABLE sigatoka_lote ADD COLUMN IF NOT EXISTS latitud DOUBLE;
ALTER TABLE sigatoka_lote ADD COLUMN IF NOT EXISTS longitud DOUBLE;
