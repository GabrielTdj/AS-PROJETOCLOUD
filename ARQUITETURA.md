# 🏗️ Arquitetura da Galeria de Artes Online

## Diagrama de Arquitetura Completo

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         USUÁRIO / NAVEGADOR                              │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 │ HTTPS
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      AZURE STATIC WEB APPS                               │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    FRONTEND - REACT                               │   │
│  │  • App.js (Componente Principal)                                 │   │
│  │  • GaleriaObras (Grid de Obras)                                  │   │
│  │  • CardObra (Card Individual)                                    │   │
│  │  • Axios (Cliente HTTP)                                          │   │
│  │  • Filtros por Estilo                                            │   │
│  │                                                                   │   │
│  │  📦 Build: npm run build                                         │   │
│  │  🚀 Deploy: GitHub Actions                                       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 │ REST API (HTTPS)
                                 │ GET /api/obras
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        AZURE FUNCTION APP                                │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                   BACKEND - PYTHON 3.9                            │   │
│  │                                                                   │   │
│  │  Endpoints HTTP Trigger:                                         │   │
│  │  • GET /api/obras              → Lista todas obras               │   │
│  │  • GET /api/obras/{id}         → Obra específica                 │   │
│  │  • GET /api/obras/artista/...  → Filtrar por artista            │   │
│  │  • GET /api/obras/estilo/...   → Filtrar por estilo             │   │
│  │  • GET /api/health             → Health check                    │   │
│  │                                                                   │   │
│  │  📚 Bibliotecas:                                                 │   │
│  │  • azure-functions                                               │   │
│  │  • pymysql (conexão MySQL)                                       │   │
│  │                                                                   │   │
│  │  🔒 Secrets (Application Settings):                             │   │
│  │  • MYSQL_HOST                                                    │   │
│  │  • MYSQL_USER, MYSQL_PASSWORD                                    │   │
│  │  • MYSQL_DATABASE                                                │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└────────────┬─────────────────────────────────────────┬──────────────────┘
             │                                         │
             │ SQL Query                               │ Blob URL Reference
             │ (PyMySQL)                               │
             ▼                                         ▼
┌─────────────────────────────────┐  ┌─────────────────────────────────────┐
│ AZURE DATABASE FOR MYSQL        │  │   AZURE BLOB STORAGE                │
│ (Flexible Server)               │  │   (Standard_LRS)                    │
│                                 │  │                                     │
│  Database: galeria_db           │  │   Container: obras                  │
│                                 │  │   (Public Blob Access)              │
│  Tabela: obras                  │  │                                     │
│  ┌──────────────────────────┐   │  │   📁 Imagens:                      │
│  │ id (INT PK)             │   │  │   • monalisa.jpg                   │
│  │ nome (VARCHAR)          │   │  │   • noite-estrelada.jpg            │
│  │ artista (VARCHAR)       │   │  │   • o-grito.jpg                    │
│  │ descricao (TEXT)        │   │  │   • guernica.jpg                   │
│  │ ano_criacao (INT)       │   │  │   • persistencia-memoria.jpg       │
│  │ url_imagem (VARCHAR)────┼───┼──┼─► • criacao-adao.jpg               │
│  │ estilo (VARCHAR)        │   │  │   • moca-perola.jpg                │
│  │ data_cadastro (TIMESTAMP)   │  │   • o-beijo.jpg                    │
│  └──────────────────────────┘   │  │   • abaporu.jpg                    │
│                                 │  │   • almoco-relva.jpg               │
│  📊 12 obras cadastradas        │  │   • as-meninas.jpg                 │
│                                 │  │   • nenufares.jpg                  │
│  🔐 Firewall: Azure Services    │  │                                     │
│  🔑 SSL/TLS habilitado          │  │  🌐 URL Público:                   │
└─────────────────────────────────┘  │  https://storage.blob.core.        │
                                     │  windows.net/obras/*.jpg           │
                                     └─────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                           GITHUB ACTIONS (CI/CD)                         │
│                                                                          │
│  Workflow: backend-deploy.yml         Workflow: frontend-deploy.yml    │
│  ┌──────────────────────────────┐     ┌──────────────────────────────┐ │
│  │ Trigger: push em backend/**  │     │ Trigger: push em frontend/** │ │
│  │                              │     │                              │ │
│  │ Steps:                       │     │ Steps:                       │ │
│  │ 1. Checkout                  │     │ 1. Checkout                  │ │
│  │ 2. Setup Python 3.9          │     │ 2. Setup Node.js 18          │ │
│  │ 3. Install dependencies      │     │ 3. npm install               │ │
│  │ 4. Deploy to Function App    │     │ 4. npm build                 │ │
│  │                              │     │ 5. Deploy to Static Web App  │ │
│  │ Secret:                      │     │                              │ │
│  │ AZURE_FUNCTIONAPP_          │     │ Secret:                      │ │
│  │   PUBLISH_PROFILE            │     │ AZURE_STATIC_WEB_APPS_      │ │
│  │                              │     │   API_TOKEN                  │ │
│  └──────────────────────────────┘     └──────────────────────────────┘ │
│                                                                          │
│  📁 Repositório: github.com/USUARIO/AS-PROJETOCLOUD                     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Dados

### Fluxo de Requisição (Runtime)

```
┌──────┐    ①      ┌────────────┐    ②      ┌──────────┐    ③    ┌───────┐
│      ├──────────►│            ├──────────►│          ├────────►│       │
│ USER │  GET /    │   STATIC   │ GET /api/ │ FUNCTION │  SQL    │ MYSQL │
│      │           │  WEB APP   │   obras   │   APP    │  Query  │   DB  │
│      │◄──────────┤            │◄──────────┤          │◄────────┤       │
└──────┘    ⑥      └────────────┘    ⑤      └──────────┘    ④    └───────┘
  HTML +               JSON                     Rows
  CSS +                [{obra1},                {id, nome,
  JS                   {obra2}]                 artista...}

                                    ┌──────────────┐
                                    │              │
                               ⑦───│ BLOB STORAGE │
                                    │              │
                                    └──────────────┘
                                    Imagens (.jpg)
```

**Legenda do Fluxo:**
1. Usuário acessa Static Web App
2. Frontend React faz requisição para Function API
3. Function consulta MySQL para obter dados das obras
4. MySQL retorna linhas da tabela `obras`
5. Function formata e retorna JSON
6. Frontend renderiza cards com dados
7. Browser carrega imagens direto do Blob Storage

---

## 🛠️ Fluxo de Deploy (CI/CD)

```
┌─────────┐
│ DEV     │
│ (Local) │
└────┬────┘
     │
     │ git push
     │
     ▼
┌─────────────┐
│  GITHUB     │
│  Repository │
└──────┬──────┘
       │
       │ Trigger Workflows
       │
       ├───────────────┬────────────────┐
       │               │                │
       ▼               ▼                ▼
┌────────────┐  ┌────────────┐  ┌────────────┐
│ Backend    │  │ Frontend   │  │ Changes    │
│ Workflow   │  │ Workflow   │  │ Detection  │
└─────┬──────┘  └─────┬──────┘  └────────────┘
      │               │
      │ Build + Test  │ Build + Test
      │               │
      ▼               ▼
┌────────────┐  ┌────────────┐
│ Deploy to  │  │ Deploy to  │
│ Function   │  │ Static Web │
│ App        │  │ App        │
└────────────┘  └────────────┘
```

---

## 📦 Estrutura de Recursos Azure

```
Resource Group: rg-galeria-artes
├── 🗄️ Azure Database for MySQL Flexible Server
│   ├── Server: mysql-galeria-artes-XXXX
│   ├── Database: galeria_db
│   ├── SKU: Standard_B1ms (Burstable)
│   ├── Storage: 32GB
│   └── Version: 8.0.21
│
├── 💾 Storage Account
│   ├── Name: stgaleriaXXXXX
│   ├── Type: Standard_LRS
│   ├── Container: obras
│   │   ├── Access: Public Blob
│   │   └── Files: 12 imagens .jpg
│   └── Services: Blob Storage
│
├── 📱 App Service Plan
│   ├── Name: plan-galeria-artes
│   ├── OS: Linux
│   ├── SKU: B1 (Basic)
│   └── Region: East US
│
├── ⚡ Function App
│   ├── Name: func-galeria-artes-XXXX
│   ├── Runtime: Python 3.9
│   ├── Functions Version: 4
│   ├── Storage: Linked to Storage Account
│   └── App Settings:
│       ├── MYSQL_HOST
│       ├── MYSQL_USER
│       ├── MYSQL_PASSWORD
│       └── MYSQL_DATABASE
│
└── 🌐 Static Web App
    ├── Name: stapp-galeria-artes
    ├── Framework: React
    ├── Build Location: /frontend
    ├── Output Location: build
    └── Custom Domain: Available
```

---

## 🔐 Segurança e Configuração

### Variáveis de Ambiente (Não expostas no código)

**Backend (Function App Settings):**
```
MYSQL_HOST=mysql-server.mysql.database.azure.com
MYSQL_USER=adminarte
MYSQL_PASSWORD=***SECRET***
MYSQL_DATABASE=galeria_db
MYSQL_PORT=3306
```

**Frontend (.env - Build time):**
```
REACT_APP_API_URL=https://func-galeria-artes.azurewebsites.net/api
```

**GitHub Secrets:**
```
AZURE_FUNCTIONAPP_PUBLISH_PROFILE=***XML***
AZURE_STATIC_WEB_APPS_API_TOKEN=***TOKEN***
REACT_APP_API_URL=***URL***
```

---

## 🌐 CORS Configuration

```
Function App CORS:
├── Allowed Origins: *
├── Allow Credentials: false
└── Max Age: 3600s

Static Web App:
└── Custom Headers: Configured via workflow
```

---

## 📊 Custos Estimados (Mensais)

```
Recurso                      | SKU/Tier        | Custo Estimado
─────────────────────────────┼─────────────────┼────────────────
MySQL Flexible Server        | Standard_B1ms   | ~$13 USD
Storage Account (Blob)       | Standard_LRS    | ~$0.50 USD
App Service Plan             | B1 Basic        | ~$13 USD
Function App                 | Consumption     | Free tier
Static Web App               | Free            | $0 USD
─────────────────────────────┴─────────────────┴────────────────
TOTAL ESTIMADO                                 | ~$26.50 USD/mês

💡 Dica: Use tier gratuito/estudante para desenvolvimento
```

---

## 🚀 Escalabilidade

### Vertical (Scale Up)
- **MySQL:** Aumentar SKU para General Purpose
- **App Service Plan:** Aumentar para S1/P1V2
- **Function App:** Mudar para Premium Plan

### Horizontal (Scale Out)
- **Function App:** Auto-scale baseado em demanda
- **Static Web App:** CDN global automático
- **MySQL:** Read Replicas para leitura

---

## 📈 Monitoramento

```
Application Insights
├── Request Telemetry
├── Dependency Tracking
├── Exception Logging
└── Custom Metrics

Metrics Disponíveis:
├── Function Execution Count
├── Function Execution Time
├── MySQL Connections
├── Blob Storage Requests
└── Static Web App Hits
```

---

## 🔄 Disaster Recovery

```
Backup Strategy:
├── MySQL: Automated Backups (7 days retention)
├── Blob Storage: Soft Delete enabled
├── Code: GitHub Repository
└── Infrastructure: Documented in scripts
```

---

Esta arquitetura foi projetada para ser:
- ✅ Escalável
- ✅ Segura
- ✅ De baixo custo
- ✅ Fácil de manter
- ✅ Totalmente automatizada
