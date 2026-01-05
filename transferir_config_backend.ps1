# Script para transferir archivos de configuracion de backend_new

$servidor = "5.161.198.89"
$usuario = "root"
$localBackend = "C:\Users\WELLINGTON\Desktop\Lytiks\Lytiks\backend_new"

Write-Host "Transfiriendo archivos de configuracion..." -ForegroundColor Cyan
Write-Host ""

# Transferir archivos principales
Write-Host "1. docker-compose.yml..." -ForegroundColor Yellow
scp "$localBackend\docker-compose.yml" "${usuario}@${servidor}:/root/backend_new/"

Write-Host "2. Dockerfile..." -ForegroundColor Yellow
scp "$localBackend\Dockerfile" "${usuario}@${servidor}:/root/backend_new/"

Write-Host "3. pom.xml..." -ForegroundColor Yellow
scp "$localBackend\pom.xml" "${usuario}@${servidor}:/root/backend_new/"

Write-Host ""
Write-Host "Archivos transferidos!" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora conectate al servidor y ejecuta:" -ForegroundColor Yellow
Write-Host "  ssh root@5.161.198.89" -ForegroundColor White
Write-Host "  cd backend_new" -ForegroundColor White
Write-Host "  docker compose build --no-cache" -ForegroundColor White
Write-Host "  docker compose up -d" -ForegroundColor White
