# 🚀 COMECE AQUI - Deploy na Nuvem Azure

## ⚠️ SITUAÇÃO ATUAL

**Status:** Arquivos criados localmente ✅  
**Azure:** Nada provisionado ainda ❌  
**GitHub:** Código não está no repositório ainda ❌

---

## 🎯 Próximos Passos (Ordem Exata)

### **PASSO 1: Verificar Pré-Requisitos** ⏱️ 2 min

Abra PowerShell como **Administrador** e execute:

```powershell
# Navegar até o projeto
cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD

# Verificar se Azure CLI está instalado
az --version

# Se NÃO estiver instalado, instale:
# winget install Microsoft.AzureCLI
```

### **PASSO 2: Login no Azure** ⏱️ 1 min

```powershell
# Fazer login
az login

# Listar subscriptions disponíveis
az account list --output table

# Definir subscription ativa (se tiver múltiplas)
az account set --subscription "NOME_DA_SUA_SUBSCRIPTION"
```

### **PASSO 3: Provisionar Recursos Azure** ⏱️ 15-20 min

```powershell
# Executar script de provisionamento
cd scripts
.\01-provision-azure.ps1
```

**O que este script faz:**
- ✅ Cria Resource Group
- ✅ Cria MySQL Flexible Server
- ✅ Cria Storage Account + Container "obras"
- ✅ Cria Azure Function App
- ✅ Cria App Service Plan
- ✅ Configura firewall rules
- ✅ Gera arquivo com todas as informações

**⚠️ IMPORTANTE:** Ao final, o script exibirá informações como:
- Nome do MySQL Server
- Senha do MySQL
- Nome do Storage Account
- Nome da Function App

**ANOTE TUDO!** Você vai precisar depois.

### **PASSO 4: Configurar Banco de Dados** ⏱️ 5 min

```powershell
# Trocar pelos valores reais (que apareceram no passo anterior)
$MYSQL_SERVER = "galeria-artes-mysql-XXXXX"
$MYSQL_PASSWORD = "SENHA_GERADA"

# Executar script SQL
mysql -h $MYSQL_SERVER.mysql.database.azure.com -u adminarte -p$MYSQL_PASSWORD galeria_db < .\02-setup-database.sql

# Verificar se funcionou
mysql -h $MYSQL_SERVER.mysql.database.azure.com -u adminarte -p$MYSQL_PASSWORD galeria_db -e "SELECT COUNT(*) FROM obras;"
# Deve retornar: 12
```

**Se der erro de conexão:**
```powershell
# Adicionar seu IP ao firewall
$MyIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
az mysql flexible-server firewall-rule create `
  --resource-group galeria-artes-rg `
  --name $MYSQL_SERVER `
  --rule-name AllowMyIP `
  --start-ip-address $MyIP `
  --end-ip-address $MyIP
```

### **PASSO 5: Upload das Imagens** ⏱️ 5-10 min

```powershell
# Executar script de upload
.\03-upload-images.ps1
```

**O que faz:**
- Baixa 12 imagens de obras famosas
- Envia para Azure Blob Storage
- Configura acesso público

**Verificar:**
```powershell
# Trocar pelo nome do seu Storage Account
$STORAGE_NAME = "galeriastorageXXXXX"

az storage blob list `
  --account-name $STORAGE_NAME `
  --container-name obras `
  --output table

# Deve mostrar 12 arquivos .jpg
```

### **PASSO 6: Deploy do Backend** ⏱️ 5 min

```powershell
# Voltar para raiz do projeto
cd ..

# Entrar na pasta backend
cd backend

# Instalar Azure Functions Core Tools (se não tiver)
# npm install -g azure-functions-core-tools@4

# Trocar pelo nome da sua Function App
$FUNCTION_APP_NAME = "galeria-artes-func-XXXXX"

# Fazer deploy
func azure functionapp publish $FUNCTION_APP_NAME

# Testar
curl "https://$FUNCTION_APP_NAME.azurewebsites.net/api/health"
curl "https://$FUNCTION_APP_NAME.azurewebsites.net/api/obras"
```

**Se der erro 500:** Ver logs
```powershell
az functionapp log tail --name $FUNCTION_APP_NAME --resource-group galeria-artes-rg
```

### **PASSO 7: Deploy do Frontend** ⏱️ 10 min

```powershell
# Voltar para raiz
cd ..

# Entrar no frontend
cd frontend

# Instalar dependências (primeira vez)
npm install

# Criar arquivo .env com URL da API
@"
REACT_APP_API_URL=https://$FUNCTION_APP_NAME.azurewebsites.net
"@ | Out-File -FilePath .env -Encoding utf8

# Build de produção
npm run build

# Criar Static Web App no Azure
az staticwebapp create `
  --name galeria-artes-frontend `
  --resource-group galeria-artes-rg `
  --source https://github.com/SEU_USUARIO/galeria-artes-azure `
  --location "Central US" `
  --branch main `
  --app-location "frontend" `
  --output-location "build" `
  --login-with-github
```

**⚠️ Você vai precisar:**
1. Criar repositório no GitHub primeiro (veja passo 8)
2. Conectar sua conta GitHub quando solicitado

**Obter URL do frontend:**
```powershell
az staticwebapp show `
  --name galeria-artes-frontend `
  --resource-group galeria-artes-rg `
  --query "defaultHostname" `
  --output tsv
```

### **PASSO 8: Colocar Código no GitHub** ⏱️ 3 min

```powershell
# Voltar para raiz do projeto
cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD

# Inicializar Git
git init
git add .
git commit -m "feat: projeto inicial - Galeria de Artes Online"

# Criar repositório no GitHub
# Acesse: https://github.com/new
# Nome: galeria-artes-azure
# Visibilidade: Public ou Private
# NÃO adicionar README, .gitignore ou license

# Conectar ao GitHub (trocar SEU_USUARIO)
git remote add origin https://github.com/SEU_USUARIO/galeria-artes-azure.git
git branch -M main
git push -u origin main
```

### **PASSO 9: Configurar GitHub Actions** ⏱️ 5 min

**9.1. Obter Publish Profile do Backend:**
```powershell
az functionapp deployment list-publishing-profiles `
  --name $FUNCTION_APP_NAME `
  --resource-group galeria-artes-rg `
  --xml > publish-profile.xml

# Abrir e copiar conteúdo
notepad publish-profile.xml
```

**9.2. Obter Token do Static Web App:**
```powershell
az staticwebapp secrets list `
  --name galeria-artes-frontend `
  --resource-group galeria-artes-rg `
  --query "properties.apiKey" `
  --output tsv

# Copiar o token que aparecer
```

**9.3. Adicionar Secrets no GitHub:**

1. Acesse: `https://github.com/SEU_USUARIO/galeria-artes-azure/settings/secrets/actions`

2. Clique em **"New repository secret"**

3. Criar 3 secrets:

**Secret 1:**
- Name: `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`
- Value: (colar conteúdo do publish-profile.xml)

**Secret 2:**
- Name: `AZURE_STATIC_WEB_APPS_API_TOKEN`
- Value: (colar token do Static Web App)

**Secret 3:**
- Name: `REACT_APP_API_URL`
- Value: `https://FUNCTION_APP_NAME.azurewebsites.net`

### **PASSO 10: Testar Tudo** ⏱️ 2 min

```powershell
# Executar script de testes
cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD\scripts
.\04-test-application.ps1
```

**Testes manuais:**

1. **Backend API:**
   ```
   https://FUNCTION_APP_NAME.azurewebsites.net/api/obras
   ```

2. **Frontend:**
   ```
   https://galeria-artes-frontend.azurestaticapps.net
   ```

3. **GitHub Actions:**
   ```
   https://github.com/SEU_USUARIO/galeria-artes-azure/actions
   ```

---

## ✅ Checklist Rápido

- [ ] Azure CLI instalado
- [ ] Login no Azure (`az login`)
- [ ] Script de provisionamento executado
- [ ] Banco de dados configurado (12 obras)
- [ ] Imagens enviadas (12 arquivos)
- [ ] Backend deployado e funcionando
- [ ] Frontend deployado e funcionando
- [ ] Código no GitHub
- [ ] GitHub Actions configurado
- [ ] Tudo testado e funcionando

---

## 🆘 Problemas Comuns

### Erro: "MySQL connection refused"
```powershell
# Adicionar seu IP ao firewall
$MyIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
az mysql flexible-server firewall-rule create `
  --resource-group galeria-artes-rg `
  --name MYSQL_SERVER_NAME `
  --rule-name AllowMyIP `
  --start-ip-address $MyIP `
  --end-ip-address $MyIP
```

### Erro: "CORS blocked"
```powershell
# Adicionar domínio do frontend ao CORS
az functionapp cors add `
  --name FUNCTION_APP_NAME `
  --resource-group galeria-artes-rg `
  --allowed-origins "https://galeria-artes-frontend.azurestaticapps.net"
```

### Erro: "Function runtime unable to start"
```powershell
# Ver logs
az functionapp log tail --name FUNCTION_APP_NAME --resource-group galeria-artes-rg

# Forçar redeploy
cd backend
func azure functionapp publish FUNCTION_APP_NAME --build remote
```

---

## 💰 Custos Estimados

Após tudo provisionado:

- Azure Function (Consumption): ~R$ 0-5/mês
- MySQL Flexible Server (B1ms): ~R$ 60-80/mês
- Blob Storage: ~R$ 1-5/mês
- Static Web App (Free): R$ 0/mês

**Total: ~R$ 65-90/mês**

**Para economizar:** Parar MySQL quando não usar
```powershell
az mysql flexible-server stop --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME
```

---

## 🔥 Atalho: Executar Tudo de Uma Vez

```powershell
# Script automatizado que faz TUDO
.\run-all.ps1
```

Este script interativo vai:
1. Fazer login no Azure
2. Provisionar todos recursos
3. Configurar banco
4. Upload de imagens
5. Deploy backend
6. Deploy frontend
7. Configurar GitHub

**Tempo total: 30-45 minutos**

---

## 📞 Precisa de Ajuda?

1. **Consulte o FAQ:** `FAQ.md`
2. **Troubleshooting:** `TROUBLESHOOTING.md`
3. **Deploy detalhado:** `DEPLOY_GUIDE.md`
4. **Checklist completo:** `DEPLOY_CHECKLIST.md`

---

**🎯 COMECE AGORA PELO PASSO 1!**
