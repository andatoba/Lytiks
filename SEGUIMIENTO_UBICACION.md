# Sistema de Seguimiento de Ubicación Automático

## 📍 Descripción

Sistema automático de captura y seguimiento de ubicación GPS para técnicos de campo. Captura coordenadas cada 5 segundos durante el horario laboral (8:00 AM - 6:00 PM) y funciona tanto online como offline.

## ✨ Características

### 1. **Captura Automática**
- ✅ Captura de ubicación cada 5 segundos
- ✅ Solo durante horario laboral: 8:00 AM - 6:00 PM
- ✅ Alta precisión GPS con información de accuracy

### 2. **Modo Offline**
- ✅ Almacenamiento local en SQLite cuando no hay conexión
- ✅ Sincronización automática cuando se restaura la conexión
- ✅ Cola de sincronización para envío ordenado de datos

### 3. **Coordenadas de Matriz**
- ✅ Configuración de punto de partida (oficina/matriz)
- ✅ Registro de salida desde matriz hasta primera hacienda
- ✅ Seguimiento de retorno a matriz

### 4. **Seguimiento en Tiempo Real**
- ✅ Inicio automático al hacer login
- ✅ Historial de ubicaciones en la app
- ✅ Estado de sincronización visible

## 🚀 Configuración

### Backend (Spring Boot)

1. **Ejecutar el script SQL**
   ```bash
   mysql -u root -p lytiks_data < backend_new/database/location_tracking_table.sql
   ```

2. **Recompilar el backend**
   ```bash
   cd backend_new
   mvn clean package -DskipTests
   ```

3. **Reiniciar el servidor**
   ```bash
   java -jar target/lytiks-backend-0.0.1-SNAPSHOT.jar
   ```

### App Móvil (Flutter)

1. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

2. **Permisos de ubicación**
   Los permisos ya están configurados en `AndroidManifest.xml`:
   - `ACCESS_FINE_LOCATION`: Ubicación precisa
   - `ACCESS_COARSE_LOCATION`: Ubicación aproximada
   - `ACCESS_BACKGROUND_LOCATION`: Ubicación en segundo plano
   - `WAKE_LOCK`: Mantener dispositivo activo
   - `FOREGROUND_SERVICE`: Servicio en primer plano
   - `RECEIVE_BOOT_COMPLETED`: Reiniciar después de reinicio del dispositivo

3. **Compilar y ejecutar**
   ```bash
   flutter run
   ```

## 📱 Uso de la Aplicación

### 1. Inicio de Sesión
Al iniciar sesión como técnico (rol OPERADOR), el seguimiento de ubicación se inicia automáticamente.

### 2. Configurar Coordenadas de Matriz
1. Ir a **Inicio** → **📍 Seguimiento de Ubicación**
2. Configurar las coordenadas de la matriz:
   - Opción A: Ingresar manualmente latitud y longitud
   - Opción B: Usar el botón "Usar Ubicación Actual"
3. Presionar **Guardar**

### 3. Ver Historial
En la pantalla de "Seguimiento de Ubicación" puedes ver:
- **Estado del seguimiento**: Activo/Inactivo
- **Ubicación actual**: Coordenadas y precisión
- **Historial reciente**: Últimas 20 ubicaciones
- **Estado de sincronización**: Pendiente/Sincronizado

### 4. Sincronización Manual
Si necesitas forzar la sincronización:
1. Ir a la pantalla de "Seguimiento de Ubicación"
2. Presionar el ícono de sincronización en la barra superior

## 🔧 API Endpoints

### Guardar Ubicación
```http
POST /api/location-tracking
Content-Type: application/json

{
  "userId": "123",
  "userName": "Juan Pérez",
  "latitude": -2.1894,
  "longitude": -79.8890,
  "accuracy": 10.5,
  "matrixLatitude": -2.1800,
  "matrixLongitude": -79.8850,
  "timestamp": "2026-01-14T09:30:00"
}
```

### Obtener Ubicaciones de Hoy (por Usuario)
```http
GET /api/location-tracking/user/{userId}/today
```

### Obtener Ubicaciones en Horario Laboral
```http
GET /api/location-tracking/user/{userId}/work-hours
```

### Obtener Todas las Ubicaciones de Hoy
```http
GET /api/location-tracking/today
```

### Obtener por Rango de Fechas
```http
GET /api/location-tracking/user/{userId}/range?startDate=2026-01-14T00:00:00&endDate=2026-01-14T23:59:59
```

### Limpiar Ubicaciones Antiguas
```http
DELETE /api/location-tracking/cleanup?days=90
```

## 📊 Estructura de Datos

### Base de Datos Local (SQLite)
```sql
CREATE TABLE location_tracking (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  user_name TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  accuracy REAL,
  matrix_latitude REAL,
  matrix_longitude REAL,
  timestamp TEXT NOT NULL,
  is_synced INTEGER DEFAULT 0
)
```

### Base de Datos Servidor (MySQL)
```sql
CREATE TABLE location_tracking (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(100) NOT NULL,
  user_name VARCHAR(255),
  latitude DOUBLE NOT NULL,
  longitude DOUBLE NOT NULL,
  accuracy DOUBLE,
  matrix_latitude DOUBLE,
  matrix_longitude DOUBLE,
  timestamp DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

## 🔍 Monitoreo y Debugging

### Ver Logs en Flutter
Los logs se pueden ver en la consola con prefijos identificables:
- `📍` Captura de ubicación
- `💾` Almacenamiento local
- `📤` Sincronización con servidor
- `✅` Operación exitosa
- `❌` Error
- `⚠️` Advertencia

### Verificar en Base de Datos
```sql
-- Ver ubicaciones de hoy
SELECT * FROM location_tracking 
WHERE DATE(timestamp) = CURDATE() 
ORDER BY timestamp DESC;

-- Estadísticas por usuario
SELECT 
    user_id, 
    user_name, 
    COUNT(*) as total_registros,
    MIN(timestamp) as primer_registro,
    MAX(timestamp) as ultimo_registro
FROM location_tracking 
GROUP BY user_id, user_name;
```

## ⚙️ Configuración Avanzada

### Cambiar Intervalo de Captura
En `lib/services/location_tracking_service.dart`:
```dart
static const Duration _trackingInterval = Duration(seconds: 5);
```

### Cambiar Horario Laboral
En `lib/services/location_tracking_service.dart`:
```dart
static const int _startHour = 8;  // Hora de inicio
static const int _endHour = 18;   // Hora de fin (6 PM)
```

### Cambiar Días de Retención
En el endpoint de limpieza, el parámetro por defecto es 90 días:
```java
@DeleteMapping("/cleanup")
public ResponseEntity<Map<String, Object>> cleanupOldLocations(
    @RequestParam(defaultValue = "90") int days) {
```

## 🛡️ Privacidad y Seguridad

- ✅ Solo se captura ubicación durante horario laboral
- ✅ El usuario debe otorgar permisos explícitos
- ✅ Datos encriptados en tránsito (HTTPS cuando esté configurado)
- ✅ Almacenamiento seguro local con SQLite
- ✅ Limpieza automática de datos antiguos

## 📝 Troubleshooting

### El tracking no inicia
1. Verificar que el usuario tenga rol OPERADOR
2. Verificar permisos de ubicación en el dispositivo
3. Verificar que los servicios de ubicación estén habilitados

### Las ubicaciones no se sincronizan
1. Verificar conexión a internet
2. Verificar que el servidor esté accesible
3. Verificar logs de la app para errores específicos
4. Usar sincronización manual desde la pantalla de tracking

### Consumo excesivo de batería
1. Verificar que solo se capture durante horario laboral
2. Ajustar el intervalo de captura si es necesario
3. Verificar que el GPS se apague fuera del horario

## 📞 Soporte

Para soporte técnico o consultas, contactar al equipo de desarrollo de Lytiks.

---

**Versión:** 1.0.0  
**Última actualización:** 14 de enero de 2026
