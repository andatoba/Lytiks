# 🔍 Diagnóstico: Seguimiento de Ubicación No Guarda Datos

## Problema Detectado
Las consultas a `location_tracking` retornan "Empty set" - no hay datos guardados.

## ✅ Pasos de Verificación y Solución

### 1️⃣ VERIFICAR QUE LA TABLA EXISTE EN MYSQL

Ejecuta en MySQL:
```bash
mysql -u root -p lytiks_data
```

Luego:
```sql
SHOW TABLES LIKE 'location_tracking';
```

**Si retorna "Empty set"** → La tabla NO existe. Ejecuta:
```sql
source C:/Users/WELLINGTON/Desktop/Lytiks/verificar_location_tracking.sql
```

O ejecuta manualmente el paso 2 del archivo `verificar_location_tracking.sql`.

---

### 2️⃣ VERIFICAR QUE EL BACKEND ESTÁ CORRIENDO

Verifica que el backend Java esté ejecutándose:
```powershell
# Desde PowerShell
cd C:\Users\WELLINGTON\Desktop\Lytiks\backend_new
.\mvnw.cmd spring-boot:run
```

O si usas el JAR compilado:
```powershell
java -jar target/lytiks-backend-0.0.1-SNAPSHOT.jar
```

**Verifica en los logs** que aparezca algo como:
```
Started LytiksBackendApplication in X seconds
Tomcat started on port(s): 8081 (http)
```

---

### 3️⃣ VERIFICAR QUE EL SERVICIO DE UBICACIÓN ESTÉ INICIADO EN LA APP

El servicio de ubicación **NO se inicia automáticamente**. Debe iniciarse cuando el usuario hace login.

#### Verificar en el código:

Busca en `lib/screens/login_screen.dart` o `home_screen.dart`:
```dart
// Debe existir algo como:
final locationService = LocationTrackingService();
await locationService.startTracking(
  userId: userId,
  userName: userName,
);
```

#### Si NO existe, el servicio nunca se inicia → NO hay capturas.

---

### 4️⃣ VERIFICAR LOGS DE LA APP (Chrome DevTools)

Si la app está corriendo en Chrome:
1. Abre **Chrome DevTools** (F12)
2. Ve a la pestaña **Console**
3. Busca mensajes como:
   - `📍 Iniciando seguimiento de ubicación para usuario: XXX`
   - `✅ Ubicación obtenida: lat, lng`
   - `✅ Ubicación guardada localmente`
   - `📤 Sincronizando X ubicaciones pendientes...`
   - `✅ Ubicación ID X sincronizada`

#### Mensajes de error comunes:
- `❌ No hay permisos de ubicación` → Dar permisos de ubicación en el navegador
- `⏰ Fuera del horario de seguimiento (8 AM - 6 PM)` → Estás fuera del horario laboral
- `📡 Sin conexión - ubicaciones quedarán pendientes` → Sin internet
- `⚠️ Error al sincronizar ubicación: 404/500` → Backend no responde o tabla no existe

---

### 5️⃣ PROBAR EL ENDPOINT MANUALMENTE

Prueba el endpoint directamente con curl o Postman:

```bash
curl -X POST http://5.161.198.89:8081/api/location-tracking \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test123",
    "userName": "Usuario Test",
    "latitude": -0.9320,
    "longitude": -79.6540,
    "accuracy": 10.0,
    "timestamp": "2026-02-16T14:30:00"
  }'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Ubicación guardada exitosamente",
  "data": { ... }
}
```

Si falla:
- **404** → Endpoint no existe (backend no corriendo o ruta incorrecta)
- **500** → Error en backend (revisar logs, probablemente tabla no existe)

---

### 6️⃣ VERIFICAR HORARIO ACTUAL

El seguimiento SOLO funciona entre **8:00 AM - 6:00 PM**.

Verifica la hora actual:
```sql
SELECT NOW() as hora_servidor;
SELECT HOUR(NOW()) as hora_actual;
```

Si la hora está fuera del rango 8-18, el servicio NO captura ubicaciones.

---

### 7️⃣ VERIFICAR PERMISOS DE UBICACIÓN EN EL NAVEGADOR

En Chrome:
1. Haz clic en el **candado** (izquierda de la URL)
2. Ve a **Configuración del sitio**
3. Busca **Ubicación**
4. Asegúrate que esté en **Permitir**

---

### 8️⃣ VERIFICAR SQFLITE EN WEB

Si la app está en Web, SQLite local **NO funciona**. Las ubicaciones se envían **directamente al backend**.

Verifica en los logs:
```
⚠️ No se pudo guardar ubicación localmente (normal en Web): ...
```

Esto es **normal**. Las ubicaciones se deben enviar directamente al servidor.

---

### 9️⃣ FORZAR UNA CAPTURA MANUAL (DEBUG)

Agrega temporalmente en `home_screen.dart` un botón para forzar captura:

```dart
ElevatedButton(
  onPressed: () async {
    final locationService = LocationTrackingService();
    await locationService.startTracking(
      userId: 'test123',
      userName: 'Test User',
    );
  },
  child: Text('Iniciar Seguimiento GPS'),
)
```

---

## 🎯 SOLUCIÓN MÁS PROBABLE

Basado en que las consultas retornan "Empty set", las causas más probables son:

### **A. La tabla NO existe en MySQL**
**Solución:** Ejecuta `verificar_location_tracking.sql` paso 2

### **B. El servicio de ubicación NO se ha iniciado**
**Solución:** Verifica que en `login_screen.dart` o tras login se llame a:
```dart
LocationTrackingService().startTracking(userId: ..., userName: ...);
```

### **C. Estás fuera del horario 8 AM - 6 PM**
**Solución:** Espera al horario laboral o cambia temporalmente `_startHour` y `_endHour` en `location_tracking_service.dart`

### **D. El backend NO está corriendo**
**Solución:** Inicia el backend con `mvnw spring-boot:run` o el JAR

---

## 📊 Verificación Final

Ejecuta estas consultas en orden:

```sql
-- 1. Ver si hay ALGÚN registro (cualquier fecha)
SELECT COUNT(*) FROM location_tracking;

-- 2. Ver últimos 10 registros (cualquier fecha)
SELECT * FROM location_tracking ORDER BY timestamp DESC LIMIT 10;

-- 3. Ver registros de la última hora
SELECT * FROM location_tracking 
WHERE timestamp >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
ORDER BY timestamp DESC;
```

Si **todas** retornan 0 o "Empty set", entonces:
- ✅ La tabla existe pero está vacía
- ❌ El servicio de ubicación NO se ha iniciado nunca
- ❌ O el backend no está guardando los datos

---

## 🔧 Archivo de Verificación Creado

He creado el archivo `verificar_location_tracking.sql` con:
- Verificación de existencia de tabla
- Creación de tabla si no existe
- Consultas de diagnóstico
- Registro de prueba para verificar funcionamiento

**Ejecuta:**
```bash
mysql -u root -p lytiks_data < C:/Users/WELLINGTON/Desktop/Lytiks/verificar_location_tracking.sql
```
