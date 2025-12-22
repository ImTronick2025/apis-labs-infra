# 🔧 Configuración del Backend Remoto para Terraform

## ¿Por qué necesitamos un backend remoto?

Terraform guarda el estado de la infraestructura en un archivo `terraform.tfstate`. Para que los despliegues sean **idempotentes** (ejecutar varias veces sin cambios innecesarios) y funcionen en CI/CD, necesitamos:

1. **Persistir el estado** entre ejecuciones del workflow
2. **Compartir el estado** con el equipo
3. **Bloquear el estado** para evitar conflictos

## 📦 Paso 1: Crear el Storage Account en Azure

Ejecuta este script **UNA SOLA VEZ** antes del primer despliegue:

```powershell
# Opción A: Usando PowerShell
cd apis-labs-infra
.\setup-backend.ps1

# Opción B: Usando Azure CLI directamente
az group create --name terraform-state-rg --location eastus

az storage account create \
    --name tfstateapislabs \
    --resource-group terraform-state-rg \
    --location eastus \
    --sku Standard_LRS \
    --encryption-services blob

az storage container create \
    --name tfstate \
    --account-name tfstateapislabs \
    --auth-mode login
```

## 🚀 Paso 2: Inicializar Terraform con el Backend

```bash
cd apis-labs-infra
terraform init
```

Terraform migrará el estado local al backend remoto automáticamente.

## ✅ Verificación

Después de configurar el backend:

1. El archivo `terraform.tfstate` local será reemplazado por `terraform.tfstate.backup`
2. El estado se almacenará en Azure Storage: `tfstateapislabs/tfstate/dev.terraform.tfstate`
3. Los workflows de GitHub Actions usarán automáticamente este backend

## 🔄 Flujo Idempotente

Ahora puedes ejecutar el workflow múltiples veces:

```bash
git add .
git commit -m "Configure remote backend"
git push origin main
```

- **Primera ejecución**: Crea todos los recursos
- **Siguientes ejecuciones**: Solo actualiza lo que cambió (idempotente ✅)

## 🔐 Seguridad

El estado contiene información sensible (claves, connection strings). Azure Storage:
- ✅ Cifrado en reposo
- ✅ Acceso mediante Azure AD
- ✅ Control de acceso (RBAC)
- ✅ Versionado habilitado

## 📝 Configuración del Backend

El archivo `backend.tf` contiene:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateapislabs"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

Para **producción**, duplica este archivo con `key = "prod.terraform.tfstate"`.
