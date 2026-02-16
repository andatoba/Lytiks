# TABLAS DE BASE DE DATOS - PROYECTO LYTIKS

**Fecha de generación:** 16 de febrero de 2026  
**Base de datos:** lytiks_data (MySQL)

---

## 📊 RESUMEN

**Total de tablas:** 35 tablas principales

### Por módulo:
- **Autenticación y Usuarios:** 3 tablas
- **Clientes:** 1 tabla
- **Auditorías:** 5 tablas  
- **Haciendas y Lotes:** 3 tablas
- **Productos y Aplicaciones:** 4 tablas
- **Seguimiento de Ubicación:** 1 tabla
- **Moko:** 3 tablas
- **Sigatoka:** 8 tablas

---

## 1️⃣ MÓDULO DE AUTENTICACIÓN Y USUARIOS

### 1.1 `is_roles`
**Descripción:** Roles de usuarios del sistema  
**Campos principales:**
- `id_roles` (PK, BIGINT, AUTO_INCREMENT)
- `nombre` (VARCHAR 200)
- `detalle` (VARCHAR 1000)
- `estado` (VARCHAR 1)
- `usuario_ingreso`, `fecha_ingreso`
- `usuario_modificacion`, `fecha_modificacion`

**Índices:**
- PRIMARY KEY: `id_roles`

---

### 1.2 `is_usuarios`
**Descripción:** Usuarios del sistema con información completa  
**Campos principales:**
- `id_usuarios` (PK, BIGINT, AUTO_INCREMENT)
- `id_roles` (FK → is_roles)
- `usuario` (VARCHAR 200)
- `clave` (VARCHAR 200)
- `cedula` (VARCHAR 13)
- `nombres`, `apellidos` (VARCHAR 200)
- `direccion_dom` (VARCHAR 2000)
- `telefono_casa`, `telefono_cel`
- `correo` (VARCHAR 200)
- `logo`, `logo_ruta`
- `intentos` (INT)
- `estado` (VARCHAR 1)
- Campos de auditoría: `usuario_ingreso`, `fecha_ingreso`, etc.

**Índices:**
- PRIMARY KEY: `id_usuarios`
- `idx_is_usuarios_usuario` (usuario)
- `idx_is_usuarios_estado` (estado)
- `idx_is_usuarios_roles` (id_roles)

**Relaciones:**
- FK `id_roles` → is_roles(id_roles)

---

### 1.3 `users`
**Descripción:** Tabla legacy de usuarios (para compatibilidad/seeds)  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `username` (VARCHAR 255, UNIQUE)
- `password` (VARCHAR 255)
- `first_name`, `last_name` (VARCHAR 255)
- `email` (VARCHAR 255)
- `role` (VARCHAR 50)
- `active` (TINYINT 1)

**Índices:**
- PRIMARY KEY: `id`
- UNIQUE: `username`

---

## 2️⃣ MÓDULO DE CLIENTES

### 2.1 `clients`
**Descripción:** Información de clientes/productores  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `cedula` (VARCHAR 255, UNIQUE, NOT NULL)
- `nombre` (VARCHAR 255, NOT NULL)
- `apellidos` (VARCHAR 255)
- `telefono`, `email`, `direccion`
- `parroquia` (VARCHAR 255)
- `finca_nombre` (VARCHAR 255)
- `finca_hectareas` (DOUBLE)
- `cultivos_principales` (VARCHAR 255)
- `geolocalizacion_lat`, `geolocalizacion_lng` (DOUBLE)
- `observaciones` (TEXT)
- `estado` (VARCHAR 50, DEFAULT 'ACTIVO')
- `fecha_registro`, `fecha_actualizacion` (DATETIME)
- `tecnico_asignado_id` (BIGINT)

**Índices:**
- PRIMARY KEY: `id`
- `idx_clients_cedula` (cedula)
- `idx_clients_nombre` (nombre)
- `idx_clients_tecnico` (tecnico_asignado_id)

---

## 3️⃣ MÓDULO DE AUDITORÍAS

### 3.1 `audits`
**Descripción:** Registro principal de auditorías de campo  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `client_id` (FK → clients)
- `hacienda` (VARCHAR 255, NOT NULL)
- `cultivo` (VARCHAR 255, NOT NULL)
- `fecha` (DATETIME, NOT NULL)
- `evaluaciones` (TEXT)
- `tecnico_id` (BIGINT)
- `estado` (VARCHAR 50, DEFAULT 'PENDIENTE')
- `observaciones` (TEXT)

**Índices:**
- PRIMARY KEY: `id`
- `idx_audits_client` (client_id)
- `idx_audits_tecnico` (tecnico_id)

**Relaciones:**
- FK `client_id` → clients(id) ON DELETE SET NULL

---

### 3.2 `audit_scores`
**Descripción:** Puntuaciones por categoría de cada auditoría  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `audit_id` (FK → audits, NOT NULL)
- `categoria` (VARCHAR 255, NOT NULL)
- `puntuacion` (INT, NOT NULL)
- `max_puntuacion` (INT, DEFAULT 100)
- `observaciones` (TEXT)
- `photo_path` (VARCHAR 500)

**Índices:**
- PRIMARY KEY: `id`
- `idx_audit_scores_audit` (audit_id)

**Relaciones:**
- FK `audit_id` → audits(id) ON DELETE CASCADE

---

### 3.3 `audit_photos`
**Descripción:** Fotografías adjuntas a las auditorías  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `audit_id` (FK → audits, NOT NULL)
- `file_name` (VARCHAR 255, NOT NULL)
- `file_path` (VARCHAR 500, NOT NULL)
- `file_size` (BIGINT)
- `mime_type` (VARCHAR 100)
- `description` (TEXT)
- `categoria` (VARCHAR 255)

**Índices:**
- PRIMARY KEY: `id`
- `idx_audit_photos_audit` (audit_id)

**Relaciones:**
- FK `audit_id` → audits(id) ON DELETE CASCADE

---

### 3.4 `audit_categoria`
**Descripción:** Categorías de evaluación en auditorías (dinámicas)  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `codigo` (VARCHAR 100, NOT NULL, UNIQUE)
- `nombre` (VARCHAR 255, NOT NULL)
- `descripcion` (TEXT)
- `orden` (INT, DEFAULT 0)
- `activo` (BOOLEAN, DEFAULT TRUE)
- `created_at`, `updated_at` (TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`
- UNIQUE: `codigo`
- `idx_audit_categoria_codigo` (codigo)
- `idx_audit_categoria_activo` (activo)

**Datos iniciales:**
- ENFUNDE
- SELECCION
- COSECHA
- DESHOJE_FITOSANITARIO
- DESHOJE_NORMAL
- DESVIO_HIJOS
- APUNTALAMIENTO_ZUNCHO
- APUNTALAMIENTO_PUNTAL
- MANEJO_AGUAS_RIEGO
- MANEJO_AGUAS_DRENAJE

---

### 3.5 `audit_criterio`
**Descripción:** Criterios específicos de evaluación dentro de cada categoría  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `categoria_id` (FK → audit_categoria, NOT NULL)
- `nombre` (TEXT, NOT NULL)
- `puntuacion_maxima` (INT, NOT NULL, DEFAULT 100)
- `orden` (INT, DEFAULT 0)
- `activo` (BOOLEAN, DEFAULT TRUE)
- `created_at`, `updated_at` (TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`
- `idx_audit_criterio_categoria` (categoria_id)
- `idx_audit_criterio_activo` (activo)

**Relaciones:**
- FK `categoria_id` → audit_categoria(id) ON DELETE CASCADE

**Ejemplos de criterios (ENFUNDE):**
- ATRASO DE LABOR E MAL IDENTIFICACION
- RETOLDEO
- CIRUGIA, SE ENCUENTRAN MELLIZOS
- FALTA DE PROTECTORES Y/O MAL COLOCADO
- SACUDIR BRACTEAS 2DA SUBIDA Y 3RA SUBIDA AL RACIMO

---

## 4️⃣ MÓDULO DE HACIENDAS Y LOTES

### 4.1 `configuracion_logo`
**Descripción:** Configuración de logos del sistema  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `nombre` (VARCHAR 255, NOT NULL)
- `ruta_logo` (VARCHAR 500, NOT NULL)
- `logo_base64` (LONGTEXT)
- `tipo_mime` (VARCHAR 100)
- `activo` (TINYINT 1, DEFAULT 1)
- `descripcion` (TEXT)
- `fecha_creacion`, `fecha_actualizacion` (TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`
- `idx_logo_activo` (activo)

---

### 4.2 `hacienda`
**Descripción:** Haciendas/fincas de los clientes  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `nombre` (VARCHAR 255, NOT NULL)
- `detalle` (TEXT)
- `ubicacion` (VARCHAR 500)
- `hectareas` (DOUBLE)
- `cliente_id` (FK → clients, NOT NULL)
- `estado` (VARCHAR 50, DEFAULT 'ACTIVO')
- `fecha_creacion`, `fecha_actualizacion` (TIMESTAMP)
- `usuario_creacion`, `usuario_actualizacion` (VARCHAR 255)

**Índices:**
- PRIMARY KEY: `id`
- `idx_hacienda_cliente` (cliente_id)
- `idx_hacienda_nombre` (nombre)
- `idx_hacienda_estado` (estado)

**Relaciones:**
- FK `cliente_id` → clients(id) ON DELETE CASCADE

---

### 4.3 `lote`
**Descripción:** Lotes/secciones dentro de cada hacienda  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `nombre` (VARCHAR 255, NOT NULL)
- `codigo` (VARCHAR 100, NOT NULL)
- `detalle` (TEXT)
- `hectareas` (DOUBLE)
- `variedad` (VARCHAR 100)
- `edad` (VARCHAR 50)
- `hacienda_id` (FK → hacienda, NOT NULL)
- `estado` (VARCHAR 50, DEFAULT 'ACTIVO')
- `fecha_creacion`, `fecha_actualizacion` (TIMESTAMP)
- `usuario_creacion`, `usuario_actualizacion` (VARCHAR 255)

**Índices:**
- PRIMARY KEY: `id`
- `idx_lote_hacienda` (hacienda_id)
- `idx_lote_codigo` (codigo)
- UNIQUE: (hacienda_id, codigo)

**Relaciones:**
- FK `hacienda_id` → hacienda(id) ON DELETE CASCADE

---

## 5️⃣ MÓDULO DE PRODUCTOS Y APLICACIONES

### 5.1 `producto`
**Descripción:** Catálogo de productos agrícolas  
**Campos principales:**
- `id_producto` (PK, INT, AUTO_INCREMENT)
- `nombre` (VARCHAR 255, NOT NULL)
- `detalle` (VARCHAR 255)
- `cantidad` (INT)
- `peso_kg` (DOUBLE)

**Índices:**
- PRIMARY KEY: `id_producto`

---

### 5.2 `productos_contencion`
**Descripción:** Productos específicos para contención de enfermedades  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `nombre` (VARCHAR 255, NOT NULL)
- `presentacion` (VARCHAR 255)
- `dosis_sugerida` (VARCHAR 500)
- `url` (VARCHAR 1000)
- `created_at`, `updated_at` (TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`

---

### 5.3 `aplicaciones`
**Descripción:** Planes de aplicación de productos  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `cliente_id` (FK → clients, NOT NULL)
- `producto_id` (BIGINT, NOT NULL)
- `producto_nombre` (VARCHAR 255)
- `plan` (VARCHAR 255, DEFAULT 'Moko')
- `lote` (VARCHAR 255)
- `area_hectareas` (DECIMAL 10,2)
- `dosis` (VARCHAR 255)
- `fecha_inicio` (DATETIME)
- `frecuencia_dias` (INT, DEFAULT 7)
- `repeticiones` (INT, DEFAULT 4)
- `recordatorio_hora` (VARCHAR 10, DEFAULT '08:00')
- `created_at`, `updated_at` (TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`
- `idx_aplicaciones_cliente` (cliente_id)
- `idx_aplicaciones_producto` (producto_id)

---

### 5.4 `seguimiento_aplicaciones`
**Descripción:** Seguimiento de cada aplicación programada  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `aplicacion_id` (FK → aplicaciones, NOT NULL)
- `numero_aplicacion` (INT, NOT NULL)
- `fecha_programada` (DATETIME, NOT NULL)
- `fecha_aplicada` (DATETIME NULL)
- `estado` (VARCHAR 50, DEFAULT 'programada')
- `dosis_aplicada` (VARCHAR 255)
- `lote` (VARCHAR 255)
- `observaciones` (TEXT)
- `foto_evidencia` (VARCHAR 500)
- `recordatorio_activo` (BOOLEAN, DEFAULT TRUE)
- `hora_recordatorio` (VARCHAR 10, DEFAULT '08:00')
- `fecha_creacion`, `fecha_actualizacion` (TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`
- `idx_seguimiento_aplicacion` (aplicacion_id)
- `idx_seguimiento_fecha` (fecha_programada)

**Relaciones:**
- FK `aplicacion_id` → aplicaciones(id) ON DELETE CASCADE

---

## 6️⃣ MÓDULO DE SEGUIMIENTO DE UBICACIÓN

### 6.1 `location_tracking`
**Descripción:** Trazabilidad GPS de técnicos en campo (cada 5 segundos, 8AM-4PM)  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `user_id` (VARCHAR 100, NOT NULL)
- `user_name` (VARCHAR 255)
- `latitude` (DOUBLE, NOT NULL)
- `longitude` (DOUBLE, NOT NULL)
- `accuracy` (DOUBLE)
- `matrix_latitude` (DOUBLE)
- `matrix_longitude` (DOUBLE)
- `timestamp` (DATETIME, NOT NULL)
- `created_at` (DATETIME, DEFAULT CURRENT_TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`
- `idx_location_user_id` (user_id)
- `idx_location_timestamp` (timestamp)
- `idx_location_user_timestamp` (user_id, timestamp)

**Configuración:**
- Captura automática cada **5 segundos**
- Horario: 8:00 AM - 4:00 PM
- Retención: 90 días recomendados

---

## 7️⃣ MÓDULO DE MOKO

### 7.1 `sintomas`
**Descripción:** Catálogo de síntomas de Moko  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `categoria` (VARCHAR 50)
- `sintoma_observable` (VARCHAR 200)
- `descripcion_tecnica` (TEXT)
- `severidad` (VARCHAR 20)

**Índices:**
- PRIMARY KEY: `id`

**Categorías de síntomas:**
- Externo
- Fruto
- Flor masculina
- Pseudotallo
- Hoja
- Rizoma

---

### 7.2 `registro_moko`
**Descripción:** Registro de focos de Moko detectados  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `numero_foco` (INT, UNIQUE, NOT NULL)
- `cliente_id` (FK → clients, NOT NULL)
- `gps_coordinates` (VARCHAR 255)
- `plantas_afectadas` (INT, NOT NULL)
- `fecha_deteccion` (DATETIME, NOT NULL)
- `sintoma_id` (FK → sintomas)
- `sintomas_json` (TEXT)
- `lote` (VARCHAR 255)
- `area_hectareas` (DOUBLE)
- `severidad` (VARCHAR 255)
- `metodo_comprobacion` (VARCHAR 255)
- `observaciones` (TEXT)
- `foto_path` (VARCHAR 500)
- `fecha_creacion` (DATETIME, DEFAULT CURRENT_TIMESTAMP)

**Índices:**
- PRIMARY KEY: `id`
- UNIQUE: `numero_foco`
- `idx_registro_moko_cliente` (cliente_id)
- `idx_registro_moko_sintoma` (sintoma_id)

**Relaciones:**
- FK `cliente_id` → clients(id)
- FK `sintoma_id` → sintomas(id)

---

### 7.3 `seguimiento_moko`
**Descripción:** Seguimiento semanal de medidas de control en focos de Moko  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `foco_id` (FK → registro_moko, NOT NULL)
- `numero_foco` (INT, NOT NULL)
- `semana_inicio` (INT)
- `plantas_afectadas` (INT, NOT NULL)
- `plantas_inyectadas` (INT, NOT NULL)
- **Medidas de control (BOOLEAN):**
  - `control_vectores`
  - `cuarentena_activa`
  - `unica_entrada_habilitada`
  - `eliminacion_maleza_hospedera`
  - `control_picudo_aplicado`
  - `inspeccion_plantas_vecinas`
  - `corte_riego`
  - `pediluvio_activo`
- `ppm_solucion_desinfectante` (INT)
- `fecha_seguimiento` (DATETIME, NOT NULL)
- `fecha_creacion` (DATETIME, NOT NULL)

**Índices:**
- PRIMARY KEY: `id`
- `idx_foco_id` (foco_id)
- `idx_numero_foco` (numero_foco)
- `idx_fecha_seguimiento` (fecha_seguimiento)
- `idx_semana_inicio` (semana_inicio)
- `idx_pediluvio_activo` (pediluvio_activo)
- `idx_cuarentena_activa` (cuarentena_activa)

**Relaciones:**
- FK `foco_id` → registro_moko(id) ON DELETE CASCADE

---

## 8️⃣ MÓDULO DE SIGATOKA

### 8.1 `sigatoka_evaluacion`
**Descripción:** Evaluación principal de Sigatoka  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `cliente_id` (BIGINT, NOT NULL)
- `hacienda` (VARCHAR 200, NOT NULL)
- `fecha` (DATE, NOT NULL)
- `semana_epidemiologica` (INT) - **ISO 8601**
- `periodo` (VARCHAR 50) - **Auto-calculado**
- `evaluador` (VARCHAR 100, NOT NULL)
- `created_at`, `updated_at` (DATETIME)

**Índices:**
- PRIMARY KEY: `id`
- `idx_sigatoka_eval_cliente` (cliente_id)

---

### 8.2 `sigatoka_lote`
**Descripción:** Lotes evaluados en una evaluación de Sigatoka  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `evaluacion_id` (FK → sigatoka_evaluacion, NOT NULL)
- `lote_codigo` (VARCHAR 100, NOT NULL)

**Índices:**
- PRIMARY KEY: `id`
- `idx_sigatoka_lote_eval` (evaluacion_id)

**Relaciones:**
- FK `evaluacion_id` → sigatoka_evaluacion(id) ON DELETE CASCADE

---

### 8.3 `sigatoka_muestra`
**Descripción:** Datos detallados de cada muestra (planta) evaluada  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `evaluacion_id` (FK → sigatoka_evaluacion)
- `lote_id` (FK → sigatoka_lote)
- `numero_muestra`, `muestra_num` (INT)
- `lote` (VARCHAR 100)
- `variedad`, `edad` (VARCHAR 50)
- **Conteo de hojas:**
  - `hojas_emitidas`, `hojas_erectas`, `hojas_con_sintomas` (INT)
  - `hoja_mas_joven_enferma`, `hoja_mas_joven_necrosada` (INT)
- **Promedios:**
  - `promedio_hojas_emitidas`, `promedio_hojas_erectas`, etc. (DECIMAL 10,2)
- **Grados de infección:**
  - `hoja_3era`, `hoja_4ta`, `hoja_5ta` (VARCHAR 10) - ej: "2a", "3c"
  - `total_hojas_3era`, `total_hojas_4ta`, `total_hojas_5ta` (INT)
- **Estadísticas:**
  - `plantas_muestreadas`, `plantas_con_lesiones`, `total_lesiones` (INT)
  - `plantas_3er_estadio`, `total_letras` (INT)
- **Valores Stover (Semana 0):**
  - `h_v_l_e_0w`, `h_v_l_q_0w`, `h_v_l_q5_0w`, `t_h_0w` (DECIMAL 5,2)
- **Valores Stover (Semana 10):**
  - `h_v_l_e_10w`, `h_v_l_q_10w`, `h_v_l_q5_10w`, `t_h_10w` (DECIMAL 5,2)

**Índices:**
- PRIMARY KEY: `id`
- `idx_sigatoka_muestra_eval` (evaluacion_id)
- `idx_sigatoka_muestra_lote` (lote_id)

**Relaciones:**
- FK `evaluacion_id` → sigatoka_evaluacion(id) ON DELETE CASCADE
- FK `lote_id` → sigatoka_lote(id) ON DELETE CASCADE

---

### 8.4 `sigatoka_resumen`
**Descripción:** Resumen calculado de la evaluación  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `evaluacion_id` (FK → sigatoka_evaluacion, UNIQUE, NOT NULL)
- `promedio_hojas_emitidas` (DECIMAL 10,2)
- `promedio_hojas_erectas` (DECIMAL 10,2)
- `promedio_hojas_sintomas` (DECIMAL 10,2)
- `promedio_hoja_joven_enferma` (DECIMAL 10,2)
- `promedio_hoja_joven_necrosada` (DECIMAL 10,2)

**Índices:**
- PRIMARY KEY: `id`
- UNIQUE: `evaluacion_id`

**Relaciones:**
- FK `evaluacion_id` → sigatoka_evaluacion(id) ON DELETE CASCADE

---

### 8.5 `sigatoka_indicadores`
**Descripción:** Indicadores calculados de la enfermedad  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `evaluacion_id` (FK → sigatoka_evaluacion, UNIQUE, NOT NULL)
- `incidencia_promedio` (DECIMAL 10,2)
- `severidad_promedio` (DECIMAL 10,2)
- `indice_hojas_erectas` (DECIMAL 10,2)
- `ritmo_emision` (DECIMAL 10,2)
- `velocidad_evolucion` (DECIMAL 10,2)
- `velocidad_necrosis` (DECIMAL 10,2)

**Índices:**
- PRIMARY KEY: `id`
- UNIQUE: `evaluacion_id`

**Relaciones:**
- FK `evaluacion_id` → sigatoka_evaluacion(id) ON DELETE CASCADE

---

### 8.6 `sigatoka_estado_evolutivo`
**Descripción:** Estado evolutivo de Sigatoka por hoja  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `evaluacion_id` (FK → sigatoka_evaluacion, UNIQUE, NOT NULL)
- `ee_3era_hoja` (DECIMAL 10,2)
- `ee_4ta_hoja` (DECIMAL 10,2)
- `ee_5ta_hoja` (DECIMAL 10,2)
- `nivel_infeccion` (VARCHAR 50)

**Índices:**
- PRIMARY KEY: `id`
- UNIQUE: `evaluacion_id`

**Relaciones:**
- FK `evaluacion_id` → sigatoka_evaluacion(id) ON DELETE CASCADE

---

### 8.7 `sigatoka_stover_promedio`
**Descripción:** Promedio de índices Stover por hoja  
**Campos principales:**
- `id` (PK, BIGINT, AUTO_INCREMENT)
- `evaluacion_id` (FK → sigatoka_evaluacion, UNIQUE, NOT NULL)
- `stover_3era_hoja` (DECIMAL 10,2)
- `stover_4ta_hoja` (DECIMAL 10,2)
- `stover_5ta_hoja` (DECIMAL 10,2)
- `stover_promedio` (DECIMAL 10,2)
- `nivel_infeccion` (VARCHAR 50)

**Índices:**
- PRIMARY KEY: `id`
- UNIQUE: `evaluacion_id`

**Relaciones:**
- FK `evaluacion_id` → sigatoka_evaluacion(id) ON DELETE CASCADE

---

### 8.8 `sigatoka_muestra_completa`
**Descripción:** Vista/tabla auxiliar para consultas complejas de Sigatoka  
*Nota: Esta puede ser una view materializada o tabla auxiliar según implementación*

---

## 🔧 SCRIPTS DE MIGRACIÓN DISPONIBLES

### Archivo: `V1__baseline.sql`
- **Ubicación:** `backend_new/src/main/resources/db/migration/`
- **Contenido:** Esquema base completo con todas las tablas principales
- **Estado:** ✅ Listo para aplicar

### Archivo: `audit_categories_tables.sql`
- **Ubicación:** `backend_new/database/`
- **Contenido:** Tablas `audit_categoria` y `audit_criterio` con datos iniciales (10 categorías, 55+ criterios)
- **Estado:** ✅ Listo para aplicar

### Archivo: `new_tables_hacienda_lote_logo.sql`
- **Ubicación:** `backend_new/database/`
- **Contenido:** Tablas `hacienda`, `lote`, `configuracion_logo`
- **Estado:** ✅ Listo para aplicar

### Archivo: `sigatoka_complete_tables.sql`
- **Ubicación:** `backend_new/database/`
- **Contenido:** Sistema completo de Sigatoka con cálculos automáticos
- **Estado:** ⚠️ Revisar - puede estar en conflicto con V1__baseline.sql

### Archivo: `location_tracking_table.sql`
- **Ubicación:** `backend_new/database/`
- **Contenido:** Tabla de seguimiento GPS (configurada para 5 segundos)
- **Estado:** ✅ Listo para aplicar

### Archivo: `seguimiento_moko_table.sql`
- **Ubicación:** `backend_new/database/`
- **Contenido:** Tabla de seguimiento de focos Moko
- **Estado:** ✅ Listo para aplicar

### Archivo: `moko_tables.sql`
- **Ubicación:** `backend_new/src/main/resources/`
- **Contenido:** Tablas `sintomas` y `registro_moko` con datos de síntomas
- **Estado:** ✅ Listo para aplicar

---

## ✅ ORDEN DE EJECUCIÓN RECOMENDADO

```sql
-- 1. Esquema base (usuarios, clientes, auditorías base)
source backend_new/src/main/resources/db/migration/V1__baseline.sql

-- 2. Categorías de auditoría (nuevas tablas dinámicas)
source backend_new/database/audit_categories_tables.sql

-- 3. Haciendas y lotes
source backend_new/database/new_tables_hacienda_lote_logo.sql

-- 4. Moko (síntomas incluidos)
source backend_new/src/main/resources/moko_tables.sql

-- 5. Productos de contención
source backend_new/database/init_productos_contencion.sql

-- NOTA: location_tracking y seguimiento_moko ya están en V1__baseline.sql
-- Solo ejecutar si hay diferencias o actualizaciones específicas
```

---

## 🔍 VERIFICACIÓN DE TABLAS EXISTENTES

Ejecuta este comando en MySQL para ver qué tablas ya existen:

```sql
USE lytiks_data;
SHOW TABLES;
```

Para verificar estructura de una tabla específica:

```sql
DESCRIBE nombre_tabla;
```

Para ver relaciones (Foreign Keys):

```sql
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'lytiks_data'
AND REFERENCED_TABLE_NAME IS NOT NULL;
```

---

## 📌 NOTAS IMPORTANTES

1. **Dependencias de tablas:**
   - Ejecutar en orden: roles → usuarios → clients → hacienda → lote
   - Ejecutar antes las tablas de catálogo (sintomas, audit_categoria, productos)

2. **Configuración actual:**
   - Location tracking: **5 segundos** (8 AM - 4 PM)
   - Semana epidemiológica: **ISO 8601**
   - Periodo semana del mes: **Auto-calculado**

3. **Tablas con datos iniciales:**
   - `sintomas`: 13 registros de síntomas de Moko
   - `audit_categoria`: 10 categorías de auditoría
   - `audit_criterio`: 55+ criterios de evaluación
   - `productos_contencion`: (usar init_productos_contencion.sql)

4. **Backend compilado:**
   - JAR: `backend_new/target/lytiks-backend-0.0.1-SNAPSHOT.jar`
   - APIs REST disponibles en: `http://5.161.198.89:8081/api`

---

## 🚀 PRÓXIMOS PASOS

1. **Verificar tablas existentes** en la base de datos
2. **Aplicar migraciones faltantes** en orden correcto
3. **Iniciar backend:** `java -jar backend_new/target/lytiks-backend-0.0.1-SNAPSHOT.jar`
4. **Verificar endpoints:** `GET http://5.161.198.89:8081/api/audit-categorias/con-criterios`
5. **Probar integración** Flutter → API → Base de datos

---

**Generado automáticamente por GitHub Copilot**  
**Proyecto: Lytiks - Sistema de gestión agrícola**
