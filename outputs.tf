output "resource_group_name" {
  description = "Nombre del Resource Group creado"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID de la Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "apim_name" {
  description = "Nombre del API Management"
  value       = azurerm_api_management.main.name
}

output "apim_gateway_url" {
  description = "URL del Gateway de API Management"
  value       = azurerm_api_management.main.gateway_url
}

output "apim_portal_url" {
  description = "URL del Portal de Desarrolladores de APIM"
  value       = azurerm_api_management.main.developer_portal_url
}

output "cosmosdb_endpoint" {
  description = "Endpoint de Cosmos DB"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmosdb_name" {
  description = "Nombre de la cuenta de Cosmos DB"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmosdb_primary_key" {
  description = "Primary key de Cosmos DB (sensible)"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmosdb_connection_string" {
  description = "Connection string de Cosmos DB (sensible)"
  value       = azurerm_cosmosdb_account.main.primary_sql_connection_string
  sensitive   = true
}

output "application_insights_key" {
  description = "Instrumentation Key de Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection String de Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "function_app_name" {
  description = "Nombre de la Function App"
  value       = azurerm_function_app_flex_consumption.main.name
}

output "function_app_url" {
  description = "URL base de la Function App"
  value       = "https://${azurerm_function_app_flex_consumption.main.default_hostname}"
}

output "functions_storage_account_name" {
  description = "Nombre del Storage Account de Functions"
  value       = azurerm_storage_account.functions.name
}
