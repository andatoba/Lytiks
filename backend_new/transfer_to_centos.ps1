# 📡 TRANSFERENCIA DE LYTIKS BACKEND A CENTOS VIA SSH
# Ejecutar desde Windows PowerShell

Write-Host "🚀 Transferiendo Lytiks Backend a CentOS..." -ForegroundColor Green

# Variables
$REMOTE_USER = "angie"
$REMOTE_IP = "192.168.0.110"
$LOCAL_PATH = "C:\Users\User\Desktop\Lytiks\backend_new"
$REMOTE_PATH = "/home/angie/lytiks-backend"

Write-Host "📁 Transferencia iniciada..." -ForegroundColor Yellow
Write-Host "🎯 Destino: $REMOTE_USER@$REMOTE_IP:$REMOTE_PATH" -ForegroundColor Cyan

# Comando SCP para transferir toda la carpeta
Write-Host "💡 Ejecuta este comando en PowerShell:" -ForegroundColor Green
Write-Host "scp -r `"$LOCAL_PATH`" $REMOTE_USER@${REMOTE_IP}:$REMOTE_PATH" -ForegroundColor White

Write-Host "" 
Write-Host "🔐 Después de la transferencia, conectar por SSH:" -ForegroundColor Green
Write-Host "ssh $REMOTE_USER@$REMOTE_IP" -ForegroundColor White

Write-Host ""
Write-Host "⚡ Comandos para ejecutar en CentOS después de conectar:" -ForegroundColor Green
Write-Host "cd $REMOTE_PATH" -ForegroundColor White
Write-Host "ls -la" -ForegroundColor White