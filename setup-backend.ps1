# Setup script for Terraform backend in Azure Storage
# Run this ONCE before first deployment

param(
    [string]$Location = "eastus",
    [string]$ResourceGroupName = "terraform-state-rg",
    [string]$StorageAccountName = "tfstateapislabs"
)

Write-Host "Creating Terraform backend storage in Azure..." -ForegroundColor Cyan

# Create resource group
Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Create storage account
Write-Host "Creating storage account: $StorageAccountName" -ForegroundColor Yellow
az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Standard_LRS `
    --encryption-services blob `
    --https-only true `
    --min-tls-version TLS1_2

# Create blob container
Write-Host "Creating blob container: tfstate" -ForegroundColor Yellow
az storage container create `
    --name tfstate `
    --account-name $StorageAccountName `
    --auth-mode login

Write-Host "`n✅ Terraform backend setup complete!" -ForegroundColor Green
Write-Host "Backend configuration:" -ForegroundColor Cyan
Write-Host "  Resource Group: $ResourceGroupName"
Write-Host "  Storage Account: $StorageAccountName"
Write-Host "  Container: tfstate"
