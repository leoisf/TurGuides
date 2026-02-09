#!/usr/bin/env pwsh
# Script completo para inicializar o TourGuides App
# Valida emulador, backend e inicia o projeto

param(
    [switch]$SkipBackendCheck,
    [switch]$ForceRestart
)

# Cores e símbolos
$ErrorColor = "Red"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$InfoColor = "Cyan"
$HeaderColor = "Magenta"

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host "  $Text" -ForegroundColor $HeaderColor
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
    Write-Host ""
}

function Write-Step {
    param([string]$Number, [string]$Text)
    Write-Host "$Number  $Text" -ForegroundColor $InfoColor
}

function Write-Success {
    param([string]$Text)
    Write-Host "✅ $Text" -ForegroundColor $SuccessColor
}

function Write-Error {
    param([string]$Text)
    Write-Host "❌ $Text" -ForegroundColor $ErrorColor
}

function Write-Warning {
    param([string]$Text)
    Write-Host "⚠️  $Text" -ForegroundColor $WarningColor
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ️  $Text" -ForegroundColor "Gray"
}

# Banner
Clear-Host
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor $HeaderColor
Write-Host "║                                                       ║" -ForegroundColor $HeaderColor
Write-Host "║           🧳 TOURGUIDES - APP DO TURISTA 🧳          ║" -ForegroundColor $HeaderColor
Write-Host "║                                                       ║" -ForegroundColor $HeaderColor
Write-Host "║              Script de Inicialização v1.0            ║" -ForegroundColor $HeaderColor
Write-Host "║                                                       ║" -ForegroundColor $HeaderColor
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor $HeaderColor
Write-Host ""

# ============================================================================
# PASSO 1: Verificar Flutter
# ============================================================================
Write-Header "1️⃣  VERIFICANDO FLUTTER"

try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    if ($flutterVersion) {
        Write-Success "Flutter instalado"
        Write-Info "   $flutterVersion"
    } else {
        throw "Flutter não encontrado"
    }
} catch {
    Write-Error "Flutter não está instalado ou não está no PATH"
    Write-Host ""
    Write-Host "💡 Instale o Flutter:" -ForegroundColor $WarningColor
    Write-Host "   https://docs.flutter.dev/get-started/install" -ForegroundColor White
    exit 1
}

# ============================================================================
# PASSO 2: Verificar Backend (opcional)
# ============================================================================
if (-not $SkipBackendCheck) {
    Write-Header "2️⃣  VERIFICANDO BACKEND"
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -Method GET -TimeoutSec 3 -ErrorAction Stop
        Write-Success "Backend está rodando (porta 3001)"
        Write-Info "   Status: $($response.StatusCode)"
    } catch {
        Write-Warning "Backend não está respondendo"
        Write-Host ""
        Write-Host "💡 Para iniciar o backend:" -ForegroundColor $WarningColor
        Write-Host "   cd C:\Users\leonardo.flores\Desktop\dev\nodejs+react\Tur\tur\backend" -ForegroundColor White
        Write-Host "   npm run dev" -ForegroundColor White
        Write-Host ""
        
        $continue = Read-Host "Deseja continuar sem o backend? (S/N)"
        if ($continue -ne "S" -and $continue -ne "s") {
            Write-Host "Abortado pelo usuário." -ForegroundColor $ErrorColor
            exit 1
        }
    }
} else {
    Write-Info "Verificação de backend ignorada (--SkipBackendCheck)"
}

# ============================================================================
# PASSO 3: Verificar Emuladores Disponíveis
# ============================================================================
Write-Header "3️⃣  VERIFICANDO EMULADORES DISPONÍVEIS"

$emulatorsList = flutter emulators 2>&1
$availableEmulators = @()

if ($emulatorsList -match "Medium_Phone") {
    $availableEmulators += "Medium_Phone"
    Write-Success "Emulador 'Medium_Phone' encontrado"
}
if ($emulatorsList -match "Medium_Phone_2") {
    $availableEmulators += "Medium_Phone_2"
    Write-Success "Emulador 'Medium_Phone_2' encontrado"
}

if ($availableEmulators.Count -eq 0) {
    Write-Error "Nenhum emulador encontrado"
    Write-Host ""
    Write-Host "💡 Crie um emulador:" -ForegroundColor $WarningColor
    Write-Host "   flutter emulators --create --name Medium_Phone" -ForegroundColor White
    Write-Host "   Ou use o Android Studio: Tools > Device Manager" -ForegroundColor White
    exit 1
}

$selectedEmulator = $availableEmulators[0]
Write-Info "   Emulador selecionado: $selectedEmulator"

# ============================================================================
# PASSO 4: Verificar se Emulador Está Rodando
# ============================================================================
Write-Header "4️⃣  VERIFICANDO STATUS DO EMULADOR"

$devices = flutter devices 2>&1
$emulatorRunning = $false
$emulatorId = ""

if ($devices -match "emulator-\d+") {
    $emulatorMatch = [regex]::Match($devices, "emulator-\d+")
    if ($emulatorMatch.Success) {
        $emulatorId = $emulatorMatch.Value
        $emulatorRunning = $true
        Write-Success "Emulador já está rodando: $emulatorId"
        
        # Verificar detalhes do emulador
        if ($devices -match "sdk gphone64 x86 64") {
            Write-Info "   Dispositivo: sdk gphone64 x86 64"
        }
        if ($devices -match "Android \d+ \(API \d+\)") {
            $androidVersion = [regex]::Match($devices, "Android \d+ \(API \d+\)").Value
            Write-Info "   Sistema: $androidVersion"
        }
    }
}

# ============================================================================
# PASSO 5: Iniciar Emulador (se necessário)
# ============================================================================
if (-not $emulatorRunning -or $ForceRestart) {
    Write-Header "5️⃣  INICIANDO EMULADOR"
    
    if ($ForceRestart -and $emulatorRunning) {
        Write-Warning "Forçando reinício do emulador..."
        Write-Info "   Fechando emulador atual..."
        adb -s $emulatorId emu kill 2>$null
        Start-Sleep -Seconds 3
    }
    
    Write-Info "   Iniciando $selectedEmulator..."
    flutter emulators --launch $selectedEmulator | Out-Null
    
    Write-Info "   Aguardando emulador inicializar..."
    $maxWait = 60
    $waited = 0
    $emulatorReady = $false
    
    while ($waited -lt $maxWait -and -not $emulatorReady) {
        Start-Sleep -Seconds 2
        $waited += 2
        
        $devices = flutter devices 2>&1
        if ($devices -match "emulator-\d+") {
            $emulatorMatch = [regex]::Match($devices, "emulator-\d+")
            if ($emulatorMatch.Success) {
                $emulatorId = $emulatorMatch.Value
                $emulatorReady = $true
                Write-Success "Emulador iniciado: $emulatorId"
                Write-Info "   Tempo de inicialização: $waited segundos"
            }
        } else {
            Write-Host "." -NoNewline -ForegroundColor Gray
        }
    }
    
    if (-not $emulatorReady) {
        Write-Error "Timeout ao iniciar emulador (${maxWait}s)"
        Write-Host ""
        Write-Host "💡 Tente iniciar manualmente:" -ForegroundColor $WarningColor
        Write-Host "   Android Studio > Device Manager > Play" -ForegroundColor White
        exit 1
    }
    
    # Aguardar boot completo
    Write-Info "   Aguardando boot completo do Android..."
    Start-Sleep -Seconds 5
    
} else {
    Write-Info "   Emulador já está pronto"
}

# ============================================================================
# PASSO 6: Configurar ADB Reverse
# ============================================================================
Write-Header "6️⃣  CONFIGURANDO CONEXÃO COM BACKEND"

try {
    $adbResult = adb reverse tcp:3001 tcp:3001 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "ADB reverse configurado (porta 3001)"
        Write-Info "   Emulador pode acessar localhost:3001"
    } else {
        Write-Warning "Não foi possível configurar ADB reverse"
        Write-Info "   O app pode não conseguir conectar ao backend"
    }
} catch {
    Write-Warning "Erro ao configurar ADB reverse: $_"
}

# Verificar portas configuradas
$reverseList = adb reverse --list 2>&1
if ($reverseList -match "tcp:3001") {
    Write-Info "   ✓ Porta 3001 mapeada"
}

# ============================================================================
# PASSO 7: Instalar Dependências
# ============================================================================
Write-Header "7️⃣  INSTALANDO DEPENDÊNCIAS"

Write-Info "   Executando flutter pub get..."
$pubGetOutput = flutter pub get 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Success "Dependências instaladas"
    
    # Contar pacotes
    $packagesCount = ($pubGetOutput | Select-String "packages").Count
    if ($packagesCount -gt 0) {
        Write-Info "   Pacotes verificados e atualizados"
    }
} else {
    Write-Error "Erro ao instalar dependências"
    Write-Host $pubGetOutput
    exit 1
}

# ============================================================================
# PASSO 8: Informações Finais
# ============================================================================
Write-Header "8️⃣  INICIANDO APLICATIVO"

Write-Host ""
Write-Host "📱 INFORMAÇÕES DO DISPOSITIVO:" -ForegroundColor $HeaderColor
Write-Host "   Emulador: $emulatorId" -ForegroundColor White
Write-Host "   Backend: http://localhost:3001" -ForegroundColor White
Write-Host "   ADB Reverse: Configurado" -ForegroundColor White
Write-Host ""

Write-Host "🎨 FUNCIONALIDADES DISPONÍVEIS:" -ForegroundColor $HeaderColor
Write-Host "   • Login e Autenticação" -ForegroundColor White
Write-Host "   • Buscar Guias (DatePicker em português)" -ForegroundColor White
Write-Host "   • Meus Agendamentos" -ForegroundColor White
Write-Host "   • Roteiros Turísticos (com mapa)" -ForegroundColor White
Write-Host "   • Pontos Turísticos" -ForegroundColor White
Write-Host "   • Perfil do Turista" -ForegroundColor White
Write-Host ""

Write-Host "💡 COMANDOS ÚTEIS NO FLUTTER:" -ForegroundColor $HeaderColor
Write-Host "   r  - Hot reload (recarregar mudanças)" -ForegroundColor White
Write-Host "   R  - Hot restart (reiniciar app)" -ForegroundColor White
Write-Host "   q  - Quit (sair do app)" -ForegroundColor White
Write-Host "   h  - Help (ajuda)" -ForegroundColor White
Write-Host ""

Write-Host "🚀 Executando: flutter run -d $emulatorId" -ForegroundColor $SuccessColor
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""

# ============================================================================
# PASSO 9: Executar App
# ============================================================================

# Verificação final: garantir que temos um emulador válido
if ([string]::IsNullOrEmpty($emulatorId)) {
    Write-Error "Nenhum emulador disponível para executar o app"
    Write-Host ""
    Write-Host "💡 Detectando dispositivos disponíveis..." -ForegroundColor $WarningColor
    
    $allDevices = flutter devices 2>&1
    Write-Host $allDevices
    
    # Tentar pegar qualquer dispositivo Android
    if ($allDevices -match "emulator-\d+") {
        $emulatorMatch = [regex]::Match($allDevices, "emulator-\d+")
        $emulatorId = $emulatorMatch.Value
        Write-Success "Dispositivo encontrado: $emulatorId"
    } else {
        Write-Host ""
        Write-Host "❌ Nenhum dispositivo Android encontrado" -ForegroundColor $ErrorColor
        Write-Host ""
        Write-Host "💡 Inicie um emulador manualmente:" -ForegroundColor $WarningColor
        Write-Host "   flutter emulators --launch $selectedEmulator" -ForegroundColor White
        Write-Host "   Ou use: Android Studio > Device Manager > Play" -ForegroundColor White
        exit 1
    }
}

Write-Host "🚀 Iniciando app no dispositivo: $emulatorId" -ForegroundColor $SuccessColor
Write-Host ""

flutter run -d $emulatorId

# ============================================================================
# Finalização
# ============================================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host "  App finalizado" -ForegroundColor $InfoColor
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $HeaderColor
Write-Host ""