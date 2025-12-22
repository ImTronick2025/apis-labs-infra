#!/usr/bin/env pwsh
# Script para importar las APIs de GitHub a Azure API Management

param(
    [Parameter()]
    [string]$ResourceGroup = "apis-labs-rg",
    
    [Parameter()]
    [string]$ApimName,
    
    [switch]$ImportPetstore,
    
    [switch]$ImportOrders,
    
    [switch]$All
)

$ErrorActionPreference = "Stop"

Write-Host "📋 Azure API Management - Import APIs from GitHub" -ForegroundColor Cyan
Write-Host ""

# Verificar Azure CLI
if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI no está instalado" -ForegroundColor Red
    exit 1
}

# Obtener nombre de APIM si no se proporcionó
if (!$ApimName) {
    Write-Host "🔍 Obteniendo nombre de API Management..." -ForegroundColor Cyan
    try {
        $ApimName = terraform output -raw apim_name
        Write-Host "   ✓ APIM: $ApimName" -ForegroundColor Green
    } catch {
        Write-Host "❌ No se pudo obtener el nombre de APIM desde Terraform" -ForegroundColor Red
        Write-Host "   Usa: -ApimName <nombre>" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""

# Función para importar API
function Import-API {
    param(
        [string]$Name,
        [string]$DisplayName,
        [string]$Path,
        [string]$SpecUrl
    )
    
    Write-Host "📦 Importando $DisplayName..." -ForegroundColor Cyan
    Write-Host "   URL: $SpecUrl" -ForegroundColor Gray
    
    try {
        az apim api import `
            --resource-group $ResourceGroup `
            --service-name $ApimName `
            --path $Path `
            --api-id $Name `
            --display-name $DisplayName `
            --specification-url $SpecUrl `
            --specification-format OpenApiJson `
            --protocols https `
            --subscription-required true
        
        Write-Host "   ✅ $DisplayName importada exitosamente!" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Error importando $DisplayName" -ForegroundColor Red
        Write-Host "   $_" -ForegroundColor Red
    }
    Write-Host ""
}

# Importar APIs según flags
if ($All -or $ImportPetstore) {
    Import-API `
        -Name "petstore-api" `
        -DisplayName "Petstore API" `
        -Path "petstore" `
        -SpecUrl "https://raw.githubusercontent.com/ImTronick2025/apis-labs-api/main/petstore-api.yaml"
}

if ($All -or $ImportOrders) {
    Import-API `
        -Name "orders-api" `
        -DisplayName "Orders API" `
        -Path "orders" `
        -SpecUrl "https://raw.githubusercontent.com/ImTronick2025/apis-labs-api/main/orders-api.yaml"
}

if (!$All -and !$ImportPetstore -and !$ImportOrders) {
    Write-Host "ℹ️  Uso:" -ForegroundColor Yellow
    Write-Host "   .\import-apis.ps1 -All" -ForegroundColor Gray
    Write-Host "   .\import-apis.ps1 -ImportPetstore" -ForegroundColor Gray
    Write-Host "   .\import-apis.ps1 -ImportOrders" -ForegroundColor Gray
    Write-Host "   .\import-apis.ps1 -ApimName <nombre> -All" -ForegroundColor Gray
    exit 0
}

Write-Host "✅ Proceso de importación completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Verifica las APIs en:" -ForegroundColor Cyan
Write-Host "   https://portal.azure.com/#@/resource/subscriptions/0ec51f00-9547-405f-9a39-25fb1b9f42e5/resourceGroups/$ResourceGroup/providers/Microsoft.ApiManagement/service/$ApimName/apis" -ForegroundColor Gray
