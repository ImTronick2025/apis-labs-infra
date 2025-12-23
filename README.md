# APIs Labs - Infra (Terraform)

Terraform provisions:
- Resource Group
- VNet + subnets
- APIM (Consumption)
- Cosmos DB (serverless)
- Function App (Flex Consumption, .NET 8 isolated)
- Storage Account
- Key Vault (secrets)
- App Insights

## Quickstart (dev)
```
terraform init
terraform apply -var-file="dev.tfvars" -auto-approve
```

## Outputs

- apim_name, apim_gateway_url
- function_app_name, function_app_url
- cosmosdb_endpoint
- key_vault_name, key_vault_uri

## Key Vault access

Variables:
- key_vault_admin_object_id
- key_vault_operator_object_ids

The Function App identity gets Get permission for secrets.

## APIM Import

APIM import is handled in apis-labs-api via deploy-apim-books.yml.
