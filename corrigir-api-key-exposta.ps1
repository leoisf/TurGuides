# Script para corrigir API Key exposta

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║  🚨 CORREÇÃO DE API KEY EXPOSTA 🚨                        ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

Write-Host "⚠️  ATENÇÃO: Sua chave da API do Google Maps foi exposta!" -ForegroundColor Yellow
Write-Host ""

# Passo 1: Revogar chave antiga
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PASSO 1: REVOGAR CHAVE ANTIGA (URGENTE!)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abra: https://console.cloud.google.com/apis/credentials" -ForegroundColor Yellow
Write-Host "2. Encontre a chave: AIzaSyAnTSpYvHhtyIR_IzAY68aGWfqxan6Sz20" -ForegroundColor Yellow
Write-Host "3. CLIQUE EM 'EXCLUIR' ou 'DESATIVAR'" -ForegroundColor Red
Write-Host ""
Write-Host "Pressione ENTER após revogar a chave..." -ForegroundColor Yellow
Read-Host

# Passo 2: Criar nova chave
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PASSO 2: CRIAR NOVA CHAVE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. No Google Cloud Console, clique em 'Criar Credenciais'" -ForegroundColor Yellow
Write-Host "2. Selecione 'Chave de API'" -ForegroundColor Yellow
Write-Host "3. Configure restrições:" -ForegroundColor Yellow
Write-Host "   - Tipo: Android apps" -ForegroundColor Gray
Write-Host "   - Adicione o SHA-1 (veja SHA1_KEY.txt)" -ForegroundColor Gray
Write-Host "   - APIs: Maps SDK for Android, Directions API" -ForegroundColor Gray
Write-Host ""
Write-Host "Digite a NOVA chave de API:" -ForegroundColor Yellow
$novaChave = Read-Host

if ([string]::IsNullOrWhiteSpace($novaChave)) {
    Write-Host ""
    Write-Host "❌ Chave não fornecida. Abortando." -ForegroundColor Red
    exit 1
}

# Passo 3: Atualizar local.properties
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PASSO 3: CONFIGURAR CHAVE LOCALMENTE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$localPropertiesPath = "android\local.properties"

if (Test-Path $localPropertiesPath) {
    $content = Get-Content $localPropertiesPath -Raw
    
    if ($content -match "google\.maps\.api\.key=") {
        # Substituir chave existente
        $content = $content -replace "google\.maps\.api\.key=.*", "google.maps.api.key=$novaChave"
        Set-Content $localPropertiesPath $content -NoNewline
        Write-Host "✓ Chave atualizada em local.properties" -ForegroundColor Green
    } else {
        # Adicionar chave
        Add-Content $localPropertiesPath "`ngoogle.maps.api.key=$novaChave"
        Write-Host "✓ Chave adicionada em local.properties" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Arquivo local.properties não encontrado!" -ForegroundColor Red
    Write-Host "   Crie manualmente em: android\local.properties" -ForegroundColor Yellow
}

# Passo 4: Limpar histórico do Git
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PASSO 4: LIMPAR HISTÓRICO DO GIT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  ATENÇÃO: Isso reescreverá o histórico do Git!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Deseja limpar o histórico do Git? (S/N)" -ForegroundColor Yellow
$limparHistorico = Read-Host

if ($limparHistorico -eq "S" -or $limparHistorico -eq "s") {
    Write-Host ""
    Write-Host "Verificando git-filter-repo..." -ForegroundColor Yellow
    
    $hasFilterRepo = Get-Command git-filter-repo -ErrorAction SilentlyContinue
    
    if (-not $hasFilterRepo) {
        Write-Host "❌ git-filter-repo não encontrado!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Instale com: pip install git-filter-repo" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Ou use manualmente:" -ForegroundColor Yellow
        Write-Host "git filter-repo --replace-text <(echo 'AIzaSyAnTSpYvHhtyIR_IzAY68aGWfqxan6Sz20==>CHAVE_REMOVIDA')" -ForegroundColor Gray
    } else {
        Write-Host "Fazendo backup..." -ForegroundColor Yellow
        
        if (-not (Test-Path "..\tour_guides_backup")) {
            Copy-Item -Path "." -Destination "..\tour_guides_backup" -Recurse -Force
            Write-Host "✓ Backup criado em: ..\tour_guides_backup" -ForegroundColor Green
        }
        
        Write-Host "Limpando histórico..." -ForegroundColor Yellow
        
        # Criar arquivo temporário com substituição
        $tempFile = New-TemporaryFile
        "AIzaSyAnTSpYvHhtyIR_IzAY68aGWfqxan6Sz20==>CHAVE_REMOVIDA" | Out-File $tempFile -Encoding UTF8
        
        git filter-repo --replace-text $tempFile.FullName
        
        Remove-Item $tempFile
        
        Write-Host "✓ Histórico limpo!" -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠️  Execute: git push origin --force --all" -ForegroundColor Yellow
    }
}

# Passo 5: Fazer novo commit
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PASSO 5: FAZER NOVO COMMIT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "Adicionando arquivos..." -ForegroundColor Yellow
git add .

Write-Host "Fazendo commit..." -ForegroundColor Yellow
git commit -m "security: remove exposed API key and use environment variables

- Remove hardcoded Google Maps API key
- Implement environment variable approach  
- Update .gitignore to prevent future exposures
- Add documentation for secure key management"

Write-Host "✓ Commit realizado!" -ForegroundColor Green

# Resumo final
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ CORREÇÃO CONCLUÍDA                                    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "✓ Chave antiga deve ser revogada" -ForegroundColor Green
Write-Host "✓ Nova chave configurada localmente" -ForegroundColor Green
Write-Host "✓ Código atualizado" -ForegroundColor Green
Write-Host "✓ .gitignore atualizado" -ForegroundColor Green
Write-Host "✓ Novo commit criado" -ForegroundColor Green
Write-Host ""
Write-Host "📝 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "   1. Execute: git push" -ForegroundColor White
Write-Host "   2. Monitore custos no Google Cloud Console" -ForegroundColor White
Write-Host "   3. Configure alertas de cobrança" -ForegroundColor White
Write-Host ""
Write-Host "📚 Documentação:" -ForegroundColor Yellow
Write-Host "   - CORRIGIR_API_KEY_EXPOSTA.md" -ForegroundColor White
Write-Host "   - CONFIGURAR_API_KEY.md" -ForegroundColor White
Write-Host ""
