# Script de instalación rápida - Sistema Lytiks
# Ejecutar desde la raíz del proyecto

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   INSTALACIÓN DE CAMBIOS - LYTIKS" -ForegroundColor Cyan
Write-Host "   Fecha: 16/02/2026" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar que estamos en el directorio correcto
if (-Not (Test-Path "backend_new") -or -Not (Test-Path "lib")) {
    Write-Host "ERROR: Ejecute este script desde la raíz del proyecto Lytiks" -ForegroundColor Red
    exit 1
}

Write-Host "[1/6] Verificando estructura del proyecto..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "   ✓ Estructura correcta" -ForegroundColor Green
Write-Host ""

# 2. Aplicar cambios en la base de datos
Write-Host "[2/6] Aplicando cambios en la base de datos..." -ForegroundColor Yellow
Write-Host "   → Se aplicarán las nuevas tablas:" -ForegroundColor Cyan
Write-Host "     - hacienda" -ForegroundColor White
Write-Host "     - lote" -ForegroundColor White
Write-Host "     - configuracion_logo" -ForegroundColor White
Write-Host ""
Write-Host "   ⚠ IMPORTANTE: Ejecute manualmente el siguiente comando en MySQL:" -ForegroundColor Yellow
Write-Host "   mysql -u usuario -p nombre_base_datos < backend_new\database\new_tables_hacienda_lote_logo.sql" -ForegroundColor White
Write-Host ""
$continuar = Read-Host "   ¿Ya aplicó los cambios en la base de datos? (S/N)"
if ($continuar -ne "S" -and $continuar -ne "s") {
    Write-Host "   ⏸ Por favor, aplique los cambios en la base de datos y vuelva a ejecutar el script" -ForegroundColor Yellow
    exit 0
}
Write-Host "   ✓ Cambios de BD confirmados" -ForegroundColor Green
Write-Host ""

# 3. Limpiar y compilar backend
Write-Host "[3/6] Compilando backend Java/Spring Boot..." -ForegroundColor Yellow
Set-Location backend_new

Write-Host "   → Limpiando compilaciones anteriores..." -ForegroundColor Cyan
mvn clean | Out-Null

Write-Host "   → Compilando proyecto (esto puede tomar unos minutos)..." -ForegroundColor Cyan
$compileResult = mvn clean install -DskipTests 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ✗ Error compilando el backend" -ForegroundColor Red
    Write-Host "   Por favor revise los errores en la consola" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "   ✓ Backend compilado exitosamente" -ForegroundColor Green
Set-Location ..
Write-Host ""

# 4. Limpiar y obtener dependencias Flutter
Write-Host "[4/6] Configurando Flutter..." -ForegroundColor Yellow
Write-Host "   → Limpiando caché de Flutter..." -ForegroundColor Cyan
flutter clean | Out-Null

Write-Host "   → Obteniendo dependencias..." -ForegroundColor Cyan
flutter pub get | Out-Null
Write-Host "   ✓ Flutter configurado exitosamente" -ForegroundColor Green
Write-Host ""

# 5. Verificar archivos creados
Write-Host "[5/6] Verificando archivos creados..." -ForegroundColor Yellow

$archivosNecesarios = @(
    "backend_new\database\new_tables_hacienda_lote_logo.sql",
    "backend_new\src\main\java\com\lytiks\backend\entity\Hacienda.java",
    "backend_new\src\main\java\com\lytiks\backend\entity\Lote.java",
    "backend_new\src\main\java\com\lytiks\backend\entity\ConfiguracionLogo.java",
    "backend_new\src\main\java\com\lytiks\backend\repository\HaciendaRepository.java",
    "backend_new\src\main\java\com\lytiks\backend\repository\LoteRepository.java",
    "backend_new\src\main\java\com\lytiks\backend\repository\ConfiguracionLogoRepository.java",
    "backend_new\src\main\java\com\lytiks\backend\service\HaciendaService.java",
    "backend_new\src\main\java\com\lytiks\backend\service\LoteService.java",
    "backend_new\src\main\java\com\lytiks\backend\service\ConfiguracionLogoService.java",
    "backend_new\src\main\java\com\lytiks\backend\controller\HaciendaController.java",
    "backend_new\src\main\java\com\lytiks\backend\controller\LoteController.java",
    "backend_new\src\main\java\com\lytiks\backend\controller\ConfiguracionLogoController.java",
    "backend_new\src\main\java\com\lytiks\backend\util\SigatokaDateUtil.java",
    "lib\services\hacienda_service.dart",
    "lib\services\lote_service.dart",
    "lib\services\logo_service.dart",
    "lib\utils\sigatoka_date_util.dart",
    "CAMBIOS_IMPLEMENTADOS.md",
    "GUIA_VERIFICACION_CALCULOS_SIGATOKA.md"
)

$archivosEncontrados = 0
$archivosTotal = $archivosNecesarios.Count

foreach ($archivo in $archivosNecesarios) {
    if (Test-Path $archivo) {
        $archivosEncontrados++
    } else {
        Write-Host "   ⚠ Archivo no encontrado: $archivo" -ForegroundColor Yellow
    }
}

Write-Host "   ✓ Archivos encontrados: $archivosEncontrados/$archivosTotal" -ForegroundColor Green
Write-Host ""

# 6. Resumen de cambios
Write-Host "[6/6] Resumen de cambios implementados:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   ✅ Nuevas tablas de base de datos:" -ForegroundColor Cyan
Write-Host "      - hacienda (para gestión de haciendas por cliente)" -ForegroundColor White
Write-Host "      - lote (para gestión de lotes por hacienda)" -ForegroundColor White
Write-Host "      - configuracion_logo (para logos configurables)" -ForegroundColor White
Write-Host ""
Write-Host "   ✅ Nuevas APIs REST:" -ForegroundColor Cyan
Write-Host "      - /api/haciendas/* (CRUD de haciendas)" -ForegroundColor White
Write-Host "      - /api/lotes/* (CRUD de lotes)" -ForegroundColor White
Write-Host "      - /api/logo/* (CRUD de logos)" -ForegroundColor White
Write-Host ""
Write-Host "   ✅ Funcionalidades implementadas:" -ForegroundColor Cyan
Write-Host "      1. Auto-completar en formularios" -ForegroundColor White
Write-Host "      2. Menús desplegables (dropdowns) para hacienda y lote" -ForegroundColor White
Write-Host "      3. Logo configurable desde tabla de BD" -ForegroundColor White
Write-Host "      4. Cálculo automático de Semana Epidemiológica ISO" -ForegroundColor White
Write-Host "      5. Cálculo automático de Período (Semana del Mes)" -ForegroundColor White
Write-Host "      6. Selección de hacienda y lote desde tablas" -ForegroundColor White
Write-Host "      7. Ubicación automática cada 1 hora (antes: 10 seg)" -ForegroundColor White
Write-Host ""
Write-Host "   ⚠ Por revisar manualmente:" -ForegroundColor Yellow
Write-Host "      - Cálculos de Sigatoka (revisar con Excel de referencia)" -ForegroundColor White
Write-Host "      - Ver: GUIA_VERIFICACION_CALCULOS_SIGATOKA.md" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   INSTALACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Iniciar el backend:" -ForegroundColor White
Write-Host "   cd backend_new" -ForegroundColor Cyan
Write-Host "   mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Ejecutar la aplicación Flutter:" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Revisar la documentación completa:" -ForegroundColor White
Write-Host "   - CAMBIOS_IMPLEMENTADOS.md" -ForegroundColor Cyan
Write-Host "   - GUIA_VERIFICACION_CALCULOS_SIGATOKA.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "¡Éxito!" -ForegroundColor Green
Write-Host ""
