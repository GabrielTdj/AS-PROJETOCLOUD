# ========================================
# Script de Provisionamento Azure
# Galeria de Artes Online
# ========================================

Write-Host "🎨 Iniciando provisionamento da Galeria de Artes Online..." -ForegroundColor Cyan

# ========================================
# 1. VARIÁVEIS DE CONFIGURAÇÃO
# ========================================

$RESOURCE_GROUP = "rg-galeria-artes"
$LOCATION = "eastus"
$MYSQL_SERVER = "mysql-galeria-artes-$(Get-Random -Minimum 1000 -Maximum 9999)"
$MYSQL_USER = "adminarte"
$MYSQL_PASSWORD = "GaleriaArte@2025#Secure"
$MYSQL_DATABASE = "galeria_db"
$STORAGE_ACCOUNT = "stgaleria$(Get-Random -Minimum 10000 -Maximum 99999)"
$CONTAINER_NAME = "obras"
$FUNCTION_APP = "func-galeria-artes-$(Get-Random -Minimum 1000 -Maximum 9999)"
$STATIC_WEBAPP = "stapp-galeria-artes"
$APP_SERVICE_PLAN = "plan-galeria-artes"

Write-Host "📋 Configurações:" -ForegroundColor Yellow
Write-Host "  Resource Group: $RESOURCE_GROUP"
Write-Host "  Location: $LOCATION"
Write-Host "  MySQL Server: $MYSQL_SERVER"
Write-Host "  Storage Account: $STORAGE_ACCOUNT"
Write-Host "  Function App: $FUNCTION_APP"
Write-Host ""

# ========================================
# 2. CRIAR RESOURCE GROUP
# ========================================

Write-Host "📦 Criando Resource Group..." -ForegroundColor Green
az group create `
  --name $RESOURCE_GROUP `
  --location $LOCATION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Resource Group criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar Resource Group" -ForegroundColor Red
    exit 1
}

# ========================================
# 3. CRIAR AZURE DATABASE FOR MYSQL
# ========================================

Write-Host "`n🗄️ Criando Azure Database for MySQL Flexible Server..." -ForegroundColor Green
az mysql flexible-server create `
  --resource-group $RESOURCE_GROUP `
  --name $MYSQL_SERVER `
  --location $LOCATION `
  --admin-user $MYSQL_USER `
  --admin-password $MYSQL_PASSWORD `
  --sku-name Standard_B1ms `
  --tier Burstable `
  --storage-size 32 `
  --version 8.0.21 `
  --public-access 0.0.0.0-255.255.255.255

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ MySQL Server criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar MySQL Server" -ForegroundColor Red
    exit 1
}

# Criar banco de dados
Write-Host "📊 Criando banco de dados '$MYSQL_DATABASE'..." -ForegroundColor Green
az mysql flexible-server db create `
  --resource-group $RESOURCE_GROUP `
  --server-name $MYSQL_SERVER `
  --database-name $MYSQL_DATABASE

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Banco de dados criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar banco de dados" -ForegroundColor Red
    exit 1
}

# Configurar regra de firewall para Azure Services
Write-Host "🔓 Configurando firewall do MySQL..." -ForegroundColor Green
az mysql flexible-server firewall-rule create `
  --resource-group $RESOURCE_GROUP `
  --name $MYSQL_SERVER `
  --rule-name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

# ========================================
# 4. CRIAR STORAGE ACCOUNT E CONTAINER
# ========================================

Write-Host "`n💾 Criando Storage Account..." -ForegroundColor Green
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --sku Standard_LRS `
  --kind StorageV2 `
  --allow-blob-public-access true

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Storage Account criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar Storage Account" -ForegroundColor Red
    exit 1
}

# Obter chave do Storage Account
Write-Host "🔑 Obtendo chave do Storage Account..." -ForegroundColor Green
$STORAGE_KEY = az storage account keys list `
  --resource-group $RESOURCE_GROUP `
  --account-name $STORAGE_ACCOUNT `
  --query "[0].value" `
  --output tsv

# Criar container para as obras
Write-Host "📦 Criando container 'obras'..." -ForegroundColor Green
az storage container create `
  --name $CONTAINER_NAME `
  --account-name $STORAGE_ACCOUNT `
  --account-key $STORAGE_KEY `
  --public-access blob

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Container criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar container" -ForegroundColor Red
    exit 1
}

# ========================================
# 5. CRIAR APP SERVICE PLAN
# ========================================

Write-Host "`n📱 Criando App Service Plan..." -ForegroundColor Green
az appservice plan create `
  --name $APP_SERVICE_PLAN `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --sku B1 `
  --is-linux

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service Plan criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar App Service Plan" -ForegroundColor Red
    exit 1
}

# ========================================
# 6. CRIAR FUNCTION APP (PYTHON)
# ========================================

Write-Host "`n⚡ Criando Azure Function App..." -ForegroundColor Green
az functionapp create `
  --resource-group $RESOURCE_GROUP `
  --name $FUNCTION_APP `
  --storage-account $STORAGE_ACCOUNT `
  --plan $APP_SERVICE_PLAN `
  --runtime python `
  --runtime-version 3.9 `
  --functions-version 4 `
  --os-type Linux

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Function App criada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar Function App" -ForegroundColor Red
    exit 1
}

# Configurar variáveis de ambiente da Function
Write-Host "⚙️ Configurando variáveis de ambiente..." -ForegroundColor Green

$MYSQL_CONNECTION_STRING = "mysql+pymysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_SERVER}.mysql.database.azure.com:3306/${MYSQL_DATABASE}"
$STORAGE_CONNECTION_STRING = "DefaultEndpointsProtocol=https;AccountName=${STORAGE_ACCOUNT};AccountKey=${STORAGE_KEY};EndpointSuffix=core.windows.net"

az functionapp config appsettings set `
  --name $FUNCTION_APP `
  --resource-group $RESOURCE_GROUP `
  --settings `
    "MYSQL_CONNECTION_STRING=$MYSQL_CONNECTION_STRING" `
    "STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT" `
    "STORAGE_ACCOUNT_KEY=$STORAGE_KEY" `
    "STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING" `
    "CONTAINER_NAME=$CONTAINER_NAME"

# Habilitar CORS
Write-Host "🌐 Habilitando CORS..." -ForegroundColor Green
az functionapp cors add `
  --name $FUNCTION_APP `
  --resource-group $RESOURCE_GROUP `
  --allowed-origins "*"

# ========================================
# 7. CRIAR STATIC WEB APP (REACT)
# ========================================

Write-Host "`n🌟 Criando Azure Static Web App..." -ForegroundColor Green
Write-Host "⚠️ Nota: Static Web App requer repositório GitHub. Execute após criar o repositório:" -ForegroundColor Yellow
Write-Host ""
Write-Host "az staticwebapp create \" -ForegroundColor Cyan
Write-Host "  --name $STATIC_WEBAPP \" -ForegroundColor Cyan
Write-Host "  --resource-group $RESOURCE_GROUP \" -ForegroundColor Cyan
Write-Host "  --location $LOCATION \" -ForegroundColor Cyan
Write-Host "  --source https://github.com/SEU-USUARIO/galeria-artes \" -ForegroundColor Cyan
Write-Host "  --branch main \" -ForegroundColor Cyan
Write-Host "  --app-location '/frontend' \" -ForegroundColor Cyan
Write-Host "  --api-location '/backend' \" -ForegroundColor Cyan
Write-Host "  --output-location 'build' \" -ForegroundColor Cyan
Write-Host "  --token SEU_GITHUB_TOKEN" -ForegroundColor Cyan
Write-Host ""

# ========================================
# 8. SALVAR CONFIGURAÇÕES
# ========================================

Write-Host "`n💾 Salvando configurações..." -ForegroundColor Green

$configContent = @"
# ========================================
# CONFIGURAÇÕES DA GALERIA DE ARTES
# Gerado automaticamente em $(Get-Date)
# ========================================

# Resource Group
RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION

# MySQL Database
MYSQL_SERVER=$MYSQL_SERVER
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_CONNECTION_STRING=$MYSQL_CONNECTION_STRING

# Storage Account
STORAGE_ACCOUNT=$STORAGE_ACCOUNT
STORAGE_KEY=$STORAGE_KEY
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
CONTAINER_NAME=$CONTAINER_NAME

# Function App
FUNCTION_APP=$FUNCTION_APP
FUNCTION_URL=https://${FUNCTION_APP}.azurewebsites.net

# Static Web App
STATIC_WEBAPP=$STATIC_WEBAPP

# ========================================
# COMANDOS ÚTEIS
# ========================================

# Conectar ao MySQL:
# mysql -h $MYSQL_SERVER.mysql.database.azure.com -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# Upload de imagem para Blob:
# az storage blob upload --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY --container-name $CONTAINER_NAME --name obra1.jpg --file ./imagens/obra1.jpg

# Ver logs da Function:
# az functionapp log tail --name $FUNCTION_APP --resource-group $RESOURCE_GROUP

# Deletar todos os recursos:
# az group delete --name $RESOURCE_GROUP --yes --no-wait
"@

$configContent | Out-File -FilePath ".\azure-config.txt" -Encoding UTF8

Write-Host "✅ Configurações salvas em 'azure-config.txt'" -ForegroundColor Green

# ========================================
# 9. RESUMO FINAL
# ========================================

Write-Host "`n" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "🎉 PROVISIONAMENTO CONCLUÍDO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Recursos criados:" -ForegroundColor Cyan
Write-Host "  ✅ Resource Group: $RESOURCE_GROUP"
Write-Host "  ✅ MySQL Server: $MYSQL_SERVER"
Write-Host "  ✅ Storage Account: $STORAGE_ACCOUNT"
Write-Host "  ✅ Container Blob: $CONTAINER_NAME"
Write-Host "  ✅ Function App: $FUNCTION_APP"
Write-Host ""
Write-Host "🔗 URLs importantes:" -ForegroundColor Cyan
Write-Host "  Function API: https://${FUNCTION_APP}.azurewebsites.net/api/obras"
Write-Host "  Storage URL: https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/"
Write-Host ""
Write-Host "📝 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Execute o script SQL: scripts\02-setup-database.sql"
Write-Host "  2. Faça upload das imagens: scripts\03-upload-images.ps1"
Write-Host "  3. Deploy do backend: cd backend; func azure functionapp publish $FUNCTION_APP"
Write-Host "  4. Configure o GitHub e crie o Static Web App"
Write-Host ""
Write-Host "📄 Configurações salvas em: azure-config.txt" -ForegroundColor Green
Write-Host ""
