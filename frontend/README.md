# Frontend - Galeria de Artes Online

Frontend React para a Galeria de Artes Online hospedado em Azure Static Web Apps.

## 🚀 Características

- Interface responsiva e moderna
- Filtros por estilo artístico
- Cards interativos com animações
- Loading states e tratamento de erros
- Otimizado para Azure Static Web Apps

## 🔧 Desenvolvimento Local

### Instalar dependências:

```powershell
npm install
```

### Configurar variável de ambiente:

Crie um arquivo `.env` na raiz do frontend:

```
REACT_APP_API_URL=https://SEU_FUNCTION_APP.azurewebsites.net/api
```

### Executar em modo desenvolvimento:

```powershell
npm start
```

Acesse: http://localhost:3000

### Build para produção:

```powershell
npm run build
```

## 📦 Deploy para Azure

### Método 1: Azure Static Web Apps (Recomendado)

O deploy é automático via GitHub Actions quando você criar o Static Web App:

```powershell
az staticwebapp create \
  --name stapp-galeria-artes \
  --resource-group rg-galeria-artes \
  --source https://github.com/SEU-USUARIO/galeria-artes \
  --branch main \
  --app-location "/frontend" \
  --output-location "build"
```

### Método 2: Manual via Azure CLI

```powershell
# Build
npm run build

# Deploy
az staticwebapp deploy \
  --name stapp-galeria-artes \
  --resource-group rg-galeria-artes \
  --app-location "./build"
```

## 🎨 Componentes

- **App.js** - Componente principal com lógica de estado
- **Header** - Cabeçalho da aplicação
- **GaleriaObras** - Grid de obras
- **CardObra** - Card individual de cada obra
- **Loading** - Indicador de carregamento
- **ErrorMessage** - Mensagem de erro com retry

## 🔗 API Integration

O frontend consome os seguintes endpoints:

- `GET /api/obras` - Lista todas as obras
- `GET /api/obras/{id}` - Obra específica
- `GET /api/obras/artista/{artista}` - Filtrar por artista
- `GET /api/obras/estilo/{estilo}` - Filtrar por estilo

## 📱 Responsividade

- Desktop: Grid de 3+ colunas
- Tablet: Grid de 2 colunas
- Mobile: Grid de 1 coluna

## 🌐 Variáveis de Ambiente

- `REACT_APP_API_URL` - URL da Azure Function API
