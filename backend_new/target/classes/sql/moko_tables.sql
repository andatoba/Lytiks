-- Crear tabla de síntomas si no existe
CREATE TABLE IF NOT EXISTS sintomas (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    categoria VARCHAR(50),
    sintoma_observable VARCHAR(200),
    descripcion_tecnica TEXT,
    severidad VARCHAR(20)
);

-- Insertar datos de síntomas basados en la información proporcionada
INSERT INTO sintomas (categoria, sintoma_observable, descripcion_tecnica, severidad) VALUES
('Externo', 'Amarillamiento de hojas bajas', 'Primeras hojas muestran amarillamiento desde el borde hacia el centro.', 'Bajo'),
('Externo', 'Marchitez o colapso de hojas', 'Las hojas se doblan en forma de "paraguas"; planta pierde turgencia rápidamente.', 'Medio'),
('Externo', 'Muerte apical / pseudotallo blando', 'La parte superior del pseudotallo se ablanda, colapsa o presenta exudado.', 'Alto'),
('Externo', 'Hojas jóvenes torcidas o con bordes secos', 'Indica bloqueo vascular incipiente; hojas no se abren completamente.', 'Medio'),
('Fruto', 'Frutos pequeños o deformados', 'Racimos con dedos torcidos, desarrollo irregular o aborrados.', 'Medio'),
('Fruto', 'Pulpa con manchas marrón-rojizas', 'Al cortar el fruto se observan vetas marrones, típicos del Moko.', 'Alto'),
('Fruto', 'Exudado bacteriano ("ooze") en pedúnculo', 'Gotas blancas o amarillentas viscosas en el corte del racimo.', 'Alto'),
('Flor masculina', 'Necrosis o ennegrecimiento en el nudo floral', 'Zona de flor masculina muerta o seca, punto frecuente de infección.', 'Medio'),
('Pseudotallo', 'Amarillamiento de hojas bajas', 'Al cortar el pseudotallo transversalmente se ven anillos concéntricos cafés oscuros.', 'Alto'),
('Pseudotallo', 'Puntos café en haces vasculares longitudinales', 'Al cortar verticalmente el pseudotallo se aprecian líneas o puntos oscuros en los haces.', 'Alto'),
('Pseudotallo', 'Exudado viscoso al presionar corte', 'Sale líquido blanquecino-amarillo de textura mucilaginosa.', 'Alto'),
('Hoja', 'Decoloración en pecíolos o base de hojas', 'Cuando se corta la base del pecíolo se observan líneas marrones.', 'Medio'),
('Rizoma', 'Oscurecimiento en el corazón del rizoma', 'Corte del cormo muestra anillos o puntos marrones, a veces con olor agrio.', 'Alto');

-- Crear tabla de registro_moko
CREATE TABLE IF NOT EXISTS registro_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    numero_foco INT UNIQUE NOT NULL,
    cliente_id BIGINT NOT NULL,
    gps_coordinates VARCHAR(100),
    plantas_afectadas INT,
    fecha_deteccion DATETIME,
    sintoma_id BIGINT,
    severidad VARCHAR(20),
    foto_path VARCHAR(500),
    metodo_comprobacion VARCHAR(50),
    observaciones TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sintoma_id) REFERENCES sintomas(id),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);