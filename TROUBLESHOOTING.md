# 🔧 Troubleshooting - Problemas Comuns e Soluções

Guia de resolução de problemas frequentes da Galeria de Artes Online.

---

## 🗄️ Problemas com MySQL

### ❌ Erro: "Can't connect to MySQL server"

**Sintomas:**
```
pymysql.err.OperationalError: (2003, "Can't connect to MySQL server")
```

**Causas e Soluções:**

1. **Firewall não configurado**
   ```powershell
   # Adicionar regra para Azure Services
   az mysql flexible-server firewall-rule create `
     --resource-group rg-galeria-artes `
     --name SEU_MYSQL_SERVER `
     --rule-name AllowAzureServices `
     --start-ip-address 0.0.0.0 `
     --end-ip-address 0.0.0.0
   ```

2. **Credenciais incorretas**
   ```powershell
   # Verificar variáveis de ambiente
   az functionapp config appsettings list `
     --name SEU_FUNCTION_APP `
     --resource-group rg-galeria-artes
   ```

3. **Host incorreto**
   ```
   # Host deve incluir .mysql.database.azure.com
   Correto: mysql-server.mysql.database.azure.com
   Errado: mysql-server
   ```

### ❌ Erro: "Access denied for user"

**Solução:**
```powershell
# Verificar usuário e senha
$MYSQL_USER = "adminarte"
$MYSQL_PASSWORD = "SuaSenhaCorreta"

# Testar conexão manualmente
mysql -h SEU_MYSQL_SERVER.mysql.database.azure.com `
  -u $MYSQL_USER `
  -p$MYSQL_PASSWORD `
  galeria_db
```

### ❌ Tabela `obras` não existe

**Solução:**
```powershell
# Executar script de criação
mysql -h SEU_MYSQL_SERVER.mysql.database.azure.com `
  -u adminarte -p `
  galeria_db < .\scripts\02-setup-database.sql

# Verificar
mysql -h SEU_MYSQL_SERVER.mysql.database.azure.com `
  -u adminarte -p `
  -e "USE galeria_db; SHOW TABLES;"
```

---

## 💾 Problemas com Blob Storage

### ❌ Imagens não carregam (404)

**Sintomas:** Frontend mostra "Imagem indisponível"

**Soluções:**

1. **Verificar acesso público**
   ```powershell
   az storage container show-permission `
     --name obras `
     --account-name SEU_STORAGE_ACCOUNT
   
   # Configurar acesso público se necessário
   az storage container set-permission `
     --name obras `
     --public-access blob `
     --account-name SEU_STORAGE_ACCOUNT
   ```

2. **Verificar URLs no banco**
   ```sql
   USE galeria_db;
   SELECT nome, url_imagem FROM obras LIMIT 5;
   
   -- URLs devem seguir formato:
   -- https://STORAGE_ACCOUNT.blob.core.windows.net/obras/ARQUIVO.jpg
   ```

3. **Fazer upload novamente**
   ```powershell
   .\scripts\03-upload-images.ps1
   
   # Atualizar URLs
   mysql -h SEU_MYSQL_SERVER.mysql.database.azure.com `
     -u adminarte -p `
     galeria_db < .\update-urls.sql
   ```

### ❌ Erro: "The specified container does not exist"

**Solução:**
```powershell
# Criar container
az storage container create `
  --name obras `
  --account-name SEU_STORAGE_ACCOUNT `
  --public-access blob
```

---

## ⚡ Problemas com Azure Function

### ❌ Function retorna erro 500

**Diagnóstico:**
```powershell
# Ver logs em tempo real
az functionapp log tail `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes

# Ver últimos logs
az functionapp log download `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes
```

**Soluções comuns:**

1. **Dependências não instaladas**
   ```powershell
   cd backend
   pip install -r requirements.txt
   func azure functionapp publish SEU_FUNCTION_APP --build remote
   ```

2. **Variáveis de ambiente faltando**
   ```powershell
   az functionapp config appsettings set `
     --name SEU_FUNCTION_APP `
     --resource-group rg-galeria-artes `
     --settings `
       "MYSQL_HOST=SEU_MYSQL_SERVER.mysql.database.azure.com" `
       "MYSQL_USER=adminarte" `
       "MYSQL_PASSWORD=SUA_SENHA" `
       "MYSQL_DATABASE=galeria_db" `
       "MYSQL_PORT=3306"
   ```

### ❌ CORS bloqueando requisições

**Sintomas:**
```
Access to fetch at 'https://func.azurewebsites.net/api/obras' 
from origin 'https://stapp.azurestaticapps.net' has been blocked by CORS policy
```

**Solução:**
```powershell
# Adicionar origem específica
az functionapp cors add `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --allowed-origins "https://SEU_STATIC_WEB_APP.azurestaticapps.net"

# Ou permitir todas (apenas desenvolvimento)
az functionapp cors add `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --allowed-origins "*"
```

### ❌ Function não responde

**Diagnóstico:**
```powershell
# Verificar status
az functionapp show `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --query "state"

# Reiniciar
az functionapp restart `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes
```

---

## 🌐 Problemas com Static Web App

### ❌ Deploy falha no GitHub Actions

**Verificar:**

1. **Secret configurado corretamente**
   - GitHub → Settings → Secrets → Actions
   - Verificar `AZURE_STATIC_WEB_APPS_API_TOKEN`

2. **Obter novo token**
   ```powershell
   az staticwebapp secrets list `
     --name stapp-galeria-artes `
     --resource-group rg-galeria-artes `
     --query "properties.apiKey" `
     --output tsv
   ```

3. **Atualizar secret no GitHub**

### ❌ Variável de ambiente não carrega

**Problema:** `process.env.REACT_APP_API_URL` retorna `undefined`

**Solução:**

1. **Prefixo obrigatório:** Deve começar com `REACT_APP_`
   ```javascript
   // Correto
   const API_URL = process.env.REACT_APP_API_URL;
   
   // Errado
   const API_URL = process.env.API_URL;
   ```

2. **Configurar no workflow**
   ```yaml
   # .github/workflows/frontend-deploy.yml
   env:
     REACT_APP_API_URL: ${{ secrets.REACT_APP_API_URL }}
   ```

3. **Build novamente**
   ```powershell
   cd frontend
   npm run build
   ```

### ❌ Página não atualiza após deploy

**Solução:**
```powershell
# Limpar cache do navegador
# Ou abrir em modo anônimo

# Verificar versão deployada
curl https://SEU_STATIC_WEB_APP.azurestaticapps.net
```

---

## 🔄 Problemas com GitHub Actions

### ❌ Workflow não executa

**Verificar:**

1. **Workflow habilitado**
   - GitHub → Actions → Verificar se workflows estão ativos

2. **Branch correta**
   ```yaml
   # Verificar em .github/workflows/*.yml
   on:
     push:
       branches:
         - main  # Deve corresponder à sua branch
   ```

3. **Paths corretos**
   ```yaml
   on:
     push:
       paths:
         - 'backend/**'  # Verifica sintaxe
   ```

### ❌ Erro: "Secret not found"

**Solução:**
```powershell
# Verificar secrets existentes
# GitHub → Settings → Secrets and variables → Actions

# Criar secret faltante
# Seguir guia: .github/SECRETS_SETUP.md
```

### ❌ Deploy backend falha

**Erros comuns:**

1. **Publish profile expirado**
   ```powershell
   # Obter novo
   az functionapp deployment list-publishing-profiles `
     --name SEU_FUNCTION_APP `
     --resource-group rg-galeria-artes `
     --xml > publish-profile.xml
   
   # Atualizar no GitHub
   ```

2. **Python version mismatch**
   ```yaml
   # Verificar versão em workflow
   PYTHON_VERSION: '3.9'  # Deve corresponder à Function
   ```

---

## 🧪 Problemas ao Testar Localmente

### ❌ Function local não inicia

**Erro:** `Host.json file ... is invalid`

**Solução:**
```powershell
# Verificar instalação do Functions Core Tools
func --version

# Reinstalar se necessário
npm install -g azure-functions-core-tools@4

# Verificar host.json
cd backend
func start
```

### ❌ Erro: "ModuleNotFoundError: No module named 'pymysql'"

**Solução:**
```powershell
cd backend

# Criar ambiente virtual
python -m venv .venv

# Ativar
.\.venv\Scripts\Activate.ps1

# Instalar dependências
pip install -r requirements.txt

# Executar
func start
```

### ❌ Frontend não conecta à API local

**Problema:** API local em `localhost:7071` não aceita requisições do frontend em `localhost:3000`

**Solução:**

1. **Adicionar CORS no local.settings.json**
   ```json
   {
     "Host": {
       "CORS": "*"
     }
   }
   ```

2. **Usar proxy no package.json**
   ```json
   {
     "proxy": "http://localhost:7071"
   }
   ```

---

## 📦 Problemas de Instalação

### ❌ Azure CLI não reconhecido

**Windows:**
```powershell
# Instalar via winget
winget install Microsoft.AzureCLI

# Ou via MSI
# Download: https://aka.ms/installazurecliwindows
```

### ❌ Node.js version incompatível

**Solução:**
```powershell
# Verificar versão
node --version

# Deve ser 16+ para React 18
# Download: https://nodejs.org/
```

### ❌ Python não encontrado

**Solução:**
```powershell
# Verificar instalação
python --version

# Instalar Python 3.9+
# Download: https://www.python.org/downloads/
```

---

## 🔍 Comandos de Diagnóstico

### Verificar todos os recursos

```powershell
# Listar recursos no Resource Group
az resource list `
  --resource-group rg-galeria-artes `
  --output table

# Status da Function
az functionapp show `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --query "state"

# Status do MySQL
az mysql flexible-server show `
  --resource-group rg-galeria-artes `
  --name SEU_MYSQL_SERVER `
  --query "state"

# Listar blobs
az storage blob list `
  --container-name obras `
  --account-name SEU_STORAGE_ACCOUNT `
  --output table
```

### Testar conectividade

```powershell
# Testar API
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/health

# Testar MySQL
mysql -h SEU_MYSQL_SERVER.mysql.database.azure.com `
  -u adminarte -p `
  -e "SELECT 1"

# Testar Blob Storage
curl https://SEU_STORAGE_ACCOUNT.blob.core.windows.net/obras/monalisa.jpg
```

---

## 🆘 Ainda com Problemas?

### Passos gerais de troubleshooting:

1. **Verificar logs**
   ```powershell
   az functionapp log tail --name SEU_FUNCTION_APP --resource-group rg-galeria-artes
   ```

2. **Verificar Application Insights** (se habilitado)
   - Portal Azure → Function App → Application Insights

3. **Recriar recurso problemático**
   ```powershell
   # Exemplo: Recriar Function App
   az functionapp delete --name SEU_FUNCTION_APP --resource-group rg-galeria-artes
   # Executar novamente o script de provisionamento
   ```

4. **Limpar e redeployar**
   ```powershell
   # Backend
   cd backend
   func azure functionapp publish SEU_FUNCTION_APP --build remote
   
   # Frontend
   cd frontend
   npm run build
   # Trigger GitHub Actions
   ```

5. **Verificar cotas e limites**
   - Portal Azure → Subscriptions → Usage + quotas

---

## 📞 Suporte

- **Documentação Azure:** https://docs.microsoft.com/azure/
- **Stack Overflow:** Tag `azure-functions`, `azure-static-web-apps`
- **GitHub Issues:** Criar issue no repositório
- **Azure Support:** Portal Azure → Help + support

---

## 🧹 Reset Completo (Último Recurso)

**⚠️ ATENÇÃO: Isso deletará TODOS os recursos!**

```powershell
# Deletar Resource Group
az group delete `
  --name rg-galeria-artes `
  --yes `
  --no-wait

# Aguardar conclusão
az group wait `
  --name rg-galeria-artes `
  --deleted

# Executar provisionamento novamente
.\scripts\01-provision-azure.ps1
```
