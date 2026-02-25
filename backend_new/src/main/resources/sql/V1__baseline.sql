-- Baseline schema for lytiks_db
-- Generated from current JPA entities and supporting SQL scripts.

-- Roles and usuarios (auth)
CREATE TABLE IF NOT EXISTS is_roles (
    id_roles BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200),
    detalle VARCHAR(1000),
    id_empresa BIGINT,
    id_ciudad BIGINT,
    id_sector BIGINT,
    estado VARCHAR(1),
    usuario_ingreso VARCHAR(100),
    fecha_ingreso DATETIME,
    usuario_modificacion VARCHAR(100),
    fecha_modificacion DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS is_usuarios (
    id_usuarios BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_roles BIGINT,
    id_area BIGINT,
    usuario VARCHAR(200),
    clave VARCHAR(200),
    tipo_persona VARCHAR(1),
    cedula VARCHAR(13),
    nombres VARCHAR(200),
    apellidos VARCHAR(200),
    direccion_dom VARCHAR(2000),
    telefono_casa VARCHAR(9),
    telefono_cel VARCHAR(10),
    correo VARCHAR(200),
    logo VARCHAR(300),
    logo_ruta VARCHAR(1000),
    detalle VARCHAR(1000),
    intentos INT,
    id_empresa BIGINT,
    id_ciudad BIGINT,
    id_sector BIGINT,
    estado VARCHAR(1),
    usuario_ingreso VARCHAR(100),
    fecha_ingreso DATETIME,
    usuario_modificacion VARCHAR(100),
    fecha_modificacion DATETIME,
    INDEX idx_is_usuarios_usuario (usuario),
    INDEX idx_is_usuarios_estado (estado),
    INDEX idx_is_usuarios_roles (id_roles),
    CONSTRAINT fk_is_usuarios_roles FOREIGN KEY (id_roles) REFERENCES is_roles(id_roles)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuarios legacy (si se usa para seed de pruebas)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    role VARCHAR(50),
    active TINYINT(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Clientes
CREATE TABLE IF NOT EXISTS clients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cedula VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255),
    telefono VARCHAR(255),
    email VARCHAR(255),
    direccion TEXT,
    parroquia VARCHAR(255),
    finca_nombre VARCHAR(255),
    finca_hectareas DOUBLE,
    cultivos_principales VARCHAR(255),
    geolocalizacion_lat DOUBLE,
    geolocalizacion_lng DOUBLE,
    observaciones TEXT,
    estado VARCHAR(50) DEFAULT 'ACTIVO',
    fecha_registro DATETIME,
    fecha_actualizacion DATETIME,
    tecnico_asignado_id BIGINT,
    INDEX idx_clients_cedula (cedula),
    INDEX idx_clients_nombre (nombre),
    INDEX idx_clients_tecnico (tecnico_asignado_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Auditorias
CREATE TABLE IF NOT EXISTS audits (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT,
    hacienda VARCHAR(255) NOT NULL,
    cultivo VARCHAR(255) NOT NULL,
    fecha DATETIME NOT NULL,
    evaluaciones TEXT,
    tecnico_id BIGINT,
    estado VARCHAR(50) DEFAULT 'PENDIENTE',
    observaciones TEXT,
    INDEX idx_audits_client (client_id),
    INDEX idx_audits_tecnico (tecnico_id),
    CONSTRAINT fk_audits_client FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_scores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    audit_id BIGINT NOT NULL,
    categoria VARCHAR(255) NOT NULL,
    puntuacion INT NOT NULL,
    max_puntuacion INT DEFAULT 100,
    observaciones TEXT,
    photo_path VARCHAR(500),
    INDEX idx_audit_scores_audit (audit_id),
    CONSTRAINT fk_audit_scores_audit FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_photos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    audit_id BIGINT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    description TEXT,
    categoria VARCHAR(255),
    INDEX idx_audit_photos_audit (audit_id),
    CONSTRAINT fk_audit_photos_audit FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Productos y aplicaciones
CREATE TABLE IF NOT EXISTS producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    detalle VARCHAR(255),
    cantidad INT,
    peso_kg DOUBLE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS productos_contencion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    presentacion VARCHAR(255),
    dosis_sugerida VARCHAR(500),
    url VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS aplicaciones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    producto_nombre VARCHAR(255),
    plan VARCHAR(255) DEFAULT 'Moko',
    lote VARCHAR(255),
    area_hectareas DECIMAL(10,2),
    dosis VARCHAR(255),
    fecha_inicio DATETIME,
    frecuencia_dias INT DEFAULT 7,
    repeticiones INT DEFAULT 4,
    recordatorio_hora VARCHAR(10) DEFAULT '08:00',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_aplicaciones_cliente (cliente_id),
    INDEX idx_aplicaciones_producto (producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS seguimiento_aplicaciones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    aplicacion_id BIGINT NOT NULL,
    numero_aplicacion INT NOT NULL,
    fecha_programada DATETIME NOT NULL,
    fecha_aplicada DATETIME NULL,
    estado VARCHAR(50) DEFAULT 'programada',
    dosis_aplicada VARCHAR(255),
    lote VARCHAR(255),
    observaciones TEXT,
    foto_evidencia VARCHAR(500),
    recordatorio_activo BOOLEAN DEFAULT TRUE,
    hora_recordatorio VARCHAR(10) DEFAULT '08:00',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_seguimiento_aplicacion (aplicacion_id),
    INDEX idx_seguimiento_fecha (fecha_programada),
    CONSTRAINT fk_seguimiento_aplicaciones_aplicacion FOREIGN KEY (aplicacion_id) REFERENCES aplicaciones(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seguimiento de ubicacion
CREATE TABLE IF NOT EXISTS location_tracking (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    user_name VARCHAR(255),
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    accuracy DOUBLE,
    matrix_latitude DOUBLE,
    matrix_longitude DOUBLE,
    `timestamp` DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_location_user_id (user_id),
    INDEX idx_location_timestamp (`timestamp`),
    INDEX idx_location_user_timestamp (user_id, `timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Moko
CREATE TABLE IF NOT EXISTS sintomas (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    categoria VARCHAR(50),
    sintoma_observable VARCHAR(200),
    descripcion_tecnica TEXT,
    severidad VARCHAR(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS registro_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    numero_foco INT UNIQUE NOT NULL,
    cliente_id BIGINT NOT NULL,
    gps_coordinates VARCHAR(255),
    plantas_afectadas INT NOT NULL,
    fecha_deteccion DATETIME NOT NULL,
    sintoma_id BIGINT,
    sintomas_json TEXT,
    lote VARCHAR(255),
    area_hectareas DOUBLE,
    severidad VARCHAR(255),
    metodo_comprobacion VARCHAR(255),
    observaciones TEXT,
    foto_path VARCHAR(500),
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_registro_moko_cliente (cliente_id),
    INDEX idx_registro_moko_sintoma (sintoma_id),
    CONSTRAINT fk_registro_moko_cliente FOREIGN KEY (cliente_id) REFERENCES clients(id),
    CONSTRAINT fk_registro_moko_sintoma FOREIGN KEY (sintoma_id) REFERENCES sintomas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS seguimiento_moko (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    foco_id BIGINT NOT NULL,
    numero_foco INT NOT NULL,
    semana_inicio INT,
    plantas_afectadas INT NOT NULL,
    plantas_inyectadas INT NOT NULL,
    control_vectores BOOLEAN NOT NULL DEFAULT FALSE,
    cuarentena_activa BOOLEAN NOT NULL DEFAULT FALSE,
    unica_entrada_habilitada BOOLEAN NOT NULL DEFAULT FALSE,
    eliminacion_maleza_hospedera BOOLEAN NOT NULL DEFAULT FALSE,
    control_picudo_aplicado BOOLEAN NOT NULL DEFAULT FALSE,
    inspeccion_plantas_vecinas BOOLEAN NOT NULL DEFAULT FALSE,
    corte_riego BOOLEAN NOT NULL DEFAULT FALSE,
    pediluvio_activo BOOLEAN NOT NULL DEFAULT FALSE,
    ppm_solucion_desinfectante INT,
    fecha_seguimiento DATETIME NOT NULL,
    fecha_creacion DATETIME NOT NULL,
    INDEX idx_foco_id (foco_id),
    INDEX idx_numero_foco (numero_foco),
    INDEX idx_fecha_seguimiento (fecha_seguimiento),
    INDEX idx_semana_inicio (semana_inicio),
    INDEX idx_pediluvio_activo (pediluvio_activo),
    INDEX idx_cuarentena_activa (cuarentena_activa),
    CONSTRAINT fk_seguimiento_moko_foco FOREIGN KEY (foco_id) REFERENCES registro_moko(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sigatoka
CREATE TABLE IF NOT EXISTS sigatoka_evaluacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    hacienda VARCHAR(200) NOT NULL,
    fecha DATE NOT NULL,
    semana_epidemiologica INT,
    periodo VARCHAR(50),
    evaluador VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_sigatoka_eval_cliente (cliente_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sigatoka_lote (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL,
    lote_codigo VARCHAR(100) NOT NULL,
    INDEX idx_sigatoka_lote_eval (evaluacion_id),
    CONSTRAINT fk_sigatoka_lote_eval FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sigatoka_muestra (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NULL,
    lote_id BIGINT NULL,
    numero_muestra INT NULL,
    muestra_num INT NULL,
    lote VARCHAR(100) NULL,
    variedad VARCHAR(50) NULL,
    edad VARCHAR(50) NULL,
    hojas_emitidas INT NULL,
    hojas_erectas INT NULL,
    hojas_con_sintomas INT NULL,
    hoja_mas_joven_enferma INT NULL,
    hoja_mas_joven_necrosada INT NULL,
    promedio_hojas_emitidas DECIMAL(10,2) NULL,
    promedio_hojas_erectas DECIMAL(10,2) NULL,
    promedio_hojas_sintomas DECIMAL(10,2) NULL,
    promedio_hoja_joven_enferma DECIMAL(10,2) NULL,
    promedio_hoja_joven_necrosada DECIMAL(10,2) NULL,
    hoja_3era VARCHAR(10) NULL,
    hoja_4ta VARCHAR(10) NULL,
    hoja_5ta VARCHAR(10) NULL,
    total_hojas_3era INT NULL,
    total_hojas_4ta INT NULL,
    total_hojas_5ta INT NULL,
    plantas_muestreadas INT NULL,
    plantas_con_lesiones INT NULL,
    total_lesiones INT NULL,
    plantas_3er_estadio INT NULL,
    total_letras INT NULL,
    h_v_l_e_0w DECIMAL(5,2) NULL,
    h_v_l_q_0w DECIMAL(5,2) NULL,
    h_v_l_q5_0w DECIMAL(5,2) NULL,
    t_h_0w DECIMAL(5,2) NULL,
    h_v_l_e_10w DECIMAL(5,2) NULL,
    h_v_l_q_10w DECIMAL(5,2) NULL,
    h_v_l_q5_10w DECIMAL(5,2) NULL,
    t_h_10w DECIMAL(5,2) NULL,
    INDEX idx_sigatoka_muestra_eval (evaluacion_id),
    INDEX idx_sigatoka_muestra_lote (lote_id),
    CONSTRAINT fk_sigatoka_muestra_eval FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE,
    CONSTRAINT fk_sigatoka_muestra_lote FOREIGN KEY (lote_id) REFERENCES sigatoka_lote(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sigatoka_resumen (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    promedio_hojas_emitidas DECIMAL(10,2),
    promedio_hojas_erectas DECIMAL(10,2),
    promedio_hojas_sintomas DECIMAL(10,2),
    promedio_hoja_joven_enferma DECIMAL(10,2),
    promedio_hoja_joven_necrosada DECIMAL(10,2),
    CONSTRAINT fk_sigatoka_resumen_eval FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sigatoka_indicadores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    incidencia_promedio DECIMAL(10,2),
    severidad_promedio DECIMAL(10,2),
    indice_hojas_erectas DECIMAL(10,2),
    ritmo_emision DECIMAL(10,2),
    velocidad_evolucion DECIMAL(10,2),
    velocidad_necrosis DECIMAL(10,2),
    CONSTRAINT fk_sigatoka_indicadores_eval FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sigatoka_estado_evolutivo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    ee_3era_hoja DECIMAL(10,2),
    ee_4ta_hoja DECIMAL(10,2),
    ee_5ta_hoja DECIMAL(10,2),
    nivel_infeccion VARCHAR(50),
    CONSTRAINT fk_sigatoka_estado_eval FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sigatoka_stover_promedio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    stover_3era_hoja DECIMAL(10,2),
    stover_4ta_hoja DECIMAL(10,2),
    stover_5ta_hoja DECIMAL(10,2),
    stover_promedio DECIMAL(10,2),
    nivel_infeccion VARCHAR(50),
    CONSTRAINT fk_sigatoka_stover_eval FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
