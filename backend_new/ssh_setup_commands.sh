#!/bin/bash
# 🚀 CONFIGURACIÓN COMPLETA DE LYTIKS BACKEND EN CENTOS
# Ejecutar estos comandos uno por uno en SSH

echo "🚀 Configurando Lytiks Backend en CentOS..."

# 1. Verificar que la carpeta se transfirió correctamente
echo "📁 Verificando archivos transferidos..."
cd /home/angie/backend_new
ls -la

# 2. Actualizar sistema
echo "🔄 Actualizando sistema..."
sudo yum update -y

# 3. Instalar Docker
echo "🐳 Instalando Docker..."
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Iniciar y habilitar Docker
echo "▶️ Iniciando Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# 5. Agregar usuario al grupo docker
echo "👤 Configurando permisos de usuario..."
sudo usermod -aG docker angie
echo "⚠️ IMPORTANTE: Necesitas desloguearte y volver a conectar por SSH para que los permisos tomen efecto"

# 6. Instalar Docker Compose (versión standalone)
echo "🔧 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 7. Verificar instalación
echo "✅ Verificando instalaciones..."
docker --version
docker-compose --version

echo "🎉 Instalación completada!"
echo "🔄 Ahora desconéctate (exit) y vuelve a conectar por SSH"