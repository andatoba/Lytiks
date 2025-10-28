# Guía de Configuración y Pruebas - Lytiks

## 📋 Configuración Inicial

### 1. Dependencias
Ejecuta este comando para instalar las nuevas dependencias:
```
flutter pub get
```

### 2. Configurar la URL del servidor
En el archivo `lib/services/auth_service.dart`, modifica la línea 8:
```dart
final String baseUrl = 'http://TU_IP_AQUI:8080/api';
```

Reemplaza `TU_IP_AQUI` con:
- `localhost` si estás usando un emulador de Android
- `10.0.2.2` si estás usando el emulador de Android Studio
- La IP real de tu máquina si estás usando un dispositivo físico

## 🧪 Cómo Probar la Aplicación

### Paso 1: Verificar el servidor Spring Boot
1. Asegúrate de que el servidor Spring Boot esté ejecutándose
2. Verifica que puedas acceder a: `http://localhost:8080/api/auth/login`

### Paso 2: Probar la autenticación con curl
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Paso 3: Ejecutar la aplicación Flutter
```
flutter run
```

## 👤 Usuarios de Prueba

Si has configurado los datos iniciales en Spring Boot, deberías tener:

**Usuario Administrador:**
- Usuario: `admin`
- Contraseña: `admin123`
- Rol: ADMIN

**Usuario Técnico (si lo creaste):**
- Usuario: `tecnico`
- Contraseña: `tecnico123`
- Rol: TECHNICIAN

## 📱 Funcionalidades Implementadas

### ✅ Pantalla de Splash
- Muestra el logo de Lytiks
- Verifica automáticamente si el usuario ya está autenticado
- Redirige al Home si está logueado, o al Login si no lo está

### ✅ Pantalla de Login
- Validación real contra la base de datos
- Muestra errores específicos (usuario incorrecto, sin conexión, etc.)
- Indicador de carga durante la autenticación
- Almacena el token de forma segura

### ✅ Pantalla de Perfil
- Muestra información del usuario autenticado
- Indica claramente si es Admin o Técnico
- Permite cerrar sesión con confirmación
- Diseño moderno y responsive

### ✅ Navegación Mejorada
- Nueva pestaña "Perfil" en el menú inferior
- Persistencia de sesión (no necesitas loguearte cada vez)
- Cierre de sesión seguro

## 🔧 Resolución de Problemas Comunes

### Error de Conexión
Si ves el mensaje "No se puede conectar al servidor":
1. Verifica que el servidor Spring Boot esté funcionando
2. Comprueba que la URL en `auth_service.dart` sea correcta
3. Asegúrate de que no haya firewall bloqueando el puerto 8080

### Error "Usuario o contraseña incorrectos"
1. Verifica que existan usuarios en la base de datos
2. Comprueba que las contraseñas estén encriptadas correctamente en la BD
3. Revisa los logs del servidor Spring Boot

### Error al ejecutar Flutter
Si hay errores de compilación:
1. Ejecuta `flutter clean`
2. Luego `flutter pub get`
3. Finalmente `flutter run`

## 📊 Base de Datos - Verificación

Para verificar que tienes datos en la base de datos:

```sql
-- Conectar a MySQL
mysql -u root -p

-- Usar la base de datos
USE Agro_ISO;

-- Verificar roles
SELECT * FROM is_role;

-- Verificar usuarios
SELECT id, username, first_name, last_name, email, active, role_id FROM is_user;

-- Verificar que las contraseñas estén encriptadas
SELECT username, password FROM is_user;
```

## 🎯 Próximos Pasos

Una vez que todo funcione correctamente, puedes:
1. Crear más usuarios de prueba
2. Implementar funcionalidades específicas para cada rol
3. Conectar las auditorías con la base de datos
4. Añadir validaciones adicionales de seguridad

## ⚠️ Notas Importantes

1. **Seguridad**: En producción, cambia las contraseñas por defecto
2. **URL**: En producción, usa HTTPS y una URL segura
3. **Tokens**: Los tokens JWT tienen un tiempo de vida limitado
4. **Conexión**: Asegúrate de manejar casos sin conexión a internet

## 📞 Soporte

Si encuentras algún problema:
1. Revisa los logs de Flutter: `flutter logs`
2. Revisa los logs de Spring Boot en la consola
3. Verifica la conectividad de red
4. Comprueba que todas las dependencias estén instaladas