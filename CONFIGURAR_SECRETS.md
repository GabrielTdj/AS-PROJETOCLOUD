# Configurar GitHub Secrets

Acesse: https://github.com/GabrielTdj/AS-PROJETOCLOUD/settings/secrets/actions

Clique em **"New repository secret"** e adicione cada um:

---

## 1. AZURE_STATIC_WEB_APPS_API_TOKEN

**Name:** `AZURE_STATIC_WEB_APPS_API_TOKEN`

**Value:**
```
cb38237d2e4acbc48605261711d0975c9a8465e4ba377d6638a66db7bb33f29903-aa9c6f44-7702-4f21-9be1-0324db3d779400f080803fd1e40f
```

---

## 2. REACT_APP_API_URL

**Name:** `REACT_APP_API_URL`

**Value:**
```
https://func-galeria-5678.azurewebsites.net/api
```

---

## 3. AZURE_FUNCTIONAPP_PUBLISH_PROFILE

**Name:** `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`

**Value:** Execute o comando abaixo no PowerShell e copie TODO o XML gerado:

```powershell
az functionapp deployment list-publishing-profiles --name func-galeria-5678 --resource-group rg-galeria-artes --xml
```

---

## Depois de Configurar os Secrets

1. Vá em **Actions** no GitHub
2. Selecione o workflow **"Deploy Frontend"**
3. Clique em **"Run workflow"**
4. Aguarde o deploy (2-3 minutos)
5. Acesse: https://orange-desert-03fd1e40f.3.azurestaticapps.net

---

## URLs Finais

- **Frontend:** https://orange-desert-03fd1e40f.3.azurestaticapps.net
- **Backend API:** https://func-galeria-5678.azurewebsites.net/api/obras
- **Health Check:** https://func-galeria-5678.azurewebsites.net/api/health
