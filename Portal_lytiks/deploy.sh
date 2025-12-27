#!/bin/bash

# Script de despliegue para Portal Lytiks

echo "🚀 Iniciando despliegue de Portal Lytiks..."

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker y Docker Compose instalados${NC}"

# Ir al directorio del backend donde está docker-compose.yml
cd ../Lytiks/backend_new || exit 1

echo -e "${YELLOW}📦 Construyendo imagen de Portal Web...${NC}"
docker-compose build portal-web

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al construir la imagen${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Imagen construida exitosamente${NC}"

echo -e "${YELLOW}🚀 Desplegando Portal Web...${NC}"
docker-compose up -d portal-web

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al desplegar el contenedor${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Portal Web desplegado exitosamente${NC}"

# Esperar a que el contenedor esté listo
echo -e "${YELLOW}⏳ Esperando a que el servicio esté listo...${NC}"
sleep 5

# Verificar estado
if docker ps | grep -q "lytiks-portal-web"; then
    echo -e "${GREEN}✅ Contenedor en ejecución${NC}"
    echo ""
    echo -e "${GREEN}🌐 Portal Web disponible en:${NC}"
    echo -e "${GREEN}   http://localhost:8082${NC}"
    echo -e "${GREEN}   http://5.161.198.89:8082${NC}"
    echo ""
    echo "📋 Comandos útiles:"
    echo "   Ver logs:      docker-compose logs -f portal-web"
    echo "   Reiniciar:     docker-compose restart portal-web"
    echo "   Detener:       docker-compose stop portal-web"
    echo "   Eliminar:      docker-compose down portal-web"
else
    echo -e "${RED}❌ El contenedor no está en ejecución${NC}"
    echo "Ver logs con: docker-compose logs portal-web"
    exit 1
fi
