# APIs Labs - Infraestructura (Terraform)

Este repositorio contiene la infraestructura como código (IaC) para el laboratorio DevOps de APIs modernas en Azure.

## 📋 Recursos Desplegados

- **Resource Group**: `apis-labs-rg` (configurable)
- **Virtual Network**: Con dos subnets (APIM y Cosmos DB)
- **Azure API Management**: SKU Developer para gestión de APIs
- **Cosmos DB**: Modo serverless para almacenamiento NoSQL
- **Azure Functions**: Function App .NET 8.0 con plan Consumption
- **Storage Account**: Para Azure Functions

## 🚀 Prerequisitos

1. Suscripción de Azure activa
2. Service Principal con permisos Contributor
3. Cuenta de GitHub
4. Terraform instalado localmente (opcional, para pruebas)

## 🔧 Configuración Inicial

### 1. Crear el Secret en GitHub

Ve a tu repositorio `apis-labs-infra` en GitHub:
1. Settings → Secrets and variables → Actions
2. Clic en "New repository secret"
3. Nombre: `AZURE_CREDENTIALS`
4. Valor:
```json
{
  "clientId": "YOUR_CLIENT_ID",
  "clientSecret": "YOUR_CLIENT_SECRET",
  "subscriptionId": "YOUR_SUBSCRIPTION_ID",
  "tenantId": "YOUR_TENANT_ID",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### 2. Personalizar Variables (Opcional)

Edita `variables.tf` para cambiar:
- `location`: Región de Azure (default: "East US")
- `prefix`: Prefijo para nombres de recursos (default: "apislabs")
- `apim_publisher_email`: Tu email para APIM

## 📦 Despliegue

### Despliegue Automático (GitHub Actions)

1. Haz push a la rama `main`:
```bash
git add .
git commit -m "Initial infrastructure setup"
git push origin main
```

2. El workflow se ejecutará automáticamente y desplegará la infraestructura
3. Revisa el progreso en la pestaña "Actions" de GitHub

### Despliegue Manual (Local)

```bash
# Inicializar Terraform
terraform init

# Ver el plan de ejecución
terraform plan

# Aplicar cambios
terraform apply

# Ver outputs
terraform output
```

Para autenticación local:
```bash
az login
az account set --subscription 0ec51f00-9547-405f-9a39-25fb1b9f42e5
```

## 📝 Importar APIs a API Management

### Opción 1: Manual (Portal Azure)

1. Ve a Azure Portal → API Management
2. APIs → Add API → OpenAPI
3. URL del OpenAPI spec:
   - Usa raw URLs de GitHub: `https://raw.githubusercontent.com/ImTronick2025/apis-labs-api/main/petstore-api.yaml`
4. Completa el formulario y crea la API

### Opción 2: Automatizada (Terraform)

Agrega al `main.tf`:

```hcl
resource "azurerm_api_management_api" "petstore" {
  name                = "petstore-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.main.name
  revision            = "1"
  display_name        = "Petstore API"
  path                = "petstore"
  protocols           = ["https"]
  
  import {
    content_format = "openapi-link"
    content_value  = "https://raw.githubusercontent.com/ImTronick2025/apis-labs-api/main/petstore-api.yaml"
  }
}
```

### Opción 3: Azure CLI

```bash
az apim api import \
  --resource-group apis-labs-rg \
  --service-name <apim-name> \
  --path petstore \
  --specification-url https://raw.githubusercontent.com/ImTronick2025/apis-labs-api/main/petstore-api.yaml \
  --specification-format OpenApiJson
```

## 🗄️ Backend Remoto (Opcional)

Para almacenar el estado de Terraform en Azure:

1. Crear recursos manualmente:
```bash
az group create --name terraform-state-rg --location eastus
az storage account create --name tfstateapislab --resource-group terraform-state-rg --location eastus --sku Standard_LRS
az storage container create --name tfstate --account-name tfstateapislab
```

2. Descomentar el bloque `backend` en `main.tf`

3. Reinicializar:
```bash
terraform init -migrate-state
```

## 📊 Outputs Importantes

Después del despliegue, obtén:

```bash
terraform output apim_gateway_url        # URL del Gateway APIM
terraform output apim_portal_url         # Portal de Desarrolladores
terraform output cosmosdb_endpoint       # Endpoint de Cosmos DB
terraform output function_app_url        # URL de la Function App
```

Para valores sensibles:
```bash
terraform output -raw cosmosdb_primary_key
terraform output -raw cosmosdb_connection_string
```

## 🔄 Workflow de Desarrollo

1. **Pull Request**: Ejecuta `terraform plan` y comenta el resultado
2. **Push a main**: Ejecuta `terraform apply` automáticamente
3. **Destruir recursos**:
```bash
terraform destroy
```

## 🐛 Troubleshooting

### Error: API Management ya existe
Los nombres de APIM deben ser únicos globalmente. Cambia el `prefix` en variables.tf

### Error: Permisos insuficientes
Verifica que el Service Principal tenga rol "Contributor" en la suscripción

### Timeout en despliegue de APIM
APIM puede tardar 30-45 minutos en desplegarse. Es normal.

## 📚 Recursos Adicionales

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure API Management Docs](https://docs.microsoft.com/azure/api-management/)
- [Cosmos DB Serverless](https://docs.microsoft.com/azure/cosmos-db/serverless)
