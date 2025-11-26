# FAQ - Perguntas Frequentes 🤔

## 📚 Índice
- [Geral](#geral)
- [Azure](#azure)
- [Backend](#backend)
- [Frontend](#frontend)
- [Banco de Dados](#banco-de-dados)
- [Blob Storage](#blob-storage)
- [Deploy e CI/CD](#deploy-e-cicd)
- [Custos](#custos)
- [Troubleshooting](#troubleshooting)

---

## Geral

### ❓ Posso usar este projeto para minha disciplina/trabalho acadêmico?

**Sim!** Este projeto foi criado especificamente para fins educacionais. Você pode:
- Usar como está
- Modificar conforme necessário
- Adicionar features extras
- Usar como base para aprendizado

**Recomendações**:
- Entenda o código antes de apresentar
- Personalize com suas próprias obras/tema
- Adicione funcionalidades únicas
- Documente suas mudanças

### ❓ Preciso ter conhecimento prévio em Azure?

**Não é obrigatório**, mas ajuda. O projeto foi criado para ser:
- Completamente automatizado via scripts
- Documentado passo a passo
- Com comandos prontos para copiar e colar
- Explicações detalhadas em português

**Tempo estimado de aprendizado**: 2-4 horas para entender o básico.

### ❓ Quanto tempo leva para fazer o deploy completo?

| Fase | Tempo Estimado |
|------|----------------|
| Preparação local | 15-30 min |
| Provisionamento Azure | 15-20 min |
| Setup banco de dados | 5-10 min |
| Upload de imagens | 5-10 min |
| Deploy backend | 3-5 min |
| Deploy frontend | 5-10 min |
| Configurar CI/CD | 10-15 min |
| Testes e validação | 10-15 min |
| **TOTAL** | **60-120 min** |

**Dica**: Use o script `run-all.ps1` para automatizar tudo (~30-45 min).

### ❓ Posso usar outro tema além de "obras de arte"?

**Sim!** O projeto é facilmente adaptável para:
- **Restaurante**: cardápio com pratos
- **E-commerce**: catálogo de produtos
- **Portfólio**: projetos pessoais
- **Blog**: artigos/posts
- **Imobiliária**: imóveis
- **Biblioteca**: livros

**O que precisa mudar**:
1. Renomear tabela `obras` → `produtos`, `receitas`, etc.
2. Ajustar campos do banco de dados
3. Trocar imagens no Blob Storage
4. Atualizar textos do frontend
5. Modificar estilos CSS se desejar

---

## Azure

### ❓ Preciso de cartão de crédito para usar o Azure?

**Depende do tipo de conta**:

- ✅ **Azure for Students**: NÃO precisa de cartão (US$ 100 em créditos grátis)
- ✅ **Free Trial**: Precisa, mas não cobra por 30 dias (US$ 200 em créditos)
- ❌ **Pay-As-You-Go**: Precisa e cobra conforme uso

**Recomendação**: Use Azure for Students se for elegível.

### ❓ Quais recursos do Azure são usados?

| Recurso | Finalidade | Tier/SKU |
|---------|-----------|----------|
| Azure Function | Backend API | Consumption (serverless) |
| MySQL Flexible Server | Banco de dados | Standard_B1ms |
| Storage Account | Armazenar imagens | Standard_LRS |
| Static Web App | Hospedar React | Free |
| App Service Plan | Infra para Function | B1 (Basic) |

### ❓ Posso usar o Free Tier do Azure?

**Parcialmente**. Alguns serviços têm free tier:
- ✅ Azure Functions: 1 milhão de execuções/mês grátis
- ✅ Static Web Apps: Tier Free (100 GB bandwidth/mês)
- ❌ MySQL Flexible Server: NÃO tem tier totalmente free
- ✅ Blob Storage: Primeiros 5 GB grátis

**Custo inevitável**: MySQL (~R$ 50-80/mês no Brasil).

**Alternativa econômica**: 
- Usar MySQL containerizado no Azure Container Instances (~R$ 30/mês)
- Ou Azure Database for PostgreSQL (tem mais opções baratas)

### ❓ Como vejo quanto estou gastando no Azure?

```powershell
# Ver custos acumulados no mês
az consumption usage list --start-date 2024-11-01 --end-date 2024-11-30 --query "[?instanceName=='galeria-artes-rg']" --output table

# Configurar alertas de custo
az monitor metrics alert create --name CustoAlto --resource-group galeria-artes-rg --condition "total budget > 100"
```

**Dica**: Configure alertas de custo no Azure Portal → Cost Management.

### ❓ Como deletar tudo depois de usar?

**Opção 1: Deletar Resource Group** (recomendado)
```powershell
# Deleta TUDO de uma vez
az group delete --name galeria-artes-rg --yes --no-wait
```

**Opção 2: Deletar recursos individualmente**
```powershell
az functionapp delete --name FUNCTION_APP_NAME --resource-group galeria-artes-rg
az mysql flexible-server delete --name MYSQL_SERVER_NAME --resource-group galeria-artes-rg --yes
az storage account delete --name STORAGE_ACCOUNT_NAME --resource-group galeria-artes-rg --yes
az staticwebapp delete --name galeria-artes-frontend --resource-group galeria-artes-rg --yes
```

---

## Backend

### ❓ Por que usar Azure Functions ao invés de VM ou App Service?

**Vantagens do Azure Functions**:
- ✅ **Serverless**: Não precisa gerenciar servidor
- ✅ **Auto-scaling**: Escala automaticamente
- ✅ **Pay-per-execution**: Paga só quando usa
- ✅ **Integração nativa** com outros serviços Azure
- ✅ **Fácil deploy** via GitHub Actions

**Quando usar VM/App Service**:
- Aplicação que roda 24/7 com tráfego constante
- Precisa de controle total do ambiente
- Usa frameworks que não funcionam bem serverless

### ❓ Posso usar outra linguagem no backend?

**Sim!** Azure Functions suporta:
- JavaScript/TypeScript (Node.js)
- Python
- C#
- Java
- PowerShell
- Go (via custom handler)

**Para trocar para Node.js**, por exemplo:
1. Criar nova Function em JavaScript
2. Ajustar dependencies (package.json ao invés de requirements.txt)
3. Reescrever lógica de conexão MySQL (usar mysql2 ou sequelize)
4. Ajustar workflow do GitHub Actions

### ❓ Como adicionar novos endpoints na API?

**No arquivo `backend/function_app.py`**:

```python
@app.route(route="obras/recentes", methods=["GET"])
def obras_recentes(req: func.HttpRequest) -> func.HttpResponse:
    try:
        connection = get_db_connection()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        cursor.execute(
            "SELECT * FROM obras ORDER BY data_cadastro DESC LIMIT 5"
        )
        
        obras = cursor.fetchall()
        return func.HttpResponse(
            json.dumps(obras, default=str, ensure_ascii=False),
            mimetype="application/json",
            status_code=200
        )
    except Exception as e:
        return func.HttpResponse(
            json.dumps({"error": str(e)}),
            status_code=500
        )
    finally:
        cursor.close()
        connection.close()
```

Depois, fazer commit e push (GitHub Actions faz deploy automático).

### ❓ Como debugar a Azure Function localmente?

1. Instalar Azure Functions Core Tools:
   ```powershell
   npm install -g azure-functions-core-tools@4
   ```

2. Configurar `local.settings.json` com suas credenciais

3. Iniciar localmente:
   ```powershell
   cd backend
   func start
   ```

4. Testar endpoints em http://localhost:7071

5. Ver logs em tempo real no terminal

**VS Code**: Use a extensão "Azure Functions" com breakpoints.

---

## Frontend

### ❓ Posso usar Vue.js ou Angular ao invés de React?

**Sim!** Azure Static Web Apps suporta:
- React
- Vue.js
- Angular
- Svelte
- Next.js
- Gatsby
- Hugo (site estático)

**Para trocar para Vue.js**:
1. Substituir código em `frontend/` por app Vue
2. Ajustar `app-location` e `output-location` no workflow
3. Manter chamadas à API do backend

### ❓ Como adicionar autenticação de usuários?

**Opção 1: Azure AD B2C** (recomendado)
```javascript
// Instalar
npm install @azure/msal-react @azure/msal-browser

// Configurar
import { MsalProvider } from '@azure/msal-react';
```

**Opção 2: Azure Static Web Apps Authentication** (mais fácil)
- Suporta GitHub, Twitter, Google, Azure AD
- Configuração via Azure Portal
- Endpoints automáticos: `/.auth/login/github`

**Opção 3: Custom (JWT)**
- Implementar no backend
- Usar bibliotecas como PyJWT
- Armazenar tokens no localStorage

### ❓ Como adicionar funcionalidade de busca?

**No Frontend (`App.js`)**:
```javascript
const [termoBusca, setTermoBusca] = useState('');

const filtrarObras = () => {
  return obras.filter(obra => {
    const matchEstilo = filtroEstilo === '' || obra.estilo === filtroEstilo;
    const matchBusca = termoBusca === '' || 
                       obra.nome.toLowerCase().includes(termoBusca.toLowerCase()) ||
                       obra.artista.toLowerCase().includes(termoBusca.toLowerCase());
    return matchEstilo && matchBusca;
  });
};

// No JSX
<input 
  type="text" 
  placeholder="Buscar obra ou artista..."
  value={termoBusca}
  onChange={(e) => setTermoBusca(e.target.value)}
/>
```

**No Backend (busca no servidor)**:
```python
@app.route(route="obras/busca", methods=["GET"])
def buscar_obras(req: func.HttpRequest) -> func.HttpResponse:
    termo = req.params.get('q', '')
    cursor.execute(
        "SELECT * FROM obras WHERE nome LIKE %s OR artista LIKE %s",
        (f'%{termo}%', f'%{termo}%')
    )
```

### ❓ O design do frontend pode ser melhorado?

**Sim!** Algumas ideias:

**1. Usar biblioteca de componentes**:
- Material-UI: `npm install @mui/material @emotion/react @emotion/styled`
- Ant Design: `npm install antd`
- Chakra UI: `npm install @chakra-ui/react @emotion/react`

**2. Adicionar animações**:
- Framer Motion: `npm install framer-motion`
```javascript
import { motion } from 'framer-motion';

<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.5 }}
>
  {/* conteúdo */}
</motion.div>
```

**3. Melhorar responsividade**:
- Usar CSS Grid mais avançado
- Implementar dark mode
- Adicionar skeleton loading

---

## Banco de Dados

### ❓ Por que MySQL e não PostgreSQL ou MongoDB?

**MySQL foi escolhido por**:
- ✅ Familiaridade (mais comum em cursos)
- ✅ Integração nativa no Azure
- ✅ Performance para dados relacionais
- ✅ Suporte a transações

**Você pode trocar**:
- **PostgreSQL**: Similar ao MySQL, troque os comandos
- **MongoDB**: Precisa reescrever queries (NoSQL)
- **CosmosDB**: Alternativa Azure para NoSQL

### ❓ Como fazer backup do banco de dados?

**Opção 1: Backup automático do Azure** (já habilitado)
```powershell
# Listar backups disponíveis
az mysql flexible-server backup list --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME

# Restaurar de backup
az mysql flexible-server restore --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME --restore-point-in-time "2024-11-24T10:00:00Z"
```

**Opção 2: Exportar para SQL**
```powershell
mysqldump -h MYSQL_SERVER_NAME.mysql.database.azure.com -u adminarte -p galeria_db > backup.sql
```

**Opção 3: Exportar para CSV**
```sql
SELECT * FROM obras INTO OUTFILE '/tmp/obras.csv' 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n';
```

### ❓ Como adicionar mais campos na tabela de obras?

1. **Criar migration SQL**:
```sql
ALTER TABLE obras ADD COLUMN dimensoes VARCHAR(100);
ALTER TABLE obras ADD COLUMN localizacao VARCHAR(200);
ALTER TABLE obras ADD COLUMN preco DECIMAL(10,2);
```

2. **Executar no MySQL**:
```powershell
mysql -h MYSQL_SERVER_NAME.mysql.database.azure.com -u adminarte -p galeria_db -e "ALTER TABLE obras ADD COLUMN dimensoes VARCHAR(100);"
```

3. **Atualizar backend** (`function_app.py`):
```python
def format_obra(row):
    return {
        "id": row["id"],
        "nome": row["nome"],
        # ... campos existentes ...
        "dimensoes": row["dimensoes"],  # NOVO
        "localizacao": row["localizacao"],  # NOVO
        "preco": float(row["preco"]) if row["preco"] else None  # NOVO
    }
```

4. **Atualizar frontend** (`CardObra.js`):
```javascript
<p className="obra-dimensoes">📏 {obra.dimensoes}</p>
<p className="obra-preco">💰 {obra.preco}</p>
```

### ❓ Como conectar ao MySQL de outras ferramentas?

**MySQL Workbench**:
1. Download: https://dev.mysql.com/downloads/workbench/
2. New Connection
3. Hostname: `MYSQL_SERVER_NAME.mysql.database.azure.com`
4. Port: `3306`
5. Username: `adminarte`
6. Password: (sua senha)
7. Test Connection → OK

**DBeaver** (alternativa gratuita):
1. Download: https://dbeaver.io/download/
2. Database → New Database Connection
3. MySQL → Next
4. Preencher credenciais
5. Test Connection → Finish

**VS Code** (com extensão):
1. Instalar extensão "MySQL" de Jun Han
2. Add Connection
3. Preencher credenciais
4. Executar queries direto no VS Code

---

## Blob Storage

### ❓ Como adicionar mais imagens depois do deploy?

**Via Azure CLI**:
```powershell
az storage blob upload `
  --account-name STORAGE_ACCOUNT_NAME `
  --container-name obras `
  --name nova-obra.jpg `
  --file C:\caminho\para\nova-obra.jpg `
  --content-type "image/jpeg"
```

**Via Azure Storage Explorer**:
1. Download: https://azure.microsoft.com/features/storage-explorer/
2. Connect to Azure account
3. Navigate to Storage Account → Blob Containers → obras
4. Upload files via drag & drop

**Via Python Script**:
```python
from azure.storage.blob import BlobServiceClient

connection_string = "DefaultEndpointsProtocol=https;AccountName=..."
blob_service = BlobServiceClient.from_connection_string(connection_string)
container_client = blob_service.get_container_client("obras")

with open("nova-obra.jpg", "rb") as data:
    container_client.upload_blob(
        name="nova-obra.jpg", 
        data=data,
        overwrite=True
    )
```

### ❓ Como otimizar imagens para reduzir custos?

**Antes do upload, comprimir imagens**:

**Opção 1: Online** (TinyPNG, Squoosh)
- https://tinypng.com/
- https://squoosh.app/

**Opção 2: PowerShell com ImageMagick**:
```powershell
# Instalar ImageMagick
choco install imagemagick

# Redimensionar para max 1200px width
magick input.jpg -resize 1200x output.jpg

# Comprimir mantendo qualidade
magick input.jpg -quality 85 output.jpg
```

**Opção 3: Node.js com Sharp**:
```javascript
const sharp = require('sharp');

sharp('input.jpg')
  .resize(1200)
  .jpeg({ quality: 85 })
  .toFile('output.jpg');
```

### ❓ Como servir imagens via CDN para melhor performance?

**Azure CDN integrado**:
```powershell
# Criar CDN endpoint
az cdn endpoint create `
  --resource-group galeria-artes-rg `
  --profile-name galeria-cdn `
  --name galeria-obras-cdn `
  --origin STORAGE_ACCOUNT_NAME.blob.core.windows.net `
  --origin-host-header STORAGE_ACCOUNT_NAME.blob.core.windows.net
```

**Atualizar URLs no código**:
```javascript
// Antes
const imagemUrl = `https://STORAGE.blob.core.windows.net/obras/${obra.imagem}`;

// Depois (com CDN)
const imagemUrl = `https://galeria-obras-cdn.azureedge.net/obras/${obra.imagem}`;
```

**Benefícios**:
- ⚡ Menor latência global
- 📉 Reduz carga no Storage
- 💰 Pode ser mais barato com alto tráfego

---

## Deploy e CI/CD

### ❓ O que é CI/CD e por que usar?

**CI/CD** = Continuous Integration / Continuous Deployment

**Benefícios**:
- ✅ Deploy automático a cada commit
- ✅ Testes antes de subir para produção
- ✅ Rollback fácil se algo der errado
- ✅ Menos erros manuais
- ✅ Mais agilidade

**Como funciona no projeto**:
1. Você faz commit no GitHub
2. GitHub Actions detecta mudança
3. Executa testes (se configurado)
4. Faz build do código
5. Faz deploy automático no Azure
6. Notifica se deu certo ou errado

### ❓ Como adicionar testes no CI/CD?

**Backend (Python)**:
```yaml
# Em .github/workflows/backend-deploy.yml
- name: Run tests
  run: |
    pip install pytest pytest-cov
    pytest tests/ --cov=.
```

**Criar arquivo `backend/tests/test_api.py`**:
```python
import pytest
from function_app import format_obra

def test_format_obra():
    row = {
        "id": 1,
        "nome": "Teste",
        "artista": "Artista Teste",
        "descricao": "Descrição teste",
        "ano_criacao": 2024,
        "url_imagem": "http://example.com/img.jpg",
        "estilo": "Moderno"
    }
    result = format_obra(row)
    assert result["nome"] == "Teste"
    assert result["artista"] == "Artista Teste"
```

**Frontend (React)**:
```yaml
# Em .github/workflows/frontend-deploy.yml
- name: Run tests
  run: npm test -- --coverage --watchAll=false
```

### ❓ Como fazer rollback se o deploy falhar?

**Opção 1: Via GitHub**
1. Acessar Actions → Workflow com erro
2. Clicar em "Re-run jobs"
3. Ou fazer revert do commit ruim:
   ```powershell
   git revert HEAD
   git push
   ```

**Opção 2: Deploy manual da versão anterior**
```powershell
# Backend
func azure functionapp publish FUNCTION_APP_NAME --slot staging

# Frontend
az staticwebapp deployment create --name galeria-artes-frontend --environment staging
```

**Opção 3: Slots de deployment**
```powershell
# Criar slot de staging
az functionapp deployment slot create --name FUNCTION_APP_NAME --resource-group galeria-artes-rg --slot staging

# Deploy para staging primeiro
func azure functionapp publish FUNCTION_APP_NAME --slot staging

# Se OK, trocar staging <-> production
az functionapp deployment slot swap --name FUNCTION_APP_NAME --resource-group galeria-artes-rg --slot staging
```

---

## Custos

### ❓ Quanto vou gastar por mês?

**Estimativa conservadora**:

| Recurso | Custo/mês (BRL) |
|---------|-----------------|
| Azure Function (Consumption) | R$ 0-5 |
| MySQL Flexible Server (B1ms) | R$ 60-80 |
| Blob Storage (Standard) | R$ 1-5 |
| Static Web App (Free) | R$ 0 |
| Bandwidth (egress) | R$ 5-10 |
| **TOTAL** | **R$ 65-100** |

**Se for só para trabalho acadêmico** (usar 1 mês):
- Custo total: ~R$ 70-100
- Azure for Students: US$ 100 créditos (suficiente!)

### ❓ Como reduzir custos?

**1. Usar tiers menores**:
```powershell
# MySQL: usar B1s ao invés de B1ms (50% mais barato)
az mysql flexible-server update --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME --sku-name Standard_B1s
```

**2. Parar recursos quando não usar**:
```powershell
# Parar MySQL à noite/fins de semana
az mysql flexible-server stop --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME

# Religar quando precisar
az mysql flexible-server start --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME
```

**3. Deletar após apresentação**:
```powershell
az group delete --name galeria-artes-rg --yes --no-wait
```

**4. Usar Dev/Test pricing**:
- Aplicável se tiver assinatura Visual Studio
- 20-30% de desconto

**5. Reserved Instances** (só se for usar por 1+ ano):
- 30-70% de desconto
- Mas tem commitment

### ❓ Existem alternativas gratuitas?

**Sim, mas com limitações**:

**Opção 1: Heroku (Free Tier)**
- ❌ Acabou o free tier em 2022
- ❌ Mínimo: US$ 7/mês

**Opção 2: Railway**
- ✅ US$ 5 crédito/mês grátis
- MySQL + Backend + Frontend
- Limitado mas pode funcionar

**Opção 3: Render**
- ✅ Free tier para web services
- ✅ Free PostgreSQL
- ❌ Dorme após 15min inatividade

**Opção 4: Vercel + Supabase**
- ✅ Vercel: Hosting grátis
- ✅ Supabase: PostgreSQL grátis
- Precisa adaptar backend para Vercel Functions

**Opção 5: Backend local + Netlify para frontend**
- Frontend: Netlify (grátis)
- Backend: Rodar localmente ou em VM gratuita Oracle Cloud

**Mas...**  
Se o trabalho **exige Azure**, não tem como fugir do MySQL (principal custo).

---

## Troubleshooting

### ❓ Erro: "MySQL connection refused"

**Causas possíveis**:
1. Firewall bloqueando seu IP
2. Credenciais incorretas
3. MySQL não iniciado
4. SSL requerido mas não configurado

**Soluções**:
```powershell
# 1. Adicionar seu IP ao firewall
$MyIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
az mysql flexible-server firewall-rule create `
  --resource-group galeria-artes-rg `
  --name MYSQL_SERVER_NAME `
  --rule-name AllowMyIP `
  --start-ip-address $MyIP `
  --end-ip-address $MyIP

# 2. Verificar credenciais
az mysql flexible-server show --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME

# 3. Verificar se está running
az mysql flexible-server show --resource-group galeria-artes-rg --name MYSQL_SERVER_NAME --query state

# 4. Testar conexão
mysql -h MYSQL_SERVER_NAME.mysql.database.azure.com -u adminarte -p --ssl-mode=REQUIRED
```

### ❓ Erro: "CORS blocked"

**Sintomas**: No console do navegador:
```
Access to fetch at 'https://...' from origin 'https://...' has been blocked by CORS policy
```

**Solução**:
```powershell
# Adicionar domínio do frontend ao CORS da Function
az functionapp cors add `
  --name FUNCTION_APP_NAME `
  --resource-group galeria-artes-rg `
  --allowed-origins "https://SEU-FRONTEND.azurestaticapps.net"

# Ou permitir todos (só para dev/testes!)
az functionapp cors add `
  --name FUNCTION_APP_NAME `
  --resource-group galeria-artes-rg `
  --allowed-origins "*"
```

### ❓ Erro: "Function runtime is unable to start"

**Causas**:
1. Dependências faltando em requirements.txt
2. Application Settings incorretas
3. Incompatibilidade Python version

**Soluções**:
```powershell
# Ver logs
az functionapp log tail --name FUNCTION_APP_NAME --resource-group galeria-artes-rg

# Verificar settings
az functionapp config appsettings list --name FUNCTION_APP_NAME --resource-group galeria-artes-rg

# Forçar reinstalação de dependências
func azure functionapp publish FUNCTION_APP_NAME --build remote

# Verificar versão Python
az functionapp config show --name FUNCTION_APP_NAME --resource-group galeria-artes-rg --query linuxFxVersion
```

### ❓ Imagens não carregam no frontend

**Diagnóstico**:
1. Abrir DevTools (F12) → Network
2. Ver se requests para imagens falham
3. Verificar Status Code (403, 404, CORS?)

**Soluções**:
```powershell
# Verificar se container é público
az storage container show --name obras --account-name STORAGE_ACCOUNT_NAME --query properties.publicAccess

# Tornar público se necessário
az storage container set-permission --name obras --account-name STORAGE_ACCOUNT_NAME --public-access blob

# Testar URL diretamente
Start-Process "https://STORAGE_ACCOUNT_NAME.blob.core.windows.net/obras/mona-lisa.jpg"

# Ver CORS rules
az storage cors list --account-name STORAGE_ACCOUNT_NAME --services b
```

### ❓ GitHub Actions falha com "Authentication failed"

**Causas**:
1. Secrets não configurados ou expirados
2. Publish profile inválido
3. Permissões insuficientes

**Soluções**:
```powershell
# Regerar publish profile
az functionapp deployment list-publishing-profiles --name FUNCTION_APP_NAME --resource-group galeria-artes-rg --xml > profile.xml

# Copiar conteúdo de profile.xml
Get-Content profile.xml | Set-Clipboard

# Atualizar secret no GitHub
# https://github.com/SEU_USUARIO/galeria-artes-azure/settings/secrets/actions
# Editar AZURE_FUNCTIONAPP_PUBLISH_PROFILE e colar novo conteúdo

# Para Static Web App
az staticwebapp secrets list --name galeria-artes-frontend --resource-group galeria-artes-rg --query properties.apiKey
# Copiar e atualizar secret AZURE_STATIC_WEB_APPS_API_TOKEN
```

---

## 📞 Suporte Adicional

**Documentação Oficial**:
- [Azure Functions](https://docs.microsoft.com/azure/azure-functions/)
- [Azure MySQL](https://docs.microsoft.com/azure/mysql/)
- [Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps/)
- [React](https://react.dev/)

**Comunidades**:
- Stack Overflow: tag `azure-functions`, `azure-mysql`
- Reddit: r/AZURE
- Discord: Azure Community

**Issues no Projeto**:
- Abra uma issue no GitHub do projeto
- Use os templates fornecidos
- Forneça logs e contexto

---

**Não encontrou sua pergunta?** Abra uma issue no GitHub! 🚀
