# 📚 Guia Completo de Deploy - Galeria de Artes Online

Este guia passo a passo te levará do zero até a aplicação funcionando na Azure.

---

## ✅ Pré-requisitos

Antes de começar, certifique-se de ter:

- [ ] Conta Azure ativa ([criar conta gratuita](https://azure.microsoft.com/free/))
- [ ] Azure CLI instalado ([download](https://docs.microsoft.com/cli/azure/install-azure-cli))
- [ ] Git instalado ([download](https://git-scm.com/downloads))
- [ ] Python 3.9+ instalado ([download](https://www.python.org/downloads/))
- [ ] Node.js 16+ instalado ([download](https://nodejs.org/))
- [ ] VS Code instalado ([download](https://code.visualstudio.com/))
- [ ] Conta GitHub ([criar conta](https://github.com/signup))

### Extensões VS Code Recomendadas:

```powershell
# Instalar extensões via CLI
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-azuretools.vscode-azurestaticwebapps
code --install-extension ms-python.python
code --install-extension dbaeumer.vscode-eslint
```

---

## 🚀 Parte 1: Provisionamento dos Recursos Azure

### 1.1 - Login no Azure

```powershell
# Login interativo
az login

# Listar suas assinaturas
az account list --output table

# Definir assinatura padrão (se tiver mais de uma)
az account set --subscription "Nome ou ID da assinatura"

# Verificar assinatura ativa
az account show --output table
```

### 1.2 - Executar Script de Provisionamento

```powershell
# Navegar até a pasta do projeto
cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD

# Executar script de provisionamento
.\scripts\01-provision-azure.ps1
```

**⏱️ Tempo estimado: 15-20 minutos**

Este script criará:
- ✅ Resource Group
- ✅ Azure Database for MySQL Flexible Server
- ✅ Banco de dados `galeria_db`
- ✅ Storage Account com container `obras`
- ✅ App Service Plan
- ✅ Azure Function App (Python)

**📝 Importante:** Salve o arquivo `azure-config.txt` gerado - ele contém todas as configurações!

---

## 🗄️ Parte 2: Configurar Banco de Dados

### 2.1 - Conectar ao MySQL

Você pode conectar de 3 formas:

#### Opção A: Via Azure CLI

```powershell
# Carregar variáveis do config
$config = Get-Content .\azure-config.txt | ConvertFrom-StringData
$MYSQL_SERVER = $config['MYSQL_SERVER']
$MYSQL_USER = $config['MYSQL_USER']
$MYSQL_PASSWORD = $config['MYSQL_PASSWORD']
$MYSQL_DATABASE = $config['MYSQL_DATABASE']

# Conectar
mysql -h "$MYSQL_SERVER.mysql.database.azure.com" -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE
```

#### Opção B: Via MySQL Workbench

1. Abra MySQL Workbench
2. Crie nova conexão:
   - **Hostname:** `SEU_MYSQL_SERVER.mysql.database.azure.com`
   - **Port:** `3306`
   - **Username:** `adminarte`
   - **Password:** (a senha do azure-config.txt)
3. Teste a conexão

#### Opção C: Via Azure Portal

1. Acesse o Portal Azure
2. Navegue até seu MySQL Server
3. Clique em "Connect" e use o Cloud Shell

### 2.2 - Executar Script SQL

```powershell
# Executar script SQL
mysql -h "$MYSQL_SERVER.mysql.database.azure.com" `
  -u $MYSQL_USER `
  -p$MYSQL_PASSWORD `
  $MYSQL_DATABASE `
  < .\scripts\02-setup-database.sql
```

**✅ Verificar:** Conecte novamente e execute `SELECT * FROM obras;` para ver os registros.

---

## 🖼️ Parte 3: Upload de Imagens

### 3.1 - Executar Script de Upload

```powershell
# Executar script de upload
.\scripts\03-upload-images.ps1
```

Este script irá:
- Baixar 12 imagens de obras famosas
- Fazer upload para o Azure Blob Storage
- Gerar script SQL para atualizar URLs

### 3.2 - Atualizar URLs no Banco

```powershell
# Executar script de atualização gerado
mysql -h "$MYSQL_SERVER.mysql.database.azure.com" `
  -u $MYSQL_USER `
  -p$MYSQL_PASSWORD `
  $MYSQL_DATABASE `
  < .\update-urls.sql
```

### 3.3 - Testar Acesso às Imagens

Abra no navegador:
```
https://SEU_STORAGE_ACCOUNT.blob.core.windows.net/obras/monalisa.jpg
```

---

## ⚡ Parte 4: Deploy do Backend (Azure Function)

### 4.1 - Instalar Azure Functions Core Tools

```powershell
# Via npm
npm install -g azure-functions-core-tools@4

# Verificar instalação
func --version
```

### 4.2 - Testar Localmente

```powershell
# Navegar para pasta backend
cd backend

# Criar ambiente virtual Python
python -m venv .venv

# Ativar ambiente virtual
.\.venv\Scripts\Activate.ps1

# Instalar dependências
pip install -r requirements.txt

# Configurar local.settings.json com suas credenciais
# (edite o arquivo com os valores do azure-config.txt)

# Iniciar Function localmente
func start
```

**🧪 Testar:** Abra http://localhost:7071/api/health no navegador

### 4.3 - Deploy para Azure

```powershell
# Deploy direto via Functions Core Tools
func azure functionapp publish SEU_FUNCTION_APP_NAME

# Configurar variáveis de ambiente
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

### 4.4 - Testar API em Produção

```powershell
# Testar health check
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/health

# Listar obras
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/obras
```

---

## 🌐 Parte 5: Deploy do Frontend

### 5.1 - Configurar Ambiente Local

```powershell
# Navegar para pasta frontend
cd ..\frontend

# Instalar dependências
npm install

# Criar arquivo .env
Copy-Item .env.example .env

# Editar .env e adicionar URL da sua Function App
# REACT_APP_API_URL=https://SEU_FUNCTION_APP.azurewebsites.net/api
```

### 5.2 - Testar Localmente

```powershell
# Iniciar em modo desenvolvimento
npm start
```

**🧪 Testar:** Abra http://localhost:3000 no navegador

### 5.3 - Criar Static Web App

```powershell
# Obter token do GitHub
# Acesse: https://github.com/settings/tokens
# Gere um token com permissões: repo, workflow

# Criar Static Web App
az staticwebapp create `
  --name stapp-galeria-artes `
  --resource-group rg-galeria-artes `
  --location eastus2 `
  --source https://github.com/SEU-USUARIO/AS-PROJETOCLOUD `
  --branch main `
  --app-location "/frontend" `
  --output-location "build" `
  --token SEU_GITHUB_TOKEN
```

---

## 🔄 Parte 6: Configurar CI/CD com GitHub Actions

### 6.1 - Criar Repositório GitHub

```powershell
# Inicializar Git (se ainda não fez)
cd ..
git init
git add .
git commit -m "Initial commit: Galeria de Artes Online"

# Criar repositório no GitHub e adicionar remote
git remote add origin https://github.com/SEU-USUARIO/AS-PROJETOCLOUD.git
git branch -M main
git push -u origin main
```

### 6.2 - Configurar Secrets

Execute o script para obter os valores:

```powershell
# Obter publish profile
az functionapp deployment list-publishing-profiles `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --xml > publish-profile.xml

# Obter Static Web App token
az staticwebapp secrets list `
  --name stapp-galeria-artes `
  --resource-group rg-galeria-artes
```

**Configure no GitHub:**
1. Vá para `Settings` → `Secrets and variables` → `Actions`
2. Adicione os secrets conforme `.github/SECRETS_SETUP.md`

### 6.3 - Testar GitHub Actions

```powershell
# Fazer uma alteração
echo "# Teste" >> README.md
git add .
git commit -m "Teste: GitHub Actions"
git push

# Acompanhar workflow
# Acesse: https://github.com/SEU-USUARIO/AS-PROJETOCLOUD/actions
```

---

## ✅ Parte 7: Validação Final

### Checklist de Validação

- [ ] ✅ Recursos Azure criados
- [ ] ✅ Banco de dados com tabela e dados
- [ ] ✅ Imagens no Blob Storage acessíveis
- [ ] ✅ Function App respondendo em `/api/health`
- [ ] ✅ Function App retornando obras em `/api/obras`
- [ ] ✅ Static Web App publicado
- [ ] ✅ Frontend acessível via URL pública
- [ ] ✅ Frontend exibindo imagens do Blob
- [ ] ✅ GitHub Actions executando automaticamente
- [ ] ✅ CORS configurado corretamente

### URLs para Testar

```powershell
# Backend
https://SEU_FUNCTION_APP.azurewebsites.net/api/health
https://SEU_FUNCTION_APP.azurewebsites.net/api/obras

# Frontend
https://SEU_STATIC_WEB_APP.azurestaticapps.net
```

---

## 🐛 Troubleshooting

### Problema: Function não conecta ao MySQL

**Solução:**
```powershell
# Verificar firewall
az mysql flexible-server firewall-rule list `
  --resource-group rg-galeria-artes `
  --name SEU_MYSQL_SERVER

# Adicionar regra se necessário
az mysql flexible-server firewall-rule create `
  --resource-group rg-galeria-artes `
  --name SEU_MYSQL_SERVER `
  --rule-name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0
```

### Problema: CORS bloqueando requisições

**Solução:**
```powershell
# Configurar CORS na Function App
az functionapp cors add `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes `
  --allowed-origins "*"
```

### Problema: Imagens não carregam

**Solução:**
```powershell
# Verificar acesso público ao container
az storage container set-permission `
  --name obras `
  --public-access blob `
  --account-name SEU_STORAGE_ACCOUNT
```

---

## 📊 Monitoramento

### Ver Logs da Function

```powershell
# Stream de logs em tempo real
az functionapp log tail `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes
```

### Métricas no Portal Azure

1. Acesse o Portal Azure
2. Vá para sua Function App
3. Clique em "Metrics" para ver:
   - Número de requisições
   - Tempo de resposta
   - Erros

---

## 🧹 Limpeza de Recursos

**⚠️ ATENÇÃO:** Isso deletará TODOS os recursos!

```powershell
# Deletar Resource Group completo
az group delete `
  --name rg-galeria-artes `
  --yes `
  --no-wait
```

---

## 📚 Próximos Passos

- 🔒 Configurar autenticação com Azure AD
- 📊 Adicionar Application Insights para monitoramento
- 🎨 Adicionar funcionalidade de busca
- 💾 Implementar cache com Redis
- 🔐 Restringir CORS para domínio específico
- 📱 Criar app mobile com React Native

---

## 🆘 Suporte

- **Documentação Azure:** https://docs.microsoft.com/azure/
- **Documentação React:** https://react.dev/
- **GitHub Issues:** [Criar Issue](https://github.com/SEU-USUARIO/AS-PROJETOCLOUD/issues)
