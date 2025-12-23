# Archivo de producción
# Usar con: terraform apply -var-file="prod.tfvars"

subscription_id      = "0ec51f00-9547-405f-9a39-25fb1b9f42e5"
resource_group_name  = "apis-labs-prod-rg"
location             = "East US"
prefix               = "apislabsprd"
apim_publisher_name  = "APIs Labs Production"
apim_publisher_email = "admin@apislabs.com"
key_vault_admin_object_id = "<object-id-admin>"
key_vault_operator_object_ids = []

tags = {
  Environment = "Production"
  Project     = "APIs-DevOps-Lab"
  ManagedBy   = "Terraform"
  Owner       = "ImTronick2025"
}
