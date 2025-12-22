# 🚨 IMPORTANTE: GitHub Actions Workflow

## ⚠️ Configuración del Workflow

El workflow de GitHub Actions está configurado para **DESPLIEGUE MANUAL** por seguridad y control de costos.

### ✅ Comportamiento Actual (SEGURO)

- ✅ **NO despliega automáticamente** cuando haces push a `main`
- ✅ Solo **valida** código en Pull Requests
- ✅ Requiere **ejecución manual** desde GitHub UI
- ✅ Soporta acciones: `plan`, `apply`, `destroy`
- ✅ Soporta ambientes: `dev`, `prod`

### ❌ NO Hará Esto (A Menos que lo Habilites)

- ❌ No desplegará automáticamente en push
- ❌ No creará recursos sin tu confirmación
- ❌ No generará costos inesperados

---

## 🔐 PASO 1: Configurar Secret AZURE_CREDENTIALS

**CRÍTICO:** Debes configurar este secret ANTES de ejecutar el workflow.

### Opción A: GitHub Web UI (Recomendado)

1. Ve a tu repositorio en GitHub
2. Navega a: **Settings** → **Secrets and variables** → **Actions**
3. Click en **"New repository secret"**
4. Name: `AZURE_CREDENTIALS`
5. Value: (pega el JSON completo)

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

6. Click **"Add secret"**

### Opción B: GitHub CLI

```powershell
# Crear archivo temporal con el secret
$secretJson = @"
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
"@

$secretJson | Out-File azure-creds.json -Encoding utf8

# Agregar secret al repositorio
gh secret set AZURE_CREDENTIALS --repo ImTronick2025/apis-labs-infra < azure-creds.json

# Limpiar archivo temporal
Remove-Item azure-creds.json

Write-Host "✅ Secret configurado correctamente!" -ForegroundColor Green
```

---

## 🚀 PASO 2: Crear y Subir Repositorio

```powershell
cd D:\CLOUDSOLUTIONS\apis-labs-workspace\apis-labs-infra

# Inicializar Git
git init
git add .
git commit -m "Initial infrastructure setup with manual deployment workflow"

# Crear repositorio en GitHub
gh repo create ImTronick2025/apis-labs-infra --public --source=. --remote=origin --description="Infrastructure as Code (Terraform) for Azure APIs Lab"

# Push
git push -u origin main
```

---

## 🎮 PASO 3: Usar el Workflow

### Opción A: Desde GitHub UI (Más Fácil)

1. Ve a: https://github.com/ImTronick2025/apis-labs-infra/actions
2. Click en **"Terraform Azure Infrastructure"**
3. Click en **"Run workflow"** (botón verde)
4. Selecciona opciones:
   - **Terraform action**: `plan` (para ver cambios) o `apply` (para desplegar)
   - **Environment**: `dev` o `prod`
5. Click **"Run workflow"**
6. Espera a que complete (verás el progreso en tiempo real)

### Opción B: Desde GitHub CLI

```bash
# Ver cambios sin desplegar (PLAN)
gh workflow run terraform-azure.yml \
  -f action=plan \
  -f environment=dev

# Desplegar infraestructura (APPLY)
gh workflow run terraform-azure.yml \
  -f action=apply \
  -f environment=dev

# Destruir recursos (DESTROY)
gh workflow run terraform-azure.yml \
  -f action=destroy \
  -f environment=dev

# Ver estado de ejecuciones
gh run list --workflow=terraform-azure.yml

# Ver logs de última ejecución
gh run view --log
```

---

## 📋 PASO 4: Flujo de Trabajo Recomendado

### Primer Despliegue

```bash
# 1. Subir código a GitHub
git push origin main

# 2. Ir a GitHub Actions UI
# https://github.com/ImTronick2025/apis-labs-infra/actions

# 3. Ejecutar workflow manualmente:
#    - Action: plan
#    - Environment: dev

# 4. Revisar el plan en los logs

# 5. Si todo está bien, ejecutar:
#    - Action: apply
#    - Environment: dev

# 6. Esperar 45-60 minutos (APIM es lento)
```

### Actualizaciones Futuras

```bash
# 1. Hacer cambios en archivos .tf
git add .
git commit -m "Update infrastructure"

# 2. Crear Pull Request
git checkout -b feature/update-infra
git push origin feature/update-infra
gh pr create

# 3. El workflow ejecutará 'plan' automáticamente en el PR
# 4. Revisar el plan en el comentario del PR
# 5. Si está bien, merge el PR
# 6. Ejecutar workflow manualmente con 'apply'
```

---

## 🔄 Validación en Pull Requests

Cuando crees un Pull Request, el workflow automáticamente:

1. ✅ Ejecuta `terraform fmt -check`
2. ✅ Ejecuta `terraform validate`
3. ✅ Ejecuta `terraform plan`
4. ✅ Comenta el resultado en el PR

**Pero NO despliega nada** - es solo validación.

---

## ⚠️ IMPORTANTE: NO Auto-Deploy

### Por Qué NO Está Habilitado Auto-Deploy

- ❌ Puede generar costos inesperados (APIM = $50/mes)
- ❌ Sin revisión manual de cambios
- ❌ Riesgo de desplegar errores
- ❌ No es buena práctica para laboratorios

### Si Quieres Habilitar Auto-Deploy (NO Recomendado)

Hay un archivo `.github/workflows/terraform-auto-deploy.yml.disabled` que puedes habilitar:

```bash
# Renombrar archivo
cd .github/workflows
mv terraform-auto-deploy.yml.disabled terraform-auto-deploy.yml

# Editar y descomentar la sección 'on: push'
# Commit y push
```

**⚠️ Solo hazlo si entiendes las consecuencias!**

---

## 📊 Monitoreo del Workflow

### Ver Ejecuciones

```bash
# Listar últimas 10 ejecuciones
gh run list --workflow=terraform-azure.yml --limit 10

# Ver detalles de ejecución específica
gh run view <run-id>

# Ver logs
gh run view <run-id> --log

# Ver logs en tiempo real
gh run watch
```

### Desde GitHub UI

https://github.com/ImTronick2025/apis-labs-infra/actions

---

## 🐛 Troubleshooting

### Error: "Secret AZURE_CREDENTIALS not found"

**Solución:** Configura el secret (ver PASO 1)

### Error: "Resource 'xxxx' already exists"

**Causa:** Recursos ya desplegados localmente con Terraform.

**Solución:** Importa el estado o usa diferente prefijo:

```bash
# Opción 1: Importar estado existente
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/apis-labs-rg

# Opción 2: Cambiar prefijo en dev.tfvars
prefix = "apislabs2"
```

### Error: "State lock"

**Causa:** Workflow ya ejecutándose.

**Solución:** Espera o cancela el workflow anterior en GitHub UI.

---

## ✅ Checklist Pre-Push

Antes de subir a GitHub, verifica:

- [ ] Secret `AZURE_CREDENTIALS` configurado (o listo para configurar)
- [ ] Service Principal tiene permisos Contributor
- [ ] Variables en `dev.tfvars` correctas
- [ ] Archivos `.gitignore` excluyen secrets
- [ ] No hay `terraform.tfstate` en el repo (está en .gitignore)
- [ ] Workflow es manual dispatch (no auto-deploy)

---

## 📚 Documentación Adicional

Ver archivo completo: `.github/workflows/README.md`

---

## 🎯 Resumen

1. ✅ **Configura secret AZURE_CREDENTIALS primero**
2. ✅ **Push código a GitHub**
3. ✅ **Ejecuta workflow manualmente desde UI**
4. ✅ **Workflow NO desplegará automáticamente**
5. ✅ **Siempre ejecuta 'plan' antes de 'apply'**

**¡Listo para subir a GitHub de forma segura! 🚀**
