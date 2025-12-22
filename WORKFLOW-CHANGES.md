# ⚠️ CAMBIO IMPORTANTE EN GITHUB ACTIONS

## 🔄 Actualización del Workflow

Se ha modificado el workflow de GitHub Actions para mayor control y seguridad.

---

## ❌ ANTES (Problemático)

```yaml
on:
  push:
    branches:
      - main  # ❌ Desplegaba automáticamente en cada push
```

**Problemas:**
- ❌ Desplegaba sin confirmación al hacer push a main
- ❌ Generaba costos inesperados ($50-60/mes)
- ❌ No permitía revisar cambios antes de aplicar
- ❌ Riesgo de desplegar errores accidentalmente

---

## ✅ AHORA (Seguro)

```yaml
on:
  pull_request:     # Solo valida en PRs
    branches:
      - main
  workflow_dispatch:  # Ejecución MANUAL
    inputs:
      action: [plan, apply, destroy]
      environment: [dev, prod]
```

**Ventajas:**
- ✅ **NO despliega automáticamente** en push
- ✅ Solo **valida** código en Pull Requests
- ✅ Requiere **ejecución manual** desde GitHub UI
- ✅ Control total sobre cuándo desplegar
- ✅ Soporta múltiples acciones y ambientes

---

## 🎮 Cómo Usar el Nuevo Workflow

### 1. Push Código a GitHub (NO DESPLIEGA)

```bash
git push origin main
```

**Resultado:** ✅ Código subido, pero NO se despliega nada.

### 2. Ejecutar Workflow Manualmente

#### Opción A: GitHub UI (Recomendado)

1. Ve a: https://github.com/ImTronick2025/apis-labs-infra/actions
2. Click en "Terraform Azure Infrastructure"
3. Click en "Run workflow" (botón verde)
4. Selecciona:
   - **Action**: `plan` o `apply`
   - **Environment**: `dev` o `prod`
5. Click "Run workflow"

#### Opción B: GitHub CLI

```bash
# Ejecutar plan (ver cambios)
gh workflow run terraform-azure.yml -f action=plan -f environment=dev

# Ejecutar apply (desplegar)
gh workflow run terraform-azure.yml -f action=apply -f environment=dev

# Ver estado
gh run list --workflow=terraform-azure.yml
```

---

## 📋 Flujo Completo

### Primera Vez

```bash
# 1. Configurar secret AZURE_CREDENTIALS en GitHub
#    Settings → Secrets → New repository secret

# 2. Push código
cd apis-labs-infra
git init
git add .
git commit -m "Initial setup"
gh repo create ImTronick2025/apis-labs-infra --public --source=.
git push -u origin main

# 3. Ir a GitHub Actions y ejecutar workflow manualmente
#    Actions → Terraform Azure Infrastructure → Run workflow
#    Seleccionar: action=apply, environment=dev

# 4. Esperar 45-60 minutos (APIM es lento)
```

### Actualizaciones Futuras

```bash
# 1. Hacer cambios
git add .
git commit -m "Update infrastructure"
git push origin main

# 2. Crear PR (opcional, para validación)
git checkout -b feature/update
git push origin feature/update
gh pr create

# 3. El workflow valida en el PR (automático)
# 4. Merge el PR
# 5. Ejecutar workflow manualmente con 'apply'
```

---

## 🔐 Secret Requerido

Antes de ejecutar el workflow, configura:

**Secret Name:** `AZURE_CREDENTIALS`

**Value:**
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

**Dónde configurarlo:**
https://github.com/ImTronick2025/apis-labs-infra/settings/secrets/actions

---

## 📊 Qué Hace Cada Acción

| Action | Qué Hace | Cuándo Usar |
|--------|----------|-------------|
| **plan** | Muestra qué cambios se harán (sin aplicar) | Antes de desplegar |
| **apply** | Despliega la infraestructura | Después de revisar plan |
| **destroy** | Elimina todos los recursos | Para limpiar lab |

---

## ✅ Validación en Pull Requests

Cuando creas un PR, el workflow automáticamente:

1. ✅ Ejecuta `terraform fmt -check`
2. ✅ Ejecuta `terraform validate`
3. ✅ Ejecuta `terraform plan`
4. ✅ Comenta el resultado en el PR

**Pero NO despliega nada** - solo valida.

---

## 🎯 Resumen de Cambios

### Archivo: `.github/workflows/terraform-azure.yml`

**Cambios principales:**

1. ❌ **Removido:** `on: push` (auto-deploy)
2. ✅ **Agregado:** `workflow_dispatch` con inputs
3. ✅ **Agregado:** Soporte para `dev.tfvars` y `prod.tfvars`
4. ✅ **Agregado:** Acción `destroy` para limpiar recursos
5. ✅ **Mejorado:** Plan se ejecuta en PRs automáticamente

### Nuevos Archivos:

1. **`.github/workflows/terraform-auto-deploy.yml.disabled`**
   - Workflow de auto-deploy (DESHABILITADO)
   - Para habilitarlo: renombrar a `.yml`
   - NO RECOMENDADO para laboratorios

2. **`.github/workflows/README.md`**
   - Documentación completa del workflow
   - Guías de uso y troubleshooting

3. **`WORKFLOW-GUIDE.md`** (este archivo)
   - Resumen de cambios
   - Guía rápida de uso

---

## 📚 Documentación Completa

Ver archivos:
- `.github/workflows/README.md` - Documentación técnica completa
- `WORKFLOW-GUIDE.md` - Este resumen
- `QUICKSTART.md` - Guía general de inicio rápido

---

## 🚀 Siguiente Paso

1. **Configura el secret AZURE_CREDENTIALS** (crítico)
2. **Push tu código a GitHub**
3. **Ejecuta el workflow manualmente** desde GitHub Actions UI

**¡Listo para usar de forma segura! ✅**

---

## ❓ FAQ

**P: ¿Se desplegará automáticamente al hacer push?**
R: ❌ NO. Requiere ejecución manual.

**P: ¿Cómo despliego la infraestructura?**
R: Ejecuta el workflow manualmente desde GitHub Actions UI.

**P: ¿Qué pasa si creo un Pull Request?**
R: El workflow validará el código automáticamente (fmt, validate, plan) pero NO desplegará.

**P: ¿Puedo habilitar auto-deploy?**
R: Sí, pero NO recomendado. Ver archivo `terraform-auto-deploy.yml.disabled`.

**P: ¿Cómo veo los logs del workflow?**
R: GitHub Actions → Click en la ejecución → View logs

**P: ¿Cuánto tarda el despliegue?**
R: 45-60 minutos (API Management es lento).

---

**Actualizado:** 22 de diciembre de 2024
**Versión:** 2.0 (Manual Dispatch)
