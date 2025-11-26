# ========================================
# Script de Testes - Galeria de Artes
# ========================================

param(
    [string]$FunctionAppUrl = "",
    [string]$StaticWebAppUrl = "",
    [string]$ConfigFile = ".\azure-config.txt"
)

Write-Host "🧪 Iniciando testes da Galeria de Artes..." -ForegroundColor Cyan
Write-Host ""

# ========================================
# CARREGAR CONFIGURAÇÕES
# ========================================

if (Test-Path $ConfigFile) {
    Write-Host "📄 Carregando configurações de $ConfigFile..." -ForegroundColor Green
    $config = @{}
    Get-Content $ConfigFile | ForEach-Object {
        if ($_ -match '^([^#].+?)=(.+)$') {
            $config[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    
    if (-not $FunctionAppUrl -and $config['FUNCTION_APP']) {
        $FunctionAppUrl = "https://$($config['FUNCTION_APP']).azurewebsites.net"
    }
    
    if (-not $StaticWebAppUrl -and $config['STATIC_WEBAPP']) {
        $StaticWebAppUrl = "https://$($config['STATIC_WEBAPP']).azurestaticapps.net"
    }
}

if (-not $FunctionAppUrl) {
    Write-Host "❌ URL da Function App não fornecida!" -ForegroundColor Red
    Write-Host "Use: .\04-test-application.ps1 -FunctionAppUrl 'https://sua-function.azurewebsites.net'" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Configurações carregadas" -ForegroundColor Green
Write-Host "  Function App: $FunctionAppUrl" -ForegroundColor Gray
if ($StaticWebAppUrl) {
    Write-Host "  Static Web App: $StaticWebAppUrl" -ForegroundColor Gray
}
Write-Host ""

$totalTests = 0
$passedTests = 0
$failedTests = 0

# ========================================
# FUNÇÃO DE TESTE
# ========================================

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [int]$ExpectedStatus = 200,
        [string]$ExpectedContent = ""
    )
    
    $script:totalTests++
    Write-Host "🔍 Testando: $Name" -ForegroundColor Cyan
    Write-Host "   URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 30
        
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "   ✅ Status: $($response.StatusCode) OK" -ForegroundColor Green
            
            if ($ExpectedContent -and $response.Content -notmatch $ExpectedContent) {
                Write-Host "   ⚠️ Conteúdo esperado não encontrado" -ForegroundColor Yellow
                $script:failedTests++
            } else {
                Write-Host "   ✅ Conteúdo validado" -ForegroundColor Green
                $script:passedTests++
            }
        } else {
            Write-Host "   ❌ Status: $($response.StatusCode) (esperado: $ExpectedStatus)" -ForegroundColor Red
            $script:failedTests++
        }
        
        return $response
    }
    catch {
        Write-Host "   ❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedTests++
        return $null
    }
    
    Write-Host ""
}

# ========================================
# TESTES DO BACKEND
# ========================================

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "TESTES DO BACKEND (Azure Function)" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Teste 1: Health Check
$healthResponse = Test-Endpoint `
    -Name "Health Check" `
    -Url "$FunctionAppUrl/api/health" `
    -ExpectedContent "healthy"

if ($healthResponse) {
    $healthData = $healthResponse.Content | ConvertFrom-Json
    Write-Host "   Database: $($healthData.database)" -ForegroundColor $(if ($healthData.database -eq "connected") {"Green"} else {"Red"})
    Write-Host ""
}

# Teste 2: Listar Obras
$obrasResponse = Test-Endpoint `
    -Name "Listar Todas as Obras" `
    -Url "$FunctionAppUrl/api/obras" `
    -ExpectedContent "nome"

if ($obrasResponse) {
    $obras = $obrasResponse.Content | ConvertFrom-Json
    Write-Host "   Total de obras: $($obras.Count)" -ForegroundColor Cyan
    Write-Host ""
}

# Teste 3: Obra Específica
Test-Endpoint `
    -Name "Obter Obra por ID (1)" `
    -Url "$FunctionAppUrl/api/obras/1" `
    -ExpectedContent "artista"

# Teste 4: Buscar por Artista
Test-Endpoint `
    -Name "Obras por Artista (Picasso)" `
    -Url "$FunctionAppUrl/api/obras/artista/Picasso" `
    -ExpectedStatus 200

# Teste 5: Buscar por Estilo
Test-Endpoint `
    -Name "Obras por Estilo (Renascimento)" `
    -Url "$FunctionAppUrl/api/obras/estilo/Renascimento" `
    -ExpectedStatus 200

# ========================================
# TESTES DO STORAGE
# ========================================

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "TESTES DO BLOB STORAGE" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

if ($config['STORAGE_ACCOUNT']) {
    $storageUrl = "https://$($config['STORAGE_ACCOUNT']).blob.core.windows.net/$($config['CONTAINER_NAME'])"
    
    $imagensParaTestar = @(
        "monalisa.jpg",
        "noite-estrelada.jpg",
        "o-grito.jpg"
    )
    
    foreach ($imagem in $imagensParaTestar) {
        Test-Endpoint `
            -Name "Imagem: $imagem" `
            -Url "$storageUrl/$imagem" `
            -ExpectedStatus 200
    }
} else {
    Write-Host "⏭️ Storage Account não configurado, pulando testes de imagens" -ForegroundColor Yellow
    Write-Host ""
}

# ========================================
# TESTES DO FRONTEND
# ========================================

if ($StaticWebAppUrl) {
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "TESTES DO FRONTEND (Static Web App)" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    
    Test-Endpoint `
        -Name "Página Principal" `
        -Url $StaticWebAppUrl `
        -ExpectedContent "Galeria"
} else {
    Write-Host "⏭️ Static Web App URL não fornecida, pulando testes de frontend" -ForegroundColor Yellow
    Write-Host ""
}

# ========================================
# TESTES DE INTEGRAÇÃO
# ========================================

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "TESTES DE INTEGRAÇÃO" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

$totalTests++
Write-Host "🔍 Testando: Validação de CORS" -ForegroundColor Cyan

try {
    $headers = @{
        "Origin" = $StaticWebAppUrl
    }
    $corsResponse = Invoke-WebRequest `
        -Uri "$FunctionAppUrl/api/obras" `
        -Method GET `
        -Headers $headers `
        -UseBasicParsing
    
    $accessControl = $corsResponse.Headers['Access-Control-Allow-Origin']
    
    if ($accessControl) {
        Write-Host "   ✅ CORS configurado: $accessControl" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ⚠️ CORS pode não estar configurado corretamente" -ForegroundColor Yellow
        $failedTests++
    }
}
catch {
    Write-Host "   ❌ Erro ao testar CORS" -ForegroundColor Red
    $failedTests++
}

Write-Host ""

# ========================================
# TESTE DE PERFORMANCE
# ========================================

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "TESTE DE PERFORMANCE" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

$totalTests++
Write-Host "🔍 Testando: Tempo de Resposta da API" -ForegroundColor Cyan

$tempos = @()
for ($i = 1; $i -le 5; $i++) {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        Invoke-WebRequest -Uri "$FunctionAppUrl/api/obras" -Method GET -UseBasicParsing | Out-Null
        $stopwatch.Stop()
        $tempos += $stopwatch.ElapsedMilliseconds
        Write-Host "   Requisição $i : $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Gray
    }
    catch {
        Write-Host "   ❌ Erro na requisição $i" -ForegroundColor Red
    }
}

if ($tempos.Count -gt 0) {
    $tempoMedio = ($tempos | Measure-Object -Average).Average
    Write-Host ""
    Write-Host "   📊 Tempo médio: $([math]::Round($tempoMedio, 2))ms" -ForegroundColor Cyan
    
    if ($tempoMedio -lt 1000) {
        Write-Host "   ✅ Performance excelente!" -ForegroundColor Green
        $passedTests++
    } elseif ($tempoMedio -lt 3000) {
        Write-Host "   ⚠️ Performance aceitável" -ForegroundColor Yellow
        $passedTests++
    } else {
        Write-Host "   ❌ Performance precisa melhorar" -ForegroundColor Red
        $failedTests++
    }
} else {
    Write-Host "   ❌ Não foi possível medir performance" -ForegroundColor Red
    $failedTests++
}

Write-Host ""

# ========================================
# RESUMO FINAL
# ========================================

Write-Host "========================================" -ForegroundColor Green
Write-Host "RESUMO DOS TESTES" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Total de testes: $totalTests" -ForegroundColor Cyan
Write-Host "Testes passados: $passedTests" -ForegroundColor Green
Write-Host "Testes falhados: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) {"Green"} else {"Red"})
Write-Host ""

$successRate = [math]::Round(($passedTests / $totalTests) * 100, 2)
Write-Host "Taxa de sucesso: $successRate%" -ForegroundColor $(if ($successRate -ge 80) {"Green"} elseif ($successRate -ge 60) {"Yellow"} else {"Red"})
Write-Host ""

if ($failedTests -eq 0) {
    Write-Host "🎉 PARABÉNS! Todos os testes passaram!" -ForegroundColor Green
    Write-Host "✅ Sua aplicação está funcionando perfeitamente!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Alguns testes falharam. Revise as configurações." -ForegroundColor Yellow
    Write-Host "📖 Consulte o DEPLOY_GUIDE.md para troubleshooting" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
