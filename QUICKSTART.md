# Infra Quickstart

## Deploy
```
terraform init
terraform apply -var-file="dev.tfvars" -auto-approve
```

## Publish Functions
```
$funcName = terraform output -raw function_app_name
func azure functionapp publish $funcName
```

## Import API to APIM

Push to main in apis-labs-api (deploy-apim-books.yml).

## Test
```
$funcName = terraform output -raw function_app_name
$funcRg = terraform output -raw resource_group_name
$funcKey = az functionapp keys list -g $funcRg -n $funcName --query "functionKeys.default" -o tsv
curl "https://$funcName.azurewebsites.net/api/health"
curl "https://$funcName.azurewebsites.net/api/books" -H "x-functions-key: $funcKey"
```
