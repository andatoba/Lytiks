# Guía Rápida - Aplicación Lytiks

## 🚀 Tu aplicación está ejecutándose!

La aplicación Lytiks se está iniciando en Chrome. La primera ejecución puede tardar algunos minutos.

## ✨ Características implementadas:

### 🔐 Pantalla de Login
- **Usuario**: Cualquier texto (ej: "admin")
- **Contraseña**: Mínimo 6 caracteres (ej: "123456")
- Validación en tiempo real
- Diseño basado en el logo de Lytiks

### 🏠 Pantalla Principal (Dashboard)
Una vez que hagas login, verás:

#### 📊 Dashboard
- Estadísticas principales de las plantaciones
- Alertas en tiempo real
- Tarjetas con información resumida:
  - **Plantaciones**: 12 activas
  - **Alertas Activas**: 3 pendientes
  - **Áreas Monitoreadas**: 850 Ha
  - **Eficiencia**: 94%

#### 🐛 Monitoreo (En desarrollo)
- Control de plagas
- Sensores IoT
- Mapas de calor

#### 📈 Reportes (En desarrollo)
- Análisis de datos
- Gráficos interactivos
- Exportación de reportes

#### ⚙️ Configuración (En desarrollo)
- Ajustes de usuario
- Configuración de notificaciones
- Gestión de plantaciones

## 🎨 Paleta de Colores

La aplicación usa los colores de tu logo:
- **Principal**: #1B5E5F (Teal oscuro)
- **Secundario**: Tonos de teal
- **Fondos**: Grises claros
- **Acentos**: Verde, naranja, rojo para estados

## 📱 Cómo probar la aplicación:

1. **Espera a que termine de cargar** (se abrirá automáticamente en Chrome)
2. **Pantalla de Login**:
   - Usuario: `admin`
   - Contraseña: `123456`
3. **Explora el Dashboard**: Revisa las estadísticas y alertas
4. **Navega por las tabs**: Dashboard, Monitoreo, Reportes, Config

## 🛠️ Para futuras sesiones:

Para usar Flutter más fácilmente en el futuro, ejecuta:
```powershell
.\setup_flutter.ps1
```

Esto agregará Flutter a tu PATH temporalmente.

## 🔄 Durante el desarrollo:

Mientras la app está ejecutándose, puedes:
- **Hot Reload**: Presiona `r` en la terminal para recargar cambios
- **Hot Restart**: Presiona `R` para reiniciar completamente
- **Quit**: Presiona `q` para salir

## 📝 Próximos pasos sugeridos:

1. **Backend**: Conectar con APIs reales
2. **Base de datos**: Implementar SQLite local
3. **Autenticación**: Sistema de login real
4. **Sensores IoT**: Integración con dispositivos
5. **Mapas**: Geolocalización de plantaciones
6. **Notificaciones**: Push notifications

---

¡Tu aplicación Lytiks está lista para el desarrollo! 🌱