terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend remoto opcional para almacenar el estado de Terraform en Azure Storage
  # Descomenta y configura después de crear el Storage Account manualmente
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstateapislab"
  #   container_name       = "tfstate"
  #   key                  = "apis-labs.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

locals {
  functions_storage_account_name = substr(
    lower(replace("${var.prefix}func${random_string.suffix.result}", "-", "")),
    0,
    24
  )
  key_vault_name = substr(
    lower(replace("${var.prefix}kv${random_string.suffix.result}", "-", "")),
    0,
    24
  )
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network con dos subnets
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Subnet para API Management
resource "azurerm_subnet" "apim" {
  name                 = "apim-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet para Cosmos DB (private endpoint)
resource "azurerm_subnet" "cosmosdb" {
  name                 = "cosmosdb-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Azure API Management (SKU Consumption - Serverless)
resource "azurerm_api_management" "main" {
  name                = "${var.prefix}-apim"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = "Consumption_0"

  tags = var.tags
}

# Cosmos DB Account (Serverless)
resource "azurerm_cosmosdb_account" "main" {
  name                = "${var.prefix}-cosmos-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # Serverless capacity mode
  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  tags = var.tags
}

# Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "apis-labs-db"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

# Cosmos DB SQL Container
resource "azurerm_cosmosdb_sql_container" "main" {
  name                = "items"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/id"]
}

# Random suffix para nombres únicos globales
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Application Insights para monitoring (para futuro uso con Functions u otros servicios)
resource "azurerm_application_insights" "main" {
  name                = "${var.prefix}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = var.tags

  lifecycle {
    ignore_changes = [workspace_id]
  }
}

# Key Vault for secrets
resource "azurerm_key_vault" "main" {
  name                = local.key_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled  = false
  rbac_authorization_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Backup",
      "Restore",
      "Recover"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Backup",
      "Restore",
      "Recover",
      "Purge"
    ]
  }

  tags = var.tags
}

# Store secrets in Key Vault
resource "azurerm_key_vault_secret" "cosmosdb_primary_key" {
  name         = "cosmosdb-primary-key"
  value        = azurerm_cosmosdb_account.main.primary_key
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "cosmosdb_connection_string" {
  name         = "cosmosdb-connection-string"
  value        = azurerm_cosmosdb_account.main.primary_sql_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  name         = "appinsights-connection-string"
  value        = azurerm_application_insights.main.connection_string
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "functions_storage_connection_string" {
  name         = "functions-storage-connection-string"
  value        = azurerm_storage_account.functions.primary_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

# Storage Account para Azure Functions (requerido por Flex Consumption)
resource "azurerm_storage_account" "functions" {
  name                            = local.functions_storage_account_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

# Plan Flex Consumption para Azure Functions
resource "azurerm_service_plan" "functions" {
  name                = "${var.prefix}-func-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "FC1"
  tags                = var.tags
}

# Function App (Flex Consumption) para API de catalogo de libros
resource "azurerm_storage_container" "functions" {
  name                  = "functions-flex"
  storage_account_id    = azurerm_storage_account.functions.id
  container_access_type = "private"
}

resource "azurerm_function_app_flex_consumption" "main" {
  name                = "${var.prefix}-func-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.functions.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.functions.primary_blob_endpoint}${azurerm_storage_container.functions.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.functions.primary_access_key
  runtime_name                = "dotnet-isolated"
  runtime_version             = "8.0"
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.appinsights_connection_string.versionless_id})"
    CosmosDbConnectionString              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.cosmosdb_connection_string.versionless_id})"
    CosmosDbDatabaseName                  = azurerm_cosmosdb_sql_database.main.name
    CosmosDbContainerName                 = azurerm_cosmosdb_sql_container.main.name
    KeyVaultUri                           = azurerm_key_vault.main.vault_uri
  }

  site_config {}

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "functions" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app_flex_consumption.main.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}

# Importación automática de APIs desde GitHub (Opcional - descomenta para usar)
# resource "azurerm_api_management_api" "petstore" {
#   name                = "petstore-api"
#   resource_group_name = azurerm_resource_group.main.name
#   api_management_name = azurerm_api_management.main.name
#   revision            = "1"
#   display_name        = "Petstore API"
#   path                = "petstore"
#   protocols           = ["https"]
#   
#   import {
#     content_format = "openapi-link"
#     content_value  = "https://raw.githubusercontent.com/ImTronick2025/apis-labs-api/main/petstore-api.yaml"
#   }
#   
#   depends_on = [azurerm_api_management.main]
# }

# resource "azurerm_api_management_api" "orders" {
#   name                = "orders-api"
#   resource_group_name = azurerm_resource_group.main.name
#   api_management_name = azurerm_api_management.main.name
#   revision            = "1"
#   display_name        = "Orders API"
#   path                = "orders"
#   protocols           = ["https"]
#   
#   import {
#     content_format = "openapi-link"
#     content_value  = "https://raw.githubusercontent.com/ImTronick2025/apis-labs-api/main/orders-api.yaml"
#   }
#   
#   depends_on = [azurerm_api_management.main]
# }

# Backend de APIM apuntando a Azure Functions (Opcional - descomenta para usar)
# resource "azurerm_api_management_backend" "functions" {
#   name                = "petstore-backend"
#   resource_group_name = azurerm_resource_group.main.name
#   api_management_name = azurerm_api_management.main.name
#   protocol            = "http"
#   url                 = "https://${azurerm_windows_function_app.main.default_hostname}/api"
#   
#   credentials {
#     header = {
#       "x-functions-key" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.function_key.id})"
#     }
#   }
# }

# Policy para redirigir tráfico de APIM a Functions (Opcional)
# resource "azurerm_api_management_api_policy" "petstore" {
#   api_name            = azurerm_api_management_api.petstore.name
#   api_management_name = azurerm_api_management.main.name
#   resource_group_name = azurerm_resource_group.main.name
#   
#   xml_content = <<XML
# <policies>
#   <inbound>
#     <base />
#     <set-backend-service backend-id="${azurerm_api_management_backend.functions.name}" />
#     <set-header name="x-functions-key" exists-action="override">
#       <value>{{function-key}}</value>
#     </set-header>
#   </inbound>
#   <backend>
#     <base />
#   </backend>
#   <outbound>
#     <base />
#   </outbound>
#   <on-error>
#     <base />
#   </on-error>
# </policies>
# XML
# }
