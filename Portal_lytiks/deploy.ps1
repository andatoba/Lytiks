# Script de despliegue para Portal Lytiks (Windows PowerShell)

Write-Host "🚀 Iniciando despliegue de Portal Lytiks..." -ForegroundColor Green

# Verificar Docker
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker no está instalado" -ForegroundColor Red
    exit 1
}

if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker Compose no está instalado" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker y Docker Compose instalados" -ForegroundColor Green

# Ir al directorio del backend donde está docker-compose.yml
Set-Location ..\Lytiks\backend_new

Write-Host "📦 Construyendo imagen de Portal Web..." -ForegroundColor Yellow
docker-compose build portal-web

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir la imagen" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Imagen construida exitosamente" -ForegroundColor Green

Write-Host "🚀 Desplegando Portal Web..." -ForegroundColor Yellow
docker-compose up -d portal-web

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al desplegar el contenedor" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Portal Web desplegado exitosamente" -ForegroundColor Green

# Esperar a que el contenedor esté listo
Write-Host "⏳ Esperando a que el servicio esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar estado
$containerRunning = docker ps | Select-String "lytiks-portal-web"

if ($containerRunning) {
    Write-Host "✅ Contenedor en ejecución" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Portal Web disponible en:" -ForegroundColor Green
    Write-Host "   http://localhost:8082" -ForegroundColor Green
    Write-Host "   http://5.161.198.89:8082" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Comandos útiles:"
    Write-Host "   Ver logs:      docker-compose logs -f portal-web"
    Write-Host "   Reiniciar:     docker-compose restart portal-web"
    Write-Host "   Detener:       docker-compose stop portal-web"
    Write-Host "   Eliminar:      docker-compose down portal-web"
} else {
    Write-Host "❌ El contenedor no está en ejecución" -ForegroundColor Red
    Write-Host "Ver logs con: docker-compose logs portal-web"
    exit 1
}
