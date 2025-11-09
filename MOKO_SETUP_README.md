# Módulo de Registro de Moko - Instrucciones de Setup

## Base de Datos

### 1. Ejecutar Script SQL
Ejecuta el archivo `backend_new/src/main/resources/moko_tables.sql` en tu base de datos MySQL para crear las tablas necesarias:

```sql
-- Se crearán las siguientes tablas:
-- 1. sintomas: Catálogo de síntomas del Moko con severidades
-- 2. registro_moko: Registros de focos de Moko encontrados
```

### 2. Estructura de Datos

**Tabla `sintomas`:**
- Contiene 13 síntomas predefinidos del Moko
- Cada síntoma tiene categoría, descripción técnica y severidad (Bajo/Medio/Alto)
- La severidad se asigna automáticamente al seleccionar el síntoma

**Tabla `registro_moko`:**
- Almacena cada foco de Moko registrado
- Número secuencial automático para cada foco
- Relación con cliente y síntoma seleccionado
- Coordenadas GPS, fotos y observaciones

## Backend (Spring Boot)

### Archivos Creados:
1. `RegistroMokoController.java` - API REST endpoints
2. `RegistroMoko.java` - Entidad JPA
3. `Sintoma.java` - Entidad JPA para síntomas
4. `RegistroMokoService.java` - Lógica de negocio
5. `SintomaService.java` - Servicio para síntomas
6. `RegistroMokoRepository.java` - Repositorio JPA
7. `SintomaRepository.java` - Repositorio JPA

### Endpoints API:
- `GET /api/moko/next-foco-number` - Obtener próximo número de foco
- `GET /api/moko/sintomas` - Listar todos los síntomas
- `POST /api/moko/registrar` - Crear nuevo registro con foto
- `GET /api/moko/registros` - Listar todos los registros
- `GET /api/moko/registro/{id}` - Obtener registro específico
- `PUT /api/moko/registro/{id}` - Actualizar registro
- `DELETE /api/moko/registro/{id}` - Eliminar registro

## Frontend (Flutter)

### Archivos Creados:
1. `registro_moko_screen.dart` - Pantalla de registro de nuevo foco
2. `registro_moko_service.dart` - Servicio para comunicación con API

### Funcionalidades:
- **Número de Foco**: Generado automáticamente de forma secuencial
- **GPS**: Obtiene coordenadas del cliente o ubicación actual
- **Plantas Afectadas**: Campo numérico para ingresar cantidad
- **Fecha Detección**: Fecha actual automática
- **Síntomas**: Dropdown conectado a base de datos
- **Severidad**: Se completa automáticamente según síntoma seleccionado
- **Foto**: Captura de cámara integrada
- **Método Comprobación**: Dropdown (visual/laboratorio/prueba rápida/sospecha)
- **Observaciones**: Campo de texto libre

### Navegación:
- Se accede desde el botón "Registrar Nuevo Foco" en el módulo Moko
- Requiere tener un cliente seleccionado previamente
- Validación de campos obligatorios antes de guardar

## Carpeta de Fotos
Las fotos se guardan en: `photos/moko/`
Con formato: `moko_foco_[numero]_[timestamp]_[uuid].jpg`

## Validaciones
- Cliente debe estar seleccionado
- Campos obligatorios: plantas afectadas, síntoma, método comprobación
- Foto opcional pero recomendada
- Coordenadas GPS automáticas con fallback

## Colores del Tema
- **Rojo (#E53E3E)**: Para nuevo foco (urgencia)
- **Naranja (#ED8936)**: Para seguimiento (monitoreo) 
- **Verde (#38A169)**: Para listados (consulta)

## Estado de Severidad
- **Bajo** (Verde): Síntomas iniciales
- **Medio** (Naranja): Síntomas moderados
- **Alto** (Rojo): Síntomas avanzados/críticos