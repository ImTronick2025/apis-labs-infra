variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "0ec51f00-9547-405f-9a39-25fb1b9f42e5"
}

variable "resource_group_name" {
  description = "Nombre del Resource Group principal"
  type        = string
  default     = "apis-labs-rg"
}

variable "location" {
  description = "Ubicación de Azure para los recursos"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "apislabs"
}

variable "apim_publisher_name" {
  description = "Nombre del publicador para API Management"
  type        = string
  default     = "APIs Labs Organization"
}

variable "apim_publisher_email" {
  description = "Email del publicador para API Management"
  type        = string
  default     = "admin@apislabs.com"
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    Environment = "Lab"
    Project     = "APIs-DevOps-Lab"
    ManagedBy   = "Terraform"
  }
}
