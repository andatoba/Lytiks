# Script para configurar Flutter en el PATH temporal
# Ejecuta este script antes de usar Flutter en nuevas sesiones de PowerShell

# Ruta donde está instalado Flutter
$flutterPath = "C:\flutter_windows_3.35.4-stable\flutter\bin"

# Agregar Flutter al PATH de la sesión actual
$env:PATH = "$flutterPath;$env:PATH"

Write-Host "Flutter agregado al PATH de esta sesión." -ForegroundColor Green
Write-Host "Ahora puedes usar 'flutter' directamente." -ForegroundColor Green
Write-Host ""
Write-Host "Comandos útiles para Lytiks:" -ForegroundColor Cyan
Write-Host "  flutter run -d chrome    # Ejecutar en Chrome" -ForegroundColor Yellow
Write-Host "  flutter run -d windows   # Ejecutar como app de Windows" -ForegroundColor Yellow
Write-Host "  flutter hot-reload       # Recarga rápida durante desarrollo" -ForegroundColor Yellow
Write-Host "  flutter doctor           # Verificar configuración" -ForegroundColor Yellow
Write-Host ""

# Verificar que Flutter funciona
flutter doctor -v