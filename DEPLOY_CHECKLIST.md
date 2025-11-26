# Galeria de Artes Online - Checklist de Deploy ✅

## 📋 Pré-Requisitos

### Software Instalado
- [ ] Azure CLI instalado e atualizado
  ```powershell
  az --version
  az upgrade
  ```
- [ ] Git instalado
  ```powershell
  git --version
  ```
- [ ] Node.js 18+ e npm instalados
  ```powershell
  node --version
  npm --version
  ```
- [ ] Python 3.9+ instalado
  ```powershell
  python --version
  ```
- [ ] MySQL Client instalado (para setup do banco)
  ```powershell
  mysql --version
  ```
- [ ] Visual Studio Code (recomendado)

### Conta Azure
- [ ] Conta Azure ativa (pode ser Azure for Students)
- [ ] Permissões para criar recursos
- [ ] Subscription ID anotado

### Conta GitHub
- [ ] Conta GitHub criada
- [ ] Git configurado localmente
  ```powershell
  git config --global user.name "Seu Nome"
  git config --global user.email "seu@email.com"
  ```

---

## 🚀 Fase 1: Preparação Local

### 1.1 Navegação e Verificação
- [ ] Abrir PowerShell como Administrador
- [ ] Navegar até o diretório do projeto
  ```powershell
  cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD
  ```
- [ ] Verificar estrutura de arquivos
  ```powershell
  ls -R
  ```

### 1.2 Inicializar Git
- [ ] Inicializar repositório
  ```powershell
  git init
  ```
- [ ] Adicionar todos os arquivos
  ```powershell
  git add .
  ```
- [ ] Criar commit inicial
  ```powershell
  git commit -m "feat: projeto inicial - Galeria de Artes Online"
  ```
- [ ] Verificar status
  ```powershell
  git status
  git log --oneline
  ```

### 1.3 Criar Repositório GitHub
- [ ] Acessar https://github.com/new
- [ ] Nome: `galeria-artes-azure` (ou outro nome)
- [ ] Visibilidade: Public ou Private (conforme preferir)
- [ ] NÃO inicializar com README, .gitignore ou license
- [ ] Criar repositório
- [ ] Copiar URL do repositório (será algo como: `https://github.com/SEU_USUARIO/galeria-artes-azure.git`)

### 1.4 Conectar ao GitHub
- [ ] Adicionar remote
  ```powershell
  git remote add origin https://github.com/SEU_USUARIO/galeria-artes-azure.git
  ```
- [ ] Verificar remote
  ```powershell
  git remote -v
  ```
- [ ] Push do código
  ```powershell
  git branch -M main
  git push -u origin main
  ```
- [ ] Verificar no GitHub que os arquivos subiram

---

## ☁️ Fase 2: Provisionamento Azure

### 2.1 Login no Azure
- [ ] Fazer login
  ```powershell
  az login
  ```
- [ ] Selecionar subscription (se tiver múltiplas)
  ```powershell
  az account list --output table
  az account set --subscription "SUBSCRIPTION_ID"
  ```
- [ ] Verificar subscription ativa
  ```powershell
  az account show
  ```

### 2.2 Executar Script de Provisionamento
- [ ] Navegar até scripts
  ```powershell
  cd scripts
  ```
- [ ] Executar script (15-20 minutos)
  ```powershell
  .\01-provision-azure.ps1
  ```
- [ ] **IMPORTANTE**: Anotar as informações exibidas ao final:
  - Resource Group Name
  - MySQL Server Name
  - MySQL Admin Password
  - Storage Account Name
  - Function App Name
  - Blob Container URL

### 2.3 Verificar Recursos Criados
- [ ] Listar recursos
  ```powershell
  az resource list --resource-group galeria-artes-rg --output table
  ```
- [ ] Verificar MySQL
  ```powershell
  az mysql flexible-server show --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME
  ```
- [ ] Verificar Storage
  ```powershell
  az storage account show --name STORAGE_ACCOUNT_NAME --resource-group galeria-artes-rg
  ```

---

## 🗄️ Fase 3: Configuração do Banco de Dados

### 3.1 Conectar ao MySQL
- [ ] Abrir novo terminal
- [ ] Executar comando (trocar pelos seus valores):
  ```powershell
  mysql -h MYSQL_SERVER_NAME.mysql.database.azure.com -u adminarte -p galeria_db
  ```
- [ ] Digitar a senha quando solicitado
- [ ] Verificar conexão bem-sucedida

### 3.2 Executar Script SQL
- [ ] Se conectou com sucesso, sair (digite `exit`)
- [ ] Executar script SQL:
  ```powershell
  mysql -h MYSQL_SERVER_NAME.mysql.database.azure.com -u adminarte -p galeria_db < .\02-setup-database.sql
  ```
- [ ] Digitar senha novamente

### 3.3 Verificar Dados
- [ ] Conectar novamente ao MySQL
  ```powershell
  mysql -h MYSQL_SERVER_NAME.mysql.database.azure.com -u adminarte -p galeria_db
  ```
- [ ] Executar comandos de verificação:
  ```sql
  SHOW TABLES;
  SELECT COUNT(*) FROM obras;
  SELECT nome, artista FROM obras LIMIT 3;
  exit
  ```
- [ ] Deve mostrar 12 obras cadastradas

---

## 🖼️ Fase 4: Upload de Imagens

### 4.1 Executar Script de Upload
- [ ] Voltar ao diretório scripts (se saiu)
  ```powershell
  cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD\scripts
  ```
- [ ] Executar script (5-10 minutos)
  ```powershell
  .\03-upload-images.ps1
  ```
- [ ] Verificar que 12 imagens foram baixadas e enviadas

### 4.2 Verificar Blob Storage
- [ ] Listar blobs
  ```powershell
  az storage blob list --account-name STORAGE_ACCOUNT_NAME --container-name obras --output table
  ```
- [ ] Deve mostrar 12 arquivos .jpg
- [ ] Testar acesso a uma imagem no navegador:
  ```
  https://STORAGE_ACCOUNT_NAME.blob.core.windows.net/obras/mona-lisa.jpg
  ```

---

## 🔧 Fase 5: Deploy do Backend

### 5.1 Preparar Backend Localmente
- [ ] Navegar até backend
  ```powershell
  cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD\backend
  ```
- [ ] Criar ambiente virtual Python
  ```powershell
  python -m venv venv
  .\venv\Scripts\Activate.ps1
  ```
- [ ] Instalar dependências
  ```powershell
  pip install -r requirements.txt
  ```

### 5.2 Testar Backend Localmente (Opcional)
- [ ] Copiar local.settings.json.example
  ```powershell
  cp local.settings.json.example local.settings.json
  ```
- [ ] Editar local.settings.json com credenciais reais
- [ ] Iniciar Function localmente
  ```powershell
  func start
  ```
- [ ] Testar endpoint: http://localhost:7071/api/obras
- [ ] Se funcionou, parar (Ctrl+C)

### 5.3 Deploy para Azure
- [ ] Deploy da Function
  ```powershell
  func azure functionapp publish FUNCTION_APP_NAME
  ```
- [ ] Aguardar conclusão (2-3 minutos)
- [ ] Anotar a URL da Function: `https://FUNCTION_APP_NAME.azurewebsites.net`

### 5.4 Testar Backend em Produção
- [ ] Testar health check:
  ```powershell
  curl https://FUNCTION_APP_NAME.azurewebsites.net/api/health
  ```
- [ ] Testar lista de obras:
  ```powershell
  curl https://FUNCTION_APP_NAME.azurewebsites.net/api/obras
  ```
- [ ] Deve retornar JSON com 12 obras

---

## 🎨 Fase 6: Deploy do Frontend

### 6.1 Preparar Frontend Localmente
- [ ] Navegar até frontend
  ```powershell
  cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD\frontend
  ```
- [ ] Instalar dependências
  ```powershell
  npm install
  ```
- [ ] Copiar .env.example
  ```powershell
  cp .env.example .env
  ```
- [ ] Editar .env com URL da Function:
  ```
  REACT_APP_API_URL=https://FUNCTION_APP_NAME.azurewebsites.net
  ```

### 6.2 Testar Frontend Localmente (Opcional)
- [ ] Iniciar dev server
  ```powershell
  npm start
  ```
- [ ] Abrir navegador em http://localhost:3000
- [ ] Verificar que as obras carregam com imagens
- [ ] Se funcionou, parar (Ctrl+C)

### 6.3 Build de Produção
- [ ] Criar build otimizado
  ```powershell
  npm run build
  ```
- [ ] Verificar pasta build/ criada
  ```powershell
  ls build
  ```

### 6.4 Deploy para Static Web App
- [ ] Criar Static Web App
  ```powershell
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
- [ ] Seguir instruções para autenticar com GitHub
- [ ] Aguardar provisionamento (3-5 minutos)

### 6.5 Obter URL do Frontend
- [ ] Listar Static Web Apps
  ```powershell
  az staticwebapp show --name galeria-artes-frontend --resource-group galeria-artes-rg --query "defaultHostname" --output tsv
  ```
- [ ] Anotar URL: `https://XXXXXXX.azurestaticapps.net`

---

## 🔐 Fase 7: Configurar GitHub Secrets

### 7.1 Obter Publish Profile do Backend
- [ ] Download do publish profile
  ```powershell
  az functionapp deployment list-publishing-profiles --name FUNCTION_APP_NAME --resource-group galeria-artes-rg --xml
  ```
- [ ] Copiar TODA a saída XML

### 7.2 Obter Token do Static Web App
- [ ] Listar deployment token
  ```powershell
  az staticwebapp secrets list --name galeria-artes-frontend --resource-group galeria-artes-rg --query "properties.apiKey" --output tsv
  ```
- [ ] Copiar o token

### 7.3 Adicionar Secrets no GitHub
- [ ] Acessar: `https://github.com/SEU_USUARIO/galeria-artes-azure/settings/secrets/actions`
- [ ] Clicar em "New repository secret"
- [ ] Criar secret `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`:
  - Name: `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`
  - Value: (colar XML do publish profile)
  - Clicar "Add secret"
- [ ] Criar secret `AZURE_STATIC_WEB_APPS_API_TOKEN`:
  - Name: `AZURE_STATIC_WEB_APPS_API_TOKEN`
  - Value: (colar token)
  - Clicar "Add secret"
- [ ] Criar secret `REACT_APP_API_URL`:
  - Name: `REACT_APP_API_URL`
  - Value: `https://FUNCTION_APP_NAME.azurewebsites.net`
  - Clicar "Add secret"

---

## 🤖 Fase 8: Ativar GitHub Actions

### 8.1 Verificar Workflows
- [ ] Acessar: `https://github.com/SEU_USUARIO/galeria-artes-azure/actions`
- [ ] Verificar que existem 2 workflows:
  - Backend Deploy
  - Frontend Deploy

### 8.2 Testar CI/CD
- [ ] Fazer pequena mudança no código (ex: README.md)
  ```powershell
  cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD
  echo "# Teste de CI/CD" >> README.md
  git add .
  git commit -m "test: verificar CI/CD"
  git push
  ```
- [ ] Acessar Actions no GitHub
- [ ] Verificar que workflows foram disparados
- [ ] Aguardar conclusão (verde = sucesso)

---

## ✅ Fase 9: Validação Final

### 9.1 Executar Script de Testes
- [ ] Navegar até scripts
  ```powershell
  cd c:\Users\bielm\Desktop\AS-PROJETOCLOUD\scripts
  ```
- [ ] Executar testes automatizados
  ```powershell
  .\04-test-application.ps1
  ```
- [ ] Verificar que todos os testes passam

### 9.2 Verificações Manuais

#### Backend
- [ ] Health check funciona: `https://FUNCTION_APP_NAME.azurewebsites.net/api/health`
- [ ] Lista obras funciona: `https://FUNCTION_APP_NAME.azurewebsites.net/api/obras`
- [ ] Retorna JSON válido com 12 obras
- [ ] Imagens têm URLs válidas

#### Frontend
- [ ] Acessar: `https://XXXXXXX.azurestaticapps.net`
- [ ] Página carrega sem erros
- [ ] 12 obras são exibidas
- [ ] Todas as imagens carregam
- [ ] Filtro por estilo funciona
- [ ] Layout responsivo funciona (testar mobile)

#### Banco de Dados
- [ ] Conexão funciona
- [ ] 12 obras estão cadastradas
- [ ] Dados estão corretos

#### Blob Storage
- [ ] 12 imagens estão no container
- [ ] Imagens são públicas e acessíveis
- [ ] URLs funcionam no navegador

---

## 📊 Fase 10: Documentação dos URLs

### 10.1 Anotar Todos os URLs
- [ ] **Frontend**: `https://XXXXXXX.azurestaticapps.net`
- [ ] **Backend API**: `https://FUNCTION_APP_NAME.azurewebsites.net`
- [ ] **Health Check**: `https://FUNCTION_APP_NAME.azurewebsites.net/api/health`
- [ ] **API Obras**: `https://FUNCTION_APP_NAME.azurewebsites.net/api/obras`
- [ ] **Blob Container**: `https://STORAGE_ACCOUNT_NAME.blob.core.windows.net/obras`
- [ ] **GitHub Repo**: `https://github.com/SEU_USUARIO/galeria-artes-azure`

### 10.2 Criar Arquivo de URLs
- [ ] Criar arquivo `DEPLOYED_URLS.txt` na raiz do projeto com todos os URLs
- [ ] Commit e push
  ```powershell
  git add DEPLOYED_URLS.txt
  git commit -m "docs: adicionar URLs de produção"
  git push
  ```

---

## 🎓 Fase 11: Checklist dos Requisitos do Professor

### Requisitos Funcionais
- [ ] ✅ Aplicação hospedada na nuvem Azure
- [ ] ✅ Backend Azure Function em Python
- [ ] ✅ Banco de dados MySQL no Azure
- [ ] ✅ 10+ obras cadastradas (temos 12)
- [ ] ✅ Imagens no Blob Storage
- [ ] ✅ Frontend React consumindo API
- [ ] ✅ Frontend em Static Web App
- [ ] ✅ URLs públicas e acessíveis

### Requisitos Técnicos
- [ ] ✅ Infraestrutura como código (scripts PowerShell)
- [ ] ✅ Deploy automatizado via GitHub Actions
- [ ] ✅ Documentação completa em português
- [ ] ✅ Código versionado no GitHub
- [ ] ✅ Arquitetura escalável

### Requisitos de Entrega
- [ ] ✅ Código fonte no GitHub
- [ ] ✅ README com instruções
- [ ] ✅ Aplicação funcionando online
- [ ] ✅ URLs documentadas
- [ ] ✅ Possibilidade de testes pelos avaliadores

---

## 🐛 Troubleshooting Rápido

### Problema: MySQL não conecta
- [ ] Verificar firewall rules
  ```powershell
  az mysql flexible-server firewall-rule list --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME
  ```
- [ ] Adicionar seu IP se necessário
  ```powershell
  az mysql flexible-server firewall-rule create --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME --rule-name AllowMyIP --start-ip-address SEU_IP --end-ip-address SEU_IP
  ```

### Problema: Imagens não carregam
- [ ] Verificar CORS no Storage Account
  ```powershell
  az storage cors list --account-name STORAGE_ACCOUNT_NAME --services b
  ```
- [ ] Verificar se container é público
  ```powershell
  az storage container show --name obras --account-name STORAGE_ACCOUNT_NAME
  ```

### Problema: Backend retorna erro 500
- [ ] Ver logs da Function
  ```powershell
  az functionapp log tail --name FUNCTION_APP_NAME --resource-group galeria-artes-rg
  ```
- [ ] Verificar Application Settings
  ```powershell
  az functionapp config appsettings list --name FUNCTION_APP_NAME --resource-group galeria-artes-rg
  ```

### Problema: Frontend não carrega obras
- [ ] Verificar console do navegador (F12)
- [ ] Verificar Network tab para erros CORS
- [ ] Confirmar que REACT_APP_API_URL está correto no .env

---

## 📝 Notas Finais

### O que Fazer Após Deploy
- [ ] Tirar screenshots da aplicação funcionando
- [ ] Documentar os URLs em um arquivo separado
- [ ] Testar todos os endpoints
- [ ] Verificar custos no Azure Portal
- [ ] Monitorar Application Insights (se habilitado)

### Custos Estimados
- Azure Function (Consumption): ~R$ 0-5/mês
- MySQL Flexible Server (B1ms): ~R$ 50-80/mês
- Blob Storage (Standard): ~R$ 1-5/mês
- Static Web App (Free): R$ 0/mês
- **Total estimado**: ~R$ 50-90/mês

### Como Economizar
- [ ] Usar tier gratuito quando possível
- [ ] Parar recursos quando não estiver usando
- [ ] Excluir Resource Group após apresentação (se for apenas para a disciplina)
  ```powershell
  az group delete --name galeria-artes-rg --yes --no-wait
  ```

---

## ✅ Conclusão

Ao completar todos os checkboxes acima, você terá:

1. ✅ Projeto completo no GitHub
2. ✅ Infraestrutura provisionada no Azure
3. ✅ Backend funcionando com API REST
4. ✅ Frontend responsivo e moderno
5. ✅ Banco de dados populado
6. ✅ Imagens armazenadas e acessíveis
7. ✅ CI/CD configurado
8. ✅ URLs públicas funcionando
9. ✅ Documentação completa
10. ✅ Todos os requisitos atendidos

**🎉 Parabéns! Sua Galeria de Artes está online! 🎨**

---

**📌 Dica Final**: Salve este checklist preenchido como evidência do processo de deploy!
