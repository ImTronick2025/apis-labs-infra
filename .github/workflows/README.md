# ⚙️ GitHub Actions Workflows - Guía Completa

Este directorio contiene los workflows de CI/CD para el despliegue de infraestructura.

## 📋 Workflows Disponibles

### 1. `terraform-azure.yml` ⭐ (ACTIVO - Recomendado)

**Tipo:** Manual Dispatch + PR Validation

**Características:**
- ✅ **NO despliega automáticamente** en push a main
- ✅ Solo valida en Pull Requests
- ✅ Despliegue manual desde GitHub UI
- ✅ Soporta múltiples acciones: plan, apply, destroy
- ✅ Soporta múltiples ambientes: dev, prod

**Cómo usar:**

#### Opción A: Desde GitHub UI
1. Ve a: https://github.com/ImTronick2025/apis-labs-infra/actions
2. Selecciona "Terraform Azure Infrastructure"
3. Click en "Run workflow"
4. Selecciona:
   - **Action**: `plan`, `apply`, o `destroy`
   - **Environment**: `dev` o `prod`
5. Click "Run workflow"

#### Opción B: Desde CLI
```bash
# Plan (ver cambios sin aplicar)
gh workflow run terraform-azure.yml \
  -f action=plan \
  -f environment=dev

# Apply (desplegar)
gh workflow run terraform-azure.yml \
  -f action=apply \
  -f environment=dev

# Destroy (destruir recursos)
gh workflow run terraform-azure.yml \
  -f action=destroy \
  -f environment=dev
```

#### Validación en Pull Requests
Cuando crees un PR, el workflow automáticamente:
1. Ejecuta `terraform fmt -check`
2. Ejecuta `terraform validate`
3. Ejecuta `terraform plan`
4. Comenta el resultado en el PR

---

### 2. `terraform-auto-deploy.yml.disabled` (DESHABILITADO)

**Tipo:** Auto Deploy on Push

**Estado:** ⚠️ **DESHABILITADO** por seguridad

Este workflow desplegaría automáticamente en cada push a `main`, lo cual **NO es recomendado** para laboratorios porque:
- ❌ Despliega sin confirmación manual
- ❌ Puede generar costos inesperados
- ❌ No permite revisar cambios antes de aplicar

**Para habilitarlo (NO recomendado):**
1. Renombrar archivo a `terraform-auto-deploy.yml`
2. Descomentar la sección `on: push`
3. Commit y push

---

## 🔐 Secrets Requeridos

El workflow necesita el secret `AZURE_CREDENTIALS` configurado en GitHub.

### Cómo Agregar el Secret

#### Opción A: GitHub UI
1. Ve a: https://github.com/ImTronick2025/apis-labs-infra/settings/secrets/actions
2. Click "New repository secret"
3. Name: `AZURE_CREDENTIALS`
4. Value:
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

#### Opción B: GitHub CLI
```bash
# Guardar JSON en archivo temporal
cat > azure-creds.json << 'EOF'
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
EOF

# Agregar secret
gh secret set AZURE_CREDENTIALS < azure-creds.json --repo ImTronick2025/apis-labs-infra

# Limpiar
rm azure-creds.json
```

---

## 🔄 Flujo de Trabajo Recomendado

### Para Desarrollo (Local)
```bash
# 1. Hacer cambios en archivos .tf
# 2. Validar localmente
terraform fmt
terraform validate
terraform plan -var-file="dev.tfvars"

# 3. Commit y push
git add .
git commit -m "Update infrastructure"
git push origin feature-branch

# 4. Crear Pull Request
gh pr create --title "Update infrastructure" --body "Description"
```

El workflow validará automáticamente en el PR.

### Para Despliegue (GitHub Actions)
```bash
# Opción 1: Desde CLI
gh workflow run terraform-azure.yml -f action=apply -f environment=dev

# Opción 2: Desde UI
# Ve a Actions → Run workflow → Selecciona apply + dev
```

### Para Destruir Recursos
```bash
# Desde CLI
gh workflow run terraform-azure.yml -f action=destroy -f environment=dev

# O desde UI
# Actions → Run workflow → Selecciona destroy + dev
```

---

## 📊 Monitoreo de Workflows

### Ver Estado de Workflows
```bash
# Listar últimas ejecuciones
gh run list --workflow=terraform-azure.yml --limit 5

# Ver detalles de una ejecución
gh run view <run-id>

# Ver logs
gh run view <run-id> --log

# Ver logs en tiempo real (última ejecución)
gh run watch
```

### Desde GitHub UI
https://github.com/ImTronick2025/apis-labs-infra/actions

---

## 🐛 Troubleshooting

### Error: "Resource group not found"
**Causa:** Primera ejecución, recursos no existen aún.
**Solución:** Normal, Terraform los creará.

### Error: "State lock"
**Causa:** Otra ejecución en progreso.
**Solución:** Espera a que termine o cancela el workflow anterior.

### Error: "Insufficient permissions"
**Causa:** Service Principal sin permisos.
**Solución:** 
```bash
az role assignment create \
  --assignee 28abcd1c-943a-4a9c-9e17-d3828d14a1ea \
  --role Contributor \
  --scope /subscriptions/0ec51f00-9547-405f-9a39-25fb1b9f42e5
```

### Error: "Secret AZURE_CREDENTIALS not found"
**Causa:** Secret no configurado.
**Solución:** Ver sección "Secrets Requeridos" arriba.

---

## ⚡ GitHub Environments

El workflow usa GitHub Environments para control de acceso.

### Configurar Environments (Opcional)

1. Ve a: https://github.com/ImTronick2025/apis-labs-infra/settings/environments
2. Crea environments: `dev` y `prod`
3. Para `prod`, configura:
   - ✅ Required reviewers (requiere aprobación manual)
   - ✅ Wait timer (espera X minutos antes de desplegar)
   - ✅ Deployment branches (solo main puede desplegar a prod)

---

## 📚 Recursos

- [GitHub Actions Docs](https://docs.github.com/actions)
- [Terraform with GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [Azure Login Action](https://github.com/Azure/login)
- [Setup Terraform Action](https://github.com/hashicorp/setup-terraform)

---

## ✅ Checklist Post-Setup

- [ ] Secret `AZURE_CREDENTIALS` configurado
- [ ] Service Principal con rol Contributor
- [ ] Workflow ejecutado manualmente (plan) exitosamente
- [ ] Validación en PR funciona
- [ ] Environment variables correctas (dev.tfvars, prod.tfvars)

---

## 🎯 Best Practices

1. ✅ **Siempre ejecuta `plan` antes de `apply`**
2. ✅ **Usa Pull Requests** para cambios en infraestructura
3. ✅ **Revisa el plan** antes de aprobar merge
4. ✅ **Usa environments** para proteger producción
5. ✅ **Documenta cambios** en commits y PRs
6. ❌ **NO habilites auto-deploy** sin revisión
7. ❌ **NO commitees secrets** en el código

---

**Workflow configurado y listo para usar! 🚀**
