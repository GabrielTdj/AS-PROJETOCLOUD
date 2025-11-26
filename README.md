# 🎨 Galeria de Artes Online - Azure Cloud

Aplicação completa de galeria de artes usando Azure Functions, MySQL, Blob Storage e React.

## 📋 Arquitetura

- **Backend**: Azure Function Python (HTTP Trigger)
- **Banco de Dados**: Azure Database for MySQL Flexible Server
- **Armazenamento**: Azure Blob Storage (container "obras")
- **Frontend**: React hospedado em Azure Static Web Apps
- **CI/CD**: GitHub Actions (automação completa)

## 🚀 Quick Start

```powershell
# 1. Login no Azure
az login

# 2. Provisionar recursos (15-20 min)
.\scripts\01-provision-azure.ps1

# 3. Configurar banco de dados
.\scripts\02-setup-database.sql

# 4. Upload de imagens
.\scripts\03-upload-images.ps1

# 5. Deploy completo
# Ver guia detalhado: DEPLOY_GUIDE.md
```

## 📖 Documentação Completa

- **[🚀 Quick Start Guide](QUICKSTART.md)** - Comece em 5 passos
- **[📚 Deploy Guide Completo](DEPLOY_GUIDE.md)** - Guia passo a passo detalhado
- **[🏗️ Arquitetura](ARQUITETURA.md)** - Diagrama e explicação da arquitetura
- **[🎓 Requisitos do Professor](REQUISITOS_PROFESSOR.md)** - Como atende cada requisito
- **[🔐 Configurar Secrets](.github/SECRETS_SETUP.md)** - GitHub Actions secrets

## ⚡ Features Principais

### Backend (Azure Function Python)
- ✅ HTTP Trigger com múltiplos endpoints
- ✅ Conexão segura com MySQL
- ✅ CORS configurado
- ✅ Health check endpoint
- ✅ Filtros por artista e estilo

### Frontend (React)
- ✅ Design moderno e responsivo
- ✅ Cards interativos com animações
- ✅ Filtros por estilo artístico
- ✅ Loading states e error handling
- ✅ Otimizado para performance

### DevOps
- ✅ CI/CD com GitHub Actions
- ✅ Deploy automático
- ✅ Scripts de provisionamento
- ✅ Testes automatizados
- ✅ Documentação completa

## 📁 Estrutura do Projeto

```
AS-PROJETOCLOUD/
├── backend/                    # Azure Function Python
│   ├── function_app.py        # HTTP Trigger principal
│   ├── requirements.txt       # Dependências Python
│   └── host.json             # Configuração Function
├── frontend/                  # React App
│   ├── src/
│   │   ├── App.js            # Componente principal
│   │   └── components/       # Componentes da galeria
│   └── package.json
├── scripts/                   # Scripts de automação
│   ├── 01-provision-azure.ps1
│   ├── 02-setup-database.sql
│   └── 03-upload-images.ps1
├── .github/
│   └── workflows/            # GitHub Actions
│       ├── backend-deploy.yml
│       └── frontend-deploy.yml
└── .env.example              # Exemplo de variáveis
```

## 🔒 Segurança

- Connection strings armazenadas em Application Settings
- Secrets no GitHub (não expor no código)
- CORS configurado apenas para domínio do frontend

## 🧪 Testar a Aplicação

```powershell
# Executar suite de testes completa
.\scripts\04-test-application.ps1 -FunctionAppUrl "https://SEU_FUNCTION_APP.azurewebsites.net"

# Testes manuais
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/health
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/obras
```

## 📊 Endpoints da API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/obras` | Lista todas as obras |
| GET | `/api/obras/{id}` | Obra específica por ID |
| GET | `/api/obras/artista/{artista}` | Filtrar por artista |
| GET | `/api/obras/estilo/{estilo}` | Filtrar por estilo |
| GET | `/api/health` | Health check |

## 🎨 Screenshots

```
┌─────────────────────────────────────────┐
│  🎨 Galeria de Artes Online            │
│  Explore obras-primas da história      │
├─────────────────────────────────────────┤
│  [Todos os Estilos ▼]    12 obras      │
├─────────────────────────────────────────┤
│  ┌───────┐  ┌───────┐  ┌───────┐      │
│  │Mona   │  │Noite  │  │Grito  │      │
│  │Lisa   │  │Estrel.│  │       │      │
│  └───────┘  └───────┘  └───────┘      │
│  Leonardo    Van Gogh    Munch         │
└─────────────────────────────────────────┘
```

## 🛠️ Tecnologias Utilizadas

### Backend
- Python 3.9
- Azure Functions v4
- PyMySQL
- Azure Database for MySQL Flexible Server

### Frontend
- React 18
- Axios
- CSS3 (Flexbox/Grid)
- Azure Static Web Apps

### DevOps & Cloud
- Azure CLI
- GitHub Actions
- Azure Blob Storage
- PowerShell Scripts

## 🤝 Contribuindo

Este é um projeto acadêmico, mas sugestões são bem-vindas!

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais.

## 👨‍🎓 Autor

Desenvolvido como projeto da disciplina de Cloud Computing.

## 📚 Links Úteis

- [Documentação Azure Functions](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps/)
- [Azure MySQL Flexible Server](https://docs.microsoft.com/azure/mysql/flexible-server/)
- [React Documentation](https://react.dev/)
- [GitHub Actions](https://docs.github.com/actions)

---

**⭐ Se este projeto foi útil, deixe uma estrela no GitHub!**
