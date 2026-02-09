#!/usr/bin/env pwsh
# Script rápido para iniciar o TourGuides App

Write-Host "🚀 TourGuides - Início Rápido" -ForegroundColor Cyan
Write-Host ""

# Verificar se emulador está rodando
$devices = flutter devices 2>&1
if ($devices -match "emulator-(\d+)") {
    $emulatorId = $matches[0]
    Write-Host "✅ Emulador detectado: $emulatorId" -ForegroundColor Green
    
    # Configurar ADB
    adb reverse tcp:3001 tcp:3001 2>$null
    Write-Host "✅ ADB reverse configurado" -ForegroundColor Green
    
    # Rodar app
    Write-Host "🚀 Iniciando app..." -ForegroundColor Cyan
    Write-Host ""
    flutter run -d $emulatorId
} else {
    Write-Host "❌ Nenhum emulador rodando" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Use o script completo:" -ForegroundColor Yellow
    Write-Host "   .\start-tourguides.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Ou inicie o emulador manualmente e tente novamente." -ForegroundColor Yellow
}