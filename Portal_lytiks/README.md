# Portal Lytiks - Web

Portal web de gestión integral para acuicultura desarrollado con Flutter Web.

## Características

- 🔐 Sistema de autenticación
- 📊 Dashboard de monitoreo en tiempo real
- 🌊 Gestión de granjas acuícolas
- 📱 Diseño responsive (desktop y móvil)
- 🔔 Sistema de alertas y notificaciones

## Instalación

1. Asegúrate de tener Flutter instalado:
```bash
flutter --version
```

2. Instala las dependencias:
```bash
cd portal_lytiks
flutter pub get
```

3. Ejecuta en modo desarrollo web:
```bash
flutter run -d chrome
```

4. Compila para producción:
```bash
flutter build web
```

## Estructura del proyecto

```
portal_lytiks/
├── lib/
│   ├── main.dart           # Punto de entrada
│   ├── screens/            # Pantallas de la aplicación
│   │   └── login_screen.dart
│   ├── services/           # Servicios (API, auth, etc.)
│   │   └── auth_service.dart
│   └── widgets/            # Componentes reutilizables
├── web/                    # Archivos web
├── assets/                 # Recursos (imágenes, fonts)
└── pubspec.yaml           # Dependencias
```

## Colores del tema

- Primary: `#E53E3E` (Rojo Lytiks)
- Secondary: `#2D3748` (Gris oscuro)
- Background: Gradiente `#2D3748` a `#1A202C`

## Configuración del backend

El portal se conecta al backend en:
```
http://5.161.198.89:8081
```

Para cambiar la URL, edita el archivo `lib/services/auth_service.dart`.

## Licencia

© 2025 Lytiks. Todos los derechos reservados.
