# Linha de Comando para Execução Rápida

## 🚀 Execute Tudo de Uma Vez

Para quem quer executar o provisionamento completo de forma sequencial:

```powershell
# Salve este conteúdo como: run-all.ps1

Write-Host "🎨 Galeria de Artes - Deploy Completo Automatizado" -ForegroundColor Cyan
Write-Host ""

# Verificar pré-requisitos
Write-Host "✅ Verificando pré-requisitos..." -ForegroundColor Green

# Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI não encontrado. Instale: https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}

# Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python não encontrado. Instale: https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}

# Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js não encontrado. Instale: https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git não encontrado. Instale: https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Todos pré-requisitos OK!" -ForegroundColor Green
Write-Host ""

# Login Azure
Write-Host "🔐 Fazendo login no Azure..." -ForegroundColor Cyan
az login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro no login do Azure" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "ETAPA 1/5: PROVISIONAMENTO AZURE" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

.\scripts\01-provision-azure.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro no provisionamento" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⏸️  PAUSA: Configure o banco de dados manualmente" -ForegroundColor Yellow
Write-Host ""
Write-Host "Execute os comandos:" -ForegroundColor Cyan
Write-Host "1. Conecte ao MySQL:" -ForegroundColor White
Write-Host "   mysql -h MYSQL_SERVER.mysql.database.azure.com -u adminarte -p galeria_db < .\scripts\02-setup-database.sql" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Execute o script de upload de imagens:" -ForegroundColor White
Write-Host "   .\scripts\03-upload-images.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Atualize as URLs das imagens:" -ForegroundColor White
Write-Host "   mysql -h MYSQL_SERVER.mysql.database.azure.com -u adminarte -p galeria_db < .\update-urls.sql" -ForegroundColor Gray
Write-Host ""
Write-Host "Pressione qualquer tecla quando terminar..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "ETAPA 2/5: UPLOAD DE IMAGENS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

.\scripts\03-upload-images.ps1

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "ETAPA 3/5: DEPLOY BACKEND" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

Write-Host "📝 Você precisa configurar as variáveis de ambiente da Function App" -ForegroundColor Yellow
Write-Host "Depois executar: func azure functionapp publish SEU_FUNCTION_APP" -ForegroundColor Cyan
Write-Host ""

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "ETAPA 4/5: DEPLOY FRONTEND" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

Write-Host "📝 Configure o GitHub e crie o Static Web App" -ForegroundColor Yellow
Write-Host "Siga as instruções em DEPLOY_GUIDE.md - Parte 5" -ForegroundColor Cyan
Write-Host ""

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "ETAPA 5/5: TESTES" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

Write-Host "Deseja executar os testes agora? (S/N)" -ForegroundColor Yellow
$resposta = Read-Host

if ($resposta -eq "S" -or $resposta -eq "s") {
    $functionUrl = Read-Host "Digite a URL da sua Function App"
    .\scripts\04-test-application.ps1 -FunctionAppUrl $functionUrl
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "🎉 PROCESSO CONCLUÍDO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos passos manuais:" -ForegroundColor Yellow
Write-Host "1. Configurar GitHub Actions secrets" -ForegroundColor White
Write-Host "2. Fazer push para GitHub" -ForegroundColor White
Write-Host "3. Verificar deploys automáticos" -ForegroundColor White
Write-Host ""
Write-Host "📚 Consulte DEPLOY_GUIDE.md para mais detalhes" -ForegroundColor Cyan
Write-Host ""
