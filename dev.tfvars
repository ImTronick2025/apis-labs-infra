# Archivo de desarrollo local con variables
# Renombrar a terraform.tfvars para usar

subscription_id      = "0ec51f00-9547-405f-9a39-25fb1b9f42e5"
resource_group_name  = "apis-labs-dev-rg"
location             = "East US"
prefix               = "apislabsdev"
apim_publisher_name  = "APIs Labs Dev"
apim_publisher_email = "dev@apislabs.com"
key_vault_admin_object_id = "2d243312-e8d2-4926-bdb9-c6370fdd3a2f"
key_vault_operator_object_ids = ["694abb35-aa44-4c3e-8e6e-77ac94e51fa3"]

tags = {
  Environment = "Development"
  Project     = "APIs-DevOps-Lab"
  ManagedBy   = "Terraform"
  Owner       = "ImTronick2025"
}
