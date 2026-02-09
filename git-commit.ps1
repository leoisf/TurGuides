# Script para fazer commit das alterações

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GIT COMMIT - Tour Guides App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar status
Write-Host "1. Verificando status do repositório..." -ForegroundColor Yellow
git status --short
Write-Host ""

# Confirmar
Write-Host "Deseja continuar com o commit? (S/N)" -ForegroundColor Yellow
$resposta = Read-Host

if ($resposta -ne "S" -and $resposta -ne "s") {
    Write-Host "Commit cancelado." -ForegroundColor Red
    exit
}

# Adicionar arquivos
Write-Host ""
Write-Host "2. Adicionando arquivos..." -ForegroundColor Yellow
git add -A
Write-Host "Arquivos adicionados!" -ForegroundColor Green

# Mostrar diff resumido
Write-Host ""
Write-Host "3. Resumo das alterações:" -ForegroundColor Yellow
git diff --cached --stat
Write-Host ""

# Fazer commit
Write-Host "4. Fazendo commit..." -ForegroundColor Yellow
$commitMessage = @"
feat: refatoração completa para app exclusivo de turistas

BREAKING CHANGES:
- App agora é exclusivo para turistas (removido admin/guia)
- Nova tela de roteiros com mapa fixo e rotas reais
- Tema alterado para azul (#1976D2)

Features:
- Tela de roteiros com mapa fixo no topo
- Cálculo de rotas reais com Google Directions API
- 5 modos de transporte (A pé, Carro, Bicicleta, Moto, Transporte)
- Filtros em pontos turísticos
- Busca de guias disponíveis
- Localização em português (pt_BR)

Fixes:
- Correção na API de agendamentos
- Correção na busca de guias
- Mapeamento correto de campos

Chore:
- Limpeza de arquivos temporários
- Remoção de páginas não utilizadas
- Documentação atualizada
- Scripts de inicialização
"@

git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Commit realizado com sucesso!" -ForegroundColor Green
    Write-Host ""
    
    # Perguntar sobre push
    Write-Host "Deseja fazer push para o repositório remoto? (S/N)" -ForegroundColor Yellow
    $pushResposta = Read-Host
    
    if ($pushResposta -eq "S" -or $pushResposta -eq "s") {
        Write-Host ""
        Write-Host "5. Fazendo push..." -ForegroundColor Yellow
        git push
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ Push realizado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "✗ Erro ao fazer push." -ForegroundColor Red
        }
    } else {
        Write-Host ""
        Write-Host "Push cancelado. Execute 'git push' manualmente quando estiver pronto." -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "✗ Erro ao fazer commit." -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Processo finalizado" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
