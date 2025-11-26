# Azure Function - Galeria de Artes Backend

Backend da Galeria de Artes Online usando Azure Functions com Python.

## 🚀 Estrutura da API

### Endpoints Disponíveis

- **GET** `/api/obras` - Lista todas as obras
- **GET** `/api/obras/{id}` - Obtém obra específica por ID
- **GET** `/api/obras/artista/{artista}` - Busca obras por artista
- **GET** `/api/obras/estilo/{estilo}` - Busca obras por estilo
- **GET** `/api/health` - Health check da API

### Exemplo de Resposta JSON

```json
[
  {
    "id": 1,
    "nome": "Mona Lisa",
    "artista": "Leonardo da Vinci",
    "descricao": "Pintura a óleo sobre madeira...",
    "ano": 1503,
    "imagem": "https://storage.blob.core.windows.net/obras/monalisa.jpg",
    "estilo": "Renascimento"
  }
]
```

## 🔧 Desenvolvimento Local

### Pré-requisitos

- Python 3.9+
- Azure Functions Core Tools
- MySQL local ou Azure MySQL

### Configuração

1. Instalar dependências:
```powershell
pip install -r requirements.txt
```

2. Configurar `local.settings.json` com suas credenciais

3. Executar localmente:
```powershell
func start
```

4. Testar endpoint:
```powershell
curl http://localhost:7071/api/obras
```

## 📦 Deploy para Azure

### Método 1: Azure Functions Core Tools

```powershell
# Fazer login
az login

# Deploy
func azure functionapp publish SEU_FUNCTION_APP_NAME
```

### Método 2: GitHub Actions (Recomendado)

O deploy será automático ao fazer push para a branch `main`.

## 🔒 Variáveis de Ambiente

Configure no Azure Function App Settings:

- `MYSQL_HOST` - Host do MySQL
- `MYSQL_USER` - Usuário do banco
- `MYSQL_PASSWORD` - Senha do banco
- `MYSQL_DATABASE` - Nome do banco
- `MYSQL_PORT` - Porta (padrão: 3306)
- `STORAGE_ACCOUNT_NAME` - Nome da Storage Account
- `CONTAINER_NAME` - Nome do container de imagens

### Comando para configurar via CLI:

```powershell
az functionapp config appsettings set `
  --name SEU_FUNCTION_APP `
  --resource-group SEU_RESOURCE_GROUP `
  --settings `
    "MYSQL_HOST=mysql-server.mysql.database.azure.com" `
    "MYSQL_USER=adminarte" `
    "MYSQL_PASSWORD=SuaSenha@Segura123" `
    "MYSQL_DATABASE=galeria_db" `
    "MYSQL_PORT=3306"
```

## 🧪 Testes

```powershell
# Testar health check
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/health

# Listar obras
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/obras

# Obra específica
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/obras/1

# Por artista
curl https://SEU_FUNCTION_APP.azurewebsites.net/api/obras/artista/Picasso
```

## 📚 Documentação

- [Azure Functions Python](https://docs.microsoft.com/azure/azure-functions/functions-reference-python)
- [PyMySQL Documentation](https://pymysql.readthedocs.io/)
