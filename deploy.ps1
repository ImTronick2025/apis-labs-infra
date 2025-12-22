#!/usr/bin/env pwsh
# Script de despliegue de infraestructura con Terraform

param(
    [Parameter()]
    [ValidateSet('dev', 'prod')]
    [string]$Environment = 'dev',
    
    [Parameter()]
    [ValidateSet('plan', 'apply', 'destroy', 'output')]
    [string]$Action = 'plan',
    
    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Azure APIs Lab - Terraform Deployment" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Action: $Action" -ForegroundColor Yellow
Write-Host ""

# Verificar Terraform instalado
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Terraform no está instalado" -ForegroundColor Red
    Write-Host "   Descarga desde: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Verificar Azure CLI instalado y autenticado
if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI no está instalado" -ForegroundColor Red
    Write-Host "   Descarga desde: https://docs.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Verificar autenticación en Azure
Write-Host "🔐 Verificando autenticación en Azure..." -ForegroundColor Cyan
$azAccount = az account show 2>$null | ConvertFrom-Json
if (!$azAccount) {
    Write-Host "❌ No estás autenticado en Azure" -ForegroundColor Red
    Write-Host "   Ejecuta: az login" -ForegroundColor Yellow
    exit 1
}
Write-Host "   ✓ Autenticado como: $($azAccount.user.name)" -ForegroundColor Green
Write-Host "   ✓ Subscription: $($azAccount.name)" -ForegroundColor Green
Write-Host ""

# Archivo de variables según entorno
$varFile = "$Environment.tfvars"
if (!(Test-Path $varFile)) {
    Write-Host "❌ Archivo de variables no encontrado: $varFile" -ForegroundColor Red
    exit 1
}

# Inicializar Terraform (si es necesario)
if (!(Test-Path ".terraform")) {
    Write-Host "📦 Inicializando Terraform..." -ForegroundColor Cyan
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al inicializar Terraform" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Ejecutar acción
switch ($Action) {
    'plan' {
        Write-Host "📋 Generando plan de ejecución..." -ForegroundColor Cyan
        terraform plan -var-file="$varFile" -out="terraform.plan"
    }
    'apply' {
        if ($AutoApprove) {
            Write-Host "🚀 Aplicando cambios (auto-approve)..." -ForegroundColor Cyan
            terraform apply -var-file="$varFile" -auto-approve
        } else {
            Write-Host "🚀 Aplicando cambios..." -ForegroundColor Cyan
            terraform apply -var-file="$varFile"
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Infraestructura desplegada exitosamente!" -ForegroundColor Green
            Write-Host ""
            Write-Host "📊 Outputs importantes:" -ForegroundColor Cyan
            terraform output
        }
    }
    'destroy' {
        Write-Host "⚠️  ADVERTENCIA: Esto destruirá TODOS los recursos!" -ForegroundColor Yellow
        Write-Host "   Environment: $Environment" -ForegroundColor Yellow
        Write-Host ""
        
        if (!$AutoApprove) {
            $confirm = Read-Host "¿Estás seguro? Escribe 'yes' para continuar"
            if ($confirm -ne 'yes') {
                Write-Host "❌ Operación cancelada" -ForegroundColor Yellow
                exit 0
            }
        }
        
        Write-Host "💥 Destruyendo infraestructura..." -ForegroundColor Red
        terraform destroy -var-file="$varFile" -auto-approve
    }
    'output' {
        Write-Host "📊 Outputs de Terraform:" -ForegroundColor Cyan
        terraform output
    }
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Error en la ejecución" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Proceso completado" -ForegroundColor Green
