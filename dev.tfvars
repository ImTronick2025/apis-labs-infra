# Archivo de desarrollo local con variables
# Renombrar a terraform.tfvars para usar

subscription_id      = "0ec51f00-9547-405f-9a39-25fb1b9f42e5"
resource_group_name  = "apis-labs-dev-rg"
location             = "East US"
prefix               = "apislabsdev"
apim_publisher_name  = "APIs Labs Dev"
apim_publisher_email = "dev@apislabs.com"

tags = {
  Environment = "Development"
  Project     = "APIs-DevOps-Lab"
  ManagedBy   = "Terraform"
  Owner       = "ImTronick2025"
}
