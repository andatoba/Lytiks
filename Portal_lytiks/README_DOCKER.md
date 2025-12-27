# Portal Lytiks - Docker Configuration

Este proyecto está configurado para desplegarse como una aplicación web usando Docker y Nginx.

## Construcción Local

```bash
# Construir la imagen
docker build -t portal-lytiks:latest .

# Ejecutar localmente
docker run -d -p 8080:80 --name portal-lytiks portal-lytiks:latest

# Acceder en: http://localhost:8080
```

## Despliegue con Docker Compose

```bash
# Desde la raíz del proyecto (donde está docker-compose.yml)
docker-compose up -d portal-lytiks

# Ver logs
docker-compose logs -f portal-lytiks

# Detener
docker-compose down
```

## Estructura del Contenedor

- **Etapa 1 (Build)**: Usa Ubuntu con Flutter SDK para compilar la aplicación web
- **Etapa 2 (Runtime)**: Usa Nginx Alpine para servir los archivos estáticos
- **Puerto**: 80 (interno), mapeado a 8082 en docker-compose

## Configuración de Producción

La aplicación está configurada para conectarse al backend en `http://5.161.198.89:8081`

## Actualizar Despliegue

```bash
# Reconstruir y redesplegar
docker-compose build portal-lytiks
docker-compose up -d portal-lytiks
```
