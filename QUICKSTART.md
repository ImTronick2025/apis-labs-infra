# 🚀 Guía de Inicio Rápido - Infraestructura

Esta guía te llevará desde cero hasta tener toda la infraestructura desplegada en Azure.

## ⚡ Inicio Rápido (5 minutos)

### Opción 1: Con Scripts PowerShell (Recomendado en Windows)

```powershell
# 1. Autenticarse en Azure
az login
az account set --subscription 0ec51f00-9547-405f-9a39-25fb1b9f42e5

# 2. Navegar al directorio
cd D:\CLOUDSOLUTIONS\apis-labs-workspace\apis-labs-infra

# 3. Desplegar infraestructura (ambiente dev)
.\deploy.ps1 -Environment dev -Action apply -AutoApprove

# 4. Configurar recursos adicionales
.\post-deploy.ps1

# 5. Importar APIs desde GitHub
.\import-apis.ps1 -All
```

### Opción 2: Con Scripts Bash (Linux/macOS)

```bash
# 1. Autenticarse en Azure
az login
az account set --subscription 0ec51f00-9547-405f-9a39-25fb1b9f42e5

# 2. Navegar al directorio
cd apis-labs-workspace/apis-labs-infra

# 3. Hacer ejecutables los scripts
chmod +x deploy.sh import-apis.sh

# 4. Desplegar infraestructura
./deploy.sh dev apply --auto-approve

# 5. Configurar recursos
pwsh post-deploy.ps1

# 6. Importar APIs
pwsh import-apis.ps1 -All
```

### Opción 3: Manual con Terraform

```powershell
# 1. Autenticarse
az login

# 2. Inicializar Terraform
terraform init

# 3. Ver plan de ejecución
terraform plan -var-file="dev.tfvars"

# 4. Aplicar cambios
terraform apply -var-file="dev.tfvars"

# 5. Ver outputs
terraform output
```

## ⏱️ Tiempos Estimados

- **Terraform init**: ~30 segundos
- **Terraform plan**: ~15 segundos
- **Terraform apply**:
  - Recursos rápidos (RG, VNet, Storage): ~2-3 minutos
  - Cosmos DB: ~5-10 minutos
  - **API Management**: ⚠️ **30-45 minutos** (es el más lento)
  - Total: **~45-60 minutos**

> 💡 **Tip**: API Management es extremadamente lento al crear. Es normal. Aprovecha para tomar un café ☕

## 📋 Prerequisitos

### Software Necesario

```powershell
# Verificar instalaciones
terraform --version   # >= 1.0
az --version          # >= 2.50
git --version         # >= 2.30
pwsh --version        # >= 7.0 (opcional)

# Instalar si falta alguno:
winget install --id Hashicorp.Terraform
winget install --id Microsoft.AzureCLI
winget install --id Git.Git
winget install --id Microsoft.PowerShell
```

### Permisos en Azure

Tu Service Principal necesita:
- ✅ **Contributor** en la suscripción
- ✅ Permisos para crear Resource Groups
- ✅ Permisos para crear recursos en el RG

Verificar permisos:
```bash
az role assignment list --assignee 28abcd1c-943a-4a9c-9e17-d3828d14a1ea --output table
```

## 🏗️ Arquitectura de la Infraestructura

```
apis-labs-rg (Resource Group)
├── apislabs-vnet (Virtual Network)
│   ├── apim-subnet (10.0.1.0/24)
│   └── cosmosdb-subnet (10.0.2.0/24)
├── apislabs-apim (API Management)
│   ├── Gateway URL
│   └── Developer Portal
├── apislabs-cosmos-xxxxxx (Cosmos DB)
│   ├── apis-labs-db (Database)
│   └── items (Container)
├── apislabs-func-xxxxxx (Function App)
│   └── .NET 8.0 Isolated
├── apislabsfuncstxxxxxx (Storage Account)
└── apislabs-appinsights (Application Insights)
```

## 📁 Estructura de Archivos

```
apis-labs-infra/
├── main.tf                    # ⭐ Recursos principales
├── variables.tf               # Variables y valores por defecto
├── outputs.tf                 # Outputs importantes
├── dev.tfvars                 # Variables de desarrollo
├── prod.tfvars                # Variables de producción
├── terraform.tfvars.example   # Template de variables
├── .gitignore                 # Archivos a ignorar
├── deploy.ps1                 # 🚀 Script de despliegue (PowerShell)
├── deploy.sh                  # 🚀 Script de despliegue (Bash)
├── post-deploy.ps1            # Configuración post-despliegue
├── import-apis.ps1            # Importar APIs desde GitHub
├── README.md                  # Documentación principal
└── .github/
    └── workflows/
        └── terraform-azure.yml # CI/CD con GitHub Actions
```

## 🎯 Recursos Desplegados

| Recurso | Tipo | SKU/Tier | Propósito |
|---------|------|----------|-----------|
| Resource Group | `azurerm_resource_group` | - | Contenedor de recursos |
| Virtual Network | `azurerm_virtual_network` | - | Red privada (10.0.0.0/16) |
| API Management | `azurerm_api_management` | Consumption ⚡ | Gateway serverless pay-per-use |
| Cosmos DB | `azurerm_cosmosdb_account` | Serverless | Base de datos NoSQL |
| Function App | `azurerm_windows_function_app` | Consumption (Y1) | Backend .NET 8.0 |
| Storage Account | `azurerm_storage_account` | Standard LRS | Para Azure Functions |
| App Insights | `azurerm_application_insights` | - | Telemetría y logs |

## 💰 Estimación de Costos

**Ambiente Dev (mensual):**
- API Management Consumption: ~$0.035 USD/10K llamadas + $0.007/GB (pay-per-use) ⚡
- Cosmos DB Serverless: ~$0.25 USD/GB + $0.28 USD/millón RUs
- Function App Consumption: Primeros 1M ejecuciones gratis
- Storage Account: ~$0.02 USD/GB
- Application Insights: Primeros 5GB gratis

**Total estimado**: ~$5-15 USD/mes (uso bajo a moderado) 💰

> 💡 **Ahorro significativo**: Consumption SKU es ~90% más barato que Developer SKU
> 💡 Solo pagas por lo que usas - ideal para labs y desarrollo

## 🔧 Comandos Útiles

### Ver Estado Actual

```powershell
# Ver recursos desplegados
terraform state list

# Ver detalles de un recurso
terraform state show azurerm_api_management.main

# Ver outputs
terraform output

# Ver output específico (sensible)
terraform output -raw cosmosdb_connection_string
```

### Actualizar Infraestructura

```powershell
# Ver cambios sin aplicar
terraform plan -var-file="dev.tfvars"

# Aplicar solo un recurso específico
terraform apply -target=azurerm_api_management.main

# Refrescar estado
terraform refresh
```

### Debugging

```powershell
# Logs detallados
$env:TF_LOG="DEBUG"
terraform apply -var-file="dev.tfvars"

# Ver el plan en JSON
terraform show -json terraform.plan | jq '.'

# Validar configuración
terraform validate
```

### Limpiar y Resetear

```powershell
# Limpiar archivos temporales
Remove-Item .terraform -Recurse -Force
Remove-Item terraform.tfstate* -Force
Remove-Item .terraform.lock.hcl -Force

# Reinicializar
terraform init
```

## 🔄 Flujos de Trabajo

### Desarrollo Local

```powershell
# 1. Hacer cambios en archivos .tf
# 2. Formatear código
terraform fmt

# 3. Validar sintaxis
terraform validate

# 4. Ver plan
.\deploy.ps1 -Environment dev -Action plan

# 5. Aplicar si está bien
.\deploy.ps1 -Environment dev -Action apply
```

### CI/CD con GitHub Actions

El workflow se ejecuta automáticamente en:
- ✅ Push a `main` → `terraform apply`
- ✅ Pull Request → `terraform plan` (comentado en PR)
- ✅ Manual trigger → `workflow_dispatch`

```bash
# Ver estado del workflow
gh run list --repo ImTronick2025/apis-labs-infra

# Ver logs
gh run view --log

# Ejecutar manualmente
gh workflow run terraform-azure.yml
```

## 🐛 Troubleshooting

### Error: "API Management name already exists"

APIM requiere nombres únicos globalmente.

**Solución**: Cambia el `prefix` en `dev.tfvars`:
```hcl
prefix = "apislabsdev2"
```

### Error: "Timeout waiting for API Management"

APIM tarda 30-45 minutos. Si Terraform hace timeout:

**Solución**: Re-ejecuta `terraform apply`, continuará desde donde quedó:
```powershell
terraform apply -var-file="dev.tfvars"
```

### Error: "insufficient permissions"

**Solución**: Verifica que el Service Principal tenga rol Contributor:
```bash
az role assignment create \
  --assignee 28abcd1c-943a-4a9c-9e17-d3828d14a1ea \
  --role Contributor \
  --scope /subscriptions/0ec51f00-9547-405f-9a39-25fb1b9f42e5
```

### Error: "Backend configuration changed"

**Solución**: Reinicializa Terraform:
```powershell
terraform init -reconfigure
```

### Error: "Error locking state"

**Solución**: Espera a que termine otra operación, o fuerza unlock:
```powershell
terraform force-unlock <LOCK_ID>
```

## 📊 Post-Deployment

### 1. Verificar Recursos en Azure Portal

```powershell
# Abrir Resource Group
az group show --name apis-labs-rg --query id -o tsv | ForEach-Object {
    Start-Process "https://portal.azure.com/#@/resource$_"
}
```

### 2. Obtener Información Importante

```powershell
# Ejecutar post-deploy para obtener todas las credenciales
.\post-deploy.ps1

# O manualmente:
terraform output apim_gateway_url
terraform output -raw cosmosdb_connection_string
terraform output function_app_name
```

### 3. Importar APIs

```powershell
# Importar todas las APIs desde GitHub
.\import-apis.ps1 -All

# O una por una
.\import-apis.ps1 -ImportPetstore
.\import-apis.ps1 -ImportOrders
```

### 4. Cargar Datos de Ejemplo

```powershell
cd ..\apis-labs-db\scripts

# Con PowerShell
$endpoint = terraform -chdir=../../apis-labs-infra output -raw cosmosdb_endpoint
$key = terraform -chdir=../../apis-labs-infra output -raw cosmosdb_primary_key
.\init-cosmosdb.ps1 -CosmosEndpoint $endpoint -CosmosKey $key

# O con Azure CLI (Bash)
./init-cosmosdb.sh
```

### 5. Desplegar Azure Functions

```powershell
cd ..\..\apis-labs-functions

# Obtener nombre de Function App
$funcName = terraform -chdir=../apis-labs-infra output -raw function_app_name

# Publicar Functions
func azure functionapp publish $funcName
```

## 🧪 Probar la Infraestructura

### Test 1: Health Check de Function

```powershell
$funcApp = terraform output -raw function_app_name
curl "https://$funcApp.azurewebsites.net/api/health"
```

### Test 2: API a través de APIM

```powershell
$apimUrl = terraform output -raw apim_gateway_url
$subKey = az apim subscription list-secrets `
    --resource-group apis-labs-rg `
    --service-name $(terraform output -raw apim_name) `
    --subscription-id master `
    --query primaryKey -o tsv

curl "$apimUrl/petstore/health" `
    -H "Ocp-Apim-Subscription-Key: $subKey"
```

### Test 3: Crear un Pet

```powershell
curl -X POST "$apimUrl/petstore/pets" `
    -H "Content-Type: application/json" `
    -H "Ocp-Apim-Subscription-Key: $subKey" `
    -d '{
        "name": "Max",
        "species": "dog",
        "breed": "Beagle",
        "age": 3,
        "weight": 12.5
    }'
```

## 📚 Documentación Adicional

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure API Management](https://docs.microsoft.com/azure/api-management/)
- [Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/)
- [Azure Functions](https://docs.microsoft.com/azure/azure-functions/)

## 🎓 Próximos Pasos

1. ✅ Infraestructura desplegada
2. ⬜ Importar APIs → `.\import-apis.ps1 -All`
3. ⬜ Cargar datos → `cd ..\apis-labs-db\scripts && .\init-cosmosdb.ps1`
4. ⬜ Desplegar Functions → `cd ..\apis-labs-functions && func azure functionapp publish <name>`
5. ⬜ Configurar policies en APIM
6. ⬜ Configurar monitoring y alerts
7. ⬜ Implementar CI/CD para Functions

---

**¿Dudas?** Revisa el archivo principal [README.md](./README.md) o los scripts individuales con comentarios detallados.
