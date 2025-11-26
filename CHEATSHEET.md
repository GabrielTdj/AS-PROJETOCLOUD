# ⚡ Comandos Rápidos - Cheat Sheet

Referência rápida dos comandos mais usados no projeto.

---

## 🚀 Setup Inicial

```powershell
# Login Azure
az login

# Listar assinaturas
az account list --output table

# Definir assinatura
az account set --subscription "NOME_OU_ID"

# Verificar assinatura ativa
az account show
```

---

## 📦 Provisionamento

```powershell
# Provisionar todos recursos (15-20 min)
.\scripts\01-provision-azure.ps1

# Listar recursos criados
az resource list --resource-group rg-galeria-artes --output table

# Ver detalhes do Resource Group
az group show --name rg-galeria-artes
```

---

## 🗄️ MySQL

```powershell
# Conectar ao banco
mysql -h MYSQL_SERVER.mysql.database.azure.com -u adminarte -p galeria_db

# Executar script SQL
mysql -h MYSQL_SERVER.mysql.database.azure.com -u adminarte -p galeria_db < .\scripts\02-setup-database.sql

# Query rápida
mysql -h MYSQL_SERVER.mysql.database.azure.com -u adminarte -p -e "USE galeria_db; SELECT COUNT(*) FROM obras;"

# Listar firewall rules
az mysql flexible-server firewall-rule list --resource-group rg-galeria-artes --name MYSQL_SERVER

# Adicionar IP ao firewall
az mysql flexible-server firewall-rule create `
  --resource-group rg-galeria-artes `
  --name MYSQL_SERVER `
  --rule-name MeuIP `
  --start-ip-address SEU_IP `
  --end-ip-address SEU_IP
```

---

## 💾 Blob Storage

```powershell
# Upload de imagens
.\scripts\03-upload-images.ps1

# Listar blobs
az storage blob list --container-name obras --account-name STORAGE_ACCOUNT --output table

# Upload manual
az storage blob upload `
  --account-name STORAGE_ACCOUNT `
  --container-name obras `
  --name imagem.jpg `
  --file ./caminho/imagem.jpg

# Configurar acesso público
az storage container set-permission `
  --name obras `
  --public-access blob `
  --account-name STORAGE_ACCOUNT

# Obter URL de um blob
az storage blob url --container-name obras --name monalisa.jpg --account-name STORAGE_ACCOUNT
```

---

## ⚡ Azure Function

```powershell
# Ver configurações
az functionapp config appsettings list --name FUNCTION_APP --resource-group rg-galeria-artes

# Configurar variável de ambiente
az functionapp config appsettings set `
  --name FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --settings "CHAVE=VALOR"

# Deploy local
cd backend
func azure functionapp publish FUNCTION_APP

# Deploy com build remoto
func azure functionapp publish FUNCTION_APP --build remote

# Logs em tempo real
az functionapp log tail --name FUNCTION_APP --resource-group rg-galeria-artes

# Download de logs
az functionapp log download --name FUNCTION_APP --resource-group rg-galeria-artes

# Reiniciar Function
az functionapp restart --name FUNCTION_APP --resource-group rg-galeria-artes

# Ver status
az functionapp show --name FUNCTION_APP --resource-group rg-galeria-artes --query "state"

# Configurar CORS
az functionapp cors add --name FUNCTION_APP --resource-group rg-galeria-artes --allowed-origins "*"

# Obter publish profile
az functionapp deployment list-publishing-profiles `
  --name FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --xml
```

---

## 🌐 Static Web App

```powershell
# Criar Static Web App
az staticwebapp create `
  --name stapp-galeria-artes `
  --resource-group rg-galeria-artes `
  --location eastus2 `
  --source https://github.com/USUARIO/REPO `
  --branch main `
  --app-location "/frontend" `
  --output-location "build" `
  --token GITHUB_TOKEN

# Obter API token
az staticwebapp secrets list `
  --name stapp-galeria-artes `
  --resource-group rg-galeria-artes

# Ver detalhes
az staticwebapp show --name stapp-galeria-artes --resource-group rg-galeria-artes

# Listar ambientes
az staticwebapp environment list --name stapp-galeria-artes --resource-group rg-galeria-artes
```

---

## 🐍 Backend Local

```powershell
cd backend

# Criar ambiente virtual
python -m venv .venv

# Ativar ambiente
.\.venv\Scripts\Activate.ps1

# Instalar dependências
pip install -r requirements.txt

# Iniciar Function localmente
func start

# Testar endpoint local
curl http://localhost:7071/api/health
curl http://localhost:7071/api/obras
```

---

## ⚛️ Frontend Local

```powershell
cd frontend

# Instalar dependências
npm install

# Modo desenvolvimento
npm start

# Build para produção
npm run build

# Testar build
npm install -g serve
serve -s build
```

---

## 🧪 Testes

```powershell
# Suite completa de testes
.\scripts\04-test-application.ps1 -FunctionAppUrl "https://FUNCTION_APP.azurewebsites.net"

# Testes manuais - Backend
curl https://FUNCTION_APP.azurewebsites.net/api/health
curl https://FUNCTION_APP.azurewebsites.net/api/obras
curl https://FUNCTION_APP.azurewebsites.net/api/obras/1
curl https://FUNCTION_APP.azurewebsites.net/api/obras/artista/Picasso

# Teste - Frontend
curl https://STATIC_WEB_APP.azurestaticapps.net

# Teste - Blob Storage
curl https://STORAGE_ACCOUNT.blob.core.windows.net/obras/monalisa.jpg
```

---

## 🔄 GitHub Actions

```powershell
# Ver workflows
gh workflow list

# Executar workflow manualmente
gh workflow run backend-deploy.yml
gh workflow run frontend-deploy.yml

# Ver status do último run
gh run list --limit 5

# Ver logs de um run
gh run view RUN_ID --log
```

---

## 📊 Monitoramento

```powershell
# Métricas da Function
az monitor metrics list `
  --resource /subscriptions/SUB_ID/resourceGroups/rg-galeria-artes/providers/Microsoft.Web/sites/FUNCTION_APP `
  --metric FunctionExecutionCount

# Application Insights (se habilitado)
az monitor app-insights component show --app FUNCTION_APP --resource-group rg-galeria-artes

# Logs do MySQL
az mysql flexible-server server-logs list --resource-group rg-galeria-artes --server-name MYSQL_SERVER
```

---

## 🧹 Limpeza

```powershell
# Deletar Resource Group completo (⚠️ CUIDADO!)
az group delete --name rg-galeria-artes --yes --no-wait

# Verificar deleção
az group exists --name rg-galeria-artes

# Deletar recursos individuais
az functionapp delete --name FUNCTION_APP --resource-group rg-galeria-artes
az staticwebapp delete --name STATIC_WEB_APP --resource-group rg-galeria-artes
az mysql flexible-server delete --resource-group rg-galeria-artes --name MYSQL_SERVER --yes
az storage account delete --name STORAGE_ACCOUNT --resource-group rg-galeria-artes --yes
```

---

## 🔍 Diagnóstico

```powershell
# Verificar versões instaladas
az --version
python --version
node --version
func --version
git --version

# Verificar login Azure
az account show

# Testar conectividade
Test-NetConnection MYSQL_SERVER.mysql.database.azure.com -Port 3306

# Ver quotas da assinatura
az vm list-usage --location eastus --output table
```

---

## 📝 Git

```powershell
# Inicializar repositório
git init

# Adicionar arquivos
git add .

# Commit
git commit -m "Mensagem do commit"

# Adicionar remote
git remote add origin https://github.com/USUARIO/REPO.git

# Push
git push -u origin main

# Ver status
git status

# Ver histórico
git log --oneline

# Criar branch
git checkout -b feature/nova-feature

# Merge
git checkout main
git merge feature/nova-feature
```

---

## 🔐 Secrets do GitHub

```powershell
# Obter Function publish profile
az functionapp deployment list-publishing-profiles `
  --name FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --xml

# Obter Static Web App token
az staticwebapp secrets list `
  --name stapp-galeria-artes `
  --resource-group rg-galeria-artes `
  --query "properties.apiKey" `
  --output tsv

# Configurar no GitHub:
# Settings → Secrets and variables → Actions → New repository secret
```

---

## 🆘 Troubleshooting Rápido

```powershell
# Function não responde
az functionapp restart --name FUNCTION_APP --resource-group rg-galeria-artes

# Ver logs de erro
az functionapp log tail --name FUNCTION_APP --resource-group rg-galeria-artes

# Verificar conexão MySQL
mysql -h MYSQL_SERVER.mysql.database.azure.com -u adminarte -p -e "SELECT 1"

# Testar CORS
curl -H "Origin: http://localhost:3000" -I https://FUNCTION_APP.azurewebsites.net/api/obras

# Verificar se blob é público
az storage container show-permission --name obras --account-name STORAGE_ACCOUNT

# Reconfigurar variáveis de ambiente
az functionapp config appsettings set --name FUNCTION_APP --resource-group rg-galeria-artes --settings @appsettings.json
```

---

## 🎯 URLs Importantes

```powershell
# Backend API
https://FUNCTION_APP.azurewebsites.net/api/obras
https://FUNCTION_APP.azurewebsites.net/api/health

# Frontend
https://STATIC_WEB_APP.azurestaticapps.net

# Blob Storage
https://STORAGE_ACCOUNT.blob.core.windows.net/obras/

# Portal Azure
https://portal.azure.com

# GitHub Actions
https://github.com/USUARIO/REPO/actions
```

---

## 💡 Dicas Úteis

```powershell
# Salvar output em variável
$FUNCTION_APP = "func-galeria-artes-1234"

# Criar alias para comandos longos
Set-Alias -Name func-logs -Value "az functionapp log tail --name $FUNCTION_APP --resource-group rg-galeria-artes"

# Usar arquivo de configuração
$config = Get-Content .\azure-config.txt | ConvertFrom-StringData
$MYSQL_SERVER = $config['MYSQL_SERVER']

# Exportar dados do MySQL para CSV
mysql -h MYSQL_SERVER.mysql.database.azure.com -u adminarte -p `
  -e "USE galeria_db; SELECT * FROM obras;" `
  | ConvertFrom-Csv -Delimiter "`t" | Export-Csv obras.csv

# Pretty print JSON
curl https://FUNCTION_APP.azurewebsites.net/api/obras | ConvertFrom-Json | ConvertTo-Json
```

---

## 📚 Referências Rápidas

- Azure CLI: `az --help`
- Functions Core Tools: `func --help`
- MySQL Client: `mysql --help`
- Git: `git --help`

---

**💾 Salve este arquivo como referência rápida!**
