#!/usr/bin/env pwsh
# Script de post-despliegue para configurar recursos

param(
    [Parameter()]
    [string]$ResourceGroup = "apis-labs-rg"
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Azure APIs Lab - Post-Deployment Configuration" -ForegroundColor Cyan
Write-Host ""

# Obtener outputs de Terraform
Write-Host "📊 Obteniendo información de recursos..." -ForegroundColor Cyan
try {
    $apimName = terraform output -raw apim_name
    $apimUrl = terraform output -raw apim_gateway_url
    $functionApp = terraform output -raw function_app_name
    $cosmosName = terraform output -raw cosmosdb_name
    $cosmosEndpoint = terraform output -raw cosmosdb_endpoint
    if ([string]::IsNullOrWhiteSpace($ResourceGroup) -or $ResourceGroup -eq "apis-labs-rg") {
        $ResourceGroup = terraform output -raw resource_group_name
    }
} catch {
    Write-Host "❌ Error obteniendo outputs de Terraform" -ForegroundColor Red
    Write-Host "   Asegúrate de haber ejecutado 'terraform apply' primero" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✓ APIM: $apimName" -ForegroundColor Green
Write-Host "   ✓ Functions: $functionApp" -ForegroundColor Green
Write-Host "   ✓ Cosmos DB: $cosmosName" -ForegroundColor Green
Write-Host ""

# Obtener Subscription Key de APIM
Write-Host "🔑 Obteniendo Subscription Key de APIM..." -ForegroundColor Cyan
$subscriptionKey = az apim subscription list-secrets `
    --resource-group $ResourceGroup `
    --service-name $apimName `
    --subscription-id master `
    --query primaryKey -o tsv

if ($functionKey) {
    Write-Host "# Listar libros (Function App):" -ForegroundColor Gray
    Write-Host "curl https://$functionApp.azurewebsites.net/api/books \\" -ForegroundColor Cyan
    Write-Host "  -H 'x-functions-key: $functionKey'" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "   ⚠️  No se pudo obtener Subscription Key" -ForegroundColor Yellow
}
Write-Host ""

# Obtener Function Key
Write-Host "🔑 Obteniendo Function App Key..." -ForegroundColor Cyan
$functionKey = az functionapp keys list `
    --name $functionApp `
    --resource-group $ResourceGroup `
    --query "functionKeys.default" -o tsv

if ($functionKey) {
    Write-Host "   ✓ Function Key obtenida" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  No se pudo obtener Function Key" -ForegroundColor Yellow
}
Write-Host ""

# Mostrar resumen
Write-Host "=" -ForegroundColor Cyan * 80
Write-Host "📝 RESUMEN DE CONFIGURACIÓN" -ForegroundColor Cyan
Write-Host "=" -ForegroundColor Cyan * 80
Write-Host ""

Write-Host "🌐 ENDPOINTS:" -ForegroundColor Yellow
Write-Host "   APIM Gateway:     $apimUrl" -ForegroundColor White
Write-Host "   Function App:     https://$functionApp.azurewebsites.net" -ForegroundColor White
Write-Host "   Cosmos DB:        $cosmosEndpoint" -ForegroundColor White
Write-Host ""

Write-Host "🔐 CREDENCIALES:" -ForegroundColor Yellow
if ($functionKey) {
    Write-Host "# Listar libros (Function App):" -ForegroundColor Gray
    Write-Host "curl https://$functionApp.azurewebsites.net/api/books \\" -ForegroundColor Cyan
    Write-Host "  -H 'x-functions-key: $functionKey'" -ForegroundColor Cyan
    Write-Host ""
}
if ($functionKey) {
    Write-Host "   Function Master Key:   $functionKey" -ForegroundColor White
}
Write-Host ""

Write-Host "🧪 PRUEBAS RÁPIDAS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Health check de Functions:" -ForegroundColor Gray
Write-Host "curl https://$functionApp.azurewebsites.net/api/health" -ForegroundColor Cyan
Write-Host ""

if ($functionKey) {
    Write-Host "# Listar libros (Function App):" -ForegroundColor Gray
    Write-Host "curl https://$functionApp.azurewebsites.net/api/books \\" -ForegroundColor Cyan
    Write-Host "  -H 'x-functions-key: $functionKey'" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "📋 PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "   1. Importar APIs:       .\import-apis.ps1 -All" -ForegroundColor White
Write-Host "   2. Cargar datos:        cd ..\apis-labs-db\scripts && .\init-cosmosdb.ps1" -ForegroundColor White
Write-Host "   3. Desplegar Functions: func azure functionapp publish $functionApp" -ForegroundColor White
Write-Host ""

Write-Host "=" -ForegroundColor Cyan * 80
Write-Host ""

# Guardar información en archivo
$infoFile = "deployment-info.json"
$deploymentInfo = @{
    timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    resourceGroup  = $ResourceGroup
    apimName       = $apimName
    apimUrl        = $apimUrl
    functionApp    = $functionApp
    cosmosName     = $cosmosName
    cosmosEndpoint = $cosmosEndpoint
    subscriptionKey = $subscriptionKey
    functionKey    = $functionKey
} | ConvertTo-Json -Depth 10

$deploymentInfo | Out-File -FilePath $infoFile -Encoding utf8
Write-Host "💾 Información guardada en: $infoFile" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Post-deployment completado!" -ForegroundColor Green
