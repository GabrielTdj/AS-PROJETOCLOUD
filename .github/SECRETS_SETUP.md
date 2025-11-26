# 🔐 Configuração de Secrets do GitHub Actions

Este documento explica como configurar os secrets necessários para os workflows de CI/CD.

## 📋 Secrets Necessários

### Backend (Azure Function)

#### `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`

**Como obter:**

```powershell
# Via Azure CLI
az functionapp deployment list-publishing-profiles `
  --name SEU_FUNCTION_APP `
  --resource-group SEU_RESOURCE_GROUP `
  --xml
```

**Como configurar:**
1. No GitHub, vá para **Settings** → **Secrets and variables** → **Actions**
2. Clique em **New repository secret**
3. Nome: `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`
4. Valor: Cole o XML completo do comando acima
5. Clique em **Add secret**

---

### Frontend (Static Web App)

#### `AZURE_STATIC_WEB_APPS_API_TOKEN`

**Como obter:**

```powershell
# Via Azure Portal
# 1. Vá para seu Static Web App no Portal Azure
# 2. Vá para "Manage deployment token"
# 3. Copie o token

# Via Azure CLI
az staticwebapp secrets list `
  --name SEU_STATIC_WEB_APP `
  --resource-group SEU_RESOURCE_GROUP `
  --query "properties.apiKey" `
  --output tsv
```

**Como configurar:**
1. No GitHub, vá para **Settings** → **Secrets and variables** → **Actions**
2. Clique em **New repository secret**
3. Nome: `AZURE_STATIC_WEB_APPS_API_TOKEN`
4. Valor: Cole o token
5. Clique em **Add secret**

#### `REACT_APP_API_URL`

**Como configurar:**
1. No GitHub, vá para **Settings** → **Secrets and variables** → **Actions**
2. Clique em **New repository secret**
3. Nome: `REACT_APP_API_URL`
4. Valor: `https://SEU_FUNCTION_APP.azurewebsites.net/api`
5. Clique em **Add secret**

---

## 🚀 Comandos Rápidos para Configuração

### Script PowerShell Completo

```powershell
# Definir variáveis
$RESOURCE_GROUP = "rg-galeria-artes"
$FUNCTION_APP = "func-galeria-artes-XXXX"
$STATIC_WEB_APP = "stapp-galeria-artes"

Write-Host "🔑 Obtendo Secrets para GitHub Actions..." -ForegroundColor Cyan

# 1. Obter publish profile da Function App
Write-Host "`n📝 1. AZURE_FUNCTIONAPP_PUBLISH_PROFILE:" -ForegroundColor Green
Write-Host "Cole este conteúdo no secret do GitHub:" -ForegroundColor Yellow
az functionapp deployment list-publishing-profiles `
  --name $FUNCTION_APP `
  --resource-group $RESOURCE_GROUP `
  --xml

# 2. Obter API Token do Static Web App
Write-Host "`n📝 2. AZURE_STATIC_WEB_APPS_API_TOKEN:" -ForegroundColor Green
Write-Host "Cole este token no secret do GitHub:" -ForegroundColor Yellow
az staticwebapp secrets list `
  --name $STATIC_WEB_APP `
  --resource-group $RESOURCE_GROUP `
  --query "properties.apiKey" `
  --output tsv

# 3. URL da API
Write-Host "`n📝 3. REACT_APP_API_URL:" -ForegroundColor Green
Write-Host "Cole esta URL no secret do GitHub:" -ForegroundColor Yellow
Write-Host "https://${FUNCTION_APP}.azurewebsites.net/api"

Write-Host "`n✅ Todos os secrets foram gerados!" -ForegroundColor Green
Write-Host "📋 Configure-os em: https://github.com/SEU-USUARIO/SEU-REPO/settings/secrets/actions" -ForegroundColor Cyan
```

---

## 📝 Checklist de Configuração

- [ ] `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` configurado
- [ ] `AZURE_STATIC_WEB_APPS_API_TOKEN` configurado
- [ ] `REACT_APP_API_URL` configurado
- [ ] Workflow do backend ativado
- [ ] Workflow do frontend ativado
- [ ] Push para `main` testado
- [ ] Deploys automáticos funcionando

---

## 🔄 Atualizar Secrets

Se precisar atualizar os secrets:

```powershell
# Regenerar publish profile (cria novas credenciais)
az functionapp deployment list-publishing-profiles `
  --name $FUNCTION_APP `
  --resource-group $RESOURCE_GROUP `
  --xml

# Regenerar token do Static Web App
az staticwebapp secrets reset-api-key `
  --name $STATIC_WEB_APP `
  --resource-group $RESOURCE_GROUP
```

Depois atualize os secrets no GitHub.

---

## 🧪 Testar GitHub Actions Localmente

Para testar workflows localmente, use [act](https://github.com/nektos/act):

```powershell
# Instalar act
winget install nektos.act

# Testar workflow
act -s AZURE_FUNCTIONAPP_PUBLISH_PROFILE="$(cat publish-profile.xml)" push
```

---

## 📚 Documentação Adicional

- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Azure Functions CI/CD](https://docs.microsoft.com/azure/azure-functions/functions-how-to-github-actions)
- [Static Web Apps CI/CD](https://docs.microsoft.com/azure/static-web-apps/github-actions-workflow)
