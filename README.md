# Lytiks - Sistema de Auditorías Agrícolas

Una aplicación Flutter completa para el manejo y control de auditorías en plantaciones de banano y palma, con sistema de monitoreo de plagas Moko y Sigatoka.

## 🚀 Características Principales

### 📋 Sistema de Auditorías Completo
- **Auditorías de Cultivo**: Sistema completo con 10 secciones de evaluación (Enfunde, Selección, Cosecha, etc.)
- **Auditorías Moko**: Control especializado de la plaga Moko del banano
- **Auditorías Sigatoka**: Monitoreo y control de Sigatoka Negra
- **Búsqueda de Clientes**: Sistema de búsqueda por cédula integrado en todas las auditorías

### 💾 Almacenamiento Offline
- **Base de Datos Local**: SQLite para almacenamiento persistente sin conexión
- **Sincronización Automática**: Los datos se sincronizan automáticamente cuando hay conexión
- **Offline-First**: La aplicación funciona completamente sin internet
- **Gestión de Pendientes**: Sistema de cola para datos pendientes de sincronización

### 👥 Gestión de Clientes
- **Registro de Clientes**: Información completa con geolocalización
- **Búsqueda Avanzada**: Por cédula, nombre, y otros criterios
- **Perfiles Detallados**: Información de fincas, cultivos y técnicos asignados

### 🔄 Sincronización Inteligente
- **Verificación de Conectividad**: Detecta conexión real con el servidor
- **Sincronización Selectiva**: Solo sincroniza datos pendientes
- **Manejo de Errores**: Reintentos automáticos y manejo de fallos
- **Limpieza Automática**: Elimina datos ya sincronizados

### 🎨 Diseño Moderno
- **Interfaz Intuitiva**: Diseño card-based con gradientes
- **Tema Personalizado**: Basado en la identidad visual de Lytiks
- **Responsivo**: Adaptable a diferentes tamaños de pantalla
- **Feedback Visual**: Indicadores de progreso y estados

## 🏗️ Arquitectura del Sistema

### Frontend (Flutter)
```
lib/
├── main.dart                           # Punto de entrada
├── screens/                           # Pantallas principales
│   ├── home_screen.dart              # Dashboard principal
│   ├── login_screen.dart             # Autenticación
│   ├── audit_screen.dart             # Auditorías de cultivo
│   ├── moko_audit_screen.dart        # Auditorías Moko
│   ├── sigatoka_audit_screen.dart    # Auditorías Sigatoka
│   ├── client_info_screen.dart       # Gestión de clientes
│   ├── profile_screen.dart           # Perfil de usuario
│   └── audit_consultation_screen.dart # Consulta de auditorías
├── services/                         # Lógica de negocio
│   ├── offline_storage_service.dart  # Almacenamiento local
│   ├── sync_service.dart             # Sincronización
│   ├── audit_service.dart            # Servicios de auditoría
│   ├── client_service.dart           # Servicios de cliente
│   ├── auth_service.dart             # Autenticación
│   ├── moko_audit_service.dart       # Servicios Moko
│   └── sigatoka_audit_service.dart   # Servicios Sigatoka
└── utils/
    └── lytiks_utils.dart             # Utilidades generales
```

### Backend (Spring Boot)
```
backend_new/
├── src/main/java/
│   └── com/lytiks/backend/
│       ├── controller/               # Controladores REST
│       ├── service/                  # Lógica de negocio
│       ├── model/                    # Modelos de datos
│       └── repository/               # Acceso a datos
├── docker-compose.yml               # Configuración Docker
├── Dockerfile                       # Imagen del contenedor
└── pom.xml                         # Dependencias Maven
```

## 📊 Base de Datos Offline

### Tablas Principales
- **`pending_audits`**: Auditorías de cultivo pendientes de sincronización
- **`pending_moko_audits`**: Auditorías Moko pendientes
- **`pending_sigatoka_audits`**: Auditorías Sigatoka pendientes
- **`pending_clients`**: Nuevos clientes pendientes de sincronización
- **`pending_audit_photos`**: Fotos de auditorías pendientes

### Campos Clave
- `is_synced`: Indica si el registro ya fue sincronizado
- `created_at`: Timestamp de creación
- `cedula_cliente`: Identificación del cliente asociado
- `audit_data`: Datos serializados de la auditoría

## 🛠️ Configuración e Instalación

### Requisitos Previos
- **Flutter SDK** (≥ 3.0.0)
- **Dart SDK** (≥ 2.18.0)
- **Android Studio** o **VS Code**
- **Git**
- **Java 17** (para el backend)
- **Docker** (opcional, para el backend)

### Instalación del Frontend

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/andatoba/Lytiks.git
   cd Lytiks
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configurar la aplicación:**
   ```bash
   flutter doctor
   ```

4. **Ejecutar en modo desarrollo:**
   ```bash
   flutter run
   ```

### Instalación del Backend

1. **Navegar al directorio del backend:**
   ```bash
   cd backend_new
   ```

2. **Ejecutar con Docker:**
   ```bash
   docker-compose up -d
   ```

3. **O ejecutar manualmente:**
   ```bash
   ./mvnw spring-boot:run
   ```

## 📱 Pantallas Implementadas

### 🏠 Dashboard Principal
- **Estadísticas en Tiempo Real**: Contadores de auditorías y clientes
- **Accesos Rápidos**: Navegación directa a funciones principales
- **Estado de Sincronización**: Indicador de elementos pendientes
- **Notificaciones**: Alertas y recordatorios importantes

### 🔐 Autenticación
- **Login Seguro**: Autenticación con token JWT
- **Gestión de Sesión**: Almacenamiento seguro de credenciales
- **Recuperación de Contraseña**: Sistema de reset integrado

### 📋 Auditorías de Cultivo
- **10 Secciones Especializadas**: 
  - Enfunde, Selección, Cosecha
  - Deshoje Fitosanitario y Normal
  - Desvío de Hijos, Apuntalamiento
  - Manejo de Aguas (Riego y Drenaje)
- **Modo Básico/Completo**: Flexibilidad según necesidades
- **Calificación por Puntos**: Sistema de scoring detallado
- **Observaciones**: Notas y comentarios por elemento

### 🦠 Auditorías Moko
- **Programa de Manejo**: Control de maleza, riego, entrada única
- **Evaluación de Estado**: Presencia de maleza y cumplimiento
- **Fotodocumentación**: Captura de evidencia visual
- **Seguimiento de Áreas**: Monitoreo específico de zonas afectadas

### 🍃 Auditorías Sigatoka
- **Análisis de Stover**: Evaluación de material vegetal
- **Parámetros Básicos**: Mediciones estándar
- **Recomendaciones**: Sugerencias de manejo
- **Estado General**: Evaluación integral del cultivo

### 👤 Gestión de Clientes
- **Registro Completo**: Datos personales y de finca
- **Geolocalización**: Coordenadas GPS de ubicación
- **Búsqueda Avanzada**: Por múltiples criterios
- **Historial**: Auditorías asociadas por cliente

## 🔄 Sistema de Sincronización

### Estrategia Offline-First
1. **Guardado Local**: Todos los datos se guardan primero en SQLite
2. **Verificación de Red**: Se verifica conectividad real con el servidor
3. **Sincronización Automática**: Los datos se suben cuando hay conexión
4. **Marcado de Estado**: Los registros se marcan como sincronizados
5. **Limpieza Automática**: Se eliminan datos ya sincronizados

### Manejo de Conflictos
- **Timestamps**: Control de versiones por fecha
- **Reintentos**: Sistema de reintento automático
- **Logs Detallados**: Seguimiento de errores y éxitos
- **Feedback Visual**: Notificaciones del estado de sincronización

## ⚙️ Configuración del Servidor

### Variables de Entorno
```env
# Servidor de desarrollo
SERVER_HOST=5.161.198.89
SERVER_PORT=8081
API_BASE_PATH=/api

# Base de datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=lytiks_db
DB_USER=admin
DB_PASSWORD=password
```

### Endpoints Principales
- **Auth**: `/api/auth/login`, `/api/auth/refresh`
- **Clientes**: `/api/clients`, `/api/clients/search`
- **Auditorías**: `/api/audits`, `/api/audits/create`
- **Moko**: `/api/moko`, `/api/moko/create`
- **Sigatoka**: `/api/sigatoka`, `/api/sigatoka/create`

## 🧪 Testing y Calidad

### Comandos de Testing
```bash
# Análisis de código
flutter analyze

# Ejecutar tests
flutter test

# Coverage report
flutter test --coverage

# Build para producción
flutter build apk --release
```

### Validaciones Implementadas
- **Validación de Formularios**: Campos obligatorios y formato
- **Verificación de Red**: Conectividad real con el servidor
- **Integridad de Datos**: Validación antes del guardado
- **Manejo de Errores**: Try-catch comprehensivo

## 📈 Métricas y Rendimiento

### Optimizaciones
- **Lazy Loading**: Carga bajo demanda de datos
- **Caché Inteligente**: Almacenamiento temporal de consultas
- **Compresión de Imágenes**: Optimización automática
- **Paginación**: Carga incremental de listas grandes

### Monitoreo
- **Logs Estructurados**: Sistema de logging comprehensivo
- **Métricas de Uso**: Tracking de funcionalidades
- **Performance**: Monitoreo de tiempos de respuesta

## 🚀 Roadmap y Futuras Funcionalidades

### Próximas Versiones
- [ ] **Dashboard Avanzado**: Gráficos y analytics en tiempo real
- [ ] **Reportes PDF**: Generación automática de reportes
- [ ] **Notificaciones Push**: Alertas en tiempo real
- [ ] **Mapas Interactivos**: Visualización geográfica de fincas
- [ ] **Machine Learning**: Predicciones y recomendaciones IA
- [ ] **Integración IoT**: Sensores automáticos de campo

### Mejoras Técnicas
- [ ] **Tests Automatizados**: Cobertura completa de testing
- [ ] **CI/CD Pipeline**: Integración y despliegue continuo
- [ ] **Microservicios**: Arquitectura escalable
- [ ] **API GraphQL**: Consultas más eficientes
- [ ] **PWA Version**: Aplicación web progresiva

## 📄 Documentación Adicional

- [GUIA_AUTENTICACION.md](GUIA_AUTENTICACION.md) - Guía de autenticación
- [GUIA_RAPIDA.md](GUIA_RAPIDA.md) - Guía rápida de uso
- [CAMBIOS_REALIZADOS.md](CAMBIOS_REALIZADOS.md) - Log de cambios
- [NUEVOS_CAMBIOS.md](NUEVOS_CAMBIOS.md) - Últimas actualizaciones

## 🤝 Contribución

### Workflow de Desarrollo
1. **Fork** del repositorio
2. **Crear rama** feature (`git checkout -b feature/nueva-funcionalidad`)
3. **Commit** cambios (`git commit -m 'feat: agrega nueva funcionalidad'`)
4. **Push** a la rama (`git push origin feature/nueva-funcionalidad`)
5. **Crear Pull Request**

### Estándares de Código
- **Dart Style Guide**: Seguir convenciones oficiales
- **Comentarios**: Documentar funciones complejas
- **Testing**: Incluir tests para nuevas funcionalidades
- **Commits Semánticos**: Usar conventional commits

## 📞 Soporte y Contacto

**Lytiks Data Solutions**
- 📧 Email: info@lytiks.com
- 🌐 Website: www.lytiks.com
- 📱 Soporte Técnico: soporte@lytiks.com

### Issues y Bugs
Para reportar problemas:
1. Buscar en [Issues existentes](https://github.com/andatoba/Lytiks/issues)
2. Crear nuevo issue con template
3. Incluir logs y pasos para reproducir
4. Agregar labels apropiados

## 📜 Licencia

Este proyecto está licenciado bajo la **MIT License**. Ver [LICENSE](LICENSE) para más detalles.

---

<div align="center">

**🌱 Tecnología para el Agro Sostenible 🌱**

*Desarrollado con ❤️ por el equipo de Lytiks*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=spring&logoColor=white)](https://spring.io/projects/spring-boot)
[![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)

</div>
