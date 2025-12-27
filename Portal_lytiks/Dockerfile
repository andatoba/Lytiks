# Etapa 1: Build de la aplicación Flutter Web
FROM ubuntu:22.04 AS build

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Descargar e instalar Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Cambiar a una versión estable de Flutter
RUN flutter channel stable && \
    flutter upgrade && \
    flutter config --enable-web

# Verificar instalación
RUN flutter doctor -v

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración
COPY pubspec.yaml pubspec.lock ./

# Descargar dependencias
RUN flutter pub get

# Copiar el resto del código
COPY . .

# Construir la aplicación web
RUN flutter build web --release --web-renderer html

# Etapa 2: Servidor Nginx para servir la aplicación
FROM nginx:alpine

# Copiar archivos construidos desde la etapa de build
COPY --from=build /app/build/web /usr/share/nginx/html

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Instalar gettext para envsubst (sustitución de variables)
RUN apk add --no-cache gettext

# Script para configurar la URL del backend dinámicamente
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'BACKEND_URL=${BACKEND_URL:-http://5.161.198.89:8081}' >> /docker-entrypoint.sh && \
    echo 'echo "Configurando Backend URL: $BACKEND_URL"' >> /docker-entrypoint.sh && \
    echo 'find /usr/share/nginx/html -type f -name "*.js" -exec sed -i "s|http://5.161.198.89:8081|$BACKEND_URL|g" {} +' >> /docker-entrypoint.sh && \
    echo 'nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Exponer puerto 80
EXPOSE 80

# Comando por defecto
CMD ["/docker-entrypoint.sh"]
