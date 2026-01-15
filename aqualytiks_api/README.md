# Aqualytiks API - FastAPI

API REST de solo consulta para la base de datos Aqualytiks.

## 🚀 Características

- ✅ API REST con FastAPI
- ✅ Solo endpoints GET (consultas)
- ✅ Documentación automática con Swagger UI
- ✅ Paginación en todas las consultas
- ✅ Filtros por fecha, empresa, etc.
- ✅ Dockerizado
- ✅ CORS configurado

## 📊 Tablas Disponibles

- **cubo** (299,094 registros) - Datos principales
- **destinos** (431 registros) - Catálogo de destinos
- **empresas** (214 registros) - Catálogo de empresas
- **dt** (14,867 registros) - Tipos de documento
- **puertos** (4 registros) - Catálogo de puertos
- **totales_mes** (381 registros) - Resúmenes mensuales
- **users** (4 registros) - Usuarios del sistema

## 🔧 Instalación y Uso

### Opción 1: Docker (Recomendado)

```bash
# Construir la imagen
docker build -t aqualytiks-api .

# Ejecutar conectándose a la red de Lytiks
docker run -d \
  --name aqualytiks-api \
  --network lytiks-network \
  -p 8083:8080 \
  -e DB_HOST=lytiks-new-mysql \
  -e DB_PASSWORD='cla@ISdb$26' \
  aqualytiks-api

# O usar docker-compose (más simple)
docker-compose up -d
```

### Opción 2: Local (sin Docker)

```bash
# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno en .env
# Ver archivo .env de ejemplo

# Ejecutar
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```

## 📡 Endpoints Disponibles

### Documentación Interactiva
- **Swagger UI**: http://localhost:8083/docs
- **ReDoc**: http://localhost:8083/redoc

### Endpoints Principales

#### Cubo
- `GET /cubo/` - Listar todos los registros (con paginación)
- `GET /cubo/{id}` - Obtener por ID
- `GET /cubo/empresa/{empresa_id}` - Por empresa
- Parámetros: `skip`, `limit`, `fecha_inicio`, `fecha_fin`, `empresa_id`

#### Destinos
- `GET /destinos/` - Listar destinos
- `GET /destinos/{id}` - Obtener por ID
- `GET /destinos/buscar/nombre?q=texto` - Buscar por nombre

#### Empresas
- `GET /empresas/` - Listar empresas
- `GET /empresas/{id}` - Obtener por ID
- `GET /empresas/buscar/nombre?q=texto` - Buscar por nombre
- `GET /empresas/buscar/ruc/{ruc}` - Buscar por RUC

#### Totales por Mes
- `GET /totales/` - Listar totales
- `GET /totales/empresa/{empresa_id}/anio/{anio}` - Totales de empresa por año
- Parámetros: `anio`, `mes`, `empresa_id`

## 🌐 Acceso en el Servidor

Una vez desplegado en el servidor, accede mediante:

```
http://IP_DEL_SERVIDOR:8083/docs
```

Reemplaza `IP_DEL_SERVIDOR` con la IP real de tu servidor.

## 🔒 Seguridad

- Solo métodos GET permitidos
- Usuario de BD puede ser configurado como READ-ONLY
- CORS configurado (ajustar en producción)
- Variables sensibles en archivo .env

## 📝 Ejemplos de Uso

### Consultar registros del cubo con filtros
```bash
curl "http://localhost:8083/cubo/?skip=0&limit=10&empresa_id=1&fecha_inicio=2024-01-01&fecha_fin=2024-12-31"
```

### Buscar empresas
```bash
curl "http://localhost:8083/empresas/buscar/nombre?q=acuicola"
```

### Obtener totales de una empresa
```bash
curl "http://localhost:8083/totales/empresa/1/anio/2024"
```

## 🛠️ Estructura del Proyecto

```
aqualytiks_api/
├── app/
│   ├── __init__.py
│   ├── main.py              # Aplicación principal
│   ├── database.py          # Configuración de BD
│   ├── models/
│   │   ├── __init__.py
│   │   └── models.py        # Modelos SQLAlchemy
│   └── routes/
│       ├── __init__.py
│       ├── cubo.py          # Endpoints de cubo
│       ├── destinos.py      # Endpoints de destinos
│       ├── empresas.py      # Endpoints de empresas
│       └── totales.py       # Endpoints de totales
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .env
└── README.md
```

## 🔄 Actualizar y Reiniciar

```bash
# Detener contenedor
docker stop aqualytiks-api

# Actualizar código
git pull  # o copiar archivos actualizados

# Reconstruir y ejecutar
docker-compose up -d --build
```

## 📞 Soporte

Para agregar más endpoints o modificar la API, edita los archivos en `app/routes/`.

Todos los endpoints están documentados automáticamente en `/docs`.
