# ⚡ Quick Start - Galeria de Artes Online

Comandos rápidos para começar agora mesmo!

## 🚀 Setup Completo em 5 Passos

### 1️⃣ Clonar e Preparar

```powershell
# Clonar repositório
git clone https://github.com/SEU-USUARIO/AS-PROJETOCLOUD.git
cd AS-PROJETOCLOUD

# Login Azure
az login
```

### 2️⃣ Provisionar Recursos Azure

```powershell
# Executar provisionamento (15-20 min)
.\scripts\01-provision-azure.ps1

# Guardar as informações geradas em azure-config.txt
```

### 3️⃣ Configurar Banco e Imagens

```powershell
# Executar script SQL
mysql -h "SEU_MYSQL_SERVER.mysql.database.azure.com" `
  -u adminarte -p `
  galeria_db < .\scripts\02-setup-database.sql

# Upload de imagens
.\scripts\03-upload-images.ps1

# Atualizar URLs no banco
mysql -h "SEU_MYSQL_SERVER.mysql.database.azure.com" `
  -u adminarte -p `
  galeria_db < .\update-urls.sql
```

### 4️⃣ Deploy Backend

```powershell
cd backend

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

# Deploy
func azure functionapp publish SEU_FUNCTION_APP

# Testar
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/health
```

### 5️⃣ Deploy Frontend

```powershell
cd ..\frontend

# Configurar .env
echo "REACT_APP_API_URL=https://SEU_FUNCTION_APP.azurewebsites.net/api" > .env

# Build e deploy via Static Web App
npm install
npm run build

# Criar Static Web App
az staticwebapp create `
  --name stapp-galeria-artes `
  --resource-group rg-galeria-artes `
  --source https://github.com/SEU-USUARIO/AS-PROJETOCLOUD `
  --branch main `
  --app-location "/frontend" `
  --output-location "build" `
  --token SEU_GITHUB_TOKEN
```

---

## ✅ Checklist Rápido

- [ ] Azure CLI instalado e logado
- [ ] Scripts executados na ordem
- [ ] azure-config.txt salvo
- [ ] Banco de dados configurado
- [ ] Imagens no Blob Storage
- [ ] Function App funcionando
- [ ] Frontend publicado
- [ ] GitHub Actions configurado

---

## 🧪 Testes Rápidos

```powershell
# Testar tudo de uma vez
.\scripts\04-test-application.ps1 `
  -FunctionAppUrl "https://SEU_FUNCTION_APP.azurewebsites.net"
```

---

## 🆘 Comandos Úteis

```powershell
# Ver logs da Function
az functionapp log tail `
  --name SEU_FUNCTION_APP `
  --resource-group rg-galeria-artes

# Listar blobs no storage
az storage blob list `
  --account-name SEU_STORAGE `
  --container-name obras `
  --output table

# Verificar status dos recursos
az resource list `
  --resource-group rg-galeria-artes `
  --output table

# Deletar tudo
az group delete `
  --name rg-galeria-artes `
  --yes --no-wait
```

---

## 📚 Links Rápidos

- **Guia Completo:** [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)
- **Configurar Secrets:** [.github/SECRETS_SETUP.md](./.github/SECRETS_SETUP.md)
- **Backend README:** [backend/README.md](./backend/README.md)
- **Frontend README:** [frontend/README.md](./frontend/README.md)
