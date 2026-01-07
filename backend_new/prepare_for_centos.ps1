# Script para preparar backend_new para CentOS
# Este script crea un archivo comprimido listo para transferir

Write-Host "🚀 Preparando Lytiks Backend para CentOS..." -ForegroundColor Green

# Crear directorio temporal
$tempDir = ".\deploy_package"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copiar archivos del proyecto
Write-Host "📁 Copiando archivos del proyecto..." -ForegroundColor Yellow
Copy-Item "src" -Destination "$tempDir\src" -Recurse
Copy-Item "pom.xml" -Destination "$tempDir\pom.xml"
Copy-Item "Dockerfile" -Destination "$tempDir\Dockerfile"
Copy-Item "docker-compose.yml" -Destination "$tempDir\docker-compose.yml"

# Crear archivo README para CentOS
$readmeContent = @"
# 🚀 LYTIKS BACKEND - DESPLIEGUE EN CENTOS

## 📋 PREREQUISITOS
- CentOS 7/8/9
- Conexión a Internet
- Usuario con permisos sudo

## 🔧 INSTALACIÓN AUTOMÁTICA
1. Ejecutar: chmod +x setup_centos.sh
2. Ejecutar: sudo ./setup_centos.sh
3. Ejecutar: ./deploy.sh

## 🎯 DESPUÉS DE LA INSTALACIÓN
- Backend: http://[IP_VM]:8081/api
- MySQL: puerto 3307
- Logs: docker-compose logs -f

## 📊 MONITOREO
- Ver logs: ./logs.sh
- Reiniciar: ./restart.sh
- Parar: ./stop.sh
"@

$readmeContent | Out-File -FilePath "$tempDir\README_CENTOS.md" -Encoding UTF8

Write-Host "✅ Archivos preparados en: $tempDir" -ForegroundColor Green
Write-Host "📦 Siguiente: Crear archivos de instalación..." -ForegroundColor Cyan