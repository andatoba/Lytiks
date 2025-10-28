# Lytiks - Control de Plagas de Banano

Una aplicación Flutter para el control inteligente de plagas en plantaciones de banano.

## Características

- 🌱 Dashboard principal con estadísticas en tiempo real
- 🐛 Sistema de monitoreo de plagas
- 📊 Reportes y análisis detallados
- ⚙️ Panel de configuración
- 🔐 Sistema de autenticación seguro
- 🎨 Diseño moderno basado en la identidad visual de Lytiks

## Colores de la Aplicación

La aplicación utiliza una paleta de colores basada en el logo de Lytiks:
- **Color principal**: #1B5E5F (Teal oscuro)
- **Color secundario**: Tonos de teal y verde azulado
- **Fondo**: Grises claros (#F5F5F5)
- **Acentos**: Blancos y grises

## Requisitos Previos

Antes de ejecutar la aplicación, asegúrate de tener instalado:

1. **Flutter SDK**: [Descargar desde flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Dart SDK**: (Incluido con Flutter)
3. **Android Studio** o **Visual Studio Code** con extensiones de Flutter
4. **Git**: Para control de versiones

## Instalación de Flutter

### Windows

1. Descarga Flutter SDK desde: https://flutter.dev/docs/get-started/install/windows
2. Extrae el archivo ZIP en una ubicación como `C:\flutter`
3. Agrega `C:\flutter\bin` a tu PATH:
   - Abre "Variables de entorno del sistema"
   - Edita la variable PATH
   - Agrega `C:\flutter\bin`
4. Abre una nueva terminal y verifica: `flutter doctor`

## Configuración del Proyecto

1. **Clonar o navegar al proyecto:**
   ```bash
   cd lytiks_app
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Verificar configuración:**
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
└── screens/
    ├── login_screen.dart     # Pantalla de inicio de sesión
    └── home_screen.dart      # Pantalla principal con tabs

assets/
└── images/
    ├── logo1.png            # Logo principal (fondo teal)
    └── logo2.png            # Logo alternativo (fondo blanco)
```

## Pantallas Implementadas

### 1. Pantalla de Login (`login_screen.dart`)
- Formulario de autenticación con validación
- Integración del logo de Lytiks
- Diseño responsivo y moderno
- Campos para usuario y contraseña
- Opción "¿Olvidaste tu contraseña?"

### 2. Pantalla Principal (`home_screen.dart`)
- **Dashboard**: Estadísticas principales, alertas recientes
- **Monitoreo**: Control de plagas (en desarrollo)
- **Reportes**: Análisis y reportes (en desarrollo)
- **Configuración**: Ajustes de la aplicación (en desarrollo)

## Características del Diseño

### Paleta de Colores
- **Primario**: `Color(0xFF1B5E5F)` - Teal oscuro del logo
- **Secundarios**: Tonos derivados del teal
- **Fondos**: Grises claros para mejor legibilidad
- **Acentos**: Blancos y colores de estado (verde, naranja, rojo)

### Componentes UI
- Botones con bordes redondeados
- Cards con sombras sutiles
- Formularios con validación visual
- Iconografía consistente con Material Design
- Tipografía clara y legible

### Responsive Design
- Adaptable a diferentes tamaños de pantalla
- Layouts flexibles con `SingleChildScrollView`
- Componentes que se ajustan automáticamente

## Funcionalidades Implementadas

### ✅ Completadas
- [x] Pantalla de login con validación
- [x] Navegación por tabs
- [x] Dashboard con estadísticas simuladas
- [x] Sistema de alertas visuales
- [x] Integración de logos
- [x] Tema personalizado

### 🚧 En Desarrollo
- [ ] Autenticación real con backend
- [ ] Integración con sensores IoT
- [ ] Sistema de notificaciones push
- [ ] Mapas interactivos de plantaciones
- [ ] Análisis de datos en tiempo real
- [ ] Reportes PDF exportables

## Comandos Útiles

```bash
# Obtener dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Generar APK
flutter build apk

# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Limpiar proyecto
flutter clean
```

## Próximos Pasos

1. **Integración Backend**: Conectar con APIs para datos reales
2. **Autenticación**: Implementar sistema de login real
3. **Sensores IoT**: Integrar datos de sensores de campo
4. **Geolocalización**: Mapas de plantaciones
5. **Notificaciones**: Sistema de alertas push
6. **Base de datos**: Almacenamiento local con SQLite

## Contribución

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto está licenciado bajo [MIT License](LICENSE).

## Contacto

**Lytiks Data Solutions**
- Email: info@lytiks.com
- Website: www.lytiks.com

---

*Tecnología para el agro sostenible* 🌱
