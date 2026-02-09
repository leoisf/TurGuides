#!/usr/bin/env pwsh
# Script para parar emulador e processos do Flutter

Write-Host "🛑 Parando TourGuides App e Emulador" -ForegroundColor Red
Write-Host "=====================================" -ForegroundColor Red
Write-Host ""

# Parar processos Flutter
Write-Host "1️⃣  Parando processos Flutter..." -ForegroundColor Yellow
$flutterProcesses = Get-Process -Name "flutter" -ErrorAction SilentlyContinue
if ($flutterProcesses) {
    $flutterProcesses | Stop-Process -Force
    Write-Host "✅ Processos Flutter parados" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Nenhum processo Flutter rodando" -ForegroundColor Gray
}

Write-Host ""

# Parar processos Dart
Write-Host "2️⃣  Parando processos Dart..." -ForegroundColor Yellow
$dartProcesses = Get-Process -Name "dart" -ErrorAction SilentlyContinue
if ($dartProcesses) {
    $dartProcesses | Stop-Process -Force
    Write-Host "✅ Processos Dart parados" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Nenhum processo Dart rodando" -ForegroundColor Gray
}

Write-Host ""

# Verificar emuladores rodando
Write-Host "3️⃣  Verificando emuladores..." -ForegroundColor Yellow
$devices = adb devices 2>&1
$emulators = @()

if ($devices -match "emulator-\d+") {
    $matches = [regex]::Matches($devices, "emulator-(\d+)")
    foreach ($match in $matches) {
        $emulators += $match.Value
    }
}

if ($emulators.Count -gt 0) {
    Write-Host "   Emuladores encontrados: $($emulators.Count)" -ForegroundColor Cyan
    
    foreach ($emulator in $emulators) {
        Write-Host "   Parando $emulator..." -ForegroundColor Yellow
        adb -s $emulator emu kill 2>$null
    }
    
    Start-Sleep -Seconds 2
    Write-Host "✅ Emuladores parados" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Nenhum emulador rodando" -ForegroundColor Gray
}

Write-Host ""

# Limpar ADB reverse
Write-Host "4️⃣  Limpando configurações ADB..." -ForegroundColor Yellow
adb reverse --remove-all 2>$null
Write-Host "✅ ADB reverse limpo" -ForegroundColor Green

Write-Host ""

# Matar servidor ADB (opcional)
$killAdb = Read-Host "Deseja parar o servidor ADB também? (S/N)"
if ($killAdb -eq "S" -or $killAdb -eq "s") {
    Write-Host "   Parando servidor ADB..." -ForegroundColor Yellow
    adb kill-server 2>$null
    Write-Host "✅ Servidor ADB parado" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Red
Write-Host "✅ Tudo parado!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Red
Write-Host ""