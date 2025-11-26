# ========================================
# Script para Upload de Imagens no Blob Storage
# Galeria de Artes Online
# ========================================

param(
    [string]$ConfigFile = ".\azure-config.txt"
)

Write-Host "🖼️ Script de Upload de Imagens para Azure Blob Storage" -ForegroundColor Cyan
Write-Host ""

# ========================================
# 1. CARREGAR CONFIGURAÇÕES
# ========================================

if (-not (Test-Path $ConfigFile)) {
    Write-Host "❌ Arquivo de configuração não encontrado: $ConfigFile" -ForegroundColor Red
    Write-Host "Execute primeiro o script 01-provision-azure.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "📄 Carregando configurações..." -ForegroundColor Green

$config = @{}
Get-Content $ConfigFile | ForEach-Object {
    if ($_ -match '^([^#].+?)=(.+)$') {
        $config[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$STORAGE_ACCOUNT = $config['STORAGE_ACCOUNT']
$STORAGE_KEY = $config['STORAGE_KEY']
$CONTAINER_NAME = $config['CONTAINER_NAME']

if (-not $STORAGE_ACCOUNT -or -not $STORAGE_KEY) {
    Write-Host "❌ Configurações incompletas no arquivo" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Configurações carregadas:" -ForegroundColor Green
Write-Host "  Storage Account: $STORAGE_ACCOUNT"
Write-Host "  Container: $CONTAINER_NAME"
Write-Host ""

# ========================================
# 2. CRIAR PASTA DE IMAGENS DE EXEMPLO
# ========================================

$imagesFolder = ".\imagens-obras"

if (-not (Test-Path $imagesFolder)) {
    Write-Host "📁 Criando pasta para imagens..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $imagesFolder | Out-Null
}

# ========================================
# 3. BAIXAR IMAGENS DE EXEMPLO
# ========================================

Write-Host "🌐 Baixando imagens de exemplo..." -ForegroundColor Green

$obras = @(
    @{nome="monalisa.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/460px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg"},
    @{nome="noite-estrelada.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/600px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg"},
    @{nome="o-grito.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Edvard_Munch%2C_1893%2C_The_Scream%2C_oil%2C_tempera_and_pastel_on_cardboard%2C_91_x_73_cm%2C_National_Gallery_of_Norway.jpg/440px-Edvard_Munch%2C_1893%2C_The_Scream%2C_oil%2C_tempera_and_pastel_on_cardboard%2C_91_x_73_cm%2C_National_Gallery_of_Norway.jpg"},
    @{nome="guernica.jpg"; url="https://upload.wikimedia.org/wikipedia/en/thumb/7/74/PicassoGuernica.jpg/600px-PicassoGuernica.jpg"},
    @{nome="persistencia-memoria.jpg"; url="https://upload.wikimedia.org/wikipedia/en/thumb/d/dd/The_Persistence_of_Memory.jpg/500px-The_Persistence_of_Memory.jpg"},
    @{nome="criacao-adao.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg/600px-Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg"},
    @{nome="moca-perola.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/1665_Girl_with_a_Pearl_Earring.jpg/440px-1665_Girl_with_a_Pearl_Earring.jpg"},
    @{nome="o-beijo.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Gustav_Klimt_016.jpg/440px-Gustav_Klimt_016.jpg"},
    @{nome="abaporu.jpg"; url="https://upload.wikimedia.org/wikipedia/en/thumb/b/b2/Abaporu.jpg/440px-Abaporu.jpg"},
    @{nome="almoco-relva.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Edouard_Manet_-_Luncheon_on_the_Grass_-_Google_Art_Project.jpg/600px-Edouard_Manet_-_Luncheon_on_the_Grass_-_Google_Art_Project.jpg"},
    @{nome="as-meninas.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Las_Meninas%2C_by_Diego_Vel%C3%A1zquez%2C_from_Prado_in_Google_Earth.jpg/500px-Las_Meninas%2C_by_Diego_Vel%C3%A1zquez%2C_from_Prado_in_Google_Earth.jpg"},
    @{nome="nenufares.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Claude_Monet_-_Water_Lilies_-_1906%2C_Ryerson.jpg/600px-Claude_Monet_-_Water_Lilies_-_1906%2C_Ryerson.jpg"}
)

foreach ($obra in $obras) {
    $filePath = Join-Path $imagesFolder $obra.nome
    
    if (Test-Path $filePath) {
        Write-Host "  ⏭️ Já existe: $($obra.nome)" -ForegroundColor Gray
    } else {
        try {
            Write-Host "  ⬇️ Baixando: $($obra.nome)" -ForegroundColor Yellow
            Invoke-WebRequest -Uri $obra.url -OutFile $filePath -UseBasicParsing
            Write-Host "  ✅ Baixado: $($obra.nome)" -ForegroundColor Green
        } catch {
            Write-Host "  ⚠️ Erro ao baixar: $($obra.nome)" -ForegroundColor Red
        }
    }
}

# ========================================
# 4. FAZER UPLOAD PARA BLOB STORAGE
# ========================================

Write-Host "`n📤 Fazendo upload para Azure Blob Storage..." -ForegroundColor Green

$imageFiles = Get-ChildItem -Path $imagesFolder -Filter "*.jpg"

if ($imageFiles.Count -eq 0) {
    Write-Host "❌ Nenhuma imagem encontrada em $imagesFolder" -ForegroundColor Red
    exit 1
}

$uploadCount = 0
foreach ($file in $imageFiles) {
    Write-Host "  📤 Upload: $($file.Name)..." -ForegroundColor Yellow
    
    az storage blob upload `
        --account-name $STORAGE_ACCOUNT `
        --account-key $STORAGE_KEY `
        --container-name $CONTAINER_NAME `
        --name $file.Name `
        --file $file.FullName `
        --overwrite true `
        --content-type "image/jpeg" | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Enviado: $($file.Name)" -ForegroundColor Green
        $uploadCount++
    } else {
        Write-Host "  ❌ Erro: $($file.Name)" -ForegroundColor Red
    }
}

# ========================================
# 5. ATUALIZAR URLs NO BANCO DE DADOS
# ========================================

Write-Host "`n📝 Gerando script SQL para atualizar URLs..." -ForegroundColor Green

$sqlUpdate = @"
-- Script para atualizar URLs das imagens no banco de dados
-- Execute este script no MySQL após o upload das imagens

USE galeria_db;

UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/monalisa.jpg' WHERE nome = 'Mona Lisa';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/noite-estrelada.jpg' WHERE nome = 'A Noite Estrelada';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/o-grito.jpg' WHERE nome = 'O Grito';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/guernica.jpg' WHERE nome = 'Guernica';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/persistencia-memoria.jpg' WHERE nome = 'A Persistência da Memória';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/criacao-adao.jpg' WHERE nome = 'A Criação de Adão';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/moca-perola.jpg' WHERE nome = 'Moça com Brinco de Pérola';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/o-beijo.jpg' WHERE nome = 'O Beijo';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/abaporu.jpg' WHERE nome = 'Abaporu';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/almoco-relva.jpg' WHERE nome = 'Almoço na Relva';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/as-meninas.jpg' WHERE nome = 'As Meninas';
UPDATE obras SET url_imagem = 'https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/nenufares.jpg' WHERE nome = 'Nenúfares';

-- Verificar as URLs atualizadas
SELECT nome, url_imagem FROM obras;
"@

$sqlUpdate | Out-File -FilePath ".\update-urls.sql" -Encoding UTF8
Write-Host "✅ Script SQL salvo em: update-urls.sql" -ForegroundColor Green

# ========================================
# 6. LISTAR BLOBS NO CONTAINER
# ========================================

Write-Host "`n📋 Listando blobs no container..." -ForegroundColor Green

az storage blob list `
    --account-name $STORAGE_ACCOUNT `
    --account-key $STORAGE_KEY `
    --container-name $CONTAINER_NAME `
    --output table

# ========================================
# 7. RESUMO FINAL
# ========================================

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "🎉 UPLOAD CONCLUÍDO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Estatísticas:" -ForegroundColor Cyan
Write-Host "  Imagens enviadas: $uploadCount"
Write-Host "  Container: $CONTAINER_NAME"
Write-Host "  Storage Account: $STORAGE_ACCOUNT"
Write-Host ""
Write-Host "🔗 URL base das imagens:" -ForegroundColor Cyan
Write-Host "  https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/" -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Execute o script SQL 'update-urls.sql' no seu banco MySQL"
Write-Host "  2. Teste acessando uma URL no navegador"
Write-Host "  3. Faça o deploy da Function App"
Write-Host ""
